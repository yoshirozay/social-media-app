//
//  ReportPostFunction.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 7/16/21.
//


import SwiftUI
import Firebase
import FirebaseFunctions

class ReportPostFunction: ObservableObject {
 
    func reportPost(content: String, postID: String, reportedUser: String){

        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        var reportInformation = [String: Any]()
        reportInformation = [
            "sentBy": userId,
            "content": content,
            "postID": postID,
            "reportedUser": reportedUser
        ]
        
        Functions.functions().httpsCallable("reportPost-reportPost").call(reportInformation) { (result, error) in
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

//sentBy: reportInformation["sentBy"],
//     content: reportInformation["content"],
//     postID: reportInformation["postID"],
//     reportedUser: reportInformation["reportedUser"]
