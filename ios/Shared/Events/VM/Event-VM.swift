//
//  Event-VM.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 7/29/22.
//

import Foundation
import SwiftUI
import Firebase

class EventModelOO: ObservableObject {
    @Published var eventItem = [EventModel]()
    @Published var pastEventItems = [EventModel]()
    @Published var eventInvitations = [String: String]()
    @Published var invitedEvents = [EventModel]()
    init(){
        getInvitations()
        getMyCurrentEvents()
    }
    func getEvent(_ eventID : String) -> EventModel?{
        if let firstIndex = self.eventItem.firstIndex(where: {$0.id == eventID}) {
           return eventItem[firstIndex]
        } else {
            return EventModel(id: "")
        }
    }
    func createTempEvent(startTime: Date, eventName: String, eventDescription: String, invitedUsers: [String], hostIDs: [String], location: String, nameOfSendingUser: String, eventID: String) {
        let format = DateFormatter()
        format.dateFormat = "MMM"
        let month = format.string(from: startTime)
        format.dateFormat = "d"
        let dateNumber = format.string(from: startTime)
        format.dateFormat = "h:mm a"
        let timeString = format.string(from: startTime)
        
        
        let tempEvent = EventModel(id: eventID, eventName: eventName, eventDescription: eventDescription, month: month, dateNumber: dateNumber, time: Timestamp(), startTime: timeString, location: location, isLoading: true)
        self.eventItem.append(tempEvent)
    }
    func updateEventDummy(eventID: String, eventName: String, eventDescription: String, location: String, startTime: Date, time: Timestamp) {
        let format = DateFormatter()
        format.dateFormat = "MMM"
        let month = format.string(from: startTime)
        format.dateFormat = "d"
        let dateNumber = format.string(from: startTime)
        format.dateFormat = "h:mm a"
        let timeString = format.string(from: startTime)
        
        let tempEvent = EventModel(id: eventID, eventName: eventName, eventDescription: eventDescription, month: month, dateNumber: dateNumber, time: time, startTime: timeString, location: location)
        if let firstIndex = self.eventItem.firstIndex(where: {$0.id == eventID}) {
            self.eventItem.remove(at: firstIndex)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.eventItem.append(tempEvent)
            }
        }
    }
    func getInvitations() {
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        let collectionRef = Firestore.firestore().collection("EventInvitations").document(userId.nonEmpty).collection("InvitedEvents")
        
        self.listener2 =  collectionRef.addSnapshotListener { [weak self] (snap, error) in
        guard let documentChanges = snap?.documentChanges, error == nil else {
            print(error?.localizedDescription ?? "")
            return
        }
            for documentChange in documentChanges {
                if documentChange.type == .added {
                    let document = documentChange.document
                    let eventID = document.documentID
                    let documentData = document.data()
                    let sentBy = documentData["sentBy"] as? String ?? ""
                    self?.eventInvitations[eventID] = sentBy
                    getEventDetails(eventID: eventID)
                }
                if documentChange.type == .removed {
                    let document = documentChange.document
                    let eventID = document.documentID
                    if self?.eventInvitations[eventID] != nil {
                        self?.eventInvitations.removeValue(forKey: eventID)
                    }
                    if let firstIndex = self?.invitedEvents.firstIndex(where: {$0.id == eventID}) {
                        self?.invitedEvents.remove(at: firstIndex)
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
                let location =  dict?["location"] as? String ?? ""
                let hasCompleted = dict?["hasCompleted"] as? Bool ?? false
                let isDeleted = dict?["isDeleted"] as? Bool ?? false
                let format = DateFormatter()
                format.dateFormat = "MMM"
                let month = format.string(from: startTime.dateValue())
                format.dateFormat = "d"
                let dateNumber = format.string(from: startTime.dateValue())
                format.dateFormat = "h:mm a"
                let timeString = format.string(from: startTime.dateValue())
                
                if hasCompleted != true && isDeleted != true {
                self?.invitedEvents.append(EventModel(id: eventID, eventName: eventName,eventDescription: eventDescription, month: month, dateNumber: dateNumber, time: startTime, startTime: timeString, location: location))
                }
                
            }
        }
    }

    func getMyCurrentEvents() {
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        let collectionRef = Firestore.firestore().collection("MyEvents").document(userId.nonEmpty).collection("Events")
        self.listener =  collectionRef.addSnapshotListener { [weak self] (snap, error) in
        guard let documentChanges = snap?.documentChanges, error == nil else {
            print(error?.localizedDescription ?? "")
            return
        }
            for documentChange in documentChanges {
                if documentChange.type == .added || documentChange.type == .modified {
                    let document = documentChange.document
                    let eventID = document.documentID
                    self?.getEventDetails(eventID: eventID)
                }
                if documentChange.type == .removed {
                    let document = documentChange.document
                    let eventID = document.documentID
                    if let firstIndex = self?.eventItem.firstIndex(where: {$0.id == eventID}) {
                        self?.eventItem.remove(at: firstIndex)
                    }
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
            let hasCompleted = dict?["hasCompleted"] as? Bool ?? false
            let isDeleted = dict?["isDeleted"] as? Bool ?? false
            let format = DateFormatter()
            format.dateFormat = "MMM"
            let month = format.string(from: startTime.dateValue())
            format.dateFormat = "d"
            let dateNumber = format.string(from: startTime.dateValue())
            format.dateFormat = "h:mm a"
            let timeString = format.string(from: startTime.dateValue())

                if hasCompleted != true {
                    if isDeleted { return }
                    if let firstIndex = self?.eventItem.firstIndex(where: {$0.id == eventID}) {
                        self?.eventItem.remove(at: firstIndex)
                    }
            self?.eventItem.append(EventModel(id: eventID, eventName: eventName,eventDescription: eventDescription, month: month, dateNumber: dateNumber, time: startTime, startTime: timeString, location: location))
                    
                } else {
                    if isDeleted { return }
                    self?.pastEventItems.append(EventModel(id: eventID, eventName: eventName,eventDescription: eventDescription, month: month, dateNumber: dateNumber, time: startTime, startTime: timeString, location: location))
                    
                }
//            if isDeleted {
//                if let firstIndex = self?.eventItem.firstIndex(where: {$0.id == eventID}) {
//                    self?.eventItem.remove(at: firstIndex)
//                }
//            }
        }
    }
    func removeEvent(eventID: String) {
        if let firstIndex = self.eventItem.firstIndex(where: {$0.id == eventID}) {
            self.eventItem.remove(at: firstIndex)
        }
    }
    func removeEventInvitation(eventID: String) {
        if let firstIndex = invitedEvents.firstIndex(where: {$0.id == eventID}) {
            if (self.eventItem.first(where: {$0.id == eventID})) != nil {
                return
            } else {
            eventItem.append(invitedEvents[firstIndex])
            }
            invitedEvents.remove(at: firstIndex)
        }
    }

    var listener: ListenerRegistration?
    var listener2: ListenerRegistration?
    var listener3: ListenerRegistration?
    deinit {
        listener?.remove()
        listener2?.remove()
        listener3?.remove()
    }
}


class EventMessageLikesOO: ObservableObject {
    @Published var messageLikes = [Person]()
    @Published var firstTenLikes = [Person]()
    var listener : ListenerRegistration?
    let id: String
    let eventID: String
    let conversationID: String
    let messageID: String
    
    init(id: String, eventID: String, conversationID: String, messageID: String) {
        self.id = id
        self.eventID = eventID
        self.conversationID = conversationID
        self.messageID = messageID
        fetchMessageLikesFromCache(){ [weak self] lastTimestamp,error in
            self?.startMessageLikeListener(lastTimestamp: lastTimestamp)
        }
    }
    
    private func fetchMessageLikesFromCache(callback: @escaping (_ lastTimestamp: Timestamp?, _ error: Error?) -> Void){
        let docRef = EventMessageModel
                 .getEventConversationMessageLikeRef(eventID: eventID, conversationID: conversationID, messageID: messageID)
                 .order(by: "time")
             docRef.getDocuments(source: .cache) {[weak self] querySnapshot, error in
                 guard let documents = querySnapshot?.documents, error == nil else {
                     callback(nil,error)
                     return
                 }
                 documents.forEach { doc in
                     if let sentBy = doc.get("sentBy") as? String{
                         self?.buildLikes(sentBy: sentBy)
                     }
                 }
                 let lastTimestamp = documents.last?.get("time") as? Timestamp
                 callback(lastTimestamp,nil)
             }
    }
    
    private  func startMessageLikeListener(lastTimestamp : Timestamp?){
        listener?.remove()
        
        let docRef = EventMessageModel.getEventConversationMessageLikeRef(eventID: eventID, conversationID: conversationID, messageID: messageID)
        var query: Query?
        if let lastTimestamp = lastTimestamp{
            query = docRef.whereField("time", isGreaterThan: lastTimestamp)
        }
        listener = (query ?? docRef).addSnapshotListener{ [weak self] (querySnapshot, error) in
            guard let documentChanges = querySnapshot?.documentChanges, error == nil else {
                print("Error fetching documents: \(error?.localizedDescription ?? "" )")
                return
            }
            for documentChange in documentChanges {
                if documentChange.type == .added {
                    let sentBy = documentChange.document.data()["sentBy"] as? String ?? ""
                        self?.buildLikes(sentBy: sentBy)
                }
            }
        }
    }
    
    private func buildLikes (sentBy: String) -> Void {
        Person.fetchLatestUserUsingCTN(id: sentBy){ [weak self]  (person, aResend, error) in
            if let person = person {
                self?.updateLikesArrays(person: person, aResend: aResend)
            }else  {
                print("buildLikes error ",error?.localizedDescription ?? "")
            }
        }
    }
    
    private func updateLikesArrays(person: Person,aResend : Bool?){
        if aResend == true {
            if let index = self.messageLikes.firstIndex(where: {$0.id == person.id }){
                self.messageLikes[index] = person
            }
            if self.messageLikes.count < 11 ,
               let index = self.firstTenLikes.firstIndex(where: {$0.id == person.id }){
                self.firstTenLikes[index] = person
            }
        }else{
            self.messageLikes.append(person)
            if self.messageLikes.count < 11 {
                self.firstTenLikes.append(person)
            }
        }
    }
    deinit {
        listener?.remove()
    }
}

extension EventModelOO {
    func getEventDetails(eventID: String, callback : (@escaping (_ event : EventModel? , _  error : Error?) -> Void)) {
        let docRef = Firestore.firestore().collection("AllEvents").document(eventID)
        docRef.getDocument { (document, error) in
            let dict = document?.data()
            let eventID = document?.documentID ?? ""
            let eventName = dict?["eventName"] as? String ?? ""
            let eventDescription = dict?["eventDescription"] as? String ?? ""
            let startTime = dict?["eventTimeStart"] as? Timestamp ?? Timestamp()
            let location = dict?["location"] as? String ?? ""
            let format = DateFormatter()
            format.dateFormat = "MMM"
            let month = format.string(from: startTime.dateValue())
            format.dateFormat = "d"
            let dateNumber = format.string(from: startTime.dateValue())
            format.dateFormat = "h:mm a"
            let timeString = format.string(from: startTime.dateValue())

           let event = EventModel(id: eventID, eventName: eventName,eventDescription: eventDescription, month: month, dateNumber: dateNumber, time: startTime, startTime: timeString, location: location)
            callback(event, nil)
            print("event = \(event)")
        }
//        return event
    }
}

class IndividualEventRequestedUsersOO: ObservableObject {
    @Published var eventRequest = [String: EventRequest]()
    @Published var friendsDictionary = FriendsDictionary()
    init (eventID: String, friendsDictionary : FriendsDictionary) {
        self.friendsDictionary = friendsDictionary
        
        let collectionRef = Firestore.firestore().collection("AllEvents").document(eventID.nonEmpty).collection("RequestToJoin")
        self.listener =  collectionRef.addSnapshotListener { [weak self] (snap, error) in
            guard let documentChanges = snap?.documentChanges, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            for documentChange in documentChanges {
                if documentChange.type == .added {
                    let document = documentChange.document
                    let requestingUserID = document.documentID
                    let message = document.data()["message"] as? String ?? ""
                    let token = document.data()["sentByUserToken"] as? String ?? ""
                    if self?.friendsDictionary.friendsDictionary[requestingUserID] != nil {
                        let friend = self?.friendsDictionary.friendsDictionary[requestingUserID] ?? Person(id: "")
                        let request = EventRequest(id: requestingUserID, person: friend, message: message, token: token)
                        self?.eventRequest[requestingUserID] = request
                    } else {
                        Person.fetchFriend(id: requestingUserID ,source: .default)  {[weak self] user, error in
                            if let user = user{
                                let request = EventRequest(id: requestingUserID, person: user, message: message, token: token)
                                self?.eventRequest[requestingUserID] = request
                            }
                        }
                    }
                }
                if documentChange.type == .removed {
                    let document = documentChange.document
                    let notRequestingUserID = document.documentID
                    if self?.eventRequest[notRequestingUserID] != nil {
                        self?.eventRequest.removeValue(forKey: notRequestingUserID)
                    }
                }
            }
        }
    }
    func removeRequest(id: String) {
        self.eventRequest.removeValue(forKey: id)
    }
    var listener: ListenerRegistration?
    deinit {
        listener?.remove()
    }
}
