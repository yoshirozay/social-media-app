//
//  LeaveGroupChat.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 12/22/21.
//

import Foundation
import SwiftUI
import FirebaseFunctions
import Firebase
class LeaveGroupChatFunction: ObservableObject {
    func leaveGroupChat(groupChatUsers: [Person], chatUID: String, usersWhoLeftGroupChat: [String]){
        
        guard let userId = currentUserID else{ return }
        
//        let notificationInfo = notificationInformation
        var currentGroupChatUserIDs = [String]()
        
        for item in groupChatUsers {
            if item.id != userId {
            currentGroupChatUserIDs.append(item.id)
            }
        }
        let users = currentGroupChatUserIDs

        var usersWhoLeft = [String]()
        usersWhoLeft = usersWhoLeftGroupChat
        usersWhoLeft.append(currentUserID ?? "")
        
        var messageInformation = [String: Any]()
        messageInformation = [
            "currentUser": currentUserID ?? "",
            "chatUID": chatUID,
            "users": users,
            "usersWhoLeft": usersWhoLeft
        ]
        
        Functions.functions().httpsCallable("leaveGroupChat-leaveGroupChat").call(messageInformation) { (result, error) in
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
//currentUser: messageInformation["currentUser"],
//chatUID: messageInformation["chatUID"],
//usersWhoLeft: messageInformation["usersWhoLeft"],
//users: messageInformation["users"],
