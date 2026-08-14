//
//  TimelinePostsOO.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 1/24/21.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage 
import FirebaseFirestore
import FirebaseFunctions
import Combine
import SDWebImageSwiftUI

final class TimelinePostsOO: ObservableObject { // uses friend dictionary
//    }
  
    func newCommentLikeVM(post : PostModel) -> CommentLikeVM{
        CommentLikeVM(post: post,friendsDictionary: friendsDictionary)
    }
     private var postInfo = [String: CommentLikeVM]() {
        didSet{
//            withAnimation {
                self.postInfoValues = self.postInfo.values.sorted(by: {$0.post.updatedAt > $1.post.updatedAt}) 
//            }
        }
    }
    @Published var myTagIDs = [String]()
    @Published var friendsDictionary = FriendsDictionary(addFriendsListener: false)
    @Published var postInfoValues  =  [CommentLikeVM]()
    @Published private(set) var canScrollToNextPage = true
    @Published var readPosts = [String]()
    @Published var didFetchAllAvailabelPosts = false
    private var pageFlagPost : PostModel!
    private var postListeners : [String:ListenerRegistration] = [:]
    private var isFirstPage = true
    private var previousPostCount = 0
    private var lastFetchedPostId : String = ""
    private var postFetchFailUserIds : Set<String> = []
    private var startWeekDate :  Timestamp?
    private var timer : Timer!
    private var tagsListener : ListenerRegistration?
    private var isTimerSet = false
    private var gotErrorAt : Date!
    var subscriptions = Set<AnyCancellable>()
    //replace this with a model func
    private var loadingPagePosts : [PostModel] = [ ]
    private var endWeekDate : Timestamp = {
        Timestamp(date: Date() - TimelinePostsOO.pageInterval)
    }()
    var showProgress : Bool{
        !(canScrollToNextPage || didFetchAllAvailabelPosts)
    }
    var tutorialNumberSub : AnyCancellable?
    var isPrelaodedPostAdded : Bool = false

    var allTimeLinePosts  : [CommentLikeVM] {
        return  postInfoValues
    }
    
    @Published var preloadedCommentLikeVM : [CommentLikeVM] = []
    var didAddPreloadedData = false
    func checkForNewUser() {
            tutorialNumberSub = UserDefaults.standard.publisher(for: \.tutorialNumber, options: [.initial, .new]).sink { [weak self] tutorialNumber in
                ///think of a better logic if possible
                ///
                guard let _ = Auth.auth().currentUser?.uid else{ return }
                
                if TutorialManager.shared.isOngoing, self?.didAddPreloadedData == false{
                    self?.addPreloadedPostInPostInfo()
                    self?.friendsDictionary.addPreloadedTristan()
                    self?.tutorialNumberSub?.cancel()
                    self?.objectWillChange.send()
                    self?.didAddPreloadedData = true
                }
            }
    }
    
    init() {
        preloadedCommentLikeVM = PostModel.Preloaded.allPosts.map{newCommentLikeVM(post: $0)}
        checkForNewUser()
        DispatchQueue.main.async {
            self.getMyTagsAccessIDs()
        }
     
  ///now the issue is that they fetched post from server does not remove these dummy ones
        let allFailedPosts = RealmPost.getAllPosts()
          if allFailedPosts.isNotEmpty{
               postInfo = allFailedPosts.reduce(into: [String : CommentLikeVM]()) {  $0[$1.postID] = newCommentLikeVM(post:  $1) }
          }
        getPostsOfAllFriends()
        DispatchQueue.global(qos: .background).async  {
            ReadPostSyncManager.syncReadPost()
        }

    }
    
   
     
    func getPost(_ postID : String) -> PostModel?{
        postInfo[postID]?.post
    }
     
    private func getPostsOfAllFriends() {
        friendsDictionary.getFriendsDictionary(source: .cache) {[weak self] (friendsDictionary, error) in
            
            if let errorCode = (error as NSError?)?.code,
               //will get unavailable error, if we did not find anything in the cache
               FirestoreErrorCode.unavailable.rawValue != errorCode {
                print(error?.localizedDescription ?? "")
                self?.startPageListenersForNewFriends(isFirstPageFetch : true)
            }else{
                
                if !friendsDictionary.isEmpty  {
                    self?.updateOldestPostTime(friendIds: friendsDictionary.map({$0.key}))
                    self?.getPostFromCacheThenNetwork()
                }
                self?.startPageListenersForNewFriends(isFirstPageFetch : friendsDictionary.isEmpty )
            }
        }
    }
    
