//
//  StrangerProfileOO.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 1/27/21.
//

import SwiftUI
import Firebase
import Combine

class StrangerProfileOO: ObservableObject {
    @Published private (set) var dismissStrangerProfile : Bool = false
    @Published var doIHaveAFriendRequest = Bool()
    @Published var didISendAFriendRequest = Bool()
    @Published var areWeFriends = false
    var myRequestsListener : ListenerRegistration?
    var otherRequestsListener : ListenerRegistration?
    var pnSub : AnyCancellable?
    let id : String
    init(id: String,addPNListener: Bool = true ){
        self.id = id
        guard let userId = currentUserID else{ return }
        let myRef = Firestore.firestore().collection("FriendRequests").document(userId.nonEmpty)
        myRequestsListener?.remove()
        myRequestsListener = myRef.addSnapshotListener { [weak self]  (document, error) in
            if let document = document, document.exists,
               let dataDescription = document.data() as? [String: String]{
              
                if dataDescription.isNotEmpty{
                    for item in dataDescription.keys {
                        if item == id {
                            self?.doIHaveAFriendRequest = true
                        }
                        if self?.doIHaveAFriendRequest != true {
                            self?.doIHaveAFriendRequest = false
                        }
                    }
                }else{
                    self?.doIHaveAFriendRequest = false
                }
            }
        }
        
        let theirRef = Firestore.firestore().collection("FriendRequests").document(id.nonEmpty)
        otherRequestsListener?.remove()
        otherRequestsListener = theirRef.addSnapshotListener {[weak self] (document, error) in
            if let document = document, document.exists,
               let dataDescription = document.data() as? [String: String]{
                 
                for item in dataDescription.keys {
                    if item == Auth.auth().currentUser?.uid {
                        self?.didISendAFriendRequest = true
                    }
                    if self?.didISendAFriendRequest != true {
                        self?.didISendAFriendRequest = false
                    }
                }
            }
        }
        setViewInfo()
        startPNListener(addPNListener: addPNListener)
    }
    func sendFriendRequest(){
        didISendAFriendRequest = true
    }
    
    func declineFriendRequest() {
        areWeFriends = false
        doIHaveAFriendRequest = false
    }
    func cancelFriendRequest() {
        didISendAFriendRequest = false
    }
    
    func acceptFriendRequest(personId : String,callback : @escaping (_ success : Bool, _ error : Error?) -> Void) {
        Firestore.firestore().collection("Friends")
            .document(personId.nonEmpty)
            .getDocument(source: .server){[weak self] (document, error) in
                if let otherUserFriendIds = (document?.data() as? [String: String])?.values,
                   otherUserFriendIds.count < 152{ //1 is the current user and 1 is Tristan so that is way its < 152 not < 150
                    self?.areWeFriends = true
                    self?.doIHaveAFriendRequest = false
                    callback(true,error)
                }else{
                    callback(false,error)
                }
            } 
    }
    deinit {
        myRequestsListener?.remove()
        otherRequestsListener?.remove()
        removeViewInfo()
        pnSub?.cancel()
    }
}

extension StrangerProfileOO : PNViewManagerSetAble{
    var docId : String {  id  }
    var type: PNViewManager.OnScreenView  { .userProfile }
    
    func startPNListener(addPNListener: Bool){
        if addPNListener{
            publisherForNewPN.assign(to: &$dismissStrangerProfile)
        }else{
            pnSub = addPushNotificationViewListener()
        }
    }
}
