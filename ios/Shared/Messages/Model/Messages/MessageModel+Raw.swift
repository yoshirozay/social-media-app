//
//  MessageModel+Raw.swift
//  speakEZ
//
//  Created by Ahmad naeem on 8/15/21.
//

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import SDWebImage
import RealmSwift

enum MessageKind : Int, PersistableEnum {
    case sendTo
    case openConversation
}
 
extension MessageModel {
    struct Raw {
       private(set) var messageUID: String = UUID().uuidString
        private(set) var sentBy: String
        private(set) var message: String
        //FIXME: - need to check why we can not mark it private (set) why are we chaning it after init
        var chatUID: String
        private(set) var otherUserID: String
        private(set) var token: String
        private(set) var nameOfSendingUser: String
        private(set) var newMedia: NewMedia?
        private(set) var isFirstMessage : Bool = false
        private(set) var alreadyViewOnce : Bool?
        private(set) var isGIF : Bool?
        ///only using in Codable for saving in userdefault for resending in case of failer
        private(set) var mediaKind : NewMedia.Kind?
        private(set) var sendTime : Date?
        private(set) var msgKind : MessageKind = .openConversation
        private(set) var groupName : String = ""
        var canReSend = true
        var isFailed = false
        private(set) var audioDirURL : URL?
        var selectedMediaKind :  NewMedia.Kind?{
            audioDirURL == nil ? newMedia?.kind : .audio
        }
        
        var isViewOnceMessage: Bool {
            alreadyViewOnce != nil
        } 
        
        var isGroupMessage : Bool{
            otherUserID.isEmpty
        }
        //it means that is message or selected media exist
        var isContentEmpty: Bool{
            message.isEmpty && newMedia == nil && audioDirURL == nil
        }
        var messageInformation : [String : Any]  {
            var dict : [String : Any] =  [
                Constant.sentBy(): sentBy,
                Constant.message() :  message.trimWhitespacesAndNewlines(),
                Constant.messageUID() :  messageUID,
                Constant.chatUID() :  chatUID,
                Constant.nameOfSendingUser() : nameOfSendingUser,
            ]
            dict[Constant.alreadyViewOnce()] = alreadyViewOnce
            dict[Constant.isGIF()] = isGIF
            if otherUserID.isNotEmpty {
                dict[Constant.otherUserID()] = otherUserID
                dict[Constant.token()] = token
            }else if groupName.isNotEmpty{
                dict[Constant.groupName()] = groupName
            }else{
//                assert(false,"some thing is wrong here should check")
            }
            return dict
        }
        
        func getMessageModel(isTimeStringInDays : Bool = false) -> MessageModel {
            MessageModel(messageRaw: self,isTimeStringInDays: isTimeStringInDays)
        }
    }
}
extension MessageModel.Raw : RealmCacheable  {
    var objectKey : String {
       return self.messageUID
    }
    init?(realmRawMsg : RealmRawMessage) {
        self.messageUID = realmRawMsg.messageUID
        self.sentBy = realmRawMsg.sentBy
        self.message = realmRawMsg.message
        self.chatUID = realmRawMsg.chatUID
        self.otherUserID = realmRawMsg.otherUserID
        self.token = realmRawMsg.token
        self.nameOfSendingUser = realmRawMsg.nameOfSendingUser
        self.isFirstMessage = realmRawMsg.isFirstMessage
        self.sendTime = realmRawMsg.sendTime
        self.msgKind = realmRawMsg.msgKind 
        self.groupName = realmRawMsg.groupName
        self.mediaKind = realmRawMsg.kind
        self.isFailed = realmRawMsg.isFailed
        self.canReSend = realmRawMsg.canReSend
        if let kind = mediaKind {
                if let selectedMedia = SelectedMedia.getSelectedMediaFromCacheFor(key: objectKey, kind: kind){
                    self.newMedia = selectedMedia.newMedia
                    self.audioDirURL = selectedMedia.audioUrl
                }else{
                    return nil
                }  
        }
        self.isGIF = realmRawMsg.isGIF
    }
      
   
    func saveInCache(callback : @escaping ( _  error : Error?) -> Void = {_ in}) {
         saveAsTemp(newMedia: newMedia, audioDirURL: audioDirURL, callback: callback)
    }
    
    internal func saveInRealm(callback: @escaping (Error?) -> Void = {_ in}) {
         let realmRawMsg = RealmRawMessage(rawMsg: self)
        realmRawMsg.saveInRealm(callback: callback)  
     }
    
    ///it remove failed Messages. and also attached media  from ther respactive cache as well. its not for the
    func removeFailedObjectsFromCache(callback : @escaping (_ error : Error?) -> Void = {_ in}) {
        Self.removeFailedMessageFromCache(objectKey : objectKey, mediaKind: selectedMediaKind, callback: callback)
    }
    
    static func removeFailedMessageFromCache(objectKey : String, mediaKind: NewMedia.Kind?, callback: @escaping (Error?) -> Void = {_ in}) {
        RealmRawMessage.deleteFromRealm(messageUID: objectKey) { error in
            callback(error)
            if let error = error {
                print(error.localizedDescription )
            }else{
                if let kind = mediaKind {
                    SelectedMedia.deleteRealmObjectMediaFromCache(objectKey: objectKey, kind: kind)
                }
            }
        }
    }
    
    func updateCacheCopy(isSentSuccessfully isSent : Bool){
        if isSent {
            removeFailedObjectsFromCache()
        } else {
            markAsFailedMessage()
        }
    }
    
    func markAsFailedMessage() {
        RealmRawMessage.markAs(failed: true, messageUID: messageUID)
    }
    
//    static func getFromCache(objectKey : String) -> MessageModel.Raw? {
//        if let realmRawMessage = RealmRawMessage.getFromRealm(messageUID: objectKey),
//           let rawMsg = MessageModel.Raw(realmRawMsg: realmRawMessage) {
//            return rawMsg
//        } else {
//            assert(false, "nope something went wrong")
//        }
//        return nil
//    }
    
   static func getOldestMessageFromRealm() -> MessageModel.Raw?  {
        if let realmRawMessage = RealmRawMessage.getOldest(),
           let rawMsg = MessageModel.Raw(realmRawMsg: realmRawMessage) {
            return rawMsg
        } else {
//            assert(false, "nope something went wrong")
        }
        return nil
    }
     
    static func getFailedRealmMessagesOf(otherUserID : String) -> [MessageModel] {
        let chatRealmRawMessages = RealmRawMessage.getFromRealm(otherUserID: otherUserID)
        return chatRealmRawMessages
    }
    
}
/*
 so  by the defination of message if the chat does not exist that is not a message and we shuld not treat it as one as welll
 */
/*
 so we do not need message
 */
/*
 so we will save ids with ordering or we will save rawMSg with date so we can send message with tie
 */
