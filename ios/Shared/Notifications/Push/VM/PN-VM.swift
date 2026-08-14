//
//  PN-VM.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import Combine

class PNBannerViewModel : ObservableObject, PNViewManagerCheckAble {
    let allMessagesOO: AllMessagesOO
    let timelinePosts: TimelinePostsOO
    let eventModel: EventModelOO
    @Published var notificationInfo = [NotificationBanner]()
    @Published private (set) var commentLikeVM : CommentLikeVM?
    @Published private (set) var selectedGroupChat : ChatModel?
    var sub : AnyCancellable?
    init(allMessagesOO: AllMessagesOO, timelinePosts: TimelinePostsOO, eventModel: EventModelOO) {
        self.allMessagesOO = allMessagesOO
        self.timelinePosts = timelinePosts
        self.eventModel = eventModel
        sub = NotificationCenter.default.publisher(for: .unHiddenPM)
            .compactMap{$0.object as? UNNotificationContent}
            .sink() {  [weak self] content in
                self?.getNotificationInfo(content: content)
            }
    }
    
    
    func removeNotificationInfo(id: String) {
        if self.notificationInfo.isNotEmpty {
            if let firstIndex = self.notificationInfo.firstIndex(where: {$0.id == id}){
            self.notificationInfo.remove(at: firstIndex)
            }
        }
    }
    