    func getPostFromCacheThenNetwork(friendsIds : [String] = [] ) {
        guard self.canScrollToNextPage else {
            return
        }
        self.canScrollToNextPage = false
        getPostFromCacheThenNetworkTest(friendsIds : friendsIds)
    }
    
    //MARK:- getPostFromCacheThenNetwork
    func getPostFromCacheThenNetworkTest(friendsIds : [String] = [] ) {
            
            DispatchQueue.global(qos: .background).async  {[weak self ] in
                var existingFriendsIds : [String] = []
                if friendsIds.isEmpty {
                    existingFriendsIds = self?.friendsDictionary.allFriendIds ?? []
                }else{
                    existingFriendsIds = self?.friendsDictionary.allFriendIds.getSet().intersection(friendsIds).getArray() ?? []
                }
                
                guard let strongSelf = self else {
                    return
                }
                
                var friendsPostFetchedRequests = existingFriendsIds.count
                let fetchingPageSource : FirestoreSource =  strongSelf.canFetchPageFromCache() ? .cache : .server
                var serverError : Error?
                for friendId in existingFriendsIds  {
                    self?.getPostPage(friendId: friendId, isFirstPage: strongSelf.isFirstPage ) { [weak self] source, error in
                        /* this code is not in use but we might need to use this in future*/
                        if source == .server {
                            //so we only need to update postFetchFailUserIds for server fetched posts
                            if let error = error {
                                //                     self?.postFetchFailUserIds.insert(friendId)
//                                print("postFetchFailUserIds =" ,error)
                                serverError = error
                            }
//                            else if self?.postFetchFailUserIds.isEmpty == false{
//                                //                     self?.postFetchFailUserIds.remove(friendId)
//                            }
                            // we will need another counter to count server response and after last reponse to check do we get error and make decisions /. but for now just assume that there will be no error while fetching from server
                        }
                        
                        
                        if fetchingPageSource == source {
                            friendsPostFetchedRequests -= 1
                            if friendsPostFetchedRequests == 0 {
                            
                                    if serverError == nil {
                                        self?.allPageFetchingRequestCompleted(source: source)
                                       
                                    }else{
                                        self?.gotErrorWhileFetchingPage()
                                    }
                                
                            }
                        }
                    }
                    
                }
 
        }
    }
    
    
    @discardableResult
    func buildPostTimeline(document: QueryDocumentSnapshot, isNew : Bool = false, isUpdated : Bool = false) -> PostModel?  {
         
       if let existingPost = self.postInfo[document.documentID]?.post,
          existingPost.status == .successfull,
          isUpdated == false {
           guard let updatedAt = document.get(PostModel.Constant.updatedAt()) as? Timestamp,
                 existingPost.updatedAt < updatedAt else{
               return nil
           }
       }
        
        let tags = document.get("tags") as? [String]
        guard let postTags = getAllowedPost(tags: tags) else {
            return nil
        }
        
        let postModel = PostModel(postDoc: document, tags: postTags)
        if isNew || isUpdated{
            return postModel
        }else{
            self.loadingPagePosts.append(postModel)
        }
        return nil
    }
    
    ///in case of nill it means post is locked
    func getAllowedPost(tags : [String]?) -> [String]? {
        guard let tags = tags else{  return []  }
        let postTags =  self.myTagIDs.getSet().intersection(tags)
        return postTags.isEmpty ? nil : postTags.getArray()
    }
    
    @discardableResult
    func buildPostTimeline123(document: QueryDocumentSnapshot, isNew : Bool = false, isUpdated : Bool = false) -> PostModel?  {
        
        let existingPost = self.postInfo[document.documentID]?.post
        guard existingPost == nil || existingPost?.status == .sending || isUpdated else{
            return nil
        }
        
        let myTagsIds =  self.myTagIDs
   
            var doesPostHaveATag = false
            var doesCurrentUserHaveAccess = false
            var postTags = [String]()
            
            if let tags = document.data()["tags"] as? [String] {
                doesPostHaveATag = true
                for item in tags {
                    if myTagsIds.contains(item)  {
                        doesCurrentUserHaveAccess = true
                        postTags.append(item)
                    }
                }
            }

            if doesPostHaveATag == false || doesPostHaveATag == true && doesCurrentUserHaveAccess == true {
                let postModel = PostModel(postDoc: document, tags: postTags)
                if isNew || isUpdated{
                    return postModel
                }else{
                    self.loadingPagePosts.append(postModel)
                }
            }
        return nil
    }
   
