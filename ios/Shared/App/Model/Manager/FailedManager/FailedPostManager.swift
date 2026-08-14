//
//  FailedPostManager.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/2/21.
//
 
import Combine
import RealmSwift
  

class FailedPostManager : FailedManager,FailedObjectManagAble {
    
    typealias ResendAbleObject = PostModel.Raw
    typealias RealmFailAbleObject = RealmPost
     
    override init() {
        super.init()
        self.addNetworkAvailabilityListener()
    } 
    
    func sendObjectUsingCloudFunc(obj: ResendAbleObject.RawResendAbleObject) {
        NewPostFunctions.sendPost(rawPostModel: obj) { [weak self] error in
            self?.cloudFuncCallBackResponse(obj: obj,error: error)
        }
    }
    
    static let shared = FailedPostManager()
        
    static func configure() {
        ReachabilityService.configure()
        let _ = Self.shared
    }
     
}


