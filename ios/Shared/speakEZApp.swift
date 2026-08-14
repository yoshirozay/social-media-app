//
//  speakEZApp.swift
//  Shared
//
//  Created by Carson O'Sullivan on 1/23/21.
//

import SwiftUI
import Firebase
import FirebaseMessaging
import FirebaseFirestore
import Combine
@main

struct speakEZApp: App {
     
    
    //MARK: - iOS
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegateIOS.self) var delegateIOS
    var body: some Scene {
            WindowGroup {
//                TestContactView()
            AppControllerWithPassword()
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        }
    }
    
   
    
#endif
    
    
    //MARK: - macOS
#if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegateMacOS.self) var appDelegateMacOS
    var body: some Scene {
        WindowGroup {
            ZStack{
               
           
            AppControllerWithPassword()
                 
//            OSLoginController(isSuccessful: false)
//                .frame(width: screenWidth/2 + screenWidth/17.92, height: screenHeight - screenHeight/13.49 )
                .frame(width:  UIScreen.width , height: screenHeight  )
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willUpdateNotification), perform: { _ in
                    hideZoomButton()
                })
//            .overlay(CompatibiltyView())
                VStack{
                    Color(#colorLiteral(red: 0.168627451, green: 0.1490196078, blue: 0.1960784314, alpha: 1) )
                     .frame( width: UIScreen.width + 2 ,  height: 30)
                      .padding(.top,-30)
                    Spacer()
                }
            }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
    func hideZoomButton() {
        for window in NSApplication.shared.windows {
            window.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isEnabled = false
        }
    }
#endif
    
   init() {
       
#if os(macOS) 
       FirebaseApp.configure()
       let settings = Firestore.firestore().settings
       settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
       Firestore.firestore().settings = settings
       
       Auth.auth().addStateDidChangeListener { (auth, user) in
           if let userId = Auth.auth().currentUser?.uid  {
               MyTagsAccessNotifier.configure(userId: userId)
           } else {
               MyTagsAccessNotifier.cancel()
           }
       }
       LoggedInStatusManager.checkLoggedInStatusAndUpdateIfNeeded()

#endif
       DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
           VideoCacheManager.shared.clearTmpDirectory()
       }
       AudioCacheManager.shared.clearTmpDirectory()
    
       DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
           FailedMessageManager.configure()
           FailedPostManager.configure()  
//           RealmUserProfile.deleteAll()
           FailedUserProfileManager.configure()
           FailedChatModelManager.configure()
       }
       
      
       RealmObject.setDefaultRealmForUser()
   }
}
 