    func canFetchPageFromCache(endWeekDate : Date? = nil) -> Bool{
        let endWeekDate = endWeekDate == nil ? self.endWeekDate.dateValue() : endWeekDate!
        if let savedLastCachedPostDate = Self.savedLastCachedPostDate,
           savedLastCachedPostDate < endWeekDate {
            return true
        }
        return false
    }
     
    ///this will be called when we get response from all posts fetch request. so it does not matter request was succefful or faild
     func gotErrorWhileFetchingPage(){
        gotErrorAt = Date()
        pageFlagPost = postInfoValues.last?.post
        DispatchQueue.main.async {
            self.canScrollToNextPage = true
        }
    }
    
    //MARK:-  page Complete fetch func
     //need to make sure that we do not keep updated the lastfetch post date and such
    ///this func is callled when posts page have been successfulll fetched
    func updatePageFlagPost(){
        pageFlagPost = postInfoValues.last?.post
        if postInfoValues.count > 7 {
            pageFlagPost = postInfoValues[postInfoValues.count - 7].post
        }
    }
    func allAvailabelPostFetched(){
        didFetchAllAvailabelPosts = true
        loadingPagePosts.removeAll()
        DispatchQueue.main.async {
            self.addPreloadedPostIfRequired()
            self.canScrollToNextPage = false
        }
        
    }
    
    func allPageFetchingRequestCompleted(source : FirestoreSource) {
        let fetchPostCount = loadingPagePosts.count
        addPostsInPostInfo(loadingPagePosts){  [weak self] in
            self?.allPageFetchingRequest(source: source,fetchPostCount: fetchPostCount)
        }
    }
    
    private func allPageFetchingRequest(source : FirestoreSource,fetchPostCount: Int) {
        
       gotErrorAt = nil
       updatePageFlagPost()
//       let newEndWeekDate = Timestamp(date: endWeekDate.dateValue() - Self.pageInterval)
    
    let savedOldestPostTime = Self.savedOldestPostTime
    
//    let thisPageWasFetchedFromSource : FirestoreSource = canFetchPageFromCache() ? .cache : .server
//    let canFetchNextPageFromCache = canFetchPageFromCache(endWeekDate: newEndWeekDate.dateValue())
   

    if Self.savedLastCachedPostDate == nil || Self.savedLastCachedPostDate! > endWeekDate.dateValue() {
        Self.savedLastCachedPostDate = endWeekDate.dateValue()
    }
    if let savedOldestPostTime = savedOldestPostTime,
       let startWeekDate = startWeekDate,
       savedOldestPostTime > startWeekDate {
        allAvailabelPostFetched()
        return
    }
    startWeekDate = endWeekDate
    endWeekDate = Timestamp(date: endWeekDate.dateValue() - Self.pageInterval)
   
    
       let lastTime = postInfoValues.last?.post.time
     
//    var canFetchNextPage = thisPageWasFetchedFromSource == source
//    if thisPageWasFetchedFromSource == .cache,
//       !canFetchNextPageFromCache {
//        canFetchNextPage = (source == .server)
//    }
//
    if let lastTime = lastTime ,
        let savedOldestPostTime = savedOldestPostTime,
        lastTime <= savedOldestPostTime ,
        source == .server {
        self.allAvailabelPostFetched()
    } else {
        DispatchQueue.main.async {
            if self.isFirstPage {
                self.isFirstPage = false
                if self.postInfoValues.count < 5 {
                    self.getPostFromCacheThenNetworkTest()
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {  [weak self] in
                        self?.loadingPagePosts.removeAll()
                        self?.canScrollToNextPage = true
                    }
                }
            }else{
                //                if self.postInfoValues.count < 4 {
                if fetchPostCount < 4 {
                    self.getPostFromCacheThenNetworkTest()
                }else{
                    self.loadingPagePosts.removeAll()
                    self.canScrollToNextPage = true
                }
                
            }
            
        }
    }
        
   }
  
