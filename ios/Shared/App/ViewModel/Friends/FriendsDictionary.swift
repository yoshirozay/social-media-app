//
//  FriendsDictionary.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 1/23/21.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import Combine

class FriendsDictionary: ObservableObject {
    @Published var friendsDictionary = [String: Person]()
    @Published var firstTenFriends = [String: Person]()
    var cancelSet = Set<AnyCancellable>()
    
    public var currentAccountCreationDate : Timestamp {
        var accountCreationDate : Timestamp = Timestamp()
        guard let userId = Auth.auth().currentUser?.uid else{
            return accountCreationDate
        }
        if let dateValue = self.friendsDictionary[userId]?.accountCreationDate.dateValue() {
            //we will remove the - (86400*250) its only here for testing
            accountCreationDate = Timestamp(date: dateValue)// - (86400*120))
        } 
        return accountCreationDate
        /*
         as we are using this in the timelineOO. i think we might be able to use it to remove the where caluse of isGreaterthen. we can just compare when we update the previousWeekDate. and if smaller then of the accountCrationDate then we just assign accountCreationDate to the previousWeekDate.
         */
    }

    var allFriendsSortedByName : [Person] {
      self.friendsDictionary.values.sorted(by: ({$0.username < $1.username }))
    }
    
    var allFriendsExcludingCurrentUser : [Person] {
        guard let userId = currentUserID else { return [] }
        return Array(self.friendsDictionary.filter({$0.key != userId }).values).sorted(by: ({$0.username < $1.username }))
    }
    
    var allFriendIds : [String] { 
        friendsDictionary.map({$0.key})
    }
    private func setFriendsDictionary(_ dictionary: [String: Person]) {
        friendsDictionary = dictionary
    } 
    private func buildFriendsDictionary (_ dataDescription: [String: String]) {
        
        var temporaryDictionary = [String: Person]()
        
        for item in dataDescription.keys {
            
            let collectionRef = Firestore.firestore().collection("UserInfo").document(item.nonEmpty)
            
            listener = collectionRef.addSnapshotListener {[weak self] (documentSnapshot, error)  in
                if error != nil{
                    print("there's an error FriendsDictionary.swift")
                    return
                }
                
                if (documentSnapshot?.get("username") == nil) {
                    print("failed to get document"); return
                }
                
                guard let userDocumentData = documentSnapshot?.data() else {
                    return
                }
                
                 Person.getPersonFromUserInfo(documentData: userDocumentData) {[weak self] (person, error) in
                     if let friend = person {
                        temporaryDictionary[friend.id] = friend
                         if temporaryDictionary.count == dataDescription.count {
                             self?.setFriendsDictionary(temporaryDictionary)
                         }
                         if dataDescription.count < 11 {
                             self?.firstTenFriends = temporaryDictionary
                         } else if temporaryDictionary.count == 10 {
                             self?.firstTenFriends = temporaryDictionary
                         }
                     }else{
                        print(error?.localizedDescription ?? "")
                     }
                 }
               
            }
        }
    }
  
    func addPreloadedTristan(){
        Person.Preloaded.getTristan {[weak self] person, _ in
            if let tristan = person{
                self?.friendsDictionary[tristan.id] = tristan
            }
        }
    }
     
    
    func checkCurrentUserToken() {
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        FriendsDictionary.getFriendOf(source: .default, docId: userId ) { currentUserModel, error in
            if let currentUserModel = currentUserModel {
                NotificationTokenManager.shared.userFcmToken = currentUserModel.token
            }
        }
    }
   
    func addTempWeblinkPublisher() { 
         UserProfile.userTempWeblinkPublisher
            .sink() {[weak self] tempWebLink in
                guard let userId = Auth.auth().currentUser?.uid else{ return }
                DispatchQueue.main.async {
                    self?.friendsDictionary[userId]?.tempWebLink = tempWebLink
                }
            }
            .store(in: &cancelSet)
    }
    
