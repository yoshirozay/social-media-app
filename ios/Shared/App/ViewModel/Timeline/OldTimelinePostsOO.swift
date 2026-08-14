//
//  OldTimelinePostsOO.swift
//  speakEZ
//
//  Created by Ahmad naeem on 4/13/22.
//


import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFunctions
import Combine
 
//class PostDetail{
//    let post
//}
//use that same object instead of making multiple objects
final class OldTimelinePostsOO: ObservableObject { // uses friend dictionary
//    func getCommentLikeVM(post : PostModel) -> CommentLikeVM{
//        postInfo[post.postID]?.startListenersIfNeeded()
//        //i do not think it will ever appened that we will not get CommentLikeVM from the postInfo but we should still be carefull
//      return  postInfo[post.postID] ?? newCommentLikeVM(post: post)
//    }
    func openedPostCommentLikeVM(post : PostModel) -> CommentLikeVM{
        postInfo[post.postID]?.startFriendLikeListenersIfNeeded()
        //i do not think it will ever appened that we will not get CommentLikeVM from the postInfo but we should still be carefull
      return  postInfo[post.postID] ?? newCommentLikeVM(post: post)
    }
    func newCommentLikeVM(post : PostModel) -> CommentLikeVM{
        CommentLikeVM(post: post,friendsDictionary: friendsDictionary)
    }
     private var postInfo = [String: CommentLikeVM]() {
        didSet{
            self.postInfoValues = self.postInfo.values.sorted(by: {$0.post.timeDate > $1.post.timeDate})
        }
    }
    @Published var myTagIDs = [String]()
    @Published var friendsDictionary = FriendsDictionary(addFriendsListener: false)
    @Published var postInfoValues  =  [CommentLikeVM]()
     private(set) var canScrollToNextPage = true
    @Published var readPosts = [String]()
    var didFetchAllAvailabelPosts = false
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
        Timestamp(date: Date() - OldTimelinePostsOO.pageInterval)
    }()
    
    var tutorialNumberSub : AnyCancellable?
    var isPrelaodedPostAdded : Bool = false

    var allTimeLinePosts  : [CommentLikeVM] {
//        var allPosts = postInfoValues
//        if self.isPrelaodedPostAdded {
//            allPosts.append(contentsOf: PostModel.Preloaded.allPosts)
//        }
        return  postInfoValues
    }
    
    let preloadedPosts = PostModel.Preloaded.allPosts
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
//    func checkReadPosts() {
//        guard let userId = Auth.auth().currentUser?.uid else{ return }
//        let docRef = Firestore.firestore().collection("ReadPost").document(userId)
//        docRef.getDocument {(document, error) in
//            if let document = document, document.exists,
//               let dataDescription = document.data() as? [String: Timestamp]{
//                for item in dataDescription.keys {
//                    self.readPosts.append(item)
//                }
//            }
//        }
//    }
    init() {
        checkForNewUser()
//        print("åß∂ OldTimelinePostsOO")
        DispatchQueue.main.async {
            self.getMyTagsAccessIDs()
        }
        getPostsOfAllFriends()
  ///now the issue is that they fetched post from server does not remove these dummy ones
        let allFailedPosts = RealmPost.getAllPosts()
          if allFailedPosts.isNotEmpty{
            addPostsInPostInfo(allFailedPosts)
          }
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
        //        print("getPostFromCacheThenNetwork called = ")
        
 
//            guard self.canScrollToNextPage else {
//            return
//        }
//            self.canScrollToNextPage = false
            
            
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
    func buildPostTimeline(document: QueryDocumentSnapshot, isNew : Bool = false) -> PostModel?  {
        
        let existingPost = self.postInfo[document.documentID]?.post
        guard existingPost == nil || existingPost?.status == .sending else{
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
//        var hasBeenRead = false
//       let postID = document.documentID
//        let firstIndex = self.readPosts.firstIndex(of: postID)
//        if firstIndex != nil {
//            hasBeenRead = true
//        }

            if doesPostHaveATag == false || doesPostHaveATag == true && doesCurrentUserHaveAccess == true {
                let postModel = PostModel(postDoc: document, tags: postTags)
                if isNew{
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
     
    //this will be called when we get response from all posts fetch request. so it does not matter request was succefful or faild
   
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
        DispatchQueue.main.async {
            self.addPreloadedPostIfRequired()
            self.canScrollToNextPage = false
        }
    }
    
   func allPageFetchingRequestCompleted(source : FirestoreSource) {
       addPostsInPostInfo(loadingPagePosts){  [weak self] in
           self?.allPageFetchingRequest(source: source)
       }
   }
    private func allPageFetchingRequest(source : FirestoreSource) {
       
//    print("!@# postInfo.count ", postInfo.count )
//    print("!@# endWeek ", endWeekDate.dateValue())
       gotErrorAt = nil
       //it means we got response of all posts requests, the response can be a error or nil
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
//                    print("123#                       self.canScrollToNextPage first but not updated = \(self.postInfoValues.count)")
//                    self.canScrollToNextPage = true
                    self.getPostFromCacheThenNetworkTest()
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//                    print("123#                       self.canScrollToNextPage first = \(self.postInfoValues.count)")
                        self.canScrollToNextPage = true
                    }
                }
            }else{
//                print("123#                       self.canScrollToNextPage = \(self.postInfoValues.count)")
                if self.postInfoValues.count < 4 {
                    self.getPostFromCacheThenNetworkTest()
                }else{
                   self.canScrollToNextPage = true
                }
               
            }
            
             
//            let numberOfNewPosts = self.postInfo.count - self.previousPostCount
//                if numberOfNewPosts < 10 {
//     //               print("not enough posts per page, postInfo.count \(postInfo.count) - previousPostCount \(previousPostCount)")
//
//                     print("numberOfNewPosts ,",numberOfNewPosts)
//                     self.getPostFromCacheThenNetwork()
//                }else{
//                    self.previousPostCount = self.postInfo.count
//                }
             
        }
    }
    
        
       //we will only want to call this if the source is the same. like we fetch from cache then on cache response , but if the page was fetched from the server then only on server response. and also need to check if the post were fetched from the cache but we do not have the next page in cache , then we will do this on server response. so to check that was previous page from cache
       
      
       