     deinit {
         postListeners.forEach({$0.value.remove()})
     }
     
}






 
 // MARK: -  updating postInfo -
extension TimelinePostsOO {
    
    private func removeDeleted(postIds :  Set<String>?) {
        postIds?.forEach({removeDeleted(postId: $0)})
    }
    
    func removeDeleted(postId :  String , animate : Bool = false) {
        DispatchQueue.main.async {
            withAnimation(animate ? .default : .none) {
     let _ = self.postInfo.removeValue(forKey: postId)
            }
        }
    }
    
    func updatePost(updatedPost: PostModel) {
        DispatchQueue.main.async {
            print("updatedPost ")
            self.postInfo[updatedPost.postID]?.set(updatedPost: updatedPost)
            if let commentLikeVM = self.postInfo[updatedPost.postID]{
                withAnimation {
                    self.postInfo[updatedPost.postID] = commentLikeVM
                }
            } 
        }
    }
    
    func delete(post : PostModel ) {
        DeletePostFunctions.deletePost(post: post)
        removeDeleted(postId : post.postID )
    }
    
    func removeDeletedPosts(cachePostPageIds :  Set<String>?,serverPostPageIds :  Set<String>?){
        if  let cachePagePostIds = cachePostPageIds,
            !cachePagePostIds.isEmpty,
            let pagePostIds = serverPostPageIds,
            cachePagePostIds.count > pagePostIds.count{
            let deletedPostsIds = cachePagePostIds.subtracting(pagePostIds)
            //for testing we will just remove some of the posts
            DispatchQueue.main.async {
                self.removeDeleted(postIds: deletedPostsIds)
            }
        }
    }
    
    func addPreloadedPostIfRequired() {
        //        return
        guard let userId = Auth.auth().currentUser?.uid else{
            return
        }
        
        if let currentUser = friendsDictionary.friendsDictionary[userId],
           currentUser.accountCreationDate > Person.defaultAccountCreationDate{
            //will only add Preload ed post for user that was created after defaultAccountCreationDate
            addPreloadedPostInPostInfo()
        }
    }
    
    func addPreloadedPostInPostInfo(){
        self.isPrelaodedPostAdded = true
    }
    
    func addPostsInPostInfo(_ newPosts : [PostModel], animate : Bool = false,callback : @escaping () -> Void = {}){
        let newPostsDict: [String : CommentLikeVM] = newPosts.reduce(into: [String : CommentLikeVM]()) {  $0[$1.postID] = newCommentLikeVM(post:  $1) }
        
        DispatchQueue.main.async {[self] in
            let dict = newPostsDict.merging(postInfo)  { (current, _) in current }
            withAnimation(animate ? .default : .none) {
                postInfo = dict
                callback()
            }
        }
    }
    
    
    func setPostInfo(newPost: PostModel) {
        DispatchQueue.main.async {
            let oldPost = self.postInfo[newPost.postID]?.post
            if  oldPost == nil || oldPost?.status == .sending {
                self.postInfo[newPost.postID] = self.newCommentLikeVM(post: newPost)
            }
        }
    }
      
}






// MARK: -   post Page related funcs  -
extension TimelinePostsOO {
    
    
   func getPostPage(friendId : String,
                    isFirstPage : Bool,
                    callback: @escaping (_ source : FirestoreSource,_ error : Error?) -> Void) {
       
       
       fetchPostPage(source: .cache, friendId: friendId) { [weak self] cachePagePostIds , error in
           
           let sendServerCallback : ((Set<String>?, Error?) -> Void) = { [weak self]  pagePostIds , error in
               
               self?.removeDeletedPosts(cachePostPageIds: cachePagePostIds, serverPostPageIds: pagePostIds)
               callback(.server, error)
           }
           
           if isFirstPage {
               self?.addListenerToPagePosts(friendId : friendId){sendServerCallback($0,$1) }
           }else{
               //for now this will always be called to fetch second page and soo on
               self?.fetchPostPage(source: .server,friendId: friendId ) {sendServerCallback($0,$1) }
           }
           callback(.cache,error)
       }
   }
    
