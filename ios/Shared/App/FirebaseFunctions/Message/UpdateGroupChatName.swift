//
//  UpdateGroupChatName.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 12/22/21.
//
import Foundation
import SwiftUI
import FirebaseFunctions
import Firebase
class UpdateGroupChatName: ObservableObject {
    func updateGroupChatName(groupChatUsers: [Person], chatUID: String, groupChatName: String){
        
        
//        let notificationInfo = notificationInformation
        var currentGroupChatUserIDs = [String]()
        
        for item in groupChatUsers {
            currentGroupChatUserIDs.append(item.id)
        }
        let users = currentGroupChatUserIDs

        
        var messageInformation = [String: Any]()
        messageInformation = [
            "chatUID": chatUID,
            "users": users,
            "name": groupChatName

        ]
        
        Functions.functions().httpsCallable("updateGroupChatName-updateGroupChatName").call(messageInformation) { (result, error) in
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
//           users: messageInformation["users"],
//           name: messageInformation["name"],
