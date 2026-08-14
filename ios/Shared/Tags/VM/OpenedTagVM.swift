//
//  OpenedTagVM.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 3/14/22.
//

import Foundation
import SwiftUI
import Firebase

class OpenedTagOO: ObservableObject {
    @Published var people = [Person]()
    @Published var friendsDictionary : FriendsDictionary
    let post : PostModel
    init(tagIDs: [String],post : PostModel, friendsDictionary : FriendsDictionary) {
        
        self.friendsDictionary = friendsDictionary
        self.post = post
        guard let _ = currentUserID else { return }
        guard tagIDs.isNotEmpty else {
            getAuthorsFriends()
            return
        }
//        friendsDictionary.getFriendsDictionary(source: .cache) {[weak self] (friendsDictionary, error) in
         //FIXME: - we also need to consider that their can be more then one tag of a post. so we can have one user in two tags
        for tagID in tagIDs {
            guard tagID.isNotEmpty else { continue }
            let docRef = Firestore.firestore().collection("TagAccess").document(tagID.nonEmpty)
            docRef.getDocument {[weak self] (document, error) in
                guard let tagAccessDict = document?.data() as? [String: Timestamp] else {
                    return
                }
                var friends : [Person] = []
                
                tagAccessDict.keys.forEach { userId in
                    if let friend = self?.friendsDictionary.friendsDictionary[userId]{
                        friends.append(friend)
                    }else{
                        Person.fetchFriend(id: userId,source: .default)  {[weak self] user, error in
                            if let user = user{
                                self?.add(person: user)
                            }
                        }
                    }
                }
     
                self?.add(persons: friends)
            }
        }
    }
    
    func add(person : Person){
        DispatchQueue.main.async {
            self.people.append(person)
        }
    }
    
    func add(persons : [Person]){
        DispatchQueue.main.async {
            self.people.append(contentsOf: persons)
        }
    }
    
    func getAuthorsFriends(){
        let docRef = Firestore.firestore().collection("Friends").document(post.id.nonEmpty)
        docRef.getDocument {[weak self]  (document, error) in
            guard let friendIdDict = document?.data() as? [String: String] else {
                return
            }
            friendIdDict.keys.forEach { userId in
                Person.fetchFriend(id: userId,source: .default)  {[weak self] user, error in
                    if let user = user {
                        self?.add(person: user)
                        if self?.post.id == TristanUserID {
                            self?.add(person: self?.friendsDictionary.friendsDictionary[currentUserID ?? ""] ?? Person(id: ""))
                        }
                    }
                }
            }
        }
    }
}
