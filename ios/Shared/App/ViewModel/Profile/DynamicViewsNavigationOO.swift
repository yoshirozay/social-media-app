//
//  SharedPersonOO.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/11/21.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine
import SDWebImage.SDWebImageManager

class DynamicViewsNavigationOO: ObservableObject {
    @Published var person : Person?
    @Published var didGetDynamicLink = false
    @Published var event = EventModel(id: "")
    var listener : AuthStateDidChangeListenerHandle?
    ///this func will only be called if the user is not logged in
    func addUserSigninListener(userId : String){
        SecretPasswordFunction.setDynamiclinkAsSecretPasswordIfNone()
        listener = Auth.auth().addStateDidChangeListener {[weak self] (auth, user) in
            if let _ = user {
                self?.fetchPerson(userId : userId)
                self?.removeListnener()
            }
        }
    }
   
    func fetchPerson(userId : String) {
        
        guard let _ = Auth.auth().currentUser?.uid else {
            addUserSigninListener(userId : userId)
            return
        }
        
        Firestore.firestore()
            .collection("UserInfo")
            .document(userId.nonEmpty)
            .getDocument { (doc, error)  in
            guard let userDocData = doc?.data(),
                  userDocData["username"] != nil,
                  error == nil else {
                return
            }
            Person.getPersonFromUserInfo(documentData: userDocData) {[weak self] (fetchedUser, error) in
                if let fetchedUser = fetchedUser {
                    self?.person = fetchedUser
                    self?.didGetDynamicLink = true
                    if let photoURL = fetchedUser.profilePicLink{
                        SDWebImageManager.shared.loadImage(with: photoURL,  progress: nil) { _, _, _, _, _, _ in }
                    }
                }else{
                    print(error?.localizedDescription ?? "")
                }
            }
        }
    }
    func getEventDetails(eventID: String) {
        let docRef = Firestore.firestore().collection("AllEvents").document(eventID)
        docRef.getDocument {[weak self] (document, error) in
            let dict = document?.data()
            let eventID = document?.documentID ?? ""
            let eventName = dict?["eventName"] as? String ?? ""
            let eventDescription = dict?["eventDescription"] as? String ?? ""
            let startTime = dict?["eventTimeStart"] as? Timestamp ?? Timestamp()
            let location = dict?["location"] as? String ?? ""
//            let hasCompleted = dict?["hasCompleted"] as? Bool ?? false
            let format = DateFormatter()
            format.dateFormat = "MMM"
            let month = format.string(from: startTime.dateValue())
            format.dateFormat = "d"
            let dateNumber = format.string(from: startTime.dateValue())
            format.dateFormat = "h:mm a"
            let timeString = format.string(from: startTime.dateValue())

            let event = EventModel(id: eventID, eventName: eventName,eventDescription: eventDescription, month: month, dateNumber: dateNumber, time: startTime, startTime: timeString, location: location)
            self?.event = event
        }
    }
    func parseToDeepLink(url : URL){
        #if os(iOS)
        DynamicLinkManager.shared.parseToDeepLink(url: url) {[weak self] deeplink in
            switch deeplink {
            case .stranger( let userID):
                self?.fetchPerson(userId : userID)
                self?.didGetDynamicLink = true
            case .profileCreation,.none:
                break
            case .event( let eventID):
                self?.getEventDetails(eventID: eventID)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.didGetDynamicLink = true
                }
            }
        }
         #endif
    }
    
    func refresh() { 
        person = nil
        event = EventModel(id: "")
        didGetDynamicLink = false
    }
    func removeListnener(){
        if let listener = listener{
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
     deinit {
        removeListnener()
     }
}

/*
 not sure if this is possible but, after someone creates an account using the link, it would be cool if it went directly to StrangerProfile before the user has to complete the tutorial
 now for this we need to changes
 
 so we will just save the userId in the user default. and will also add a tracker for user singin notifier
 */