    init(addFriendsListener : Bool = true) {
        addTempWeblinkPublisher()
        checkCurrentUserToken()
        guard addFriendsListener  else {
            return
        }
        //first fetch friends from chache
//        getFriendsDictionary(source: .cache) { [weak self] (_, error) in
//            print(error?.localizedDescription ?? "")
//            //then fetch from server
//            /*
//             we can just add a listener that will only get friends which were updated so we can also update our friends dict.
//             but we do not have that right now, so we can have two things here after we get friends from the cache,
//             1. do that same as it was before like the listener in the init.
//             2. first get from the server and then start the listener for the new friends.
//             */
//            self?.getFriendsDictionary(source: .server) { [weak self] (_, error) in   print(error?.localizedDescription ?? "")
//                //then add listener for any new firends so we can update our firends dict
//                self?.startListeningToNewFriends { (freindsIds, error) in
//                    print(error?.localizedDescription ?? "")
//                }
//            }
//        }
        
        if let userId = Auth.auth().currentUser?.uid  {
            let docRef  = Firestore.firestore().collection("Friends").document(userId.nonEmpty)

            listener =  docRef.addSnapshotListener {[weak self]  (document, error) in
                if let document = document, document.exists,
                    let dataDescription = document.data() as? [String: String] {
                    self?.buildFriendsDictionary(dataDescription)
                }
            }
        }
        
    }
    var listener: ListenerRegistration?
    struct ListenedFriend {
        var ids : [String]
        var isNew : Bool
    }
    
    func startListeningToNewFriends( callback : @escaping (_ newFriendIds : ListenedFriend,  _  error : Error?) -> Void) {
      
            guard let userId = Auth.auth().currentUser?.uid  else {
                return
            }
        
        let callBack : ( (ListenedFriend,Error?) -> Void) = {[weak self] listenedFriend,error in
            if error == nil{
                if listenedFriend.isNew{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        listenedFriend.ids.forEach { self?.addFriendListenerAndUpdateDict(friendId: $0) }
                    }
                }else{
                    listenedFriend.ids.forEach { self?.friendListeners[$0] = nil }
                }
            }
            callback( listenedFriend, error)
        }
            let docRef = Firestore.firestore().collection("Friends").document(userId.nonEmpty)
            newFriendsListenerReg?.remove()
            newFriendsListenerReg = docRef.addSnapshotListener {[weak self]  (document, error) in
                if let document = document, document.exists,
                   let dataDescription = document.data() as? [String: String]{
                
                    var latestFriendsIds : Set<String> = Set( dataDescription.map({$0.key}))
                    guard let strongSelf = self else {
                        return
                    }
                
                    let oldFreindsIds : Set<String> = Set(strongSelf.friendsDictionary.map({$0.key}))
                    let deletedFriendIds = oldFreindsIds.subtracting(latestFriendsIds).getArray()
                    latestFriendsIds.subtract(oldFreindsIds)
               
                    //we can also get remove friends id here. then we can use that id to remove it from the dict and stop listener of posts of the deleted friends
                    if !latestFriendsIds.isEmpty{
                        Self.buildFriendsDictionary(source: .server, Array(latestFriendsIds)) {[weak self] (newFriendsDict, error) in
                            let friendsIds = newFriendsDict.map({$0.key})
                            //now we will merge the old firends dict and the new friends dict.
                            if friendsIds.isNotEmpty,
                               let newFriendsDictionary = self?.friendsDictionary.merging(newFriendsDict, uniquingKeysWith: { (_, new) in new }) {
                                self?.setFriendsDictionary(newFriendsDictionary)
                                callBack( ListenedFriend(ids: friendsIds, isNew: true), error)
                            }
                        }
                    }
                    
                    if !deletedFriendIds.isEmpty {
                        deletedFriendIds.forEach({self?.friendsDictionary.removeValue(forKey: $0)}) 
                        callBack( ListenedFriend(ids: deletedFriendIds, isNew: false), error)
                    }
                }
            }
    }
    
    var newFriendsListenerReg : ListenerRegistration?
    var friendListeners  : [ String : ListenerRegistration ] = [:]
    deinit {
        newFriendsListenerReg?.remove()
        listener?.remove()
    }
    func getFriendsOf(ids : [String]) -> [Person] {
         ids.compactMap({friendsDictionary[$0]})
    }
}

extension FriendsDictionary {
    
