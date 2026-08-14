//
//  L-VM.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import Combine

class LikesOO: ObservableObject {
    @Published var postLikes = [Person]()
   
    init(id: String, postID: String) {
        getAllLikes(id: id, postID: postID, source: .cache) { [weak self] (lastTimestamp) in
            self?.addLikesListener(id: id, postID: postID, lastTime: lastTimestamp)
        }
    }
     
    private func getAllLikes(id: String, postID: String,source : FirestoreSource = .default,callback : @escaping ( _  lastTime : Timestamp?) -> Void) {
       let docRef = PostUserInteractionModel.getCollRef(authorId: id, postID: postID)
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

//we can also use cache then network technique here but then if the user is not friend and we do not refresh his/her profile pic then we will only get old pic from the cache so for now we will just use this func as it is. otherwise we will need to first find the new fetched user in the postLikes array and if found we will replace it
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
                   }else {
                       print("getFriendRequestUser error \(error?.localizedDescription ?? "")")
                       callback(nil,error)
                   }
               }
    }
    
    private func addLikesListener(id: String, postID: String,lastTime : Timestamp?) {
        let docRef = PostUserInteractionModel.getCollRef(authorId: id, postID: postID)
 
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
                    self?.buildLikes(sentBy: sentBy)
                }
            }
        }
        
        likeListenerReg?.remove()
        if let lastTime = lastTime {
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