     func getNextPageIfNeeded(post : PostModel) {
        if  canScrollToNextPage,
            (pageFlagPost == nil) || (post.updatedAt <= pageFlagPost.updatedAt),
            !didFetchAllAvailabelPosts{
//            ,!isTimerSet{
//             if let gotErrorAt = gotErrorAt{
//                let diff = Date().timeIntervalSince1970 - gotErrorAt.timeIntervalSince1970
//                if diff >= 30{
//                    getPostFromCacheThenNetwork()
//                }else {
//                    isTimerSet = true
//                    print("isTimerSet true")
//                   Timer.scheduledTimer(withTimeInterval: 30 - diff, repeats: false) {[weak self] (_) in
//                    print("isTimerSet false")
//                    self?.getPostFromCacheThenNetwork()
//                    self?.isTimerSet = false
//                    }
//                }
//            }else{
                self.isTimerSet = true
                 self.getPostFromCacheThenNetwork()
                 self.isTimerSet = false
//            }
        }
    }
    
    func getPostsQueryFor(friendId : String) -> Query {
        let collectionRef = PostModel.getPostCollectionReference(friendId: friendId)
        var postQuery = collectionRef
            .order(by: PostModel.Constant.updatedAt(), descending: true)
//            .order(by: "time", descending: true)
        
        if friendId == TristanUserID {
            let newTimeStamp = self.friendsDictionary.currentAccountCreationDate
            postQuery = collectionRef
//                .whereField("time", isGreaterThan: newTimeStamp)
//                .order(by: "time", descending: true)
                .whereField(PostModel.Constant.updatedAt(), isGreaterThan: newTimeStamp)
                .order(by: PostModel.Constant.updatedAt(), descending: true)
        }
        postQuery = postQuery
            .end(at: [endWeekDate])
//            .end(
        return postQuery
    }
    
    func fetchPostPage(source: FirestoreSource ,
                       friendId : String ,
                       callback : (@escaping (_ pagePostIds : Set<String>? , _  error : Error?) -> Void) ) {
 
        var query = getPostsQueryFor(friendId: friendId)
        if let startWeekDate = startWeekDate {
            query = query.start(at: [startWeekDate])
        }
        query.getDocuments(source: source) { [weak self] (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents, error == nil else {
                let error : Error = error ?? NSError.getWith(description: "post querySnapshot was nil")
                callback(nil , error)
                return
            }
             
                documents.forEach { document in
                    self?.buildPostTimeline(document: document)
                }
            
            let pagePostIds = Set(documents.map { $0.documentID })
            callback(pagePostIds,  nil)
        }
    }
}







//MARK: -  Listeners -
extension TimelinePostsOO {
    
