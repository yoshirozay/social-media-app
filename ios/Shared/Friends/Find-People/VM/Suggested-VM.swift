//
//  SuggestedFriendsOO.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 12/7/21.
//

import Foundation
import SwiftUI
import Contacts
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
 
//we will also update this as well. so instead of one it will need two mutual friend to be called a suggested friend
class SuggestedFriendsOO: ObservableObject, CloudFunction {
     
    @Published private var mutualFriends : [SuggestedFriend] = []
    @Published private var contactFriends : [SuggestedFriend] =  []
    @Published var firstThreeSuggestedFriends : [SuggestedFriend] = []
    @Published var areContactsAvailable = false
    @Published var removedIDs : [String] = []
    private let friendsDictionary : FriendsDictionary
    private var subs = Set<AnyCancellable>()
    
    var allSuggestedFriends : [SuggestedFriend] {
        contactFriends + mutualFriends
    }
    
    init(friendsDictionary : FriendsDictionary) {
        self.friendsDictionary = friendsDictionary
        if friendsDictionary.friendsDictionary.isNotEmpty{
            getRemovedSuggestedFriendIDs()
            getAllMutualFriendids()
        }else{
            friendsDictionary.getFriendsDictionary(source: .server) {[weak self] (_, error) in
                if error == nil, self?.friendsDictionary.friendsDictionary.isNotEmpty == true {
                    self?.getAllMutualFriendids()
                }
            }
        }
    }
    var listener: ListenerRegistration?
    func getRemovedSuggestedFriendIDs () {
        guard let userId = currentUserID else { return }
        let docRef = Firestore.firestore().collection("RemovedSuggestedFriends").document(userId.nonEmpty)
        listener = docRef.addSnapshotListener {[weak self] (document, error) in
            if let document = document, document.exists,
               let dataDescription = document.data() as? [String: Timestamp]{
                for item in dataDescription.keys {
                    self?.removedIDs.append(item)
                }
            }
        }
    }
    func getAllMutualFriendids() {
        guard let userId = currentUserID else { return }
        var secondFriendIds : [String] = []
        let group = DispatchGroup()
         
        friendsDictionary.friendsDictionary.forEach { pair in
            let friendId = pair.key
            if friendId != userId, friendId != TristanUserID {
                group.enter()
                Firestore.firestore().collection("Friends").document(friendId.nonEmpty).getDocument{ (document, error) in
                    if let friendIds = document?.data()?.arrayKeys {
                        secondFriendIds.append(contentsOf: friendIds)
                    }else{
                        print("getAllMutualFriendids id \(friendId) error = \(error.descriptionIfAny)")
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main){
            if secondFriendIds.isNotEmpty{
                var mutualFriendIds = Dictionary(grouping: secondFriendIds, by: {$0}).filter { $1.count > 1 }.setKeys
                mutualFriendIds.subtract(self.friendsDictionary.friendsDictionary.setKeys) 
                self.fetchtAllMutualFriends(mutualFriendIds: mutualFriendIds.getArray())
            }
        }
        self.startFriendDictListener()
    }
     
        func addMutualFriends(mutualFriends: [SuggestedFriend]){
            DispatchQueue.main.async {
                self.mutualFriends = (self.mutualFriends+mutualFriends)
                if self.firstThreeSuggestedFriends.count < 4{
                    self.firstThreeSuggestedFriends = Array(self.mutualFriends.prefix(3))
                }
            }
        }
        
        func fetchtAllMutualFriends(mutualFriendIds : [String]) {
            var mutualFriendIds = mutualFriendIds

            /// the reason we are doing this is because we can only add 10 equal conditions in firestore query using 'in' operator.
            let subArrayCount =  Double(mutualFriendIds.count) / 10.0
            var i = 0.0
            while subArrayCount > i {
                let tenMutualFriendIds = Array(mutualFriendIds.prefix(10))
                mutualFriendIds.removeFirst(tenMutualFriendIds.count)
                if let oneOrTenFriendIds = TenFriendIds(oneOrTenFriendIds: tenMutualFriendIds) {
                    fetchMutualFriend(tenMutualFriendIds: oneOrTenFriendIds) { [weak self]  mutualFriends, error in
                        if mutualFriends.isNotEmpty {
                            self?.addMutualFriends(mutualFriends: mutualFriends)
                        }else if let error = error{
                            print(" \(error.localizedDescription)")
                        }
                    }
                }
                i += 1
            }
        }
    
        func fetchMutualFriend(tenMutualFriendIds : TenFriendIds, callback : @escaping (_ mutualFriends : [SuggestedFriend], _  error : Error?) -> Void) {
        
            Firestore.firestore().collection("UserInfo")
                .whereField("uid", in: tenMutualFriendIds.mutualFriendIds)
                .getDocuments { snap, error in
                    guard let documents = snap?.documents, error == nil else {
                        callback([],error ?? "did not get userContact".asError)
                        return
                    }
                    
                    let mutualFriends = documents.map { doc -> SuggestedFriend in

                        let person =  Person(documentData: doc.data())
                        return SuggestedFriend(user: person)
                        
                    }
                    callback(mutualFriends, nil)
                }
        }
    class func removeSuggestFriend(removedUserID: String, callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        let removedInformation = [
            "removedUserID": removedUserID,
            "currentUser": Auth.auth().currentUser?.uid
        ]
        Self.call(funcName: "removeSuggestedFriend-removeSuggestedFriend", informationDict: removedInformation){
            callback($0)
        }
    }
       
    deinit {
        listener?.remove()
        subs.cancelAll()
    }
}



//contacts friends
extension SuggestedFriendsOO {
    
    func startFriendDictListener() {
        friendsDictionary.$friendsDictionary.dropFirst().sink {[weak self] dict in
            guard let self = self else { return  }
            let newDict = dict.filter{ self.friendsDictionary.friendsDictionary[$0.key] == nil}
            if newDict.isNotEmpty {
                var nonUserContacts : [SuggestedFriend] { self.contactFriends.filter{ newDict[$0.user.id] == nil} }
                self.setUserContacts(userContact: nonUserContacts)
                DispatchQueue.main.async {
                    self.mutualFriends.removeAll(where: { newDict[$0.user.id] != nil})
                }
            }
        }.store(in: &subs)
    }
    
   
    
///this func will ask for permission and will fetch contacts
    func askForPermissionAndFetchContacts() {
        guard areContactsAvailable == false else {  return  }
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { [weak self]  (granted, error) in
            
            if let error = error {
                print("failed to request access", error)
                return
            }
            
            DispatchQueue.main.async {
                self?.areContactsAvailable = true
            } 
            if granted {
                self?.fetchPhoneContact(store: store)
            } else {
                print("access denied")
            }
        }
    }
    func fetchPhoneContact(store: CNContactStore){
        let keys = [CNContactGivenNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        do {
            
            var fetchedContacts = Set<Contact>()
            try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                let phoneContacts = contact.phoneNumbers.map{Contact(givenName: contact.givenName, phoneNumber: $0.value.stringValue)  }
                fetchedContacts.formUnion(phoneContacts)
            })
            DispatchQueue.main.async { [weak self] in
                self?.fetchtAllFirebaseContactUsers(allContacts: fetchedContacts)
            }
            print(" got all contacts")
        } catch let error {
            print("Failed to enumerate contact", error)
        }
        
    }
    
    func ifPermissionGrantedThenFetchContacts() {
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            return
        }
         fetchPhoneContact(store: CNContactStore())
    }
    
   //FIXME: - we will also need to add listenr of friend dictionary so when a user adds suggested friend we can remove it.
    ///in this func we will get all firebaseUserContacts and will show them in a list
    func fetchtAllFirebaseContactUsers(allContacts : Set<Contact>) {
        let nonUserContacts = allContacts.filter{ contact in
              (friendsDictionary.friendsDictionary.first(where: {$0.value.phoneNumber == contact.phoneNumber}) ==  nil)
        }.getArray()
        var allContacts = nonUserContacts
        /// the reason we are doing this is because we can only add 10 equal conditions in firestore query using 'in' operator.
        let subArrayCount =  Double(allContacts.count) / 10.0
        var i = 0.0
        while subArrayCount > i {
            let tenContacts = Array(allContacts.prefix(10))
            allContacts.removeFirst(tenContacts.count)
            if let oneOrTenContacts = TenContact(oneOrTenContacts: tenContacts){
                getFirebaseUsersFrom(tenContact: oneOrTenContacts) { [weak self]  userContact, error in
                    if let error = error{
                        print(" \(error.localizedDescription)")
                    }else{
                        print("userContact  \(userContact)")
                        self?.addUserContacts(userContact: userContact)
                    }
                }
            }
            i += 1
        }
    }
    

    ///now in this func we will only give it 10 contacts each time to get other friends. in future i think it would be best to first fetch them from the cache and then from the server if not found.
    func getFirebaseUsersFrom(tenContact : TenContact, callback : @escaping (_ userContact : [SuggestedFriend], _  error : Error?) -> Void) {
        let firstTenPhoneNumbers = tenContact.contacts.map({$0.phoneNumber})
        Firestore.firestore().collection("UserInfo")
            .whereField("phoneNumber", in: firstTenPhoneNumbers)
            .getDocuments { [weak self]  snap, error in
                guard let documents = snap?.documents, error == nil else {
                    callback([],error ?? "did not get userContact".asError)
                    return
                }
                let userContacts = documents.compactMap { doc -> SuggestedFriend? in
                    let person =  Person(documentData: doc.data())
                    if  let contact = tenContact.contacts.first(where: {$0.phoneNumber == person.phoneNumber}){
                        if self?.removedIDs.firstIndex(of: person.id) != nil {
                            return nil
                        } else {
                        return SuggestedFriend(user: person, contact: contact)
                        }
                    }
                    return nil
                }
                callback(userContacts, nil)
            }
    }
    
    func setUserContacts(userContact: [SuggestedFriend]) {
        DispatchQueue.main.async {
            self.contactFriends = userContact
        }
    }
    
    func addUserContacts(userContact: [SuggestedFriend]){
        DispatchQueue.main.async {
            self.contactFriends = (self.contactFriends+userContact)
        }
    }
}
 
/*
 so now we need to check for two things one is that
 1) Check for multiple contacts with same phone number
 2)  when Friend dict update we will also need to update the suggested friend
 3) also need to upate Mutual two friend from one
  */
///the reason we are using TenFriendIds and TenContact because we use the their arrays in the firebase query in cluse. so if array is empty or has more then 10 valuse the app will crash. so to make sure we have no risk we create types which will make 100% sure that 1-10 elements get through
extension SuggestedFriendsOO {
    
    struct TenFriendIds {
        init?(oneOrTenFriendIds mutualFriendIds: [String]) {
            guard mutualFriendIds.count < 11 ,  mutualFriendIds.count > 0 else { return nil }
            self.mutualFriendIds = mutualFriendIds
        }
        let mutualFriendIds : [String]
    }
    struct TenContact {
        init?(oneOrTenContacts contacts: [Contact]) {
            guard contacts.count < 11 ,  contacts.count > 0 else { return nil }
            self.contacts = contacts
        }
        let contacts : [Contact]
    }
}
