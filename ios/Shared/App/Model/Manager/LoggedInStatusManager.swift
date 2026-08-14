//
//  LoggedInStatusManager.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/3/21.
//

import Foundation
import FirebaseAuth
class LoggedInStatusManager {
   class func checkLoggedInStatusAndUpdateIfNeeded() {
       if LoggedInStatus.isFirstLaunch {
           if let _ = Auth.auth().currentUser {
               do {
                   try Auth.auth().signOut()
               } catch {
                   print("we got problem Auth.auth().signOu t()\(error)")
                   assert(false, "try Auth.auth().signOu t()")
               }
           }
           LoggedInStatus.isFirstLaunch = true
       }
   }
     class LoggedInStatus {
       ///only call on did finish launching
       
       class  var isFirstLaunch : Bool {
           get {
               !UserDefaults.standard.bool(forKey: LoggedInStatus.Key.alreadyLoggedIn())
           }
           set {
               UserDefaults.standard.set(newValue, forKey: LoggedInStatus.Key.alreadyLoggedIn())
           }
       }
       private enum Key : String {
           case alreadyLoggedIn
       }
   }
   
}
