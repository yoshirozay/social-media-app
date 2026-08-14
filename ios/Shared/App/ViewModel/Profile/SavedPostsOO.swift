//
//  SavedPostsOO.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 7/30/21.
//

import SwiftUI
import Firebase
import Combine
import FirebaseStorage

class SavedPostsOO: ObservableObject {
    @Published var postInfo = [PostModel]()
    @Published var myTagIDs = [String]()
    var savedPostsListener : ListenerRegistration?
    var sub: AnyCancellable!
    
    init() {
        DispatchQueue.main.async {
            self.getMyTagsAccessIDs()
        }
        getSavedPostIDs()
    }
    
    func getSavedPostIDs(source: FirestoreSource = .default) {
        
        guard let userId = Auth.auth().currentUser?.uid else{  return  }
        savedPostsListener?.remove()
        let collectionRef = getSavedPostCollectionRef(userId: userId)
        savedPostsListener = collectionRef.addSnapshotListener{[weak self] (querySnapshot, error) in
          
            guard let documentChanges = querySnapshot?.documentChanges,error == nil else {
                print(" fetching documents: ",error?.localizedDescription ?? "documents is zero" )
                return
            }
            
            for document in documentChanges {
                if document.type == .added,
                   let dataDescription = document.document.data() as? [String: Timestamp] {
                    let postIDs = dataDescription.map({$0.key})
                    let friendID = document.document.documentID
                    
                    for postID in postIDs { 
                        let newCollectionRef = PostModel.getPostCollectionReference(friendId: friendID) 
                            .document(postID.nonEmpty)
                        newCollectionRef.getDocument { (documentSnapshot, error)  in
                            if let error = error  {
                                print("there's an error FriendsDictionary.swift",error.localizedDescription)
                                return
                            }
                            self?.fetchPostFromCacheOrNetwork(postID: postID, friendID: friendID)
                        }
                    }
                    
                }
                //                else if  document.type == .removed{
                //                    removePost(postID: <#T##String#>)
                //                }
            }
        }
        
    }
    
    func getSavedPostCollectionRef(userId : String) -> CollectionReference{
          Firestore.firestore()
            .collection("SavedPosts")
            .document(userId.nonEmpty)
            .collection("Posts")
    }
    
  private func fetchPostFromCacheOrNetwork(postID: String, friendID: String) {
        
          PostModel.fetchPostFromCacheOrNetwork(postID: postID, friendId: friendID) {[weak self] postModel, error in
              //                                        showLoading = false
              if var post = postModel {
                  var tagNames = [String]()
                    for item in post.tags {
                        if self?.myTagIDs.firstIndex(of: item) != nil {
                            tagNames.append(item)
                        }
                    }
                     
                if post.tags.isEmpty || tagNames.isNotEmpty {
                         post.tags = tagNames
                    
                    self?.postInfo.append(post)
                  }
              }else if let error = error{
                  print(error.localizedDescription)
              }
          }
    }
    
    private func removeDeleted(postIds :  Set<String>?) {
     postIds?.forEach({removePost(postID: $0)})
    }

       func removePost(postID: String) {
         if let firstIndex = postInfo.firstIndex(where: {$0.postID == postID}) {
             postInfo.remove(at: firstIndex)
         }
         
     }
    
    deinit {
        savedPostsListener?.remove()
        sub?.cancel()
    }
}

//MARK: - getMyTagsAccessIDs
extension SavedPostsOO : MyTagsAccessNotifierAccessAble {
    
  
    func getMyTagsAccessIDs() {
        
        self.myTagIDs = myTagsAccessNotifier.myTagIDs
        //         var isFirstResponse = true
        sub = myTagsAccessNotifier.myTagsAccessPublisher.sink { tagAccessInfo in
            let allTagIds  = tagAccessInfo.allTags.ids
            
            let deletedPostIDs = tagAccessInfo.getDeletedPostsIds(currentPosts: self.postInfo)
            if  deletedPostIDs.isNotEmpty {
                 self.removeDeleted(postIds: deletedPostIDs.getSet())
            } 
            //            if !isFirstResponse {
            //                tagAccessInfo.addedTags.forEach{ tag in
            //                    self.addPostsWihtTag(friendId: tag.creatorID, tag: tag.id)
            //                }
            //            }else{
            //                isFirstResponse = false
            //            }
            self.myTagIDs = allTagIds
        }
    }
    
    /*
     for now we will not implement  the adding post with new tags. because savepost document does not have tag properties , so we will have to fetch all not added post ids which exist in postInfo and then check one by one
     */
    //    func addPostsWihtTag( friendId : String,
    //                              tag : String) {
    //        let ref = getSavedPostCollectionRef(friendId: friendId)
    //        let query =  ref
    //            .whereField("tags", arrayContains: tag)
    //        query.getDocuments(source: .cache) { [weak self] (querySnapshot, error) in
    //            guard let documents = querySnapshot?.documents else {
    //                return
    //            }
    //            guard let self = self else { return  }
    //            let myTagsIds =  self.myTagIDs
    //            let posts : [PostModel] = documents.compactMap { doc in
    //                    var postTags = [String]()
    //                    if let tags = doc.data()["tags"] as? [String] {
    //                        postTags = myTagsIds.getSet().intersection((tags)).getArray()
    //                    }
    //                return PostModel(postDoc: doc, tags: postTags)
    //
    //            }
    ////            self.addPostsInPostInfo(posts)
    //        }
    //    }
    
}

