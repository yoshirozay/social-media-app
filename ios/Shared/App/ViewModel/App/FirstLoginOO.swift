//
//  FirstLoginOO.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 2/13/21.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine


class FirstLoginOO: ObservableObject {
    var accountHasBeenCreated: Bool{
        profileHasBeenCreated ?? true
    }
    @Published var profileHasBeenCreated: Bool?
    @Published var showVerifyPhoneAlert = false
    var listener: ListenerRegistration?
    
    init(){
        guard let userId = currentUserID else{ return }
        let docRef = Firestore.firestore().collection("UserInfo").document(userId.nonEmpty)
        docRef.getDocument(source: .cache){[weak self] (docSnap, error) in
            if error == nil,
               let userLoginInfo = try? docSnap?.data(as: UserLoginInfo.self) {
                if userLoginInfo.createdProfile ?? true {
                    self?.checkUserLoginStatus(userLoginInfo: userLoginInfo,isFromCache: true)
                } else {
                    self?.profileHasBeenCreated = false
                    self?.addUserInfoListener()
                }
            }else {
                self?.profileHasBeenCreated = false
                self?.addUserInfoListener()
            }
         
        }
    }
    
    func addUserInfoListener() {
        guard let userId = currentUserID else { return }
        let docRef = Firestore.firestore().collection("UserInfo").document(userId.nonEmpty)
 
        listener = docRef.addSnapshotListener{[weak self] (docSnap, error) in
            guard  error == nil,
                  let userLoginInfo = try? docSnap?.data(as: UserLoginInfo.self) else {
                print( error?.localizedDescription ?? "there's an error FirstLoginOO.swift or with userLoginInfo")
                return
            }
            self?.checkUserLoginStatus(userLoginInfo: userLoginInfo)
 
            
//            if error != nil{
//                print("there's an error FirstLoginOO.swift")
//                return
//            }
//            var profileHasBeenCreated = documentSnapshot?.get("createdProfile") as? Bool ?? false
//            profileHasBeenCreated = documentSnapshot?.get("webLink") as? String != nil
//            self?.accountHasBeenCreated = profileHasBeenCreated
//            if profileHasBeenCreated {
//#if os(iOS)
//                DynamicLinkManager.shared.createAndSaveDynamicLinkIfNotExist()
//#endif
//                if let phoneNumber = currentUser?.phoneNumber {
//                    if (documentSnapshot?.get("phoneNumber") as? String) == nil {
//                        EditProfileFunction.updatePhoneNumberOf(userId: userId, phoneNumber: phoneNumber)
//                    }
//                }else{
//                    if Self.shouldShowVerifyAlert {
//                        self?.showVerifyPhoneAlert = true
//                    }
//                }
//            }
        }
    }
    
    func checkUserLoginStatus(userLoginInfo: UserLoginInfo,isFromCache: Bool = false) {
        let profileHasBeenCreated = userLoginInfo.profileHasBeenCreated
        if profileHasBeenCreated {
#if os(iOS)
            DynamicLinkManager.shared.createAndSaveDynamicLinkIfNotExist(isAnEvent: false)
#endif
            if let phoneNumber = currentUser?.phoneNumber {
                if userLoginInfo.phoneNumber == nil,
                   let userId = currentUserID {
                    EditProfileFunction.updatePhoneNumberOf(userId: userId, phoneNumber: phoneNumber)
                }
            }else if !isFromCache, Self.shouldShowVerifyAlert {
                showVerifyPhoneAlert = true
            }
        }
        self.profileHasBeenCreated = profileHasBeenCreated
    }
    
    class var shouldShowVerifyAlert: Bool {
        get {
            let nextTimeToShowAlert = verifyAlertIntervals + UserDefaults.standard.double(forKey: Key.lastTimePhoneVerifyAlertWasShown.rawValue)
            let val = Date(timeIntervalSince1970: nextTimeToShowAlert) <= Date()
            Self.shouldShowVerifyAlert = val
            return val
        }
        set {
            if newValue{
                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: Key.lastTimePhoneVerifyAlertWasShown.rawValue)
            }
        }
    }
    enum Key : String {
        case lastTimePhoneVerifyAlertWasShown
    }
    static var verifyAlertIntervals : Double {
         //FIXME: - uncomment it after testing
        (86400*7)
//        (100)
    }
    deinit {
        listener?.remove()
    }
    
    struct UserLoginInfo: Codable {
        var createdProfile: Bool?
        var webLink: String?
        var phoneNumber: String?
        var profileHasBeenCreated : Bool{
            createdProfile == true && webLink != nil
        }
    }
}


