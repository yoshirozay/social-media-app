//
//  SavePostFunction.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 7/26/21.
//

import SwiftUI
import Firebase
import FirebaseFunctions

class SavePostFunction: ObservableObject {
 
    func savePost(postID: String, postAuthor: String){

        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        var postInformation = [String: Any]()
        postInformation = [
            "currentUser": userId,
            "postID": postID,
            "postAuthor": postAuthor,
        ]
        
        Functions.functions().httpsCallable("savePost-savePost").call(postInformation) { (result, error) in
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
    func deleteSavedPost(postID: String, postAuthor: String){

        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        var postInformation = [String: Any]()
        postInformation = [
            "currentUser": userId,
            "postID": postID,
            "postAuthor": postAuthor,
        ]
        
        Functions.functions().httpsCallable("deleteSavedPost-deleteSavedPost").call(postInformation) { (result, error) in
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