    func getNotificationInfo(content : UNNotificationContent) {
        print("CONTENT2 = \(content.userInfo)")
        var userInfo : [AnyHashable : Any]  {content.userInfo}
        guard let type = userInfo[PushNotificationVM.Constant.type()] as? String,
              let notificationType = PNType(rawValue: type) else { return }
        
        
        switch notificationType {
        case .newComment:
            self.appendNewCommentBanner(content: content)

        case .newPost:
            appendNewPostBanner(content: content)

        case .newGroupMessage:
            appendGroupMessageBanner(content: content)
            
        case .newPrivateMessage:
            self.appendPrivateMessageBanner(content : content)
            
        case .newFriendRequest:
            self.appendNewFriendRequest(content: content)
        case .newCommentLike:
            self.appendNewCommentLikeBanner(content: content)
        
        case .newPostLike:
            self.appendNewPostLikeBanner(content: content)
        case .newCommentMention:
            appendNewCommentMentionBanner(content: content)
        case .newPostMention:
            appendNewPostMentionBanner(content: content)
        case .newEvent:
            appendEventBanner(content: content)
        case .newEventMessage:
            appendEventMessageBanner(content: content)
        }
        
    }
    func appendNewFriendRequest(content : UNNotificationContent) {
        var resourceID: String = ""
        if let pnModel = try?  PushNotificationModel(decoding: content.userInfo){
            if  pnModel.type == .newFriendRequest {
//                timelinePosts.friendsDictionary.getUserOf(id: pnModel.userID ?? "") {[weak self] userInfo,error  in
//                    if let userInfo = userInfo,let self = self{
//                        if userInfo.isFriend {
//
//                        }
//                    }
//                }
                let banner = NotificationBanner(id: UUID().uuidString,
                                                notificationType: .newFriendRequest,
                                                resourceID: resourceID,
                                                userID: pnModel.userID ?? "",
                                                title: pnModel.aps.alert.title,
                                                body: pnModel.aps.alert.body)
                self.notificationInfo.append(banner)
            }
        }
    }
    func appendPrivateMessageBanner(content : UNNotificationContent) {
        var resourceID: String = ""
        var authorID: String = ""
        
        if let pnModel = try?  PushNotificationModel(decoding: content.userInfo){
            if  pnModel.type == .newPrivateMessage, let chatUID = pnModel.chatId{
                resourceID = chatUID
                if let chatModel = allMessagesOO.allChats.first(where: {$0.chatUID == chatUID}) {
                    if chatModel.isAGroup {
                        print(" we will check for group related data")
                    }else if let otherUserID = chatModel.lastMessage?.otherUserID {
                        authorID = otherUserID
                    }
                }
            }
            
            let banner = NotificationBanner(id: UUID().uuidString,
                                            notificationType: .newPrivateMessage,
                                            resourceID: resourceID,
                                            authorID: authorID,
                                            title: pnModel.aps.alert.title,
                                            body: pnModel.aps.alert.body)
            if shouldHideBannerPN(content: banner) {
                print("view is already open, shouldHideBannerPN == true")
            } else {
            self.notificationInfo.append(banner)
            }
        }
    }
    func appendGroupMessageBanner(content : UNNotificationContent) {
        var resourceID: String = ""
        var authorID: String = ""
        if let pnModel = try?  PushNotificationModel(decoding: content.userInfo){
            if  pnModel.type == .newGroupMessage, let chatUID = pnModel.chatId{
                resourceID = chatUID
                if let chatModel = allMessagesOO.allChats.first(where: {$0.chatUID == chatUID}) {
                    if chatModel.isAGroup {
                        if allMessagesOO.groupChatInfo[chatUID] != nil {
                            self.selectedGroupChat = chatModel
                        }
                    }else if let otherUserID = chatModel.lastMessage?.otherUserID {
                        authorID = otherUserID
                    }
                }
            }

            let banner = NotificationBanner(id: UUID().uuidString,
                                            notificationType: .newGroupMessage,
                                            resourceID: resourceID,
                                            authorID: authorID,
                                            title: pnModel.aps.alert.title,
                                            body: pnModel.aps.alert.body,
                                            userImage: pnModel.userImage)
            if shouldHideBannerPN(content: banner) {
                print("view is already open, shouldHideBannerPN == true")
            } else {
            self.notificationInfo.append(banner)
            }
        }
    }
    func appendEventMessageBanner(content : UNNotificationContent) {
        if let pnModel = try?  PushNotificationModel(decoding: content.userInfo){
            if pnModel.type == .newEventMessage, let eventID = pnModel.eventID, let authorId = pnModel.authorId {
                if let event = eventModel.eventItem.first(where: {$0.id == eventID}) {
                                let banner = NotificationBanner(id: UUID().uuidString,
                                                                notificationType: .newEventMessage,
                                                                resourceID: eventID,
                                                                authorID: authorId,
                                                                title: pnModel.aps.alert.title,
                                                                body: pnModel.aps.alert.body)
                                if shouldHideBannerPN(content: banner) {
                                    print("view is already open, shouldHideBannerPN == true")
                                } else {
                                self.notificationInfo.append(banner)
                                }
                }
            }

        }
    }
    func appendEventBanner(content : UNNotificationContent) {
        if let pnModel = try?  PushNotificationModel(decoding: content.userInfo){
            if pnModel.type == .newEvent, let eventID = pnModel.eventID {
//                if let event = eventModel.eventItem.first(where: {$0.id == eventID}) {
                                let banner = NotificationBanner(id: UUID().uuidString,
                                                                notificationType: .newEvent,
                                                                resourceID: eventID,
                                                                authorID: pnModel.authorId ?? "",
                                                                title: pnModel.aps.alert.title,
                                                                body: pnModel.aps.alert.body)
                                if shouldHideBannerPN(content: banner) {
                                    print("view is already open, shouldHideBannerPN == true")
                                } else {
                                self.notificationInfo.append(banner)
                                }
//                }
            }

        }
    }
    func appendNewCommentLikeBanner(content: UNNotificationContent) {
        var resourceID: String = ""
        if let pnModel = try?  PushNotificationModel(decoding: content.userInfo){
            if  pnModel.type == .newCommentLike, let postID = pnModel.postId{
                resourceID = postID
                if let postData = timelinePosts.postInfoValues.first(where: {$0.post.postID == postID}) {
                    let banner = NotificationBanner(id: UUID().uuidString,
                                                    notificationType: .newCommentLike,
                                                    resourceID: resourceID,
                                                    authorID: pnModel.authorId ?? "",
                                                    userID: pnModel.userID ?? "",
                                                    title: postData.post.content,
                                                    body: pnModel.comment ?? "")
                    if shouldHideBannerPN(content: banner) {
                        print("view is already open, shouldHideBannerPN == true")
                    } else {
                    self.notificationInfo.append(banner)
                    self.commentLikeVM = postData
                    }
                }
                
            }
        }
    }
    func appendNewCommentBanner(content: UNNotificationContent) {
        var resourceID: String = ""
        if let pnModel = try?  PushNotificationModel(decoding: content.userInfo){
            if  pnModel.type == .newComment, let postID = pnModel.postId{
                resourceID = postID
                if let postData = timelinePosts.postInfoValues.first(where: {$0.post.postID == postID}) {

                    let banner = NotificationBanner(id: UUID().uuidString,
                                                    notificationType: .newComment,
                                                    resourceID: resourceID,
                                                    authorID: pnModel.authorId ?? "",
                                                    userID: pnModel.commentAuthorId ?? "",
                                                    title: pnModel.aps.alert.title,
                                                    body: pnModel.aps.alert.body)
                    
                    if shouldHideBannerPN(content: banner) {
                        print("view is already open, shouldHideBannerPN == true")
                    } else {
                    self.notificationInfo.append(banner)
                    self.commentLikeVM = postData
                    }
                }
                
            }
        }
    }
    func appendNewPostBanner(content: UNNotificationContent) {
        var resourceID: String = ""
        if let pnModel = try?  PushNotificationModel(decoding: content.userInfo){
            if  pnModel.type == .newPost, let postID = pnModel.postId{
                resourceID = postID
                if let postData = timelinePosts.postInfoValues.first(where: {$0.post.postID == postID}) {

                    let banner = NotificationBanner(id: UUID().uuidString,
                                                    notificationType: .newPost,
                                                    resourceID: resourceID,
                                                    authorID: pnModel.authorId ?? "",
                                                    userID: pnModel.commentAuthorId ?? "",
                                                    title: "Moment",
                                                    body: pnModel.aps.alert.body)
                    
                    if shouldHideBannerPN(content: banner) {
                        print("view is already open, shouldHideBannerPN == true")
                    } else {
                    self.notificationInfo.append(banner)
                    self.commentLikeVM = postData
                    }
                }
                
            }
        }
    }
    func appendNewPostLikeBanner(content: UNNotificationContent) {
        var resourceID: String = ""
        if let pnModel = try?  PushNotificationModel(decoding: content.userInfo){
            if  pnModel.type == .newPostLike, let postID = pnModel.postId{
                resourceID = postID
                if let postData = timelinePosts.postInfoValues.first(where: {$0.post.postID == postID}) {
                    let banner = NotificationBanner(id: UUID().uuidString,
                                                    notificationType: .newPostLike,
                                                    resourceID: resourceID,
                                                    authorID: pnModel.authorId ?? "",
                                                    userID: pnModel.userID ?? "",
                                                    title: postData.post.content,
                                                    body: pnModel.comment ?? "")
                    if shouldHideBannerPN(content: banner) {
                        print("view is already open, shouldHideBannerPN == true")
                    } else {
                    self.notificationInfo.append(banner)
                    self.commentLikeVM = postData
                    }
                }
                
            }
        }
    }
    func appendNewPostMentionBanner(content: UNNotificationContent) {
        var resourceID: String = ""
        if let pnModel = try?  PushNotificationModel(decoding: content.userInfo){
            if  pnModel.type == .newPostMention, let postID = pnModel.postId{
                resourceID = postID
                if let postData = timelinePosts.postInfoValues.first(where: {$0.post.postID == postID}) {
                    let banner = NotificationBanner(id: UUID().uuidString,
                                                    notificationType: .newPostMention,
                                                    resourceID: resourceID,
                                                    authorID: pnModel.authorId ?? "",
                                                    userID: pnModel.userID ?? "",
                                                    title: postData.post.content,
                                                    body: pnModel.comment ?? "")
                    if shouldHideBannerPN(content: banner) {
                        print("view is already open, shouldHideBannerPN == true")
                    } else {
                    self.notificationInfo.append(banner)
                    self.commentLikeVM = postData
                    }
                }
                
            }
        }
    }
    func appendNewCommentMentionBanner(content: UNNotificationContent) {
        var resourceID: String = ""
        if let pnModel = try?  PushNotificationModel(decoding: content.userInfo){
            if  pnModel.type == .newCommentMention, let postID = pnModel.postId{
                resourceID = postID
                if let postData = timelinePosts.postInfoValues.first(where: {$0.post.postID == postID}) {
                    let banner = NotificationBanner(id: UUID().uuidString,
                                                    notificationType: .newCommentMention,
                                                    resourceID: resourceID,
                                                    authorID: pnModel.authorId ?? "",
                                                    userID: pnModel.commentAuthorId ?? "",
                                                    title: postData.post.content,
                                                    body: pnModel.aps.alert.body)
                    if shouldHideBannerPN(content: banner) {
                        print("view is already open, shouldHideBannerPN == true")
                    } else {
                    self.notificationInfo.append(banner)
                    self.commentLikeVM = postData
                    }
                }
                
            }
        }
    }
    deinit {
        sub?.cancel()
    }
}
/// we should do same with Banner
