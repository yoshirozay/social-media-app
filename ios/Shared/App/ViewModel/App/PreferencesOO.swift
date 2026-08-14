//
//  PreferencesOO.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 6/27/21.
//

import SwiftUI
import Firebase

class PreferencesOO: ObservableObject {
    @Published var listView = true

    init(){
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        let docRef = Firestore.firestore().collection("UserInfo").document(userId.nonEmpty).collection("Settings").document("Preferences")
        listener = docRef.addSnapshotListener{[weak self] (documentSnapshot, error) in
            
            if error != nil{
                print("there's an error PreferencesOO.swift")
                return
            }
            let friendsListViewPreference = documentSnapshot?.get("friendsListView") as? Bool ?? true
            self?.listView = friendsListViewPreference
        }
    }
    var listener: ListenerRegistration?
    deinit {
        listener?.remove()
    }
}


class ProfileCirclesOO: ObservableObject {
    @Published var profileCircles = [String: ProfileCircleModel]()

    init(){
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        let docRef = Firestore.firestore().collection("UserInfo").document(userId.nonEmpty).collection("Settings").document("ProfileCircles")
        listener = docRef.addSnapshotListener{[weak self] (document, error) in
            
            if error != nil{
                print("there's an error ProfileCirclesOO.swift")
                return
            }
            if let document = document, document.exists,
               let dataDescription = document.data() {
                
                for item in dataDescription {

                    self?.profileCircles[item.key] = ProfileCircleModel(color: getBackgroundColor(backgroundColor: item.key), order: item.value as? String ?? "")
                    
                }
            }
        }
    }
    var listener: ListenerRegistration?
    deinit {
        listener?.remove()
    }
}


struct ProfileCircleModel: Identifiable, Hashable {
    var id = UUID()
    let color: Color
    let order: String
}