    //we need to call complete page fetch func. so we can update class var, and can fetch the next pages
    //will only be called on every app startup.
    ///but if we have none use that we will this as fetching friends for the first time, and fetching posts from the server as well using listener
    func startPageListenersForNewFriends(isFirstPageFetch : Bool = false) {
        if isFirstPageFetch  {
            guard canScrollToNextPage else { return }
            self.canScrollToNextPage = false
        }
        
        func removePostOfDeletedUser(IDs : [String]) {
            var allPostIds =  [String]()
            for deletedUserId in IDs{
                let postIds = postInfo.compactMap {   $0.value.post.id == deletedUserId ? $0.value.post.postID : nil }
                allPostIds.append(contentsOf: postIds)
                postListeners[deletedUserId]?.remove()
                postListeners[deletedUserId] = nil
            }
            updateOldestPostTime(friendIds: IDs)
            allPostIds.forEach {  postInfo.removeValue(forKey: $0)  }
            objectWillChange.send()
        }
        
        self.friendsDictionary.startListeningToNewFriends {[weak self] (friends, error) in
            guard friends.isNew else {
                removePostOfDeletedUser(IDs: friends.ids)
                 return
            }
            
            let friendsIds = friends.ids
            if friendsIds.isNotEmpty {
                var friendsPostFetchedRequests: Int = friendsIds.count
                 
                self?.updateOldestPostTime(friendIds: friendsIds, areFriendsNew: true)
                
                for friendId in friendsIds  {
                    if let _ = self?.friendsDictionary.friendsDictionary[friendId] {
                        self?.addListenerToPagePosts(friendId : friendId ){ allPostIds,error in
                            friendsPostFetchedRequests -= 1
                            if friendsPostFetchedRequests == 0 {
                                //only for fist page
                                if isFirstPageFetch {
                                    self?.allPageFetchingRequestCompleted(source: .server)
                                }else{
                                    self?.addPostsInPostInfo(self?.loadingPagePosts ?? [])
                                }
                            }
                        }
                    }
                }
            }else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK:- addListenerToPagePosts
    
    ///this listener will start listening to a single users posts. for the first response that we use as simple fetch we will only return callback for the first response. for the second and  response we will not return call back. we can also just fetch posts and use most latest post date and add listener for that user posts.
    func addListenerToPagePosts(friendId : String
                                , callback: @escaping (_ allPostIds : Set<String>?, _  error : Error?) -> Void = { _ , _ in}) {
        
        var isFirstResponse = true
        
        let postQuery = getPostsQueryFor(friendId: friendId)
        let postListener = postQuery
            .addSnapshotListener{ [weak self] (querySnapshot, error) in
                
                guard let documentChanges = querySnapshot?.documentChanges, error == nil else {
                    let error : Error = error ?? NSError.getWith(description: "documentChanges were nil while fetching posts from listener")
                    if isFirstResponse {
                        callback(nil,error)
                    }
                    return
                }
                
                var allPostIds : Set<String>?
                var allPosts : [PostModel?] = []
                documentChanges.forEach { docChange in
                    let doc = docChange.document
                    if docChange.type == .added {
                        if isFirstResponse {
                            self?.buildPostTimeline(document: doc)
                        }else{
                            /*
                             so we have two pages each have 10 posts.
                             now 2nd page post get updated. so now first page listener will mark it as new added. but  when it will try to add it in the dict as one already exist it will return nil.
                             so now what we need to do is if we get and nil then we need to check does the updatedAt of new one is the same as the old one if yes we will replace them. if not then we will ignore it.
                             
                             */
                            let post = self?.buildPostTimeline(document: doc, isNew : true)
                            allPosts.append(post)
                        }
                        
                    }else if docChange.type == .removed {
                            self?.removeDeleted(postId: doc.documentID,animate: true)
                    }else if docChange.type == .modified{
                        if (docChange.document.get("isDeleted") as? Bool) == true{
                            self?.removeDeleted(postId: doc.documentID,animate: true)
                        }else if let updatedPost = self?.buildPostTimeline(document: doc,isUpdated: true) {
                            self?.updatePost(updatedPost: updatedPost) 
                        }
                    }
                }
                 
                
                if isFirstResponse {
                    isFirstResponse = false
                    callback(allPostIds,nil)
                    allPostIds = nil
                }else {
                    let allPosts = allPosts.compactMap({$0})
                    if allPosts.isNotEmpty{
                        self?.addPostsInPostInfo(allPosts, animate: true)

                    }
                }
            }
        
        postListeners[friendId]?.remove()
        postListeners[friendId] = postListener
    }
}







// MARK: - MyTagsAccessIDs related -
extension TimelinePostsOO : MyTagsAccessNotifierAccessAble{
    
    struct AccessTag : Hashable {
        var id : String
        var creatorID : String
    }
    /*
     so for now we will test this publisher for the openedPost which are open from mainView timeline
     
     */
    typealias AccessTagPublisher = Publishers.Map<Published<[String]>.Publisher, Bool>
    //return bool haveLostAcessed
    func getAccessTagPublisher(postTags : [String]) -> MyTagsAccessNotifier.PostsAccessTagPublisher {
      myTagsAccessNotifier.getPostsAccessTagPublisher(postTags: postTags)
//        return $myTagIDs.map {
//            (postTags.isNotEmpty && $0.getSet().intersection(postTags).isEmpty)
//        }
    }
    

    
    func getMyTagsAccessIDs() {
        
        self.myTagIDs = myTagsAccessNotifier.myTagIDs
        var isFirstResponse = true
        myTagsAccessNotifier.myTagsAccessPublisher.sink { tagAccessInfo in
            let allTagIds  = tagAccessInfo.allTags.ids
            //            let deletedTagIds  = tagAccessInfo.deletedTags.ids
            let deletedPostIDs = tagAccessInfo.getDeletedPostsIds(currentPosts: self.postInfo.map({$0.value.post}))
            if deletedPostIDs.isNotEmpty {
                self.removeDeleted(postIds: deletedPostIDs.getSet())
            }
            
            if !isFirstResponse {
                tagAccessInfo.addedTags.forEach{ tag in
                    self.addPostsWihtTag(friendId: tag.creatorID, tag: tag.id)
                }
            }else{
                isFirstResponse = false
            }
            self.myTagIDs = allTagIds
        }.store(in: &subscriptions)
    }
    
     /// this func is called when the current user is added into a tag by a friend. so timeline will then fetch all previous lock posts.
    func addPostsWihtTag( friendId : String,
                              tag : String) {
        let ref = PostModel.getPostCollectionReference(friendId: friendId)
        let query =  ref
            .whereField("tags", arrayContains: tag)
            .order(by: PostModel.Constant.updatedAt(), descending: true)
            .end(at: [endWeekDate])
        query.getDocuments(source: .cache) { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                return
            }
            guard let self = self else { return  }
              let posts =   documents.compactMap { self.buildPostTimeline(document: $0,isNew : true)  }
            self.addPostsInPostInfo(posts)
        }
    }
}







// MARK: - cloud func calling -
extension TimelinePostsOO {
     
