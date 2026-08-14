//
//  IndividualEvent-VM.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 8/12/22.
//

import Foundation
import Firebase

class IndividualEventOO: ObservableObject {
    @Published var friendsDictionary = FriendsDictionary()
    @Published var attendingFriends = [Person]()
    @Published var attendingFriendTokens = [String]()
    @Published var allAttendingTokens = [String]()
    @Published var attendingStrangers = [Person]()
    @Published var invitedFriends = [Person]()
    @Published var invitedStrangers = [Person]()
    @Published var notAttendingFriends = [Person]()
    @Published var notAttendingStrangers = [Person]()
    @Published var hosts = [Person]()
    @Published var isAttending = false
    @Published var isNotAttending = false
    @Published var eventConversationID = String()
    init (eventID: String, friendsDictionary : FriendsDictionary) {
        
        self.friendsDictionary = friendsDictionary
        
        let collectionRef = Firestore.firestore().collection("AllEvents").document(eventID.nonEmpty).collection("AttendingUsers")
        self.listener =  collectionRef.addSnapshotListener { [weak self] (snap, error) in
        guard let documentChanges = snap?.documentChanges, error == nil else {
            print(error?.localizedDescription ?? "")
            return
        }
            for documentChange in documentChanges {
                if documentChange.type == .added {
                    let document = documentChange.document
                    let attendingUserID = document.documentID
                    if attendingUserID == Auth.auth().currentUser?.uid {
                        self?.isAttending = true
                    }
                    if let friend = self?.friendsDictionary.friendsDictionary[attendingUserID] {
                        if (self?.attendingFriends.firstIndex(of: friend) == nil) {
                        self?.attendingFriends.append(friend)
                        }
                        let token = friendsDictionary.friendsDictionary[attendingUserID]?.token ?? ""
                        if (self?.attendingFriendTokens.firstIndex(of: token) == nil) {
                            if attendingUserID != Auth.auth().currentUser?.uid {
                        self?.attendingFriendTokens.append(token)
                            }
                        }
                        if (self?.allAttendingTokens.firstIndex(of: token) == nil) {
                            if attendingUserID != Auth.auth().currentUser?.uid {
                        self?.allAttendingTokens.append(token)
                            }
                        }
                        
                    } else {
                        Person.fetchFriend(id: attendingUserID ,source: .default)  {[weak self] user, error in
                            if let user = user{
                                self?.add(person: user)
                                if (self?.allAttendingTokens.firstIndex(of: user.token) == nil) {
                                    self?.allAttendingTokens.append(user.token)
                                }
                            }
                        }
                    }
                }
                                if documentChange.type == .removed {
                                    let document = documentChange.document
                                    let notAttendingUserID = document.documentID
                                    if let firstIndex = self?.attendingFriends.firstIndex(where: {$0.id == notAttendingUserID}) {
                                        self?.attendingFriends.remove(at: firstIndex)
                                    }
                                    if let firstIndex = self?.attendingStrangers.firstIndex(where: {$0.id == notAttendingUserID}) {
                                        self?.attendingStrangers.remove(at: firstIndex)
                                    }
                            }
            }
        }
        let hostsCollectionRef = Firestore.firestore().collection("AllEvents").document(eventID.nonEmpty).collection("Hosts")
        self.listener =  hostsCollectionRef.addSnapshotListener { [weak self] (snap, error) in
        guard let documentChanges = snap?.documentChanges, error == nil else {
            print(error?.localizedDescription ?? "")
            return
        }
            for documentChange in documentChanges {
                if documentChange.type == .added {
                    let document = documentChange.document
                    let attendingUserID = document.documentID
                    
                    if let friend = self?.friendsDictionary.friendsDictionary[attendingUserID] {
                        self?.hosts.append(friend)
                    } else {
                        Person.fetchFriend(id: attendingUserID ,source: .default)  {[weak self] user, error in
                            if let user = user{
                                self?.addHost(person: user)
                            }
                        }
                    }
                }
            }
        }
        let invitedRef = Firestore.firestore().collection("AllEvents").document(eventID.nonEmpty).collection("InvitedUsers")
        self.listener =  invitedRef.addSnapshotListener { [weak self] (snap, error) in
        guard let documentChanges = snap?.documentChanges, error == nil else {
            print(error?.localizedDescription ?? "")
            return
        }
            for documentChange in documentChanges {
                if documentChange.type == .added {
                    let document = documentChange.document
                    let attendingUserID = document.documentID
                    
                    if let friend = self?.friendsDictionary.friendsDictionary[attendingUserID] {
                        if (self?.invitedFriends.firstIndex(of: friend) == nil) {
                        self?.invitedFriends.append(friend)
                        }
                    } else {
                        Person.fetchFriend(id: attendingUserID ,source: .default)  {[weak self] user, error in
                            if let user = user{
                                self?.addInvited(person: user)
                            }
                        }
                    }
                }
                if documentChange.type == .removed {
                    let document = documentChange.document
                    let invitedUserID = document.documentID
                    if let firstIndex = self?.invitedFriends.firstIndex(where: {$0.id == invitedUserID}) {
                        
                        self?.invitedFriends.remove(at: firstIndex)
                    }
                    if let firstIndex = self?.invitedStrangers.firstIndex(where: {$0.id == invitedUserID}) {
                        self?.invitedStrangers.remove(at: firstIndex)
                    }
            }
            }
        }
        let notAttendingRef = Firestore.firestore().collection("AllEvents").document(eventID.nonEmpty).collection("NotAttendingUsers")
        self.listener =  notAttendingRef.addSnapshotListener { [weak self] (snap, error) in
        guard let documentChanges = snap?.documentChanges, error == nil else {
            print(error?.localizedDescription ?? "")
            return
        }
            for documentChange in documentChanges {
                if documentChange.type == .added {
                    let document = documentChange.document
                    let attendingUserID = document.documentID
                    
                    if let friend = self?.friendsDictionary.friendsDictionary[attendingUserID] {
                        if (self?.notAttendingFriends.firstIndex(of: friend) == nil) {
                        self?.notAttendingFriends.append(friend)
                        }
                    } else {
                        Person.fetchFriend(id: attendingUserID ,source: .default)  {[weak self] user, error in
                            if let user = user{
                                self?.addNotAttending(person: user)
                            }
                        }
                    }
                }
                if documentChange.type == .removed {
                    let document = documentChange.document
                    let invitedUserID = document.documentID
                    if let firstIndex = self?.notAttendingFriends.firstIndex(where: {$0.id == invitedUserID}) {
                        self?.notAttendingFriends.remove(at: firstIndex)
                    }
                    if let firstIndex = self?.notAttendingStrangers.firstIndex(where: {$0.id == invitedUserID}) {
                        self?.notAttendingStrangers.remove(at: firstIndex)
                    }
            }
            }
        }
        let conversationRef = Firestore.firestore().collection("AllEvents").document(eventID.nonEmpty).collection("EventConversation")
        conversationRef.getDocuments() { [weak self] (snap, error) in
        guard let documentChanges = snap?.documentChanges, error == nil else {
            print(error?.localizedDescription ?? "")
            return
        }
            for documentChange in documentChanges {
                if documentChange.document.documentID != "Subscribed" {
                self?.eventConversationID = documentChange.document.documentID
                }
            }
        }
    }

