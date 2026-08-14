//
//  FriendRequestsFunctions.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 2/17/21.
//

import SwiftUI
import Firebase
import FirebaseFunctions
import Combine

class FriendRequestsFunctions: ObservableObject ,CloudFunction {
    func addFriend (id: String, nameOfSendingUser: String, token: String) {
        print("Adding Friend")
        var friendRequestData = [String: Any]()
        friendRequestData = [
            "id": id,
            "nameOfSendingUser": nameOfSendingUser,
            "token": token
        ]
        Functions.functions().httpsCallable("friendRequest-friendRequest").call(friendRequestData) { (result, error) in
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
    } // FUNCTION
    
    func acceptFriendRequest (id: String, nameOfSendingUser: String, token: String) {
        print("Accepting Request")
        var friendRequestData = [String: Any]()
        friendRequestData = [
            "id": id,
            "nameOfSendingUser": nameOfSendingUser,
            "token": token
        ]
        Functions.functions().httpsCallable("acceptFriendRequest-acceptFriendRequest").call(friendRequestData) { (result, error) in
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
    } // FUNCTION
    
    func deleteFriendRequest (id: String) {
        print("Deleting Request")
        Functions.functions().httpsCallable("cancelFriendRequest-cancelFriendRequest").call([id]) { (result, error) in
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
    func declineFriendRequest (id: String) {
        print("Rejecting Request")
        Functions.functions().httpsCallable("deleteFriendRequest-deleteFriendRequest").call([id]) { (result, error) in
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
  
        func deleteFriend(deletedUserID: String){
           
            guard let userId = Auth.auth().currentUser?.uid, TristanUserID != deletedUserID else{ return }
            
            RealmRawMessage.deleteAllMessagesOf(otherUserID: deletedUserID)
            var deleteInfo = [String: Any]()
                deleteInfo = [
                    "deletedUser": deletedUserID,
                    "currentUser": userId
                ]
            if deletedUserID != "ctgg158KOnajMBuFZ5GyHLyRYPE3" || deletedUserID != userId {
                Functions.functions().httpsCallable("deleteFriend-deleteFriend").call(deleteInfo) { (result, error) in
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
    func readFriendRequest(){
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        var requestInfo = [String: Any]()
        requestInfo = [
                "id": userId
            ]
            Functions.functions().httpsCallable("readFriendRequests-readFriendRequests").call(requestInfo) { (result, error) in
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
    
//    I made the function createUserChat-createUserChat, you need to send it the current user, a UUID() for chatUID, and the otherUserID
    class func createUserChat(currentUserId: String,
                                   otherUserID : String,
                                   callback: @escaping (Error?) -> Void = {_ in }){
     
        let informationDict : [String : Any] =
        [Constant.currentUser() : currentUserId,
         Constant.chatUID() : UUID().uuidString,
         Constant.otherUserID(): otherUserID]
        Self.call(funcName: Constant.createUserChatFuncName(), informationDict: informationDict, callback: callback)
    }
    
    enum Constant : String{
        case createUserChatFuncName = "createUserChat-createUserChat"
        case currentUser
        case chatUID
        case otherUserID
    }
}
 
