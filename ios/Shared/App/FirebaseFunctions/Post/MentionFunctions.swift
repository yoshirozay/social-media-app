//
//  MentionFunctions.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 5/31/21.
//

import SwiftUI
import FirebaseFunctions
import Firebase
import Combine

class MentionFunctions: ObservableObject {
    @Published var friendsDictionary = FriendsDictionary()
    
    private var mentionedInformation = [MentionNotification]()
    
    func getMentionedFriendsInfo (mentionedIDs: [String], postID: String, originalAuthor: String) {
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        friendsDictionary.getFriendsDictionary(source: .cache) {[weak self] (friendsDictionary, error) in
            
            for item in mentionedIDs {
                self?.mentionedInformation.append(MentionNotification(id: "\(UUID())", resourceID: postID, sentBy: userId, sentTo: item, token: self?.friendsDictionary.friendsDictionary[item]?.token ?? "", nameOfSendingUser: self?.friendsDictionary.friendsDictionary[userId]?.name ?? "", originalAuthor: originalAuthor))
            }
        }
    }
    
    func postMentionFunction(mentionedIDs: [String], postID: String, originalAuthor: String){
        
        getMentionedFriendsInfo(mentionedIDs: mentionedIDs, postID: postID, originalAuthor: originalAuthor)
        
        Functions.functions().httpsCallable(Constant.postMentionFunc()).call(self.mentionedInformation) { (result, error) in
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            self.mentionedInformation.removeAll()
            }

        }
    
    }
    func commentMentionFunction(mentionedIDs: [String], postID: String, originalAuthor: String){
        
        getMentionedFriendsInfo(mentionedIDs: mentionedIDs, postID: postID, originalAuthor: originalAuthor)
        
        Functions.functions().httpsCallable(Constant.postMentionFunc()).call(self.mentionedInformation) { (result, error) in
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            self.mentionedInformation.removeAll()
            }
        }
    }
}

extension MentionFunctions : CloudFunction {
    enum Constant : String {
        case postMentionFunc = "postMention-postMention"
        case commentMentionFunc = "commentMention-commentMention"
    }
    class func sendMentions(informationDict : [[String : String]], callback: @escaping (Error?) -> Void = {_ in }){
        Self.call(funcName: Constant.postMentionFunc(), informationDict: informationDict,callback: callback)
    }
}