    func attendEvent() {
        self.isAttending = true
        self.isNotAttending = false
        if let firstIndex = self.invitedFriends.firstIndex(where: {$0.id == Auth.auth().currentUser?.uid}) {
            self.invitedFriends.remove(at: firstIndex)
        }
        if self.attendingFriends.firstIndex(where: {$0.id == Auth.auth().currentUser?.uid}) == nil {
            self.attendingFriends.append(friendsDictionary.friendsDictionary[Auth.auth().currentUser?.uid ?? ""] ?? Person(id: ""))
        }
        if let firstIndex = self.notAttendingFriends.firstIndex(where: {$0.id == Auth.auth().currentUser?.uid}) {
            self.notAttendingFriends.remove(at: firstIndex)
        }
    }
    func notAttendingEvent() {
        self.isAttending = false
        self.isNotAttending = true
        if let firstIndex = self.invitedFriends.firstIndex(where: {$0.id == Auth.auth().currentUser?.uid}) {
            self.invitedFriends.remove(at: firstIndex)
        }
        if self.notAttendingFriends.firstIndex(where: {$0.id == Auth.auth().currentUser?.uid}) == nil {
            self.notAttendingFriends.append(friendsDictionary.friendsDictionary[Auth.auth().currentUser?.uid ?? ""] ?? Person(id: ""))
        }
        if let firstIndex = self.attendingFriends.firstIndex(where: {$0.id == Auth.auth().currentUser?.uid}) {
            self.attendingFriends.remove(at: firstIndex)
        }
        
    }
    func add(person : Person){
        DispatchQueue.main.async {
            self.attendingStrangers.append(person)
        }
    }
    func addAttending(id: String, person : Person){
        DispatchQueue.main.async {
            if self.friendsDictionary.friendsDictionary[id] != nil {
                self.attendingFriends.append(person)
            } else {
            self.attendingStrangers.append(person)
            }
        }
    }
    func addInvited(person : Person){
        DispatchQueue.main.async {
            if self.friendsDictionary.friendsDictionary[person.id] != nil {
                self.invitedFriends.append(person)
            } else {
                self.invitedStrangers.append(person)
                
            }
        }
    }
    func addNotAttending(person : Person){
        DispatchQueue.main.async {
            self.notAttendingStrangers.append(person)
        }
    }
    func addHost(person : Person){
        DispatchQueue.main.async {
            self.hosts.append(person)
        }
    }
    func removeAttending(id: String, person: Person) {
        if self.friendsDictionary.friendsDictionary[id] != nil {
            if let firstIndex = self.attendingFriends.firstIndex(where: {$0.id == id}) {
                self.attendingFriends.remove(at: firstIndex)
            }
        } else {
            if let firstIndex = self.attendingStrangers.firstIndex(where: {$0.id == id}) {
                self.attendingStrangers.remove(at: firstIndex)
            }
        }
    }
    func removeNotAttending(id: String, person: Person) {
        if self.friendsDictionary.friendsDictionary[id] != nil {
            if let firstIndex = self.notAttendingFriends.firstIndex(where: {$0.id == id}) {
                self.notAttendingFriends.remove(at: firstIndex)
            }
        } else {
            if let firstIndex = self.notAttendingStrangers.firstIndex(where: {$0.id == id}) {
                self.notAttendingStrangers.remove(at: firstIndex)
            }
        }
    }
    func removeInvited(id: String, person: Person) {
        if self.friendsDictionary.friendsDictionary[id] != nil {
            if let firstIndex = self.invitedFriends.firstIndex(where: {$0.id == id}) {
                self.invitedFriends.remove(at: firstIndex)
            }
        } else {
            if let firstIndex = self.invitedStrangers.firstIndex(where: {$0.id == id}) {
                self.invitedStrangers.remove(at: firstIndex)
            }
        }
    }
    var listener: ListenerRegistration?
    deinit {
        listener?.remove()
    }
}




