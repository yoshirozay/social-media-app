//
//  CL-VM.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
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
 
class CommentReplyLikesOO: ObservableObject {
    @Published var postLikes = [Person]()
    
    init(id: String, postID: String, originalCommentID: String, commentID: String)  {
 
        getAllCommentsReplyLikes(id: id, postID: postID, originalCommentID: originalCommentID, commentID: commentID,source : .cache) {[weak self] (lastTimestamp) in
            self?.addLikesListener(id: id, postID: postID, originalCommentID: originalCommentID, commentID: commentID, lastTime: lastTimestamp)
        }
    }
    
    private func getAllCommentsReplyLikes(id: String, postID: String, originalCommentID: String, commentID: String ,source : FirestoreSource = .default,callback : @escaping ( _  lastTime : Timestamp?) -> Void) {
        let docRef = Firestore.firestore()
            .collection("Posts").document(id.nonEmpty)
            .collection("UserPosts").document(postID.nonEmpty)
            .collection("Comments").document(originalCommentID.nonEmpty)
            .collection("Comments").document(commentID.nonEmpty)
            .collection("Likes")
        docRef.getDocuments(source: source) {[weak self] (querySnapshot, error) in
            if error != nil{
                print("there's an error CommentLikesOO.swift")
                callback(nil)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "" )")
                callback(nil)
                return
            }
            
            for document in documents {
                let sentBy = document.get("sentBy") as? String ?? ""
                //cache then network technique
                self?.buildLikes(sentBy: sentBy,source: source){ userId ,error in
                    if source == .cache {
                        self?.buildLikes(sentBy: sentBy,source: .server)
                    }
                }
            }
            
            let allTimeStamp = documents.compactMap({$0.get("time") as? Timestamp})
            let lastTime = allTimeStamp.max(by: {$0.dateValue() < $1.dateValue() })
            callback(lastTime)
        }
    }
    
    private func buildLikes (sentBy: String, source : FirestoreSource = .default,callback : @escaping (_ userId : String?,  _  error : Error?) -> Void = {_ , _ in}) -> Void {
        
        Person.fetchFriend(id: sentBy,source : source){[weak self] (person, error) in
                   if let person = person{
                       if source == .server,
                          let index = self?.postLikes.firstIndex(where: {$0.id == person.id})  {
                           self?.postLikes[index] = person
                       }else{
                           self?.postLikes.append(person)
                       }
                       callback(person.id,nil)
                   } else  {
                       print("getFriendRequestUser error \(error?.localizedDescription ?? "" )")
                       callback(nil,error)
                   }
             
               }
         
    }
    
    private func addLikesListener(id: String, postID: String, originalCommentID: String, commentID: String,  lastTime : Timestamp?)  {
            let docRef = Firestore.firestore()
                .collection("Posts").document(id.nonEmpty)
                .collection("UserPosts").document(postID.nonEmpty)
                .collection("Comments").document(originalCommentID.nonEmpty)
                .collection("Comments").document(commentID.nonEmpty)
                .collection("Likes")
        let listenerClouser : ( QuerySnapshot?,Error?) -> () = { [weak self] (querySnapshot, error) in
            if error != nil{
                print("there's an error CommentLikesOO.swift")
                return
            }
            guard let documentChanges = querySnapshot?.documentChanges else {
                print("Error fetching documents: \(error?.localizedDescription ?? "" )")
                return
            }
            
            for documentChange in documentChanges {
                if documentChange.type == .added {
                    let sentBy = documentChange.document.get("sentBy") as? String ?? ""
                    //we are using source .server and cehcking contains because of the bug that same user can like the same replyed comment mutliple time and each time we just update the time of that like
                    if self?.postLikes.contains(where: {$0.id == sentBy}) == false {
                        self?.buildLikes(sentBy: sentBy,source: .server)
                    }
                }
            }
        }
        
        likeListenerReg?.remove()
        if let lastTime = lastTime {
//            print(lastTime.dateValue())
            likeListenerReg = docRef
                .whereField("time", isGreaterThan: lastTime)
                .addSnapshotListener{ listenerClouser($0,$1)}
        }else{
            likeListenerReg = docRef
                .addSnapshotListener{ listenerClouser($0,$1)}
        }
    }
    var likeListenerReg : ListenerRegistration?
    deinit {
        likeListenerReg?.remove()
    }
}

