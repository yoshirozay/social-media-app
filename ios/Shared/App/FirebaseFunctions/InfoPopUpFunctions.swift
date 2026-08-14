//
//  InfoPopUpFunctions.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 7/20/21.
//

import SwiftUI
import Firebase
import FirebaseFunctions

class InfoPopUpFunctions: ObservableObject {
 
    func reportUser(message: String, reportedUserID: String){

        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        var reportInformation = [String: Any]()
        reportInformation = [
            "reportID": "\(UUID())",
            "currentUser": userId,
            "reportedUserID": reportedUserID,
            "message": message.trimWhitespacesAndNewlines(),
        ]
        
        Functions.functions().httpsCallable("reportUser-reportUser").call(reportInformation) { (result, error) in
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
    func featureRequest(message: String){
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        

        var reportInformation = [String: Any]()
        reportInformation = [
            "id": "\(UUID())",
            "currentUser": userId,
            "message": message.trimWhitespacesAndNewlines(),
        ]

        Functions.functions().httpsCallable("featureRequest-featureRequest").call(reportInformation) { (result, error) in
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

//id: featureInformation["id"],
//currentUser: featureInformation["currentUser"],
//message: postInformation["message"],
