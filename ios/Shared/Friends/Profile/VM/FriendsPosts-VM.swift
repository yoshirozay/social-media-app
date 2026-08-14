//
//  FriendsPosts.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 1/24/21.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import Combine

class FriendsPostsOO: ObservableObject {
    @Published var postInfo = [CommentLikeVM]()
    @Published var myTagIDs = [String]()
    @Published var friendsDictionary : FriendsDictionary
    let postDeletePublisher = PassthroughSubject<String,Never>()
    var anyCancellable: AnyCancellable?
    var listener : ListenerRegistration!
     //FIXME: - need to set it in the init
    var preloadedPosts = [PostModel]()
    var sortedPostss : [CommentLikeVM] {
        postInfo//.sorted(by: {$0.post.time > $1.post.time})
    }
 
    func newCommentLikeVM(post : PostModel) -> CommentLikeVM{
        CommentLikeVM(post: post,friendsDictionary: friendsDictionary)
    }
    init(id: String,friendsDictionary : FriendsDictionary) {
        self.friendsDictionary = friendsDictionary
        guard id.isNotEmpty else {
            assert(false, "id should not be empty")
            return
        }
        if id == TristanUserID {
            preloadedPosts = PostModel.Preloaded.allPosts
        }
        DispatchQueue.main.async {
            self.getMyTagsAccessIDs()
        }
       
        let collectionRef = PostModel.getPostCollectionReference(friendId: id)
       
        listener = collectionRef.addSnapshotListener{[weak self] (querySnapshot, error) in
            
            guard let documentChanges = querySnapshot?.documentChanges,error == nil else {
                print(" fetching documents: ",error?.localizedDescription ?? "documents are zero" )
                return
            }
            
            guard let self = self else { return  }
            var newPostInfo : [CommentLikeVM] = []
            for document in documentChanges {
                if document.type == .added {
                    let doc = document.document
                    var tagNames = [String]()
                    let postTags = doc.data()["tags"] as? [String] ?? []
                    if postTags.isNotEmpty {
                        tagNames = self.myTagIDs.getSet().intersection(postTags).getArray()
                    }
                    
                    if postTags.isEmpty  || tagNames.isNotEmpty {
                        let postModel =  PostModel(postDoc: doc, tags: postTags, hasBeenRead: false)
//                        self.postInfo.append(postModel)
                        newPostInfo.append(self.newCommentLikeVM(post: postModel))
                    }
                }  else if document.type == .removed {
                    self.removePostIfExist(postID : document.document.documentID)
                }
            }
            self.updatePostInfo(newPostInfo: newPostInfo)
        }
        anyCancellable = postDeletePublisher.sink {[weak self] postID in
            self?.removePostIfExist(postID: postID)
        }
    }
   
    var sub: AnyCancellable!
    func getMyTagsAccessIDs() {
        
        self.myTagIDs = myTagsAccessNotifier.myTagIDs
        var isFirstResponse = true
        sub = myTagsAccessNotifier.myTagsAccessPublisher.sink { tagAccessInfo in
            let allTagIds = tagAccessInfo.allTags.ids
//            let deletedPostIDs = tagAccessInfo.getDeletedPostsIds(currentPosts: self.postInfo)
            let deletedPostIDs = tagAccessInfo.getDeletedPostsIds(currentPosts: self.postInfo.map({$0.post}))
            if  deletedPostIDs.isNotEmpty {
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
        }
    }
    
    func addPostsWihtTag( friendId : String, tag : String) {
        let ref = PostModel.getPostCollectionReference(friendId: friendId)
        let query =  ref
            .whereField("tags", arrayContains: tag) 
        query.getDocuments(source: .cache) { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                return
            }
            guard let self = self else { return  }
//            let posts = documents.compactMap { PostModel(postDoc: $0, currentAccesssTagIds: self.myTagIDs, hasBeenRead: false)  }
//            self.postInfo.append(contentsOf: posts)
            
            let newPostInfo  = documents.compactMap { doc -> CommentLikeVM? in //-> CommentLikeVM?
                if let post = PostModel(postDoc: doc, currentAccesssTagIds: self.myTagIDs)   {
                   return  self.newCommentLikeVM(post:  post)
                }
                return nil
            }
            self.updatePostInfo(newPostInfo: newPostInfo)
        }
    }
    
    func updatePostInfo(newPostInfo: [CommentLikeVM]) {
        guard newPostInfo.isNotEmpty else { return  }
        let newPostInfo = newPostInfo.filter { commentLikeVM in
            !postInfo.contains(where: {$0.post.postID == commentLikeVM.post.postID})
        } 
        self.postInfo = (postInfo+newPostInfo).sorted(by: {$0.post.updatedAt > $1.post.updatedAt})
        //        postInfo = self.postInfo.sorted(by: {$0.post.time > $1.post.time})
    }
    
    func removePostIfExist(postID : String) {
        if let index = postInfo.firstIndex(where: {$0.post.postID == postID }) {
            postInfo.remove(at: index)
        }
    }
    
    private func removeDeleted(postIds : Set<String>?) {
        postIds?.forEach({removePostIfExist(postID: $0)})
    }
    
    deinit {
        anyCancellable?.cancel()
       listener?.remove()
    }
}

extension FriendsPostsOO : MyTagsAccessNotifierAccessAble{
    
}
