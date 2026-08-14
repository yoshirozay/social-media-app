//
//  FailedChatModelManager.swift
//  speakEZ
//
//  Created by Ahmad naeem on 12/30/21.
//

import Foundation


import Combine
import RealmSwift
import FirebaseAuth
import Foundation

class FailedChatModelManager : FailedManager,FailedObjectManagAble {
     
    typealias ResendAbleObject = ChatModel
    typealias RealmFailAbleObject = RealmChatModel
      
    override init() {
        super.init()
        self.addNetworkAvailabilityListener()
    }
    
    func sendObjectUsingCloudFunc(obj: ResendAbleObject.RawResendAbleObject) {
        guard let userId = currentUserID else { return }
        UserChatss.doesUserChatssExist(chatUID: obj.id, userId: userId) {[weak self] doesExist, error in
            if doesExist || error != nil {
                obj.updateCacheCopy(isSentSuccessfully: error == nil)
                self?.cloudFuncCallBackResponse(obj: obj,error: error)
            }else{
                CreateGroupUserChatFunction.create(chatModel: obj,isAResend : true){ [weak self] error in
                    self?.cloudFuncCallBackResponse(obj: obj,error: error)
                }
            }
        }
    }
    
    static let shared = FailedChatModelManager()
        
    static func configure() {
        ReachabilityService.configure()
        let _ = Self.shared
    }
     
}
 
/*
 we will do this in two steps. first chatModel and then will update the messageFAiledManager for use of the chat model first messages
 1. ChatModel
 
 for that first we will need to make a realmChatModel. we do not need a raWChatModel. we will just use the current ChatModel like we used for userProfile.
 now the difference we will have is that we do not have group photo fro now. but we will have it in future for sure.
 so we need to make sure that we can easliy add photo as weill in future if needed.
 */
/*
 so now as we have setup the chat model failed manager. now we need to add a listner for it in the AllMessages as well. and also need to fetch users from the id as well
 */
