//
//  ProfileCircleFunctions.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 9/1/21.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFunctions

class ProfileCircleFunctions: ObservableObject {
 
    func updateProfileCircle(color: String){
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        var circleColor = color
        var circleInformation = [String: Any]()
        if color == "NamedColor(name: \"mainColor\", bundle: nil)" {
            circleColor = "black"
        }
        if color == "NamedColor(name: \"speakerBlue\", bundle: nil)" {
            circleColor = "aqua"
        }
        print("COLOR = \(color)")
        circleInformation = [
            "currentUser": userId,
            "color": circleColor,
        ]
        
        Functions.functions().httpsCallable("updateProfileCircle-updateProfileCircle").call(circleInformation) { (result, error) in
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
