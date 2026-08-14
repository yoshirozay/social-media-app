//
//  FailedRequestManager.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 8/15/21.
//
 
import Combine
import RealmSwift
 
class FailedMessageManager : FailedManager,FailedObjectManagAble {
     
    typealias ResendAbleObject = MessageModel.Raw
    typealias RealmFailAbleObject = RealmRawMessage
     
    
    override init() {
        super.init()
        self.addNetworkAvailabilityListener()
    }
     
    func sendObjectUsingCloudFunc(obj: ResendAbleObject.RawResendAbleObject) { 
        SendMessageFunctions.sendNewMessage(messageRaw: obj,isAResend: true) {[weak self] error in
            self?.cloudFuncCallBackResponse(obj: obj, error: error)
        }
    }
    
    static let shared = FailedMessageManager()
     
    static func configure() {
        ReachabilityService.configure()
        let _ = Self.shared
    }
     
}
 
/*
 so now we will create failedRequestManager
 which will handle all of the failed and resending of docs
 so first we will work on re send messages.
 so when sendMessage cloud func will be called we will add it in the ud
 and when we will get callback from the cloud func we will remove it if it was successfull.
 now if it was not successfull we will not remove it.
 so when the app will start again we will check all the ids of objects which are in the user defuLT AND were failed to be delevired. now we will send them one by one for now.
 for that we will also have save an array of all message ids. so
 
 so before trying to send the message again. we will first check from the server that does such document exist?
 if not then we will resend the message. the reason is that. it is possible that message was sent but cloud fun callback was not recive for some resaons ( which can be network disconnectivity, user closing app etc).
 
 now 
 */
/*
 so the best thing would be to get one message at a time from realm and then send message. that way we will not use alot of memory by getting all failed messages at once. we will just get first realm msg. then we will send it. after that we will check does this message has been sent, if we get a callback as true. if yes then we will send it again. but if we  did get callback as true but the message was not deleted from the realm we will delete it and start with the next message or until we have no more messages in realm
 
 now user sent a message while app was offline. 5 msg failed. we will add a realm listener when we will stop resending messaege, or we have sent all messages. that why when we will get new failed messages
 
 */


