//
//  MutualFriendsOO.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 5/31/21.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import Combine

class MutualFriendsOO: ObservableObject {
    @Published var mutualFriends = [String:Person]()
    @Published var friendsDictionary = FriendsDictionary()
    var anyCancellable: AnyCancellable? = nil
    init(id: String, tagMembers: [Person]){
        anyCancellable = friendsDictionary.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                
                let docRef = Firestore.firestore().collection("Friends").document(id.nonEmpty)
                docRef.getDocument { (document, error)  in
                    if let document = document, document.exists {
                        let dataDescription = document.data() as? [String: String] ?? ["":""]
                        for item in dataDescription.keys {
                            if tagMembers.firstIndex(where: {$0.id == item}) != nil || tagMembers.isEmpty {
                                if let person = self?.friendsDictionary.friendsDictionary[item]  {
                                    let username = person.username
                                    let name = person.name
                                    let bio = person.bio
                                    let imageurl = person.imageurl
                                    let token = person.token
                                    let id = person.id
                                    let webLink = person.webLink
                                    let accountCreationDate = person.accountCreationDate
                                    let profileCircle = person.profileCircle
                                    
                                    self?.mutualFriends[item] = Person(id: id, username: username, name: name, bio: bio, imageurl: imageurl, webLink: webLink, token: token, accountCreationDate: accountCreationDate, profileCircle: profileCircle)
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
}

