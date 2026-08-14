//
//  SendLikeFunction.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 2/20/21.
//

import SwiftUI
import Firebase
import FirebaseFunctions

class SendLikeFunction: ObservableObject {
    func sendLike(sentBy: String, postID: String, otherUserID: String, token: String, nameOfSendingUser: String){
        var likeInformation = [String: Any]()
        likeInformation = [
            "sentBy": sentBy,
            "postID": postID,
            "otherUserID": otherUserID,
            "token": token,
            "nameOfSendingUser": nameOfSendingUser
        ]
        Functions.functions().httpsCallable("sendLike-sendLike").call(likeInformation) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    print("\(error)")
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            print("123 \(String(describing: result?.data))")

        }
    
    }
}
