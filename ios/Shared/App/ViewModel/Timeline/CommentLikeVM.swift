//
//  CommentLikeVM.swift
//  speakEZ
//
//  Created by Ahmad naeem on 2/11/22.
//

import Foundation
import Combine
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore
import SwiftUI


class CommentLikeVM : ObservableObject {
    private var likeListener : ListenerRegistration?
    private var commentListener : ListenerRegistration?
    private var subs = Set<AnyCancellable>()
    private var likeSubs = Set<AnyCancellable>()
    
    private var hasCheckedReadStatus : Bool = false
    @Published private var likeIds = Set<PostUserInteractionModel>()
    @Published private var commentIds  = Set<PostUserInteractionModel>()
    
    @Published private (set) var commentCount : Int  =  0
    @Published private (set) var hasBeenLiked : Bool = false
    @Published private (set) var hasBeenCommented : Bool = false
    @Published private (set) var likedFriendCount = 0
    @Published private (set) var commenterFriendCount = 0
    @Published private (set) var sevenUserLikes : [UserLike] = []
    @Published private (set) var sevenUserComment : [UserComment] = []
    @Published private (set) var uniqueCommenterIds = Set<String>()
    @Published private (set) var post : PostModel
    @Published private (set) var isUpdating : Bool = false
    
    var sevenFriendsHasCommented : Bool { commenterFriendCount > 6 }
    var likesCount : Int { likeIds.count  }
    var sevenFriendsHasLiked : Bool{ likedFriendCount > 6 }
    let friendsDictionary : FriendsDictionary
    private var readPostSyncSub: AnyCancellable?
    
    private var hasSubscribedSub : AnyCancellable?
    init(post : PostModel,friendsDictionary : FriendsDictionary,updateReadStatus : Bool = true) {
        self.post = post
        self.friendsDictionary = friendsDictionary
        if updateReadStatus {
            checkReadStatus()
        }
    }
    var allowContextMenu: Bool {
        !( isUpdating || post.isDummy)
    }
    
    func postIsUpdating(_ val : Bool){
        isUpdating = val
    }
    
    func set(updatedPost : PostModel){
        var updatedPost = updatedPost
        updatedPost.hasSubscribed = post.hasSubscribed
        updatedPost.hasBeenRead = post.hasBeenRead
        post = updatedPost
        if !updatedPost.isDummy,isUpdating{
            isUpdating = false
        }
    }
    
    func checkReadStatus(){
        guard let userId = currentUserID else { return }
        DispatchQueue.global(qos: .background).async  {[weak self] in
            self?.checkIsPostHasBeenRead(userId : userId)
        }
    }
    
    func getSelf() -> CommentLikeVM{
         startListenersIfNeeded()
        //i do not think it will ever appened that we will not get CommentLikeVM from the postInfo but we should still be carefull
      return  self
    }
   
    @discardableResult
    func startAllListenersIfNeeded() -> CommentLikeVM{
        startListenersIfNeeded()
        startFriendLikeListenersIfNeeded()
        print("startAllListenersIfNeeded   ")
        return self
    }
    
    func startListenersIfNeeded(){
        DispatchQueue.global(qos: .userInitiated).async  {[weak self] in
            guard self?.subs.isEmpty == true else {  return }
            self?.startAllListenrs()
            self?.checkHasSubscribedToPost(source: .cache)
        }
    }
    
    private func startAllListenrs() {
        guard let _ = currentUserID, post.status == .successfull else { return }
         
        DispatchQueue.global(qos: .userInitiated).async { [weak self]  in
            guard  let self = self else { return }
            self.startLikelistener()
            self.startCommentListener()
            self.friendsDictionary.$friendsDictionary.didSet.dropFirst().sink { [weak self] _  in
                self?.updateUserComments()
            }.store(in: &self.subs)
        }
    }
    
