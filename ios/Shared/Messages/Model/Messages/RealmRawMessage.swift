//
//  RealmRawMessage.swift
//  speakEZ
//
//  Created by Ahmad naeem on 8/29/21.
//

import Foundation
import RealmSwift
import Realm
import Combine

class RealmRawMessage : Object {
    
    @Persisted(primaryKey: true)  var messageUID : String
    @Persisted  var sentBy: String
    @Persisted  var message: String
    @Persisted  var chatUID: String
    @Persisted  var otherUserID: String
    @Persisted  var token: String
    @Persisted  var nameOfSendingUser: String
    @Persisted  var isFirstMessage : Bool = false
    @Persisted  var kind : NewMedia.Kind?
    @Persisted  var sendTime : Date
    @Persisted  var isFailed : Bool = false
    @Persisted  var alreadyViewOnce : Bool?
    @Persisted  var msgKind : MessageKind = .openConversation
    @Persisted  var groupName : String
    @Persisted  var canReSend: Bool = true
    @Persisted  var isGIF : Bool?
    
    convenience init(rawMsg : MessageModel.Raw) {
        self.init()
        self.messageUID = rawMsg.messageUID
        self.sentBy = rawMsg.sentBy
        self.message = rawMsg.message
        self.chatUID = rawMsg.chatUID
        self.otherUserID = rawMsg.otherUserID
        self.token = rawMsg.token
        self.nameOfSendingUser = rawMsg.nameOfSendingUser
        self.isFirstMessage = rawMsg.isFirstMessage
        self.kind = rawMsg.selectedMediaKind 
        self.sendTime = Date()
        //we use this for realm listener. so we can resent message without the need to app re-launch
        self.isFailed = false
        self.alreadyViewOnce = alreadyViewOnce
        self.msgKind = rawMsg.msgKind
        self.groupName = rawMsg.groupName 
        self.isFailed = rawMsg.isFailed
        self.canReSend = rawMsg.canReSend
        self.isGIF = rawMsg.isGIF
    }
    //but do not thing we need this we can just add listener with sentTime greater then current and with isFailed to only get notifi if a user message fails
}
extension RealmRawMessage : RealmFailAble {
    
    class func updateAllMsgsIsFailedProperty(to isFailed : Bool){
        guard let realm = try? Realm(),
              let realmRawMessages = getAllFailedObjectsResult()?.filter(Constant.canReSend() + " == %@",true) else { return  }
        
        DispatchQueue.main.async {
            do {
                try realm.write {
                    realmRawMessages.forEach({$0.isFailed = isFailed})
                }
            } catch {
                assert(false, " what happend   saveInRealm \(error.localizedDescription)")
            }
        }
    }
     
    class func save(rawMsg : MessageModel.Raw) {
        let realmRawMsg = RealmRawMessage(rawMsg : rawMsg)
        realmRawMsg.saveInRealm()
    }
    
    class func getFromRealm(messageUID : String) -> RealmRawMessage? {
        guard let realm = try? Realm() else { return nil }
        let realmRawMessage = realm.objects(RealmRawMessage.self).filter("\(Constant.messageUID() ) == %@",messageUID).first
        return realmRawMessage
    }
     
    class func getOldest() -> RealmRawMessage? {
        guard let realm = try? Realm() else { return nil }
        let realmRawMessage = realm.objects(RealmRawMessage.self)
            .filter(Constant.canReSend() + " == %@",true)
            .sorted(byKeyPath: Constant.sendTime() , ascending: true)
            .first
        return realmRawMessage
    }
    
    class func deleteFromRealm(messageUID : String, callback : @escaping ( _ error : Error?) -> Void = {_ in}) {
        if let realmRawMessage = getFromRealm(messageUID: messageUID) {
            deleteFromRealm(realmObject: realmRawMessage) { callback($0) }
        }
    }
    
    class func markAs(failed : Bool,messageUID : String){
        if let realmRawMsg = getFromRealm(messageUID: messageUID){
            realmRawMsg.markAs(failed: failed)
        }
    }
    
    func markAs(failed : Bool, callback : @escaping (_ error : Error?) -> Void = {_ in}) {
        DispatchQueue.main.async {
            do {
                let realm = try Realm()
                try realm.write {
                    self.isFailed = failed
                }
            } catch {
                callback(error)
                assert(false, " what happend   saveInRealm \(error.localizedDescription)")
            }
        }
    }
    
    enum Constant : String {
        case messageUID
        case sendTime
        case isFailed
        case otherUserID
        case chatUID
        case canReSend
    }
}
 
extension RealmRawMessage {
    func getMessageModel(isTimeStringInDays : Bool = false) -> MessageModel? {
        MessageModel.Raw(realmRawMsg: self)?.getMessageModel(isTimeStringInDays: isTimeStringInDays)
    }
    class func getFromRealm(otherUserID : String) -> [MessageModel]  {
        if let chatRealmRawMessages = getRealmResultFor(otherUserID: otherUserID)?.toArray() {
            let failed : [MessageModel] = chatRealmRawMessages.compactMap {  $0.getMessageModel() }
            return failed
        }
        return []
    }
    
