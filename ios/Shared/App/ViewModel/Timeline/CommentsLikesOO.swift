//
//  CommentsLikesOO.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 1/24/21.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import Combine
  

class HasPostBeenLikedOO: ObservableObject {
    @Published var hasBeenLiked = false
    init(id: String, postID: String) {
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        let docRef = PostUserInteractionModel.getCollRef(authorId: id, postID: postID).whereField("sentBy", in: [userId])
        
        docRef.getDocuments() { [weak self]  (querySnapshot, err) in
            if let err = err {
                print("error = \(err)")
            } else if let documents = querySnapshot?.documents {
                for _ in documents {
                    self?.hasBeenLiked = true
                }
            }
        }
    }
}

class HasCommentBeenLikedOO: ObservableObject {
    @Published var hasBeenLikedByMe = false
    @Published var doesThePostHaveLikes = false
    init(id: String, postID: String, commentID: String) {
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        let docRef = Firestore.firestore().collection("Posts").document(id.nonEmpty).collection("UserPosts").document(postID.nonEmpty).collection("Comments").document(commentID.nonEmpty).collection("Likes").whereField("sentBy", in: [userId])
        
        docRef.getDocuments() { [weak self]  (querySnapshot, err) in
            if let err = err {
                print("error = \(err)")
            } else if let documents = querySnapshot?.documents {
                for _ in documents {
                    self?.hasBeenLikedByMe = true
                }
            }
        }
        let collectionRef = Firestore.firestore().collection("Posts").document(id.nonEmpty).collection("UserPosts").document(postID.nonEmpty).collection("Comments").document(commentID.nonEmpty).collection("Likes")
        listener = collectionRef.addSnapshotListener { [weak self]  (querySnapshot, error) in
            if error != nil {
                return
            }
            if querySnapshot?.isEmpty == true {
                self?.doesThePostHaveLikes = false
            } else {
                self?.doesThePostHaveLikes = true
            }
        }
    }
    var listener : ListenerRegistration?
    deinit {
        listener?.remove()
    }
}

class HasCommentReplyBeenLikedOO: ObservableObject {
    @Published var hasBeenLikedByMe = false
    @Published var doesThePostHaveLikes = false
    init(id: String, postID: String, originalCommentID: String, commentID: String) {
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        let docRef = Firestore.firestore().collection("Posts").document(id.nonEmpty).collection("UserPosts").document(postID.nonEmpty).collection("Comments").document(originalCommentID.nonEmpty).collection("Comments").document(commentID.nonEmpty).collection("Likes").whereField("sentBy", in: [userId])
        
        docRef.getDocuments() { [weak self]  (querySnapshot, err) in
            if let err = err {
                print("error = \(err)")
            } else if let documents = querySnapshot?.documents {
                for _ in  documents {
                    self?.hasBeenLikedByMe = true
                }
            }
        }
        let collectionRef = Firestore.firestore().collection("Posts").document(id.nonEmpty).collection("UserPosts").document(postID.nonEmpty).collection("Comments").document(commentID.nonEmpty).collection("Likes")
        listener = collectionRef.addSnapshotListener { [weak self]  (querySnapshot, error) in
            if error != nil {
                return
            }
            if querySnapshot?.isEmpty == true {
                self?.doesThePostHaveLikes = false
            } else {
                self?.doesThePostHaveLikes = true
            }
        }
    }
    var listener : ListenerRegistration?
    deinit {
        listener?.remove()
    }
}

class CommentLikesOO: ObservableObject {
    @Published var postLikes = [Person]()
    @Published var firstTenLikes = [Person]()
    var listener : ListenerRegistration?
    let id: String
    let postID: String
    let commentID: String
    
    init(id: String, postID: String, commentID: String) {
        self.id = id
        self.postID = postID
        self.commentID = commentID
        fetchCommentLikesFromCache(){ [weak self] lastTimestamp,error in
            self?.startCommentLikeListener(lastTimestamp: lastTimestamp)
        }
    }
    
    private func fetchCommentLikesFromCache(callback: @escaping (_ lastTimestamp: Timestamp?, _ error: Error?) -> Void){
        let docRef = CommentModel
                 .getPostCommentLikeRef(authorId: id, postID: postID, commentID: commentID)
                 .order(by: "time")
             docRef.getDocuments(source: .cache) {[weak self] querySnapshot, error in
                 guard let documents = querySnapshot?.documents, error == nil else {
                     callback(nil,error)
                     return
                 }
                 documents.forEach { doc in
                     if let sentBy = doc.get("sentBy") as? String{
                         self?.buildLikes(sentBy: sentBy)
                     }
                 }
                 let lastTimestamp = documents.last?.get("time") as? Timestamp
                 callback(lastTimestamp,nil)
             }
    }
    
    private  func startCommentLikeListener(lastTimestamp : Timestamp?){
        listener?.remove()
        
        let docRef = CommentModel.getPostCommentLikeRef(authorId: id, postID: postID, commentID: commentID)
        var query: Query?
        if let lastTimestamp = lastTimestamp{
            query = docRef.whereField("time", isGreaterThan: lastTimestamp)
        }
        listener = (query ?? docRef).addSnapshotListener{ [weak self] (querySnapshot, error) in
            guard let documentChanges = querySnapshot?.documentChanges, error == nil else {
                print("Error fetching documents: \(error?.localizedDescription ?? "" )")
                return
            }
            for documentChange in documentChanges {
                if documentChange.type == .added {
                    let sentBy = documentChange.document.data()["sentBy"] as? String ?? ""
                        self?.buildLikes(sentBy: sentBy)
                }
            }
        }
    }
    
    private func buildLikes (sentBy: String) -> Void {
        Person.fetchLatestUserUsingCTN(id: sentBy){ [weak self]  (person, aResend, error) in
            if let person = person {
                self?.updateLikesArrays(person: person, aResend: aResend)
            }else  {
                print("buildLikes error ",error?.localizedDescription ?? "")
            }
        }
    }
    
    private func updateLikesArrays(person: Person,aResend : Bool?){
        if aResend == true {
            if let index = self.postLikes.firstIndex(where: {$0.id == person.id }){
                self.postLikes[index] = person
            }
            if self.postLikes.count < 11 ,
               let index = self.firstTenLikes.firstIndex(where: {$0.id == person.id }){
                self.firstTenLikes[index] = person
            }
        }else{
            self.postLikes.append(person)
            if self.postLikes.count < 11 {
                self.firstTenLikes.append(person)
            }
        }
    }
    deinit {
        listener?.remove()
    }
}
 
