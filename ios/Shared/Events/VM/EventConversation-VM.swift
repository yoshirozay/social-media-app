//
//  EventConversation-VM.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 8/12/22.
//

import Foundation
import Firebase
import SwiftUI

class IndividualEventConversationOO: ObservableObject {
    @Published var messages = [EventMessageModel]()
    @Published private (set) var goToBottom : Bool = false
    @Published var personDict = [String : Person]()
    @Published var friendsDictionary = FriendsDictionary(addFriendsListener : false)
    
    var sortedMessages : [EventMessageModel]{
      messages.sorted(by: {$0.time  < $1.time })
    }
    private let eventID : String
    private let conversationID : String
    init(eventID: String, conversationID: String) {
        self.eventID = eventID
        self.conversationID = conversationID
        getAllMessagesOfConvo(eventID: eventID, conversationID: conversationID, source: .cache)
    }
    private func getAllMessagesOfConvo(eventID: String, conversationID: String, source: FirestoreSource = .default) {
        friendsDictionary.getFriendsDictionary(source: source) { [weak self] (_, error) in
            if let errorCode = (error as NSError?)?.code,

               FirestoreErrorCode.unavailable.rawValue != errorCode {
                print(error?.localizedDescription ?? "")
            }else{
                if self?.personDict.count == 0 {
                self?.personDict[currentUserID ?? ""] = self?.friendsDictionary.friendsDictionary[currentUserID ?? ""]
                }
                self?.getAllMessages(eventID: eventID, conversationID: conversationID, source: source) { lastTime in
                    self?.addMessageListener(eventID: eventID, conversationID: conversationID, lastTimestamp: lastTime)
                }
                    self?.goToBottom.toggle()
                  
//                self?.startListenersForNewFriends(id: id)
            }
            
        }
    }
    private func getAllMessages(eventID: String, conversationID: String, source: FirestoreSource,callback : @escaping ( _  lastTime : Timestamp?) -> Void) {
        self.fetchMessageDocs(eventID: eventID, conversationID: conversationID, source: source) {[weak self]  documents, _ in
            
            for document in documents {
                self?.buildMessageDictionaries(document, eventID: eventID)
            }
            
            let allTimeStamp = documents.compactMap({$0.get("time") as? Timestamp})
            let lastTime = allTimeStamp.max(by: {$0.dateValue() < $1.dateValue() })
            callback(lastTime)
        }
    }
    private func fetchMessageDocs(eventID: String, conversationID: String, source: FirestoreSource, callback : @escaping (_ docs : [QueryDocumentSnapshot],  _  error : Error?) -> Void){
        let docRef = EventMessageModel.getEventConversationCollRef(eventID: eventID, conversationID: conversationID)
        
        docRef.getDocuments(source: source) { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents,error == nil else {
                print("Error fetching documents: ",error?.localizedDescription ?? "")
                callback([], error)
                return
            }
            callback(documents, nil)
        }
    }
    private func buildMessageDictionaries(_ userMessage: DocumentSnapshot?, eventID: String,source: FirestoreSource = .default ) {
      
        guard let messageDict = userMessage?.data(),
              let messageID = userMessage?.documentID   else {
            return
        }
        let messageModel = EventMessageModel(messageDict: messageDict, messageID: messageID)
        let sentBy = messageModel.id
        buildMessage(messageModel)
        if let person = friendsDictionary.friendsDictionary[sentBy] {
            self.buildUserDictionary(person.id, person: person)
        }else{
            //only fetch for non friends
            buildUserInfoDictionary(source :source ,sentBy: sentBy)
        }
    }

    var tempMessages : [EventMessageModel] = []
    
    private  var messageListenerReg : ListenerRegistration?
    ///will start listener to the new comment added so we can also update our oo
    //user can not change / delete a comment the only thing we need to refetch is the user it self not the comments
    private func addMessageListener(eventID: String, conversationID: String, lastTimestamp : Timestamp?) {
        let docRef = EventMessageModel.getEventConversationCollRef(eventID: eventID, conversationID: conversationID)
        let listenerClouser : ( QuerySnapshot?,Error?) -> () = {
            [weak self] (querySnapshot, error) in
            if error != nil {
                print("there's an error Event-VM.swift")
                return
            }
            
            guard let documentChanges = querySnapshot?.documentChanges else {
                print("Error fetching documents: \(error?.localizedDescription ?? "" )")
                return
            }
            for documentChange in documentChanges {
                if documentChange.type == .added {
                    self?.buildMessageDictionaries(documentChange.document, eventID: eventID)
                }else if  documentChange.type == .removed {
                    print("message removed  ",documentChange.document)
                    self?.removeFromMessagesIfExist(messageID: documentChange.document.documentID)
                }
            }
        }
        
        messageListenerReg?.remove()
        if let lastTimestamp = lastTimestamp {
            messageListenerReg = docRef
                .whereField("time", isGreaterThan: lastTimestamp)
                .addSnapshotListener {listenerClouser($0,$1)}
        }else{
            messageListenerReg = docRef
                .addSnapshotListener {listenerClouser($0,$1)}
        }
    }
    func removeFromMessagesIfExist(messageID : String) {
        if let index = messages.firstIndex(where: {$0.messageID == messageID}){
            
          let _ =  withAnimation {
                 messages.remove(at: index)
            }
        }
    }
}



extension IndividualEventConversationOO {
    func buildDummyMessage(_ message: EventMessageModel) {
        self.tempMessages.append(message)
        self.buildMessage(message)
        self.goToBottom.toggle()
    }
    private func buildMessage(_ message: EventMessageModel) {

        if !tempMessages.isEmpty,
           message.status == .successfull,
           message.id == Auth.auth().currentUser?.uid ,
           let index = tempMessages.firstIndex(where: {$0.message == message.message}){
            let tempMessagesID = tempMessages[index].messageID
            if let indexTempComment = self.messages.firstIndex(where: {$0.messageID == tempMessagesID}){
                self.messages[indexTempComment] = message
                self.tempMessages.remove(at: index)
            }
        }else{
            self.messages.append(message)
            self.goToBottom.toggle()
            DispatchQueue.main.async {
            }
        }
        //        if tempComments.contains(where: { $0.commentID ==
        //        })
    }
    private func buildUserDictionary(_ dictionaryKey: String, person: Person) {
        self.personDict[dictionaryKey] = person
    }
    private func buildUserInfoDictionary(source: FirestoreSource = .default,sentBy: String,callback : @escaping (_ error : Error?) -> Void = {_ in}) -> Void {
        let docRef = Firestore.firestore().collection("UserInfo").document(sentBy.nonEmpty)
        docRef.getDocument {[weak self] (document, error) in
            
            guard let user = document else { return }
            let uid = user.documentID
            guard let userDocumentData = document?.data() else { return }
            Person.getPersonFromUserInfo(userId : uid , documentData: userDocumentData) {[weak self] (person, error) in
                if let person = person {
                    self?.buildUserDictionary(uid, person: person)
                    if source == .cache {
                        //we are doing this because this user is not a friends so he might have changed his user info so we need the freshe data so thats way first we get data from cahce to update the view, and then we update the data from the server to show latest data in the view.
                        self?.buildUserInfoDictionary(sentBy: sentBy)
                    }
                }else{
                    print(error?.localizedDescription ?? "")
                }
            }
        }
    }


}