    class func deleteAllMessagesOf(otherUserID : String) {
        if let result = getRealmResultFor(otherUserID: otherUserID) {
            result.forEach { msg in
                if let kind = msg.kind {
                    SelectedMedia.deleteRealmObjectMediaFromCache(objectKey: msg.messageUID, kind: kind)
                }
            }
            Self.deleteAll(realmObjects: result) { error in
                print(error?.localizedDescription ?? "deleteAllMessagesOf delete friend")
            }
        }
    }
    
    private class func getRealmResultFor(otherUserID : String) -> Results<RealmRawMessage>? {
        guard let realm = try? Realm() else { return nil }
        let results = realm.objects(RealmRawMessage.self).filter("\(Constant.otherUserID() ) == %@",otherUserID)
        return results
    }
     
    class func getAllChatsLastFailedRealmMsgResults() ->  Results<RealmRawMessage>?{
        guard let realm = try? Realm() else { return nil }
        let lastFailedRealmRawMessages = realm.objects(RealmRawMessage.self)
            .sorted(byKeyPath: Constant.sendTime() , ascending: false)
//          .distinct(by: ["otherUserID"])
            .distinct(by: [Constant.chatUID()])
        return lastFailedRealmRawMessages
    }
    
     
    class func getRealmLatestFailedMessageListener(callback : @escaping (_ newLatestFailedMessages : MessageInfo?,_ allUpdatedMessages : [MessageInfo]) -> Void) -> AnyCancellable? {
          
        var lastSentMessageInfo : MessageInfo?
        guard let results = getAllChatsLastFailedRealmMsgResults() else { return nil }
        
        let realmSubscriber = results.changesetPublisher.sink {  changes in
            
            var newMessageResults : Results<RealmRawMessage>?
            
            switch changes {
            case let .initial(initialResults):
                newMessageResults = initialResults
            case let .update(updatedResults, _, _, _):
                newMessageResults = updatedResults
            case let .error(error):
                assert(false, " results.changesetPublisher = \(error.localizedDescription) ")
            }
            
            if let result = newMessageResults {
                var newSentMessageInfo : MessageInfo?  = nil
                let msgInfos = result.getMessageInfos()
                if let lastDate = lastSentMessageInfo?.message.time.dateValue(),
                   let lastMsgInfo = msgInfos.first,
                   lastDate < lastMsgInfo.message.time.dateValue() {
                    lastSentMessageInfo = lastMsgInfo
                    newSentMessageInfo = lastMsgInfo
                }else if lastSentMessageInfo == nil {
                    lastSentMessageInfo = msgInfos.first
                    newSentMessageInfo =  msgInfos.first
                }
                
                DispatchQueue.main.async {
                    callback(newSentMessageInfo,msgInfos)
                }
            }
        }
        return realmSubscriber
    }
    class func updateAllMsgsIsFailedProperty(to isFailed : Bool, otherUserID : String){
        guard let realmRawMessages = getAllFailedObjectsResult()?
                .filter(Constant.canReSend() + " == %@",true)
                .filter(Constant.otherUserID() + " == %@",otherUserID) else { return  }
        
        DispatchQueue.main.async {
            do {
                let realm = try  Realm()
                try realm.write {
                    realmRawMessages.forEach({$0.isFailed = isFailed})
                }
            } catch {
                assert(false, " what happend   saveInRealm \(error.localizedDescription)")
            }
        }
    }
}

struct MessageInfo {
    
    var message : MessageModel
    var msgKind : MessageKind
    
    internal init(message: MessageModel, msgKind: MessageKind,mediaKind : NewMedia.Kind?) {
        self.message = message
        self.msgKind = msgKind
        self.message.addDummyLink(kind: mediaKind)
    }
}

extension Results where Element == RealmRawMessage{
     
    func getMessageInfos() -> [MessageInfo] {
        let failedMessages : [MessageInfo] = self.toArray().compactMap{ realmMsg in
            if let msg =  realmMsg.getMessageModel(isTimeStringInDays: true){
                return MessageInfo(message : msg, msgKind : realmMsg.msgKind, mediaKind: realmMsg.kind)
            }
            return nil
        }
        return failedMessages
    }

}
//MARK: - chatID funcs
extension RealmRawMessage {
    
    class private func getRealmResultFor(chatUID : String) -> Results<RealmRawMessage>? {
        guard let realm = try? Realm() else { return nil }
        let results = realm.objects(RealmRawMessage.self).filter("\(Constant.chatUID() ) == %@",chatUID)
        return results
    }
    
    class func getFromRealm(chatUID : String) -> [MessageModel]  {
        if let chatRealmRawMessages = getRealmResultFor(chatUID: chatUID)?.toArray() {
            let failed : [MessageModel] = chatRealmRawMessages.compactMap { $0.getMessageModel()
            }
            return failed
        }
        return []
    }
    class func updateGroupChatMessage(isFailed : Bool,canReSend : Bool,chatUID : String, callback : @escaping (_ error : Error?) -> Void = {_ in}) {
        if let allRealmMessages = getRealmResultFor(chatUID: chatUID) {
            DispatchQueue.main.async {
                do {
                    let realm = try Realm()
                    try realm.write {
                        allRealmMessages.forEach { realmMsg in
                            realmMsg.isFailed = isFailed
                            realmMsg.canReSend = canReSend
                        }
                    } 
                } catch {
                    callback(error)
                    assert(false, " what happend updateGroupChatMessage \(error.localizedDescription) ")
                }
            }
        }
    }
 
}
