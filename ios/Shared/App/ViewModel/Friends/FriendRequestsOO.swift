//
//  FriendRequestsOO.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 1/26/21.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import Combine 
 
class FindPeopleOO: ObservableObject {
    @Published var people = [Person]()
    @Published var isSearching : Bool = false
    
    func search(username: String) {
        guard username.isNotEmpty else { return }
        var username2 = username
        if username2.first == "@" {
            username2.removeFirst()
    }
        people.removeAll()
        isSearching = true
        Firestore.firestore()
            .collection("UserInfo")
            .whereField("username", isEqualTo: "@"+username2.lowercased())
            .getDocuments {[weak self] (snap, err) in
                guard let self = self,
                      let documents = snap?.documents,
                      err == nil else { return }
                for doc in documents {
                    Person.getPersonFromUserInfo(userId: doc.documentID, documentData: doc.data()) {[weak self] person, error in
                        if let person = person {
                            self?.add(person : person)
                        }else{
                            print(error?.localizedDescription ?? "")
                        }
                    }
                }
                self.isSearching = false
            }
    }
    
    func add(person : Person) {
//        if !people.contains(where: {$0.id == person.id}){
            people.append(person)
//        }
    }
     
}

class FriendRequestsOO: ObservableObject {
    @Published var requests = [String:Person]()
    @Published var firstThreeRequests = [String: Person]()
    var listener : ListenerRegistration?
    
    init() {
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        var oldRequestsIds = Set<String>()
        let docRef = Firestore.firestore().collection("FriendRequests").document(userId.nonEmpty)
        listener = docRef.addSnapshotListener {[weak self]  (document, error)  in
            if error != nil{
                print("there's an error FriendsDictionary.swift")
                return
            }
            
            if let document = document, document.exists,
               let dataDescription = document.data(){
            
                guard let self = self else { return  }
                 
                let latestRequestIds : Set<String> = Array(dataDescription.keys).getSet()
                let newRequestsIds =  latestRequestIds.subtracting(oldRequestsIds)
                let removedRequestsIds = oldRequestsIds.subtracting(latestRequestIds)
                oldRequestsIds = latestRequestIds
                 
                    for item in newRequestsIds {
                    Firestore.firestore().collection("UserInfo").document(item.nonEmpty).getDocument {[weak self] (doc, err) in
                        guard let user = doc, let documentData = user.data(), documentData["username"] != nil else { return }
                        let id = user.documentID
                        Person.getPersonFromUserInfo(userId: id, documentData: documentData) { person, error in
                            if let person = person {
                                self?.requests[id] = person
                                if self?.requests.count ?? 0 < 4 {
                                    self?.firstThreeRequests[id] = person
                                }
                            }
                        }
                    }
                }
                
                for id in removedRequestsIds {
                    self.requests[id] = nil
                }
            } 
        }
    }
    
    func handleModifiedRequest(_ id: String){
        if let firstIndexMatchingDocId = self.requests.keys.firstIndex(where: { $0 == id })  {
            self.requests.remove(at: firstIndexMatchingDocId)
        }
    }
    
    deinit{
        listener?.remove()
    }
}

class UnreadFriendRequestsOO: ObservableObject {
    @Published var newRequest = false
    init() {
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        let docRef  = Firestore.firestore().collection("FriendRequests").document(userId.nonEmpty).collection("NewRequests").document("NewRequests")
        
        
        listener =  docRef.addSnapshotListener { [weak self] (document, error)  in
            if error != nil{
                print("there's an error FriendsDictionary.swift")
                return
            }
            
            if let document = document, document.exists {
            
                let request = document.data()?["newRequest"] as? Bool ?? false
                
                self?.newRequest = request
            }
        }
    }
    var listener: ListenerRegistration?
    deinit {
        listener?.remove()
    }
}
