//
//  OldestObjectFetchAble.swift
//  speakEZ
//
//  Created by Ahmad naeem on 12/18/21.
//
 
import SwiftUI
import Foundation

protocol OldestObjectFetchAble : RealmCacheable {
    associatedtype RawResendAbleObject : OldestObjectFetchAble
    static func getOldestFromRealm() -> RawResendAbleObject?
    ///this var is for any case that model can be Corrupted while it was been saved in the cahce. like it happens with video saving and such
    var isCorrupted : Bool {get}
}
extension OldestObjectFetchAble {
    var isCorrupted : Bool { false }
}

extension PostModel.Raw : OldestObjectFetchAble {
    typealias RawResendAbleObject = PostModel.Raw
    
    static func getOldestFromRealm() -> RawResendAbleObject? {
        Self.getOldestPostFromRealm()
    }
    var isCorrupted : Bool {
        SelectedMedia.isTempMediaCorrupted(objectKey: objectKey, selectedMediaKind: selectedMediaKind)
//        if let _ = self.newMedia?.videoUrl,
//           VideoCacheManager.shared.doesTmpFileExistFor(key: objectKey) == false {
//            return true
//        }
//        return false
    }

}

extension MessageModel.Raw : OldestObjectFetchAble {
    typealias RawResendAbleObject = MessageModel.Raw
    
    static func getOldestFromRealm() -> RawResendAbleObject? {
        Self.getOldestMessageFromRealm()
    }
    var isCorrupted : Bool {
        SelectedMedia.isTempMediaCorrupted(objectKey: objectKey, selectedMediaKind: selectedMediaKind) 
//        if let _ = self.newMedia?.videoUrl,
//           VideoCacheManager.shared.doesTmpFileExistFor(key: objectKey) == false {
//            return true
//        }
//        return false
    }
}

extension UserProfile : OldestObjectFetchAble {
    typealias RawResendAbleObject = UserProfile
    
    static func getOldestFromRealm() -> RawResendAbleObject? {
        Self.getFromRealm()
    }
    
}

extension ChatModel : OldestObjectFetchAble {
    typealias RawResendAbleObject = ChatModel
    
    static func getOldestFromRealm() -> RawResendAbleObject? {
        Self.getFromRealm()
    }
    
}
