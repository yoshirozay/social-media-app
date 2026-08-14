//
//  ReadMessageFunctions.swift
//  speakEZ-offline (iOS)
//
//  Created by Carson O'Sullivan on 3/22/21.
//

import SwiftUI
import Firebase
import FirebaseFunctions

class ReadMessageFunctions: ObservableObject {

    func readMessage(chatUID: String){
        Self.readMessage(chatUID: chatUID)
    }
    
    class func readMessage(chatUID: String){
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        var messageInformation = [String: Any]()
            messageInformation = [
                "chatUID": chatUID,
                "currentUser": userId
            ]
            Functions.functions().httpsCallable("readMessage-readMessage").call(messageInformation) { (result, error) in
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
    
    class func markAllMessagesReadOf(chatUIDs: [String]){
        chatUIDs.forEach { id in
            Self.readMessage(chatUID: id)
        }
    }
    
}

