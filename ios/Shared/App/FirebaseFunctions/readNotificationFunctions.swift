//
//  readNotificationFunctions.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 2/23/21.
//

import SwiftUI
import FirebaseFunctions

class ReadNotificationFunction: ObservableObject {
    
    func readNotification(notificationInformation: [[String:String]]) {
        ReadNotificationFunction.readNotification(notificationInformation: notificationInformation)
    }
    
    class func readNotification(notificationInformation: [[String:String]]) {
        let notificationInfo = notificationInformation
        Functions.functions().httpsCallable("readNotification-readNotification").call(notificationInfo) { (result, error) in
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

