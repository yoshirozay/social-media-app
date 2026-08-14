//
//  LikeCommentFunctions.swift
//  speakEZ-offline (iOS)
//
//  Created by Carson O'Sullivan on 3/29/21.
//

import SwiftUI
import Firebase
import FirebaseFunctions

class LikeCommentFunction: ObservableObject {
    

    func likeComment(sentBy: String, commentID: String, postID: String, webLink: URL, postOwnerID: String, otherUserID: String, token: String, nameOfSendingUser: String){
        if postOwnerID != TristanUserID {
        var likeInformation = [String: Any]()
        likeInformation = [
            "sentBy": sentBy,
            "commentID": commentID,
            "postID": postID,
            "webLink": "\(webLink)",
            "postOwnerID": postOwnerID,
            "otherUserID": otherUserID,
            "token": token,
            "nameOfSendingUser": nameOfSendingUser
        ]
        Functions.functions().httpsCallable("likeComment-likeComment").call(likeInformation) { (result, error) in
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
}


class LikeCommentReplyFunction: ObservableObject {
    
    func likeComment(sentBy: String, originalCommentID: String, postID: String, webLink: URL, postOwnerID: String, otherUserID: String, token: String, commentID: String, nameOfSendingUser: String){
        var likeInformation = [String: Any]()
        likeInformation = [
            "sentBy": sentBy,
            "originalCommentID": originalCommentID,
            "postID": postID,
            "webLink": "\(webLink)",
            "postOwnerID": postOwnerID,
            "otherUserID": otherUserID,
            "token": token,
            "commentID": commentID,
            "nameOfSendingUser": nameOfSendingUser
        ]
        Functions.functions().httpsCallable("likeCommentReply-likeCommentReply").call(likeInformation) { (result, error) in
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
