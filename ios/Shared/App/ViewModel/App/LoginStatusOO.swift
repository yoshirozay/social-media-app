//
//  LoginStatusOO.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 2/16/21.
//

import SwiftUI
import Firebase
import SDWebImage

class LoginOO: ObservableObject {
    @AppStorage("userUID") var userUID = ""
    init(){
       Auth.auth().addStateDidChangeListener { (auth, user) in
        if let userId =  Auth.auth().currentUser?.uid  {
            self.userUID = userId 
        } else {
//            self.myUserID = ""
          // No user is signed in.
        }
       }
    }
    func signOut() {
        try? Auth.auth().signOut()
        Self.removeAllUserData()
    }
    class func removeAllUserData(){
        SDImageCache.shared.clearDisk {
            print("cleared image cache")
        }
        VideoCacheManager.shared.removeCacheDirectory{ error in
            print(error?.localizedDescription ?? "cleared video cache")
        }
        AudioCacheManager.shared.removeCacheDirectory { error in
            print(error?.localizedDescription ?? "cleared audio cache")
        }
        TimelinePostsOO.clearAllUserDefaults()
        RealmObject.deleteAll()
        #if os(iOS)
        DynamicLinkManager.shared.clearUserDefaults()
        #endif
        NotificationTokenManager.clearUserDefaults()
        OpenedConversationNewUserChatssManager.reset()
        
    }
}
