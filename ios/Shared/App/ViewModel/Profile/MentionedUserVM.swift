//
//  MentionedUserVM.swift
//  speakEZ
//
//  Created by Ahmad naeem on 2/17/22.
//

import Foundation

class MentionedUserVM : ObservableObject {
    
    @Published var strangerProfile: Person?
    @Published var profileMatchedGeometry: String = ""
    
    @Published var friendProfileSelectedID: String = ""
    @Published var friendProfileMatchedGeometry: String = ""
    
    var friendsDictionary : FriendsDictionary
    
    init(friendsDictionary : FriendsDictionary) {
        self.friendsDictionary = friendsDictionary
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
