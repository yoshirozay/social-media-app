//
//  SettingsFunctions.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 6/27/21.
//

import SwiftUI
import Firebase
import FirebaseFunctions

class SettingFunctions: ObservableObject {
 
    func friendsListPreference(preference: Bool){

        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        var settingsInfo = [String: Any]()
        settingsInfo = [
            "friendsListView": preference,
            "uid": userId,
        ]
        
        Functions.functions().httpsCallable("friendsListPreference-friendsListPreference").call(settingsInfo) { (result, error) in
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
