//
//  PNViewManager.swift
//  speakEZ
//
//  Created by Ahmad naeem on 4/21/22.
//

import Foundation
import UserNotifications 
import Combine
import NotificationCenter


protocol PNViewManagerOnScreenViewAble : AnyObject { }

extension PNViewManagerOnScreenViewAble {
    var onScreenViewInfo : PNViewManager.OnScreenViewInfo? {
        PNViewManager.shared.onScreenViewInfo
    }
}

protocol PNViewManagerSetAble : AnyObject {
    var docId : String { get }
    var type: PNViewManager.OnScreenView  { get }
}
extension PNViewManagerSetAble {
    func setViewInfo(){
        guard docId.isNotEmpty else { return }
        PNViewManager.shared.set(type: type, docId: docId)
    }
    
    func removeViewInfo(){
        PNViewManager.shared.reset(docId : docId)
    }
    
    func addPushNotificationViewListener() -> AnyCancellable{
        let type = type
        return NotificationCenter.default
            .publisher(for: PNViewManager.onScreenViewPNNotification )
            .compactMap{$0.object as? OnScreenViewUpdate }
            .filter{$0.onScreenView == type}
            .sink() {[weak self]  onScreenViewUpdate in
                switch onScreenViewUpdate.status {
                case .set:
                    self?.setViewInfo()
                case .remove:
                    self?.removeViewInfo()
                }
            }
    }
    
    var publisherForNewPN : Publishers.CompactMap<NotificationCenter.Publisher, Bool>{
        let type = type
        return NotificationCenter.default
            .publisher(for: PushNotificationVM.pushNotificationTapped)
            .compactMap{(($0.object as? PNViewManager.OnScreenView) == type).falseIsNil} 
    }
}

protocol PNViewManagerCheckAble { }
extension PNViewManagerCheckAble {
    func shouldHidePN(content: UNNotificationContent) -> Bool {
        PNViewManager.shared.shouldHidePN(content: content)
    }
    func shouldHideBannerPN(content: NotificationBanner) -> Bool {
        PNViewManager.shared.shouldHideBannerPN(notificationInfo: content)
    }
    
}

class PNViewManager {
    static var shared : PNViewManager = PNViewManager()
    enum OnScreenView {
        case post
        case privateChat
        case groupChat
        case userProfile//should change it to friend request
        case event
        
    }
    var onScreenViewInfo : OnScreenViewInfo?
    
    private init(onScreenViewInfo : OnScreenViewInfo?  = nil) {
        self.onScreenViewInfo = onScreenViewInfo
    }
    
    func set(type : OnScreenView , docId : String ){
        self.onScreenViewInfo = OnScreenViewInfo(type: type, docId: docId)
        print("132# set \(String(describing: onScreenViewInfo))")
    }
    
    func reset(docId : String) {
        if onScreenViewInfo?.docId == docId {
            print("132# reset \(String(describing: onScreenViewInfo)) to nil")
            onScreenViewInfo = nil
        }
    }
    
    func shouldHidePN(content: UNNotificationContent) -> Bool {
        var hidePN = false
        if let onScreenViewInfo = onScreenViewInfo  {
            var userInfo : [AnyHashable : Any]  {content.userInfo}
            if let type = userInfo[PushNotificationVM.Constant.type()] as? String,
               let notificationType = PNType(rawValue: type),
               onScreenViewInfo.PNTypes.contains(notificationType)   {
                
                let docId = onScreenViewInfo.docId
                switch notificationType {
                case .newComment,.newPost:
                    hidePN = docId == (userInfo[PushNotificationVM.Constant.postId()] as? String)
                case .newGroupMessage,.newPrivateMessage:
                    hidePN = docId == (userInfo[PushNotificationVM.Constant.chatId()] as? String)
                case .newFriendRequest:
                    hidePN = docId == (userInfo[PushNotificationVM.Constant.userID()] as? String)
                default:
                    hidePN = false
                }
            }
        }
 
        if hidePN == false{
            NotificationCenter.default.post(name: .unHiddenPM, object: content)
        }
        return hidePN
    }
    func shouldHideBannerPN(notificationInfo: NotificationBanner) -> Bool {
        var hidePN = false
        if let onScreenViewInfo = onScreenViewInfo  {
    
                
                let docId = onScreenViewInfo.docId
            switch notificationInfo.notificationType {
                case .newComment,.newPost:
                    hidePN = docId == notificationInfo.resourceID
            case .newGroupMessage,.newPrivateMessage:
                    hidePN = docId == notificationInfo.resourceID
                default:
                    hidePN = false
                }
            
        }
//        if hidePN == false{
////            NotificationCenter.default.post(name: .unHiddenPM, object: content)
//        }
        return hidePN
    }
    struct OnScreenViewInfo{
        var type : OnScreenView
        var docId : String
        
        var PNTypes : [PNType]{
            switch type {
            case .post:
                return [.newPost,.newComment]
            case .privateChat:
                return [.newPrivateMessage]
            case .groupChat:
                return [.newGroupMessage]
            case .userProfile:
                return [.newFriendRequest] 
            case .event:
                return [.newEvent,.newEventMessage]
            }
        }
    }
}

struct OnScreenViewUpdate {
    var pnType: PNType
    var status: Update
    enum Update {
        case set
        case remove
    }
    var onScreenView: PNViewManager.OnScreenView{
        switch pnType {
        case .newPost,.newComment,.newPostLike,.newCommentLike,.newCommentMention,.newPostMention:
            return .post
        case .newPrivateMessage:
            return .privateChat
        case .newGroupMessage:
            return .groupChat
        case .newFriendRequest :
            return .userProfile
        case .newEvent, .newEventMessage:
            return .event
        }
    }
}

extension PNViewManager  {
 static let onScreenViewPNNotification = Foundation.Notification.Name("onScreenViewPNNotification")

}
/*
 one thing we might be able to do is that we can merge the state vars on the onReceive like we did with publishers.
 or we can
 for now i think the only thing we can do is use onChange an onReceive to change the stuff
 let first do this for the post
 
 or we can add a if with all vars and add a view init and on this view appear disappear we can set and reset stuff
 */
/*
 if user has opened the tag friends or likers i think we can just show the pn we can change that in future
 */
 
/*
 so now when user will get a chat pn we will close all open chats private and group both.
 for that we will add a notification observer and when we will get that we will dismiss the chat.
 so for that let us first do this for the post as we can easily implement that. because we control post from the postVM.
 
also needs to add notification observer in the instagram picker so we can close it as well */
 
