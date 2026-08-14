//
//  NotificationTokenManager.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/9/21.
//
  
import Firebase
import FirebaseFunctions
import FirebaseAuth

class NotificationTokenManager {
    
    static let shared  = NotificationTokenManager()
    
    var appFcmToken : String = "" {
        didSet{
                DispatchQueue.main.async { self.updateUserTokenIfExpired()  }
        }
    }
    
    var userFcmToken : String = "" {
        didSet{
                DispatchQueue.main.async { self.updateUserTokenIfExpired()  }
        }
    }
     
    var didUpdate = false
    func updateUserTokenIfExpired() {
        guard let userId = Auth.auth().currentUser?.uid,
              userFcmToken.isNotEmpty,
              appFcmToken.isNotEmpty,
              userFcmToken != appFcmToken,
             !didUpdate else { return }
        print("updateNotificationTokenCloudFunc userId  \(userId)")
        didUpdate = true
        EditProfileFunction.updateNotificationTokenCloudFunc(newToken: self.appFcmToken, userId: userId){ error in
            if  let error = error {
                print("error updateNotificationIfExpired\(error.localizedDescription)")
            }
        }
    }
     
    class func clearUserDefaults() {
        shared.appFcmToken = ""
        shared.userFcmToken = ""
        shared.didUpdate = false
    } 
}

var notificationToken = ""
func getToken(token: String) {
    notificationToken = token
    NotificationTokenManager.shared.appFcmToken = token
}
