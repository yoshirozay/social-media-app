//
//  ShareFriendFunction.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 6/27/21.
//

import SwiftUI
import Firebase
import FirebaseFunctions

class ShareFriendFunction: ObservableObject {
    @Published var friendsDictionary = FriendsDictionary()

    func shareFriend(friendIDs: [String], sharedFriendID: String){
       
        guard let userId = Auth.auth().currentUser?.uid  else{ return }
 
        
        friendsDictionary.getFriendsDictionary(source: .cache) { (friendsDictionary, error) in
        var notificationInfo = [[String: Any]]()
        var temporaryNotificationInfo = [String: Any]()
            for item in friendIDs {
                if item != "" {
                    temporaryNotificationInfo = [
                        "id": "\(UUID())",
                        "resourceID": "sharedF:\(sharedFriendID)",
                        "sentFromUser": userId,
                        "nameOfSendingUser": friendsDictionary[userId]?.name ?? "",
                        "sentTo": item,
                        "sharedFriendID": sharedFriendID,
                        "nameOfSharedFriend": friendsDictionary[sharedFriendID]?.name ?? "",
                        "token": friendsDictionary[item]?.token ?? "",
                    ]
                    if let webLink = (friendsDictionary[userId]?.webLink?.absoluteString){
                        temporaryNotificationInfo["webLink"] = webLink
                    }
                    notificationInfo.append(temporaryNotificationInfo)
                }
            }
        Functions.functions().httpsCallable("shareFriend-shareFriend").call(notificationInfo) { (result, error) in
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

//const newNotificationInformation = {
//         id: item["id"],
//         resourceID: item["resourceID"],
//         sentFromUser: item["sentFromUser"],
//         nameOfSendingUser: item["nameOfSendingUser"],
//         sentTo: item["sentTo"],
//         webLink: item["webLink"],
//         nameOfSharedFriend: item["nameOfSharedFriend"],
//         createdAt: new Date(),
//         token: item["token"],
//       };
//}
