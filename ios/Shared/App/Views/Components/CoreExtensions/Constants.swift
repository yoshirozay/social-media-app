//
//  Constants.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 12/12/21.
//

import Foundation
import FirebaseAuth

let TristanUserID : String = "YOUR_SEED_USER_ID"
var UserDefaultPhotoWeblink : URL {
    URL(string: "https://example.com/default-avatar.png")!
//  URL(string: "https://example.com/default-avatar.png")!
}

var currentUser : User?{
   Auth.auth().currentUser
}
var currentUserID : String?{
   currentUser?.uid
}

