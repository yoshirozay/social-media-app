//
//  OpenedConversationNewUserChatssManager.swift
//  speakEZ
//
//  Created by Ahmad naeem on 1/8/22.
// 
import Firebase
import FirebaseFunctions
import Combine


class OpenedConversationNewUserChatssManager {
    static func reset() {
        shared = OpenedConversationNewUserChatssManager()
    }
    static var shared = OpenedConversationNewUserChatssManager()
    private var dummyGroupMessages = [MessageModel.Raw]()
    private var subs : [String : ListenerRegistration] = [:]
    
    func getAllDummyMessagesOf(otherUserID: String) -> [MessageModel] {
        dummyGroupMessages.filter{$0.otherUserID == otherUserID}.map{$0.getMessageModel()}
    }
    
    func sendMessageOfDummy(otherUserID : String, messageRaw: MessageModel.Raw){
        dummyGroupMessages.append(messageRaw)
        if subs[otherUserID] == nil {
           addListenerForNewUserChatss(otherUserID: otherUserID)
        }
    }
    
    private func addListenerForNewUserChatss(otherUserID: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let chatQuery = UserChatss.getUserChatsQuery(currentUserId: userId, otherUserID: otherUserID)
        subs[otherUserID]?.remove()
        subs[otherUserID] = chatQuery.addSnapshotListener() {[weak self] (querySnapshot, _) in
            if let userChatss = try? querySnapshot?.documentChanges.first?.document.data(as: UserChatss.self)   {
                self?.addAllMessagesToFailedManager(chatUID: userChatss.documentId,otherUserID: otherUserID)
            }
        }
    }
    
    private func addAllMessagesToFailedManager(chatUID: String,otherUserID : String) {
        subs[otherUserID]?.remove()
        subs[otherUserID] = nil
       dummyGroupMessages.filter { $0.otherUserID == otherUserID}.forEach { rawMsg in
            var rawMsg = rawMsg
            //FIXME: - why are we updation the chatUID here need to check
            rawMsg.chatUID = chatUID
            rawMsg.isFailed = true
            rawMsg.saveInCache()
        }
        dummyGroupMessages.removeAll(where: {$0.otherUserID == otherUserID})
    }
    
    deinit{
        subs.forEach({$0.value.remove()})
        subs.removeAll()
    }
}
