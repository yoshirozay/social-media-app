//
//  ChatModel.swift
//  speakEZ
//
//  Created by Ahmad naeem on 12/11/21.
//

import FirebaseFirestore

struct ChatModel {
    var chatUID : String
    var isAGroup : Bool = false
    ///for now we need to decide that will the members will also include the current user or not. i think we should not add current user in the members
    ///but for now we are adding the current user as well to make it simple
    var otherMembers : [Person]
    var lastMessage : MessageModel?
    //its UserChatss time
    var time : Date
    var groupName : String = ""
    var usersWhoLeft : [String]?
    var status : Status = .successfull
    internal init(chatUID: String, isAGroup: Bool, members: [Person], lastMessage : MessageModel?, time: Date, groupName : String = "",status : Status  = .successfull,usersWhoLeft : [String]? = nil) {
        self.chatUID = chatUID
        self.isAGroup = isAGroup
        self.otherMembers = members
        self.lastMessage = lastMessage
        self.time = time
        self.groupName = groupName
        self.status = status
        self.usersWhoLeft = usersWhoLeft
    }
    
    init(userChat: UserChatss, members: [Person],lastMessage : MessageModel?) {
        self.init(chatUID: userChat.documentId,
                  isAGroup: userChat.isGroupChat,
                  members: members,
                  lastMessage: lastMessage,
                  time: userChat.time,
                  groupName: userChat.chatGroup?.name ?? "",
                  usersWhoLeft: userChat.chatGroup?.usersWhoLeft)
    }
    
    var firstFourUsers : [Person]{
       return Array(self.otherMembers.prefix(4))
    }
    
    var allMembersDict : [String : Person]{
        otherMembers.reduce(into: [String : Person]()) {  $0[$1.id] = $1  }
    }
    
    /**For now used only for group chats,so otherUserID will always be empty string */
    var selectedGroup : SelectedChat  {
        SelectedChat(chatId: chatUID, groupName: groupName) 
    }
    var otherMembersIds : [String]{
        otherMembers.map({$0.id})
    }
    init?(realmChatModel : RealmChatModel) {
        
        self.chatUID = realmChatModel.chatUID
        self.isAGroup = realmChatModel.isAGroup
        self.otherMembers = realmChatModel.dummyMembers
        self.lastMessage = nil
        self.time = realmChatModel.time
        self.groupName = realmChatModel.groupName
        self.status = .sending
        self.usersWhoLeft = nil
 
    }
    
}

extension ChatModel : Identifiable, Hashable {
    var id : String { chatUID }
}
 
extension ChatModel  : RealmCacheable {
    var objectKey : String{
        chatUID
    }
    func saveInRealm(callback: @escaping (Error?) -> Void) {
        let RealmChatModel = RealmChatModel(chatModel: self)
        RealmChatModel.saveInRealm(callback : callback)
    }
    
    func removeFailedObjectsFromCache(callback: @escaping (Error?) -> Void = {_ in}) {
        RealmRawMessage.updateGroupChatMessage(isFailed: true, canReSend: true, chatUID: id)
        Self.removeFailedMessageFromCache(objectKey : objectKey, mediaKind: nil,callback : callback)

    }
    
   static func getFromRealm() -> ChatModel?  {
        if let realmChatModel = RealmChatModel.getOldest(),
           let ChatModel = ChatModel(realmChatModel: realmChatModel) {
            return ChatModel
        }
        return nil
    }
    
    func updateCacheCopy(isSentSuccessfully isSent : Bool){
       let _ = isSent ? removeFailedObjectsFromCache() : markAsFailedChatModel() 
    }
    
    func markAsFailedChatModel() {
        RealmChatModel.markAs(failed: true, chatUID: chatUID)
    }
    
    func saveInCache(callback : @escaping ( _  error : Error?) -> Void = {_ in}) {
        saveAsTemp(newMedia: nil,callback: callback)
    }
    
    static func removeFailedMessageFromCache(objectKey : String, mediaKind: NewMedia.Kind?, callback: @escaping (Error?) -> Void = {_ in}) {
        RealmChatModel.deleteFromRealm(chatUID: objectKey) { error in
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
}

struct SelectedChat {
    var otherUserID : String = ""
    var chatId: String
    var groupName: String = ""
}
 
