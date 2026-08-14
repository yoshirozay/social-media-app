//
//  ProfilePreferences.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 4/23/22.
//

import Foundation
import SwiftUI
import Firebase


class ProfilePreferencesOO: ObservableObject, CloudFunction {
    @Published var anonymousMode = Bool()
    @Published var momentNotifications = Bool()
    var listener: ListenerRegistration?
    var listener2: ListenerRegistration?
    init() {
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        let collectionRef = Firestore.firestore().collection("UserInfo").document(userId.nonEmpty)
        listener = collectionRef.addSnapshotListener {[weak self] (docSnapshot, error)  in
            guard error == nil,
                  let userDocumentData = docSnapshot?.data(),
                  (docSnapshot?.get("username") != nil) else {
                      return
                  }
             self?.anonymousMode =  userDocumentData["anonymousMode"]  as? Bool ?? false

        }
        
        let collectionRef2 = Firestore.firestore().collection("UserInfo").document(userId.nonEmpty).collection("Settings").document("Preferences")
        listener2 = collectionRef2.addSnapshotListener {[weak self] (docSnapshot, error)  in
            guard error == nil,
                  let userDocumentData = docSnapshot?.data(),
                  (docSnapshot?.get("momentNotifications") != nil) else {
                      return
                  }
             self?.momentNotifications =  userDocumentData["momentNotifications"] as? Bool ?? true
        }
    }
//    func updateAnonymousMode(anonymous: Bool) {
//        self.anonymousMode = anonymous
//    }
    static func updateMomentNotification(momentNotifications: Bool = true, callback : @escaping (  _  error : Error?) -> Void = {_ in}){
        print("Updating MomentNotification")
        guard let userId = Auth.auth().currentUser?.uid else{ return }


        var profileInformation = [String: Any]()
        profileInformation = [
            "uid": userId,
            "momentNotifications": momentNotifications,
        ]
        ProfilePreferencesOO.updateMomentNotificationCloudFunc(profileInformation: profileInformation){ error in
                    callback(error)
                }
    }
    static func updateAnonymousMode(anonymousMode: Bool = false, callback : @escaping (  _  error : Error?) -> Void = {_ in}){
        print("Updating Anonymous")
        guard let userId = Auth.auth().currentUser?.uid else{ return }


        var profileInformation = [String: Any]()
        profileInformation = [
            "uid": userId,
            "anonymousMode": anonymousMode,
        ]
        ProfilePreferencesOO.updateAnonymousModeCloudFunc(profileInformation: profileInformation){ error in
                    callback(error)
                }
    }
    class func updateAnonymousModeCloudFunc(profileInformation: [String : Any],callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        print(profileInformation)
        Self.call(funcName: Constant.updateAnonymousMode(), informationDict: profileInformation,callback: callback)
    }
    class func updateMomentNotificationCloudFunc(profileInformation: [String : Any],callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        print(profileInformation)
        Self.call(funcName: Constant.updateMomentNotification(), informationDict: profileInformation,callback: callback)
    }
    enum Constant : String {
        case updateAnonymousMode = "updateAnonymousMode-updateAnonymousMode"
        case updateMomentNotification = "updateMomentNotification-updateMomentNotification"
    }
    deinit {
        listener?.remove()
        listener2?.remove()
    }
}
