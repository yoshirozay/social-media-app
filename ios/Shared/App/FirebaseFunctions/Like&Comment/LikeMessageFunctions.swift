//
//  LikeMessageFunctions.swift
//  speakEZ-offline (iOS)
//
//  Created by Carson O'Sullivan on 3/29/21.
//

import SwiftUI
import Firebase
import FirebaseFunctions

class LikeMessageFunction: ObservableObject {
    func sendLike(sentBy: String, messageID: String, otherUserID: String, chatUID: String, token: String, nameOfSendingUser: String){
        var likeInformation = [String: Any]()
        likeInformation = [
            "sentBy": sentBy,
            "messageID": messageID,
            "otherUserID": otherUserID,
            "chatUID": chatUID,
            "token": token,
            "nameOfSendingUser": nameOfSendingUser
        ]
        Functions.functions().httpsCallable("likeMessage-likeMessage").call(likeInformation) { (result, error) in
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