    //MARK:- sendNewPost
    func sendNewPost(content: String, selectedMedia: SelectedMedia?, mentionedIDs: [String], tags: [String]) {
        var friendDict : [String : Person] {
            friendsDictionary.friendsDictionary
        }
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
//        
        var nameOfCurrentUser = ""
        nameOfCurrentUser = friendDict[Auth.auth().currentUser!.uid]?.name ?? ""
        //the post model will have the firebase url and the thumbnail image as well.
        let newPost = PostModel(sentBy: userId, content: content.trimWhitespacesAndNewlines(), tags: tags,  newMedia: selectedMedia?.newMedia, nameOfCurrentUser: nameOfCurrentUser)
        setPostInfo(newPost: newPost)
        
        let realmPostMentions = mentionedIDs.map { RealmPostMention(id: UUID().uuidString,
                                                                    token: friendDict[$0]?.token ?? "",
                                                                    sentTo: $0,
                                                                    nameOfSendingUser: friendDict[userId]?.name ?? "")}
        
        DispatchQueue.global(qos: .userInitiated).async  {
            let rawPostModel = PostModel.Raw(post: newPost,
                                             newMedia: selectedMedia?.newMedia,
                                             audioDirURL: selectedMedia?.audioUrl,
                                             realmPostMentions: realmPostMentions)
            rawPostModel.saveInCache()
//            return
            NewPostFunctions.sendPost(rawPostModel: rawPostModel) { error in
                rawPostModel.updateCacheCopy(isSentSuccessfully: error == nil)
            }
        }
    }
    /*
     timelinePosts.modifyMoment(content: content,
                                postID: postData.postID,
                                time: postData.time,
                                newMedia: newMedia,
                                mentionedIDs: mentionCount,
                                tags: tagIDs,
                                photoLink: postData.photoLink,
                                thumbnailUrl: postData.thumbnailUrl,
                                videoUrl: postData.thumbnailUrl)
     */
    func modifyMoment(oldPost: PostModel, content: String,oldPostMedia: OldPostMedia, mentionedIDs: [String], tags: [String],selectedMedia: SelectedMedia?) {
        var friendDict : [String : Person] {
            friendsDictionary.friendsDictionary
        }
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        let newMedia =  selectedMedia?.newMedia
        let newPost = PostModel(sentBy: userId,
                                postID: oldPost.postID,
                                content: content.trimWhitespacesAndNewlines(),
                                tags: tags,
                                newMedia: newMedia,
                                audioUrl: selectedMedia?.audioUrl,
                                timestamp: oldPost.time)
        let rawPostModel = PostModel.Raw(post: newPost, newMedia: newMedia, audioDirURL: selectedMedia?.audioUrl, realmPostMentions: [RealmPostMention]())
        ModifyPostFunctions.modifyMoment(rawPostModel: rawPostModel, oldPost: oldPost,oldPostMedia: oldPostMedia) { [weak self]  error in
            if let _ = error{
                self?.postInfo[oldPost.postID]?.postIsUpdating(false)
            }
            print("NewPostFunctions.modifyMoment: \(error?.localizedDescription ?? "was successfull")") 
        }
        postInfo[oldPost.postID]?.postIsUpdating(true)

    }
    /*we can just compare old post with new post and cehck if user removed a media*/
}

 
// MARK: -  static vars & funcs -
extension TimelinePostsOO {
    class var savedLastCachedPostDate: Date? {
        get {
            let timeInterval = UserDefaults.standard.double(forKey: Key.savedLastCachedPostDate.rawValue)
            return timeInterval == 0 ? nil : Date(timeIntervalSince1970 : timeInterval)
        }
        set {
            UserDefaults.standard.set(newValue?.timeIntervalSince1970, forKey: Key.savedLastCachedPostDate.rawValue)
        }
    }
    
