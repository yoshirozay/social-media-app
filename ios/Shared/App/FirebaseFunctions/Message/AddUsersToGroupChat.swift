//
//  AddUsersToGroupChat.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 12/22/21.
//

import Foundation
import SwiftUI
import FirebaseFunctions
import Firebase
class AddUsersToGroupChatFunction: ObservableObject {
    func addUsersToGroupChat(newGroupChatUsers: [String], groupChatName: String, currentGroupChatUsers: [Person], chatUID: String){
        var currentGroupChatUserIDs = [String]()
        
        for item in currentGroupChatUsers {
            currentGroupChatUserIDs.append(item.id)
        }
//        for item in
        var allUsers: [String]
        allUsers = currentGroupChatUserIDs
        
        for item in newGroupChatUsers {
            let firstIndex = allUsers.firstIndex(of: item)
            if firstIndex == nil {
            allUsers.append(item)
            }
        }
        
//        let notificationInfo = notificationInformation
        let users = allUsers

        let name = groupChatName

        var messageInformation = [String: Any]()
        messageInformation = [
            "users": users,
            "name": name,
            "chatUID": chatUID
        ]
        Functions.functions().httpsCallable("addUsersToGroupChat-addUsersToGroupChat").call(messageInformation) { (result, error) in
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


//chatUID: messageInformation["chatUID"],
//          users: messageInformation["users"],
//          name: messageInformation["name"],