    private func startLikelistener() {
        
        guard let userId = currentUserID else { return }
        
        let docRef = PostUserInteractionModel.getCollRef(authorId: post.id, postID: post.postID)
        
        likeListener = docRef.addSnapshotListener{ [weak self] (querySnapshot, error) in
            guard let documentChanges = querySnapshot?.documentChanges, error == nil, let self = self else {
                print("CommentLikeVM Error fetching documents: \(error?.localizedDescription ?? "" )")
                return
            }
            var newLikesIds = Set<PostUserInteractionModel>()
            var removedLikesIds = Set<PostUserInteractionModel>()
            
            for documentChange in documentChanges {
                if let like =  try? documentChange.document.data(as: PostUserInteractionModel.self){
                    let isRemovedLike = documentChange.type == .removed
                    let _ = isRemovedLike ? removedLikesIds.insert(like) : newLikesIds.insert(like)
                    if userId == like.sentBy{
                        self.setHasBeenLiked(!isRemovedLike)
                    }
                }
            }
            
            self.updateLikeIds(newLikesIds: newLikesIds, removedLikesIds: removedLikesIds)
        }
    }
    
    func setHasBeenLiked(_ hasBeenLiked : Bool) {
        DispatchQueue.main.async { [weak self] in
            if self?.hasBeenLiked != hasBeenLiked{
                withAnimation {
                    self?.hasBeenLiked = hasBeenLiked
                }
            }
        }
    }
    
    private func updateLikeIds(newLikesIds : Set<PostUserInteractionModel>, removedLikesIds : Set<PostUserInteractionModel>) {
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                self?.likeIds.formUnion(newLikesIds)
                if removedLikesIds.isNotEmpty{
                    self?.likeIds.subtract(removedLikesIds)
                }
            }
        }
    }
    
    deinit{
        likeListener?.remove()
        commentListener?.remove()
        subs.cancelAll()
        likeSubs.cancelAll()
    }
    
//    private var commentSubs = Set<AnyCancellable>()
}
 
extension CommentLikeVM{
    
     private func startCommentListener() {
        guard let _ = currentUserID else { return }
        let docRef = CommentModel.getPostCommentCollRef(authorId: post.id, postID: post.postID)
        commentListener = docRef.addSnapshotListener { [weak self] (querySnapshot, error) in
           
            guard let documentChanges = querySnapshot?.documentChanges, error == nil, let self = self else {
                print("addCommentListener Error fetching documents: \(error?.localizedDescription ?? "" )")
                return
            }
            var newCommensIds = Set<PostUserInteractionModel>()
            var removedCommensIds = Set<PostUserInteractionModel>()
            
            for documentChange in documentChanges {
                if let comment =  try? documentChange.document.data(as: PostUserInteractionModel.self){
                    let isNewComment = documentChange.type != .removed
                    let _ = isNewComment ? newCommensIds.insert(comment) : removedCommensIds.insert(comment)
                 }
            }
            self.updateCommentIds(newCommensIds: newCommensIds, removedCommensIds: removedCommensIds)
        }
    }
     
    private func updateCommentIds(newCommensIds : Set<PostUserInteractionModel>,removedCommensIds : Set<PostUserInteractionModel>) {
        guard let userId = currentUserID else { return }
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                guard let self = self else { return  }
                self.commentIds = self.commentIds.union(newCommensIds).subtracting(removedCommensIds)
//                self.commentIdDict.formUnion(newCommensIds)
//                self.commentIdDict.subtract(removedCommensIds)
                
                if self.commentCount != self.commentIds.count{
                    self.commentCount = self.commentIds.count
                }
                self.uniqueCommenterIds = self.commentIds.map{$0.sentBy}.getSet()
                if self.hasBeenCommented != self.uniqueCommenterIds.contains(userId){
                    self.hasBeenCommented.toggle()
                }
                self.updateUserComments()
            }
        }
    }
      /*
     let us think first comments can be of any one. then comment reply can also of a non current user comment.
     */
    /*
     as we can delete comments and likes, we will also remove the likes as well. now for now just use the listener to update the likeIds.
     we will just add listeners and update the count accordingly
     */
}
 