    class var savedOldestPostTime: Timestamp? {
        get {
            let timeInterval = UserDefaults.standard.double(forKey: Key.oldestPostTime.rawValue)
            return timeInterval == 0 ? nil : Timestamp(date: Date(timeIntervalSince1970 : timeInterval))
        }
        set {
            UserDefaults.standard.set(newValue?.dateValue().timeIntervalSince1970, forKey: Key.oldestPostTime.rawValue)
        }
    }
    
    enum Key: String {
        case savedLastCachedPostDate
        case oldestPostTime
    }
    
    static var pageInterval : TimeInterval = { 
        var weeks = TimeInterval(3)
        if #available(iOS 15.0, *)  {
        }else{
            weeks = 20
        }
        return (86400*7*weeks)
    }()
    
    
       
       func updateOldestPostTime(friendIds: [String],areFriendsNew : Bool = false) {
        var friendIds = friendIds
        friendIds.removeFisrIfExist(TristanUserID)
           DispatchQueue.global(qos: .background).async {
               PostModel.getMostOldestPostTime(friendIds: friendIds) {[weak self] oldestPostTime, error in
                   guard error == nil else {
                       Timer.scheduledTimer(withTimeInterval: 15, repeats: false) {[weak self] (_) in
                           self?.updateOldestPostTime(friendIds: friendIds, areFriendsNew: areFriendsNew)
                       }
   //                    assert(false, "we got error while fetching oldestPostTime")
                       return
                   }
                   if let oldestPostTime = oldestPostTime {
   //                    print("oldestPostTime ",oldestPostTime.dateValue())
                       DispatchQueue.main.async {
                           guard let savedOldestPostTime = Self.savedOldestPostTime else {
                               Self.savedOldestPostTime = oldestPostTime
                               return
                           }
                           if areFriendsNew {
                               if savedOldestPostTime > oldestPostTime {
                                   Self.savedOldestPostTime = oldestPostTime
                                 
                                self?.canScrollToNextPage = true
                                self?.didFetchAllAvailabelPosts = false
                                self?.getPostFromCacheThenNetwork()
                               }
                           } else if Self.savedOldestPostTime != oldestPostTime{
                               Self.savedOldestPostTime = oldestPostTime
                           }
                       }
                   }else if let next1kdate = Calendar.current.date(byAdding: .year, value: 1000, to: Date()){
                    Self.savedOldestPostTime = Timestamp(date: next1kdate)
                    self?.allAvailabelPostFetched()
                   }
               }
           }
           
       }
     
    static func clearAllUserDefaults() {
        savedOldestPostTime = nil
        savedLastCachedPostDate = nil
    }
}
/*
 now as we want to change our flow from time to updatedAt. so for that reason i think we need to go step by step.
 so the page listener before was only used so in case a post get deleted we can remove it from the time line. but now it user can also update a post as well. so a page is all post between two intervals. so i think updated at will work fine with that as well. because any think that will get updated we will get it in the first page. so for only updated at only first page listener will be used. and of course for delete every page listener is needed.
 
 so now we need to think about the flow of getting the last post to know we have fetched all most. i think it is not the last most but the most last date to which a post can exist of the friends of current users.
 so i think we can just use the same flow and just change the query checks with time to updatedAt. i think it willl work fine. as we are modifing the timelineoo i think i should see if we can update it in any way? like we can ditch the dict then that would be great.

 */
/*
 if the current user update the post then opened post does not get re positioned to the top check why
 */
