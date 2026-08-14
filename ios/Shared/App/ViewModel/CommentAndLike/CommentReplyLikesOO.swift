//
//  CommentReplyLikesOO.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 4/25/21.
//
 
import Firebase
import FirebaseFirestore
import Combine
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

