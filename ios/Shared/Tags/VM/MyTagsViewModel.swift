//
//  MyTagsViewModel.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 6/3/21.
//

import SwiftUI
import Firebase

class MyTagsOO: ObservableObject {
    @Published var tags = [String: TagModel2]()
    private func setTagDictionary(_ dictionary: [String: TagModel2]) {
        tags = dictionary
    }
    init() {
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        let docRef = Firestore.firestore().collection("MyTags").document(userId.nonEmpty)
        listener = docRef.addSnapshotListener {[weak self] (document, error) in
            if let document = document, document.exists,
               let dataDescription = document.data() as? [String: Timestamp]{
                 
                var temporaryTags = [String: TagModel2]()
                
                for item in dataDescription.keys {
                    let secondDocRef = Firestore.firestore().collection("Tags").document(item.nonEmpty)
                    
                    self?.listener2 = secondDocRef.addSnapshotListener { [weak self]  (documentSnapshot, error)  in
                        if error != nil{
                            print("there's an error MyTagsViewModel.swift")
                            return
                        }
                        
                        guard let tagData = documentSnapshot?.data() else {
                            return
                        }
                        
                        TagModel2.getTagFromTagID(tagID: item, documentData: tagData) {[weak self] (newTag, error) in
                            if let tag = newTag {
                                temporaryTags[tag.id] = tag
                                if temporaryTags.count == dataDescription.count {
                                    self?.setTagDictionary(temporaryTags)
                                }
                            }else{
                                print(error?.localizedDescription ?? "")
                            }
                        }
                    }
                }
                
            }
        }
    }
    func createTag(id: String, name: String, description: String) {
        tags[id] = TagModel2(id: id, name: name, description: description, sentBy: "")
    }
    
    var listener: ListenerRegistration?
    var listener2: ListenerRegistration?
    deinit {
        listener?.remove()
        listener2?.remove()
    }

}

class MyTagsAccessOO: ObservableObject {
    @Published var tags = [String]()

    init() {
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        let docRef = Firestore.firestore().collection("MyTagsAccess").document(userId.nonEmpty)
       listener = docRef.addSnapshotListener {[weak self] (document, error) in
            if let dict = document?.data() {
                let fetchedTags : [String] = dict.compactMap{  ($0.value as? String ) == nil ? nil : $0.key }
                for item in fetchedTags {
                    self?.tags.append(item)
                }
            }
        }
    }
    
    var listener: ListenerRegistration?
    deinit {
        listener?.remove()
    }

}

class MyTagInvitationsOO: ObservableObject {
    @Published var tags = [String: TagModel2]()
    private func setTagDictionary(_ dictionary: [String: TagModel2]) {
        tags = dictionary
    }
    init() {
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        let docRef = Firestore.firestore().collection("TagInvitations").document(userId.nonEmpty).collection("Invites")
      listener =  docRef.addSnapshotListener() { [weak self] (snap, error) in
            guard let documentChanges = snap?.documentChanges, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            for documentChange in documentChanges {
                if documentChange.type == .added {
                    let document = documentChange.document
                    
                    let tagID = document.data()["tagID"] as? String ?? ""
                    let tagName = document.data()["tagName"] as? String ?? ""
                    let description = document.data()["description"] as? String ?? ""
                    let sentBy = document.data()["sentBy"] as? String ?? ""
                    self?.tags[tagID] = TagModel2(id: tagID, name: tagName, description: description, sentBy: sentBy)
                    
                }
                
            }
        }
    }
    func createTag(id: String, name: String, description: String) {
        tags[id] = TagModel2(id: id, name: name, description: description, sentBy: "")
    }
    
    var listener: ListenerRegistration?
    deinit {
        listener?.remove()
    }

}

class TagFriendsOO: ObservableObject {
    @Published var friendIDs = [String]()
    @Published var friendsDictionary = FriendsDictionary()
    @Published var firstSevenFriendIDs = [String]()
    var listener : ListenerRegistration?
    init(tagID: String) {
        friendsDictionary.getFriendsDictionary(source: .cache) {[weak self] (friendsDictionary, error) in
            let docRef = Firestore.firestore().collection("TagAccess").document(tagID.nonEmpty)
            self?.listener = docRef.addSnapshotListener() {[weak self] (document, error) in
                if  let dataDescription = document?.data() as? [String: Timestamp] {
                    guard let self = self else { return  }
                    
                    let allowedFriendIds : Set<String> = dataDescription.keys.filter({self.friendsDictionary.friendsDictionary[$0] != nil}).getSet()
                    self.friendIDs = allowedFriendIds.getArray().sorted()
                    for item in self.friendIDs {
                        if self.firstSevenFriendIDs.count < 8 {
                            self.firstSevenFriendIDs.append(item)
                        }
                    }
                }
            }
        }
    }
    
    func removeFriend(id : String) {
        if let index = friendIDs.firstIndex(of: id){
            friendIDs.remove(at: index)
        }
        if let index = firstSevenFriendIDs.firstIndex(of: id){
            firstSevenFriendIDs.remove(at: index)
        }
    }
    func addFriend(id : String) {
        friendIDs.append(id)
        firstSevenFriendIDs.append(id)
    }
    deinit {
        listener?.remove()
    }
}

class TagInviteFriendsOO: ObservableObject {
    @Published var friendIDs = [String]()
    @Published var friendsDictionary = FriendsDictionary()
    init(tagID: String) {
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        friendsDictionary.getFriendsDictionary(source: .cache) {[weak self] (friendsDictionary, error) in
            
            let docRef = Firestore.firestore().collection("MyTags").document(userId.nonEmpty).collection("Invites").document(tagID.nonEmpty)
            docRef.getDocument {[weak self] (document, error) in
                if let document = document, document.exists,
                   let dataDescription = document.data() as? [String: Timestamp]{
                    for item in dataDescription.keys {
                        if self?.friendsDictionary.friendsDictionary[item] != nil {
                            self?.friendIDs.append(item)
                        }
                    }
                }
            }
            
            
        }
    }
}