//MARK: - 6 friend likes and friend like count funcs
extension CommentLikeVM {
    typealias UserComment = UserLike
    struct UserLike: Identifiable {
        var id : String {userId}
        var userId : String
        var profileURL : URL
    }
     
    func startFriendLikeListenersIfNeeded() {
        guard likeSubs.isEmpty, post.status == .successfull else { return  }
        startListenersIfNeeded()
        
        friendsDictionary.$friendsDictionary.didSet.dropFirst().sink { [weak self] _  in
            self?.updateUserLikes()
            
        }.store(in: &likeSubs)
        
        $likeIds.sink {[weak self] likes  in
            self?.updateUserLikes()
        }.store(in: &likeSubs)
        
    }
    
    private func updateUserLikes(){
        var friendIds :  [String] { Array(self.friendsDictionary.friendsDictionary.keys) }
        let likeUserIds = Set(likeIds.map{$0.sentBy})
        
        let likerFriendIds : Set<String> = Set(likeUserIds.intersection(friendIds).prefix(6))
        self.likedFriendCount = likerFriendIds.count
        
        let friendLikes = likerFriendIds.compactMap { userId -> UserLike? in
            if let user = self.friendsDictionary.friendsDictionary[userId], let profileURL = user.profilePicLink{
                return UserLike(userId: user.id, profileURL: profileURL)
            }
            return nil
        }
        self.sevenUserLikes = friendLikes.sorted(by: {$0.id < $1.id})
        if likerFriendIds.count < 6, likerFriendIds.count < likeUserIds.count {
            let nonFriendsIDs = Set(Set(likeUserIds).subtracting(likerFriendIds).prefix(6-likerFriendIds.count))
            let group = DispatchGroup()
            
            var nonFriendUsers : [Person] = []
            nonFriendsIDs.forEach { id in
                group.enter()
                self.friendsDictionary.getUserOf(id: id) { userInfo, error in
                    if let user = userInfo?.user{
                        nonFriendUsers.append(user)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main){
                let userLikes = nonFriendUsers.compactMap { user -> UserLike? in
                    if let profileURL = user.profilePicLink{
                        return UserLike(userId: user.id, profileURL: profileURL)
                    }
                    return nil
                }
                self.sevenUserLikes =  friendLikes.sorted(by: {$0.id < $1.id}) + userLikes.sorted(by: {$0.id < $1.id})
            }
        }
    }
}

/*
 no we want to start listeners only when commentLikeVM will be used in a view otherwise we will just start listener that user might not see fo no reason.
 */

//MARK: - 6 friend likes and friend like count funcs

extension CommentLikeVM {
     
    
    private func updateUserComments() {
        
        var friendIds : [String] { Array(self.friendsDictionary.friendsDictionary.keys)  }
       
        let commentUserIds = self.uniqueCommenterIds
        let allCommmenterFriendIds = commentUserIds.intersection(friendIds)
        let commenterFriendIds : Set<String> = Set(allCommmenterFriendIds.prefix(6))
          
        let friendComments = commenterFriendIds.compactMap { userId -> UserComment? in
            if let user = self.friendsDictionary.friendsDictionary[userId], let profileURL = user.profilePicLink{
                return UserComment(userId: user.id, profileURL: profileURL)
            }
            return nil
        }
        
        DispatchQueue.main.async {
            if self.commenterFriendCount != allCommmenterFriendIds.count {
                self.commenterFriendCount = allCommmenterFriendIds.count
            }
            self.sevenUserComment = friendComments.sorted(by: {$0.id < $1.id})
        }
        
        if commenterFriendIds.count < 6, commenterFriendIds.count < commentUserIds.count {
            let nonFriendsIDs = Set(commentUserIds.subtracting(commenterFriendIds).prefix(6-commenterFriendIds.count))
            let group = DispatchGroup()

            var nonFriendUsers : [Person] = []
            nonFriendsIDs.forEach { id in
                group.enter()
                self.friendsDictionary.getUserOf(id: id) { userInfo, error in
                    if let user = userInfo?.user{
                        nonFriendUsers.append(user)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main){
                let userComments = nonFriendUsers.compactMap { user -> UserComment? in
                    if let profileURL = user.profilePicLink{
                        return UserComment(userId: user.id, profileURL: profileURL)
                    }
                    return nil
                }
                self.sevenUserComment =  friendComments.sorted(by: {$0.id < $1.id}) + userComments.sorted(by: {$0.id < $1.id})
            }
        }
    }
}

extension CommentLikeVM  : ReadPostSyncAccessAble {
    
    func checkIsPostHasBeenRead(userId: String, source: FirestoreSource = .cache) {
        guard !hasCheckedReadStatus else { return   }
        hasCheckedReadStatus = true
        ReadPost.getCollRef(userId: userId).document(post.postID.nonEmpty)
            .getDocument(source: .cache){ [weak self] docSnap, error in
                if let _ = docSnap {
                    DispatchQueue.main.async {
                            self?.post.hasBeenRead = true
                    }
                } else if let _ = error, source == .cache {
                    self?.readPostSyncSub = self?.areReadPostIDsSynced.sink {[weak self] isSynced in
                            if let isSynced = isSynced {
                                if !isSynced{
                                    self?.checkIsPostHasBeenRead(userId: userId)
                                }
                                self?.readPostSyncSub?.cancel()
                        }
                        self?.readPostSyncSub?.cancel()
                    }
                }
            }
    }
    
    func readPost(postID: String) {
        guard post.hasBeenRead == false  else{ return }
//        if ReachabilityService.shared.isNetworkAvailable {
//            post.hasBeenRead = true
//        }
        ReadPostFunction.readPostCloudFunction(postID: postID){[weak self] error in
            if error == nil,self?.post.hasBeenRead == false{
                self?.post.hasBeenRead = true
            }
            print("readPostCloudFunction \(error.descriptionIfAny)")
        }
         //FIXME: - for now we will only mark hasBeenRead true, in future we can have a failedManager for hasBeenRead as well.
       
    }
    
    func checkHasSubscribedToPost(source: FirestoreSource) {
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        let postID = post.postID
        let docRef = Firestore.firestore().collection("CommentSubscription").document(userId.nonEmpty)
        docRef.getDocument(source: source) { [weak self] (document, error) in
            guard let self = self else { return  }
            if let dict = document?.data() as? [String: String]   {
                if dict[postID] == nil {
                    if  self.post.hasSubscribed != false{
                        self.post.hasSubscribed = false
                    }
                } else {
                    if  self.post.hasSubscribed != true{
                        self.post.hasSubscribed = true
                    }
                }
            }
            
            if source == .cache {
                self.checkHasSubscribedToPost(source: .server)
            }
        }
    }
    
    func unSubcribePost() {
        if post.hasSubscribed != false {
            SubscribeToPost.unsubscribeToPostCloudFunction(postID: post.postID, originalAuthor: post.id){ [weak self]  error in
                if let error = error {
                    print("unsubscribeToPostCloudFunction \(error.localizedDescription)")
                }else{
                    DispatchQueue.main.async {
                        self?.post.hasSubscribed = false
                    } 
                }
                
            }
        }
    }
    
    func subcribeToPost() {
        if post.hasSubscribed != true {
            SubscribeToPost.subscribeToPostCloudFunction(postID: post.postID, originalAuthor: post.id){ [weak self]  error in
                if let error = error {
                    print("subscribeToPostCloudFunction \(error.localizedDescription)")
                }else{
                    DispatchQueue.main.async {
                        self?.post.hasSubscribed = true
                    }
                }
                
            }
        }
    }
     
}
 
//"51FEA2E9-F65F-43E4-877B-76CDFCCAEE25"