//       if canFetchNextPage,
//          !didFetchAllAvailabelPosts {
//           let numberOfNewPosts = postInfo.count - previousPostCount
//           if numberOfNewPosts < 10 {
////               print("not enough posts per page, postInfo.count \(postInfo.count) - previousPostCount \(previousPostCount)")
////            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) {[weak self] (_) in
//                print("numberOfNewPosts ,",numberOfNewPosts)
//                self.getPostFromCacheThenNetwork()
////            }
//           }else{
//               previousPostCount = postInfo.count
//           }
//       }else{
//        print("pain ass")
//       }
//
       /*
        here we can add a listener of internet and when mark a var isOffline to true.
        and when we will get the response from net listener, we will call the getPostFromCache ThenNetwork with friendsIds using postFetchFailUserIds. and soo on.
        but for now we will just not let user scroll to next page user will have to fetch the same page again. when we are done with the main flow we will add this functionality.
        we can also add that fo 30 mins offline duration. because if your device remain offline for 30 min, the listener stop lisenting or it may get the previous fetch data again from server will need to look into it.
        */
   }
  
     deinit {
         postListeners.forEach({$0.value.remove()})
     }
     
}






 
 // MARK: -  updating postInfo -
extension OldTimelinePostsOO {
    
    private func removeDeleted(postIds :  Set<String>?) {
        postIds?.forEach({removeDeleted(postId: $0)})
    }
    
    func removeDeleted(postId :  String ) {
        DispatchQueue.main.async {
            self.postInfo.removeValue(forKey: postId)
        }
    }
    
