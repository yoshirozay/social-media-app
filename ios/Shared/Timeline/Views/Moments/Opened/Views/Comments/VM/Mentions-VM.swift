//
//  Mentions-VM.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//

import Foundation
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
                                    if id != TristanUserID {
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
}


class MentionedUserVM : ObservableObject {
    
    @Published var strangerProfile: Person?
    @Published var profileMatchedGeometry: String = ""
    
    @Published var friendProfileSelectedID: String = ""
    @Published var friendProfileMatchedGeometry: String = ""
    
    var friendsDictionary : FriendsDictionary
    
    init(friendsDictionary : FriendsDictionary) {
        self.friendsDictionary = friendsDictionary
    }
    
    func linkOrMentionTap(username: String?, link: URL?) {
        if username != "" {
            menionedTapped(username: username ?? "")
        } else if link != nil {
            print("LINK TAP")
        }
    }
    
    func menionedTapped(username : String){
        friendsDictionary.getUserOf(username: username)  {[weak self] userInfo,error  in
            if let userInfo = userInfo,let self = self{
                if userInfo.isFriend {
                    self.friendProfileSelectedID = userInfo.user.id
                    self.friendProfileMatchedGeometry = "0"
                }else{
                    self.strangerProfile = userInfo.user
                    self.profileMatchedGeometry = userInfo.user.id
                }
            }else{
                print(" friendsDictionary.getUserOf(  \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    var presentFriendProfile : Bool{
        friendProfileSelectedID.isNotEmpty && friendProfileMatchedGeometry.isNotEmpty
    }
    
    var strangerUser : Person? {
        profileMatchedGeometry.isNotEmpty ? strangerProfile :  nil
    }
    var presentTapView : Bool{
        presentFriendProfile || strangerUser != nil
    }
    func clean() {
        profileMatchedGeometry = ""
        friendProfileSelectedID = ""
        friendProfileMatchedGeometry = ""
        strangerProfile = nil
    }
}
    /*
     we need to show the profile from mentions tap from two places.
     timeline of the post in the list
     openedPo st3 comments and stuff
     */