    func getFriendsDictionary(source: FirestoreSource,
                              callback : @escaping (_ friendsDict : [String: Person],  _  error : Error?) -> Void) {
        Self.getFriendsDictionary(source: source) {[weak self] (friendsDictionary, error) in
            if !friendsDictionary.isEmpty {
                self?.setFriendsDictionary(friendsDictionary)
            }
            callback(friendsDictionary, error)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                friendsDictionary.forEach { key,_  in
                    self?.addFriendListenerAndUpdateDict(friendId: key)
                }
            }
        }
    }
    
    class func getFriendsDictionary(source: FirestoreSource,
                                    callback : @escaping (_ friendsDict : [String: Person],  _  error : Error?) -> Void) {
        if let userId = Auth.auth().currentUser?.uid   {
            let docRef  = Firestore.firestore().collection("Friends").document(userId.nonEmpty)
            docRef.getDocument(source: source) {  (document, error) in
                if let document = document, document.exists,
                   let dataDescription = document.data() as? [String: String]{
                      
                    let friendsIds = dataDescription.map({$0.key})
 
                    Self.buildFriendsDictionary(source: source, friendsIds) { (friendsDictionary, error) in
                        callback(friendsDictionary, error)
                    }
                }else{
                    //it might be called because we got error , or might because we did not get any document from the cahce at all
                    callback([:], error)
                }
            }
        }
    }
    
    class func getFriendOf(source: FirestoreSource,docId: String,callback : @escaping (_ friend :  Person?,  _  error : Error?) -> Void) {
        
        let collectionRef = Firestore.firestore().collection("UserInfo").document(docId.nonEmpty)
        
        collectionRef.getDocument(source: source) { (documentSnapshot, error)  in
            guard error == nil,
                  let userDocumentData = documentSnapshot?.data(),
                  (documentSnapshot?.get("username") != nil) else {
                      callback(nil, error ?? NSError.getWith(description: "failed to get document or username was nill"))
                      return
                  }
            Person.getPersonFromUserInfo(documentData: userDocumentData,callback : callback)
        }
    }
     
    class private func buildFriendsDictionary (source: FirestoreSource,
                                               _ friendIds: [String],
                                               callback : @escaping (_ friendsDict : [String: Person],  _  error : Error?) -> Void) {
        
        var temporaryDictionary = [String: Person]()
        
        for friendId in friendIds {
            getFriendOf(source: source, docId: friendId) { (friend, error) in
                if let friend = friend {
                    temporaryDictionary[friend.id] = friend
                    if temporaryDictionary.count == friendIds.count {
                        callback(temporaryDictionary,nil)
                    }
                }else{
                    callback([:],error)
                    return
                }
            }
        }
    }
    
    
    
 /*
  so we will call them when we get friends from the cache.
  we can add delay if we want because these listener only porpuse is to update a friend object from dict if a friend or current suer updated his/her profile
  */
   
    private func addFriendListenerAndUpdateDict (friendId :  String) {
      
            
            guard  self.friendListeners[friendId] == nil else{ return }
        self.friendListeners[friendId]  = self.addFriendListener(friendId: friendId){[weak self] (person, error) in
                if let friend = person,
                   let oldUserObject = self?.friendsDictionary[friend.id],
                   !oldUserObject.isUserEqual(friend){
                    DispatchQueue.main.async {
                        self?.friendsDictionary[friend.id] = friend
                
                    }
                }else if let error = error{
                    print(error.localizedDescription)
                }
            }
    }
    
    private func addFriendListener (friendId :  String, callback : @escaping (_ person: Person?,  _  error : Error?) -> Void) -> ListenerRegistration {
        
        let collectionRef = Firestore.firestore().collection("UserInfo").document(friendId.nonEmpty)
        return collectionRef.addSnapshotListener { (docSnapshot, error)  in
            guard error == nil,
                  let userDocumentData = docSnapshot?.data(),
                  (docSnapshot?.get("username") != nil) else {
                      callback(nil, error ?? NSError.getWith(description: "failed to get document or username was nill"))
                      return
                  }
            Person.getPersonFromUserInfo(documentData: userDocumentData,callback : callback)
        }
    }
}
 
extension FriendsDictionary{
    
    struct PersonFriendInfo{
        var user : Person
        var isFriend : Bool
    }
    
    func getFriend(username: String) -> Person?{
        return friendsDictionary.first(where: {$0.value.username == username})?.value
    }
    
    //this func will first check user in dictionary if not found then will use CTN to get from firestore db
    func getUserOf(username : String,callback : @escaping (_ user : PersonFriendInfo?,  _  error : Error?) -> Void){
        let mention = "@"+username
        if let user = getFriend(username: mention) {
            callback(PersonFriendInfo(user: user, isFriend: true),nil)
        } else {
            Person.fetchUsingCTN(username: mention) { user, error in
                if let user = user{
                    callback(PersonFriendInfo(user: user, isFriend: false),nil)
                }else{
                    callback(nil,error)
                    print("Person.fetchUsingCTN(username ) error \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
    
    func getUserOf(id : String,source: FirestoreSource = .default,callback : @escaping (_ user : PersonFriendInfo?,  _  error : Error?) -> Void){
        if let user = friendsDictionary[id] {
            callback(PersonFriendInfo(user: user, isFriend: true),nil)
        } else {
            Person.fetchFriend(id: id,source: source) { user, error in
                if let user = user{
                    callback(PersonFriendInfo(user: user, isFriend: false),nil)
                }else{
                    callback(nil,error)
                    print("Person.fetchUsingCTN(username ) error \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
}