    func updatePost(content : String,postID :  String ) {
            DispatchQueue.main.async {
                /// we commented after we set the post to private in the commentLikeVM
//                self.postInfo[postID]?.post.content = content
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
//        self.postInfoGotUpdated()
    }
    
    func addPostsInPostInfo(_ newPosts : [PostModel],callback : @escaping () -> Void = {}){
        //        print("!@# newPosts.count ", newPosts.count )
        let newPostsDict: [String : CommentLikeVM] = newPosts.reduce(into: [String : CommentLikeVM]()) {  $0[$1.postID] = newCommentLikeVM(post:  $1) }
        
        DispatchQueue.main.async {[self] in
            let dict = newPostsDict.merging(postInfo)  { (current, _) in current }
//            { (current, new) in
//                if current.status == .sending{
//                    return new
//                }
//                return current
//            }
            //            print("reloading  postInfo = dict")
//            if dict.count < 5{
//                 //FIXME: - only for testing if worked then will need additional conditions as well.
//                getPostFromCacheThenNetworkTest()
//            }else{
                postInfo = dict
                
                callback()
//            }
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
    
    private func postInfoGotUpdated() {
        DispatchQueue.main.async {
            let allPosts = self.postInfo.values.sorted(by: {$0.post.timeDate.timeIntervalSinceNow > $1.post.timeDate.timeIntervalSinceNow})
            self.postInfoValues = allPosts.map({self.newCommentLikeVM(post:   $0.post)})
        }
    }
    
}






// MARK: -   post Page related funcs  -
extension OldTimelinePostsOO {
    
    
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
            (pageFlagPost == nil) || (post.timeDate <= pageFlagPost.timeDate),
            !didFetchAllAvailabelPosts,
            !isTimerSet{
             if let gotErrorAt = gotErrorAt{
                let diff = Date().timeIntervalSince1970 - gotErrorAt.timeIntervalSince1970
                if diff >= 30{
                    getPostFromCacheThenNetwork()
                }else {
                    isTimerSet = true
                    print("isTimerSet true")
                   Timer.scheduledTimer(withTimeInterval: 30 - diff, repeats: false) {[weak self] (_) in
                    print("isTimerSet false")
                    self?.getPostFromCacheThenNetwork()
                    self?.isTimerSet = false
                    }
                }
            }else{
                self.isTimerSet = true
//                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) {[weak self] (_) in
                 self.getPostFromCacheThenNetwork()
                 self.isTimerSet = false
//                 }
//                getPostFromCacheThenNetwork()
            }
        }
    }
    
    func getPostsQueryFor(friendId : String) -> Query {
        let collectionRef = PostModel.getPostCollectionReference(friendId: friendId)
        var postQuery = collectionRef
            .order(by: "time", descending: true)
        
        if friendId == TristanUserID {
            let newTimeStamp = self.friendsDictionary.currentAccountCreationDate
            postQuery = collectionRef
                .whereField("time", isGreaterThan: newTimeStamp)
                .order(by: "time", descending: true)
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
extension OldTimelinePostsOO {
    
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
//                print("friendsIds ,count ",friendsIds.count)
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
    
    
    //  so when we get posts from the cache, we do not care about error, because the possibli the only message we can get is of that we did not get any data from cache and such.
    
    //  so currently we are only fetching pages from server. so if we get posts from cache we will let user scroll to new page. if we did not get an error then we will wait for the server request to complete. as we now we are only calling server to get posts if they do not exist in cache, or to compare with cahce posts and remove the deleted posts.   we will have to get the most last post from the cache. and use its time as flag to know that do we can fetch more pages from the posts or we need to fetch from server.
    
    //but user can still only fetch one page at a time. from cache or from server.
     
     
    ///this listener will start listening to a single users posts. for the first response that we use as simple fetch we will only return callback for the first response. for the second and  response we will not return call back. we can also just fetch posts and use most latest post date and add listener for that user posts.
  
   //MARK:- addListenerToPagePosts
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
//                    if let updateAt = (docChange.document.data()["updatedAt"] as? Timestamp){
//                          print("updateAt  \(docChange.document.data())")
//                    }
                    if docChange.type == .added {
                        if isFirstResponse {
                            self?.buildPostTimeline(document: doc)
                        }else{
                            allPosts.append(self?.buildPostTimeline(document: doc, isNew : true))
                        }
                        
                    }else if docChange.type == .removed {
                        self?.removeDeleted(postId: doc.documentID )
                    }else if let content =  docChange.document.data()["content"] as? String, docChange.type == .modified {
                        self?.updatePost(content: content, postID: doc.documentID)
                    }
                }
                 
                
                if isFirstResponse {
                    isFirstResponse = false
                    callback(allPostIds,nil)
                    allPostIds = nil
                }else {
                    let allPosts = allPosts.compactMap({$0})
                    if allPosts.isNotEmpty{
                        self?.addPostsInPostInfo(allPosts )
                    }
                }
            }
        
        postListeners[friendId]?.remove()
        postListeners[friendId] = postListener
    }
}







// MARK: - MyTagsAccessIDs related -
extension OldTimelinePostsOO : MyTagsAccessNotifierAccessAble{
    
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
      
    func addPostsWihtTag( friendId : String,
                              tag : String) {
        let ref = PostModel.getPostCollectionReference(friendId: friendId)
        let query =  ref
            .whereField("tags", arrayContains: tag)
            .order(by: "time", descending: true)
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
extension OldTimelinePostsOO {
     
    //MARK:- sendNewPost
    func sendNewPost(content: String, newMedia: NewMedia?, selectedMedia: SelectedMedia?, mentionedIDs: [String], tags: [String]) {
        var friendDict : [String : Person] {
            friendsDictionary.friendsDictionary
        }
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        var friendTokens = [String]()
        for item in friendDict.values {
            if item.doesWantAllNotifications != false && item.token != "" {
                friendTokens.append(item.token)
            }
        }
        var nameOfCurrentUser = ""
        nameOfCurrentUser = friendDict[Auth.auth().currentUser!.uid]?.name ?? ""
        //the post model will have the firebase url and the thumbnail image as well.
//        let newPost = PostModel(sentBy: userId, content: content.trimWhitespacesAndNewlines(), tags: tags,  newMedia: newMedia, friend Tokens: friendT okens, nameOfCurrentUser: nameOfCurrentUser)
        let newPost = PostModel(sentBy: userId, content: content.trimWhitespacesAndNewlines(), tags: tags,  newMedia: newMedia, nameOfCurrentUser: nameOfCurrentUser)
        
        setPostInfo(newPost: newPost)
        
       let realmPostMentions = mentionedIDs.map { RealmPostMention(id: UUID().uuidString,
                               token: friendDict[$0]?.token ?? "",
                               sentTo: $0,
                               nameOfSendingUser: friendDict[userId]?.name ?? "")}
     
//        DispatchQueue.global(qos: .userInitiated).async  {
//            let rawPostModel = PostModel.Raw(post: newPost, newMedia: newMedia, selectedMedia: selectedMedia, realmPostMentions: realmPostMentions)
//               rawPostModel.saveInCache()
//            NewPostFunctions.sendPost(rawPostModel: rawPostModel) { error in
//                rawPostModel.updateCacheCopy(isSentSuccessfully: error == nil)
//            }
//        }
    }
 
}

 
// MARK: -  static vars & funcs -
extension OldTimelinePostsOO {
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
 so MyTapAccess's are not been used anywere in the apps views. so it is not a VM. need to remember we do not need to make everu publisher a VM. we will just make it a singular object and use it every where in the app. now the issue will be that what if do not get the tags because of internet connection. For that we will add publisher for the connectivity and then try to get it again.
 so that way we will not have to create the same thing again and again
 */
/*
 for now we only add listener for posts which were posted in the previous 3 weeks. so if a post is older then three weeks, then we are just fetching it, not listening to its changes. but now we want to now if an older post was updated so we can update it if it is in the timeline. there are two ways we can do this.
 1) we add a new property called upatedAt. and update it when user user update the post. As we are using "time" property to get last three weeks post, instead we can use updateAt property to get last three weeks updated posts. by doing this we will also get posts which are older then three weeks but were update in the last three weeks. now we can just filter them using "time" property to get only last three weeks post if change type is added. if change type is modified then we will replace the content of an existing post in postInfo.
 2) we can just add listeners only for posts which were update after current Date(), by doing that we will not get older posts which were recently updated. The big advantage we will get from this is we will not have to change our currently flow of timelinePostOO like we have to do in the first approach. in worst case if user has 150 friends we will just have to add 150 listeners.
 */

 
/*
 now we will add readPost functionality, so for that we will for now just get all the posts and like
 i think the best way would be to,
 first we call firestore query in the cache to get the last readTime of a post. then we will query to server to get all readPost which readTime is greater then the readTimeo of last cache readPost. by doing this we make sure that readPost is synced .
 now we will need to post a notificion after we sync the readPost. now we will add listener to the notification from CommentLikeVM. when we will get response from the CommentLikeVM we will query in the cache for the current postData and check if it has been read.
 now the question is should we add a listener of the latest readPostIDs or not? because we also want to know and update cache when a readPost is updated.

 otherwise we will have to controll and wait until we get the readPost
 
 */
 
