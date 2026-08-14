//
//  AppDelegate.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/3/21.
//


import SwiftUI
import Firebase
import FirebaseMessaging
import FirebaseFirestore
import Combine
import UIKit
import Siren
import AVFoundation
import Contacts
import SDWebImage
 
class AppDelegateIOS: NSObject, UIApplicationDelegate, ObservableObject {
    var cancelSet = Set<AnyCancellable>()
    let gcmMessageIDKey = "gcm.message_id"
    
    func application (_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        

        FirebaseApp.configure()
        
//        Firestore.firestore().clearPersistence { error in
//            print("Firestore.firestore().clearPersistence \(error.descriptionIfAny)")
//        }
        let settings = Firestore.firestore().settings
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        Firestore.firestore().settings = settings
//      try!  Auth.auth().signOut()
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = Bundle.main.bundleIdentifier
        Messaging.messaging().delegate = self
  
 
          UNUserNotificationCenter.current().delegate = self
//          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//
//          UNUserNotificationCenter.current().requestAuthorization(
//            options: authOptions,
//            completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
//        UIApplication.shared.applicationIconBadgeNumber = 19

        
        //FIXME:  - we need to clearTmpDirectory when user does not remove the selected media from its respective view. for now we will clear it on every lanch.
        
        TutorialManager.shared.restartIfNotCompleted()
//        TutorialManager.shared.start()
//        DynamicLinkManager.shared.createShortDynamicLinkURL(currentUserId: Auth.auth().currentUser?.uid) { url, error in
//            print("createShortDynamicLinkURL = ",url)//https://speakez.cloud/H7aMjdSYuH1G5jwEA
//            print("createShortDynamicLinkURL error = ",error)
//        }

            UICollectionView.appearance().backgroundColor = .clear
//            UICollectionView.appearance().frame = .self
//            if #available(iOS 16.0, *) {
////                UICollectionLayoutListConfiguration(appearance: .sidebar).headerTopPadding = 0
//                var layoutConfig = UICollectionLayoutListConfiguration(appearance: .sidebar)
////                layoutConfig.headerMode = .supplementary
//                layoutConfig.headerTopPadding = 0
//                let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
//                UICollectionView.appearance().collectionViewLayout = listLayout
//            } else {
//                // Fallback on earlier versions
//            }
            UITextView.appearance().backgroundColor = .clear
            UITableView.appearance().backgroundColor = .clear
            UITableView.appearance().showsVerticalScrollIndicator = false
//        UIScrollView.appearance().showsVerticalScrollIndicator = false
//        UIScrollView.appearance().bounces = iOS15 ? false : true
              showAlertOfNewUpdateIfAvailabel()
        DeviceOrientationManager.deviceOrientationPublisher
           .sink() {[weak self] deviceOrientation in
               self?.orientationLock = deviceOrientation
           }
           .store(in: &cancelSet)
         
        
        
        authListener =  Auth.auth().addStateDidChangeListener {(auth, user) in
            if let userId = Auth.auth().currentUser?.uid  {
                MyTagsAccessNotifier.configure(userId: userId)
            } else {
                MyTagsAccessNotifier.cancel()
                LoginOO.removeAllUserData()
            }
        }
//        PostEditing.postEditScript()
//        UserContactsVM.fetchFriend()
//
        LoggedInStatusManager.checkLoggedInStatusAndUpdateIfNeeded()
        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber == 0 ? 1 : 0
        return true
    }
    var authListener : AuthStateDidChangeListenerHandle?
    
 
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // do somewith with message data here
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }
      print(userInfo)
//        if Auth.auth().canHandleNotification(userInfo) {
//                completionHandler(.noData)
//                return
//            }
      completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func parseDynamicLink(dynamicLink:DynamicLink) -> (imageURL : URL,name : String)?{
        
        guard let url = dynamicLink.url else {
            print("not url exist")
            return nil
        }
        print(" url exist =",url)
         
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        if let name = queryItems?[0].value, let imageURLString = queryItems?[1].value , let imageURL = URL(string: imageURLString){
                return (imageURL : imageURL, name : name)
            }
        
       return nil
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL{
            print("incomingURL =",incomingURL)
           let linkHandler = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLink, error in
                if let dynamicLink = dynamicLink{
                    self.parseDynamicLink(dynamicLink:dynamicLink)
                }else{

                }
            }
            return linkHandler
        }
         return false
    }


    func showAlertOfNewUpdateIfAvailabel() {
        let siren = Siren.shared
        let rules = Rules(promptFrequency: .weekly, forAlertType: .skip)
        siren.rulesManager = RulesManager(globalRules: rules)
        siren.wail()
        siren.presentationManager = PresentationManager(alertTitle: "Update Available"
                                                        ,  alertMessage : "An updated version of speakEZ is availbale on the AppStore"
                                                        , nextTimeButtonTitle: "Next time"
                                                        , skipButtonTitle: "Skip")
        siren.wail { results in
            switch results {
            case .success(let updateResults):
                print("AlertAction ", updateResults.alertAction)
                print("Localization ", updateResults.localization)
                print("Model ", updateResults.model)
                print("UpdateType ", updateResults.updateType)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
        
    var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        orientationLock
    }
}

extension AppDelegateIOS: MessagingDelegate {
  
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("fcmToken: ", (fcmToken ?? "token not found"))
        if let fcmToken = fcmToken {
//            let testToken = fcmToken  + "start-" + String(Int.random(in: 0...100000) ) + "-end "
//            print("our testToken: ", fcmToken  )
            print("TOKEN = \(fcmToken)")
            getToken(token: fcmToken )
        }
    }
}


 
extension AppDelegateIOS : UNUserNotificationCenterDelegate,PNViewManagerCheckAble {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      ///will be remove it is only for testing as the didReceive func did not get called from simulator
      // Do something with message data
      if let messageID = notification.request.content.userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
      }
      
      if shouldHidePN(content: notification.request.content) == false {
//          completionHandler([[.banner, .badge, .sound]])
      }else{
          print("View is already opened No Need for PN")
      }
  }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        PushNotificationVM.publisher.send(response.notification.request.content)
        completionHandler()
    }
}
  

 

 



 
