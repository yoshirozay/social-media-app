//
//  CreateTagFunctions.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 6/3/21.
//

import SwiftUI
import Firebase

class CreateTagFunction: ObservableObject,CloudFunction {
    
    func createTag(name: String, description: String, friendIDs: [String]){
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        var tagInformation = [String: Any]()
        let tagID = "\(UUID())"
        tagInformation = [
            "tagID": tagID,
            "name": name,
            "description": description,
            "createdBy": userId,
        ]
        
        Self.call(funcName: "createNewTag-createNewTag", informationDict: tagInformation ) {  ( error) in
            if  error == nil {
                let invitedFriends = friendIDs.getSet().subtracting([userId]).getArray()
                if invitedFriends.isNotEmpty{
                    Self.inviteToTag(tagID: tagID, sentTo: invitedFriends)
                }
            }else{
                //we will also need to post notification when a tags is failed so we can remove the dummy
                NotificationCenter.default.post(name: TagModel2.tagFailedNotification, object: tagID)
            }
        }
        
        let dummyTag = TagModel2(id: tagID, name: name, description: description, sentBy: "", status: .sending)
        NotificationCenter.default.post(name: TagModel2.tagNotification, object: dummyTag)
        
    }
    
    func inviteToTag(tagID: String, sentTo: [String]){
        Self.inviteToTag(tagID: tagID, sentTo: sentTo)
    }
    
   class func inviteToTag(tagID: String, sentTo: [String]){
        
        guard let userId = Auth.auth().currentUser?.uid else{
            return
        }
        
        var inviteInformation = [[String: String]]()
        
        for item in sentTo {
            
            var individualInviteInformation = [String: String]()
                    individualInviteInformation = [
                    "tagID": tagID,
                    "sentTo": item,
                    "creatorID": userId,
                ]
            
            inviteInformation.append(individualInviteInformation)
        }
        
        Self.call(funcName: "inviteToTag-inviteToTag", informationDict: inviteInformation)
    }
    
    
    func removeFromTag(tagID: String, sentTo: [String]) {
        Self.removeFromTag(tagID: tagID, sentTo: sentTo)
    }
    
    class  func removeFromTag(tagID: String, sentTo: [String]) {
         
        guard let userId = Auth.auth().currentUser?.uid  else{ return }
        let sentTo = sentTo.filter({$0 != userId})
        guard sentTo.isNotEmpty  else{
            return 
        }
        
        var inviteInformation = [[String: String]]()
        
        for item in sentTo {
            
            var individualInviteInformation = [String: String]()
                    individualInviteInformation = [
                    "tagID": tagID,
                    "sentTo": item,
                ]
            
            inviteInformation.append(individualInviteInformation)
        }
        
    
        Functions.functions().httpsCallable("removeFromTag-removeFromTag").call(inviteInformation) { (result, error) in
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
    func deleteTag(tagID: String) {
         
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        var tagInformation = [String: String]()
        
        tagInformation = [
            "tagID": tagID,
            "tagCreator": userId,
        ]
    
        Functions.functions().httpsCallable("deleteTag-deleteTag").call(tagInformation) { (result, error) in
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
    func acceptTagInvite(tagID: String, acceptingUser: String){
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        var tagInformation = [String: String]()
        tagInformation = [
            "documentID": "\(UUID())",
            "tagID": tagID,
            "acceptingUser": acceptingUser,
            "sentBy": userId,
        ]
        
        Functions.functions().httpsCallable("acceptTagInvitation-acceptTagInvitation").call(tagInformation) { (result, error) in
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

//documentID: inviteInformation["documentID"],
//         tagID: inviteInformation["tagID"],
//         acceptingUser: inviteInformation["acceptingUser"],
//         sentBy: inviteInformation["sentBy"],

//tagID: item["tagID"],
//           tagName: item["tagName"],
//           description: item["description"],
//           sentBy: item["sentBy"],
//           sentTo: item["sentTo"],
//           nameOfSendingUser: item["nameOfSendingUser"],
//           token: item["token"],
//           inviteID: item["inviteID"],
