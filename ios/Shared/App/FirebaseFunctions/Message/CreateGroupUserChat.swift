//
//  CreateGroupUserChat.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 12/6/21.
//

import Foundation
import SwiftUI
import FirebaseFunctions
import Firebase
import Combine
//before this was doing our failedManger kinda job. what his vm does is just simply holds the messages and wait for the group to be created, after that it will.
class CreateGroupUserChatFunction: ObservableObject {
     
    /*
     so we will call creatChatGroup func if we already do not have a listener. and add the rawMessage in the dummyRawMsgs array
     . now if we do have a litener then we will just add the rawMsg in the dummyGroupMessages array.
     
     we will remove listener when we will get response from the listener. so the reason we are not using the callback of createChtGroup func becase it is unpredicted. but the listenr will be called if the user get online after 10 mins and so. so in case chat group was created but user goes offline  and become online after like 5 mins. if we use listener we will not lose the messages but if we use callback of the createGroupChat we will lose the messages.
     */
    class func create(chatModel: ChatModel, isAResend: Bool = false, callback : @escaping ( _  error : Error?) -> Void){
        
        if !isAResend {
            chatModel.saveInCache()
        }
        CreateGroupUserChatFunction.createGroupUserChat(chatModel: chatModel) { error in
            chatModel.updateCacheCopy(isSentSuccessfully: error == nil)
            callback(error)
            print("CreateGroupUserChatFunction.createGroupUserChat  \(error?.localizedDescription ?? "successfull")")
        }
    }
    
    class func sendMessageOfDummy(chatModel: ChatModel,messageRaw: MessageModel.Raw) {
        var messageRaw = messageRaw
        if RealmChatModel.doesExist(chatUID: chatModel.id) == false{
              print("sendMessageOfDummy  = ")
            create(chatModel: chatModel) {
                print("CreateGroupUserChatFunction.createGroupUserChat  \($0?.localizedDescription ?? "successfull")")
            }
        }
        messageRaw.canReSend = false
        messageRaw.saveInCache()
        //first we need to change canReSend to false and then need to add this condition every where that we fetch it from the realm as well. and we also need to add this in realm as well.
        //        messageRaw.saveInCache()
    }
    
    //will use similar func in the       chatModel.updateCacheCopy(isSentSuccessfully: error == nil) and then we will either update the canReSend or we will just wait
    func checkForDummyChatModelMessages(chatModel : ChatModel) {
      let d = RealmRawMessage.getFromRealm(chatUID: "d")
        let dummyGroupMessages : [ MessageModel.Raw] = []
        guard chatModel.status == .successfull else { return }
        let chatUID = chatModel.id
        
        let allRawMsgs = dummyGroupMessages.filter { $0.chatUID == chatUID}
        if  allRawMsgs.isNotEmpty {
            let dispatchGroup = DispatchGroup()
            allRawMsgs.forEach { rawMsg in
                dispatchGroup.enter()
                rawMsg.saveInCache{ error in
                    if let error = error {
                        print("error \(error.localizedDescription)")
                    }
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
//                RealmRawMessage.updateAllMsgsIsFailed(to: true, ofChatUID: chatUID)
            }
        }
    }
    
}
 
    extension CreateGroupUserChatFunction: CloudFunction {
    fileprivate class func createGroupUserChat( chatModel : ChatModel, callback : @escaping (_ error : Error?) -> Void ){
             
            let users = chatModel.otherMembers.map({$0.id})
            
            var name = chatModel.groupName 
            if name.trimWhitespacesAndNewlines() == "" {
                name = "Group Chaat"
            }
            let messageInformation : [String: Any] = [
                Constant.chatUID(): chatModel.id,
                Constant.users(): users,
                Constant.name(): name
            ]
            call(funcName: Constant.createGroupUserChat(), informationDict: messageInformation, callback: callback)
        }
        
        enum Constant : String {
            case createGroupUserChat = "createGroupUserChat-createGroupUserChat"
            case chatUID
            case users
            case name
        }
    }
 
/*
 now we will add new message which user sent before the chatModel is created, in the realm with a properie called
 
canReSend
 so if it is true we do not fetch them. so when the group will be created we will change this property to false
 */
