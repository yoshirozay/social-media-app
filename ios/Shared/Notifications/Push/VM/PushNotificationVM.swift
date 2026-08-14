//
//  PushNotificationVM.swift
//  speakEZ
//
//  Created by Ahmad naeem on 2/17/22.
//

import Foundation 
import Combine
import UIKit
import AVFoundation
import SwiftUI
//remove all other views when user taps on a notification
class PushNotificationVM : ObservableObject,PNViewManagerOnScreenViewAble {
    
    
    var timelinePosts: TimelinePostsOO
    var allMessagesOO: AllMessagesOO
    var eventModel: EventModelOO
    var subs = Set<AnyCancellable>()
    var allChatsSubcriber : AnyCancellable?
    @Environment(\.scenePhase) var scenePhase
    @Published var currentTab = CurrentTab()
    @Published var strangerProfile:  Person?
    @Published var isFromBannerNotification = false
    @Published var profileMatchedGeometry : String = ""{
        willSet{
            updateDict(removed:  newValue.isEmpty, type: .newFriendRequest)
        }
        didSet{
            if strangerProfile != nil {
                notificationTrigger = NotificationViewTrigger(type: .strangerProfile)
            }
            if profileMatchedGeometry.isEmpty{
                strangerProfile = nil
            }
        }
    }
    @Published var notificationTrigger: NotificationViewTrigger?
    @Published var event = EventModel(id: "")
    @Published var eventMatchedGeometry : String = "" {
        
        willSet{
            updateDict(removed:  newValue.isEmpty, type: .newEvent)
            
        }
        didSet{
            if event != nil {
                notificationTrigger = NotificationViewTrigger(type: .event)
            }
            if eventMatchedGeometry.isEmpty{
                event = EventModel(id: "")
            }
        }
        
    }
    @Published var otherUserID: String = ""{
        willSet{
            updateDict(removed:  newValue.isEmpty, type: .newPrivateMessage)
        }
        didSet{
            if otherUserID != "" {

                notificationTrigger = NotificationViewTrigger(type: .message)
            }
        }
    }
    @Published var selectedGroupChat: ChatModel?{
        willSet{
            updateDict(removed:  newValue == nil, type: .newGroupMessage)
        }
        didSet{
            if selectedGroupChat != nil {

                notificationTrigger = NotificationViewTrigger(type: .groupMessage)
            }
        }
    }
    
    @Published var post: PostModel?{
        willSet{

            updateDict(removed:  newValue == nil, type: .newPost)

        }
    }
    func clearConversations() {
        otherUserID = ""
        selectedGroupChat = nil
        notificationTrigger = nil
    }
    func updateDict(removed : Bool,type: NotificationType){
          print("123# updateDict \(zIndexDict)")
        if removed{
            zIndexDict[type] = nil
        }else{
            pnTapsCount += 1
            zIndexDict[type] = pnTapsCount
        }
        print("zIndex ----              zIndexDict didSet")
        if zIndexDict.isNotEmpty  {
            let tple = zIndexDict.map { ($0.key,$0.value) }.sorted(by: {$0.1 > $1.1})
            print("123# tple \(tple)")
            let newPn = tple[0]
            
            NotificationCenter.default.post(name: PNViewManager.onScreenViewPNNotification,
                                            object: OnScreenViewUpdate(pnType: newPn.0, status: .set))
            
            guard zIndexDict.count > 1 else { return }
            let oldPN = tple[1]
            NotificationCenter.default.post(name: PNViewManager.onScreenViewPNNotification,
                                            object: OnScreenViewUpdate(pnType: oldPN.0, status: .remove))
        }else{
            if let onScreenViewInfo = onScreenViewInfo{
                lastOnScreenViewInfo = onScreenViewInfo
            }
        }
    }
    func tapFromBannerNotification() {
        self.isFromBannerNotification = true
    }
    var lastOnScreenViewInfo: PNViewManager.OnScreenViewInfo?
    var pnTapsCount : Int = 0
    @Published var zIndexDict: [NotificationType:Int] = [:]
     
    
    func zIndex( _ type: NotificationType ) -> Double{
       let val = Double( zIndexDict[type] ?? 0)
          print("type \(type) zIndex = \(val)")
        return val
    }
    var friendsDictionary : FriendsDictionary{
        timelinePosts.friendsDictionary
    }
    
    init(timelinePosts: TimelinePostsOO, allMessagesOO: AllMessagesOO, eventModel: EventModelOO){
        self.timelinePosts = timelinePosts
        self.allMessagesOO = allMessagesOO
        self.eventModel = eventModel
        
     
        Self.publisher.sink {[weak self] content in
                self?.newPushNotification(content: content)
//            self?.getNotificationInfo(content: content)
        }
        .store(in: &subs)
    }
    
    enum NotificationType : String,Decodable {
        case newComment = "COMMENT_CREATION"
        case newGroupMessage = "NEW_GROUP_MESSAGE"
        case newPrivateMessage = "NEW_PRIVATE_MESSAGE"
        //new post one is also been used for comment mention and like moment
        case newPost = "POST_CREATION"
        case newFriendRequest = "NEW_FRIEND_REQUEST"
        case newCommentLike = "NEW_COMMENT_LIKE"
        case newPostLike = "NEW_POST_LIKE"
        case newCommentMention = "NEW_COMMENT_MENTION"
        case newPostMention = "NEW_POST_MENTION"
        case newEvent = "NEW_EVENT"
        case newEventMessage = "NEW_EVENT_MESSAGE"
    }
    func newPushNotification(content: UNNotificationContent) {
        if self.isFromBannerNotification == false {
        print("content.userInfo \(content.userInfo)")
        
        guard let type = content.userInfo[Constant.type()] as? String,
              let notificationType = NotificationType(rawValue: type) else {
            return }
        
        let userInfo = content.userInfo
        
        DispatchQueue.main.async {[self] in
            switch notificationType {
            case .newComment, .newCommentLike, .newPostLike, .newPostMention, .newCommentMention:
                if let postID = userInfo[Constant.postId()] as? String,
                   let postAuthorID = userInfo[Constant.postAuthorId()] as? String{
                    showOpenedPostView(postID: postID, authorID: postAuthorID)
                    return
                }
                
            case .newGroupMessage,.newPrivateMessage:
                if let chatUID = userInfo[Constant.chatId()] as? String {
                    showMessageView(chatUID: chatUID)
                    return
                }
            case .newPost:
                if let postID = userInfo[Constant.postId()] as? String,
                   let postAuthorID = userInfo[Constant.authorId()] as? String{
                    showOpenedPostView(postID: postID, authorID: postAuthorID)
                    return
                }
            case .newFriendRequest:
                if let userId = userInfo[Constant.userID()] as? String{
                    showUserProfileView(userId: userId)
                }
            case .newEvent:
                if let eventID = userInfo[Constant.eventID()] as? String {
                    showOpenedEvent(eventID: eventID, notificationType: .newEvent)
                }
            case .newEventMessage:
                if let eventID = userInfo[Constant.eventID()] as? String {
                    showOpenedEvent(eventID: eventID, notificationType: .newEventMessage)
                }
            }
        }
    }
    }
 
func postNotificationsFor(onScreenView : PNViewManager.OnScreenView){
    NotificationCenter.default.post(name: Self.pushNotificationTapped, object: onScreenView)
}
    enum Constant: String {
        case type
        case authorId
        case postId
        case commentId
        case commentAuthorId
        case postAuthorId
        case chatId
        case messageId
        case userID
        case notificationTitle
        case notificationBody
        case eventID
    }
    
    func clearAll(){
        allChatsSubcriber?.cancel()
        allChatsSubcriber = nil
        if strangerProfile != nil{
            strangerProfile = nil
        }
        
        if profileMatchedGeometry.isNotEmpty{
            profileMatchedGeometry.removeAll()
        }
        
//        if friendProfileSelectedID.isNotEmpty{
//            friendProfileSelectedID.removeAll()
//        }
        
//        if friendProfileMatchedGeometry.isNotEmpty{
//            friendProfileMatchedGeometry.removeAll()
//        }
        if event != EventModel(id: "") {
            event = EventModel(id: "")
        }
        if otherUserID.isNotEmpty{
            otherUserID.removeAll()
        }
        
        if selectedGroupChat != nil{
            selectedGroupChat = nil
        }
        
        if post != nil{
            post = nil
        }
    }
    //so the issue is that push notification will not show openeConversation if the chat is not in the  allChats, so we can be sure that chat is not a new chat
    func showMessageView(chatUID: String) {
        if let chatModel = allMessagesOO.allChats.first(where: {$0.chatUID == chatUID}) {
            if chatModel.isAGroup {
//                clearAll()
                selectedGroupChat = chatModel
                postNotificationsFor(onScreenView: .groupChat)
//                self.notificationTrigger = NotificationViewTrigger(type: .groupMessage)
            }else if let otherUserID = chatModel.lastMessage?.otherUserID {
//                clearAll()
              self.otherUserID = otherUserID
              postNotificationsFor(onScreenView: .privateChat)
//                self.notificationTrigger = NotificationViewTrigger(type: .message)
            }
        }else{
            allChatsSubcriber = allMessagesOO.$allChats.didSet.sink {[weak self] _ in
                self?.allChatsSubcriber?.cancel()
            self?.showMessageView(chatUID: chatUID)
            }
        }
    }
     
    func showUserProfileView(userId : String){
        friendsDictionary.getUserOf(id: userId)  {[weak self] userInfo,error  in
            if let userInfo = userInfo,let self = self{
                //we will un comment the if , when we will also need to display the a friend profile
//                if userInfo.isFriend {
//                    self.clearAll()
//                    self.friendProfileSelectedID = userInfo.user.id
//                    self.friendProfileMatchedGeometry = "0"
//                }else{
//                    self.clearAll()
                    self.strangerProfile = userInfo.user
                    self.profileMatchedGeometry = userInfo.user.id
                    self.postNotificationsFor(onScreenView: .userProfile)
//                }
            }else{
                print(" friendsDictionary.getUserOf(  \(error?.localizedDescription ?? "")")
            }
        }
    }
     //FIXME: - need to check the tag of the post before opening the openedPost view
    func showOpenedPostView(postID: String, authorID: String) {
      
        if let post = timelinePosts.getPost(postID){
//             clearAll()
            self.post = post
            self.postNotificationsFor(onScreenView: .post)
        }else  {
            PostModel.fetchPostFromCacheOrNetwork(postID: postID, friendId:  authorID){[weak self] post,error in
                if let post = post{
//                    self?.clearAll()
                    self?.post = post
                    self?.postNotificationsFor(onScreenView: .post)
                }else{
                    print(error.descriptionIfAny)
                }
                
                /*
                 if var post = postModel {
                     var tagNames = [String]()
                       for item in post.tags {
                           if self?.myTagIDs.firstIndex(of: item) != nil {
                               tagNames.append(item)
                           }
                       }
                        
                   if post.tags.isEmpty || tagNames.isNotEmpty {
                            post.tags = tagNames
                       
                       self?.postInfo.append(post)
                     }
                 }else if let error = error{
                     print(error.localizedDescription)
                 }
                 */
            }
        }
    }

    func showOpenedEvent(eventID: String, notificationType: NotificationType) {
      
        if let event = eventModel.getEvent(eventID) {
            if event.eventName != "" {
            self.event = event
            self.eventMatchedGeometry = "0"
            self.postNotificationsFor(onScreenView: .event)
        }else  {
            eventModel.getEventDetails(eventID: eventID) {[weak self] event,error in
                if let event = event {
                    self?.event = event
                    self?.eventMatchedGeometry = "0"
                    self?.postNotificationsFor(onScreenView: .event)
                } else{
                    print(error.descriptionIfAny)
                }
            }
        }
        }
    }
    
    var strangerUser : Person? {
        profileMatchedGeometry.isNotEmpty ? strangerProfile :  nil
    }
    
    deinit{
        subs.cancelAll()
        allChatsSubcriber?.cancel()
        Self.publisher.send(UNNotificationContent())
    }
    
//    var presentOpenedPost : Bool {
//        friendProfileSelectedID.isNotEmpty && friendProfileMatchedGeometry.isNotEmpty
//    }
     
    
//    var presentFriendProfile : Bool{
//        friendProfileSelectedID.isNotEmpty && friendProfileMatchedGeometry.isNotEmpty
//    }
    
//    @Published var friendProfileSelectedID: String = ""
//    @Published var friendProfileMatchedGeometry: String = ""
}
 


/*
 so now heres four notification situations.
 1) like/comment/create new moment, will need to navigate to OpenPost using postID
 2) message, will need to navigate to open conversation using chatUID
 3) group message, will need to navigate to open group conversation using chatUID
 4) friend request, will need to navigate to Stranger Profile using the persons UID
 
i think we will need firendDictionary for every kind of view other then the  strange view. so what we can do is create a pusblisher called the currentValue publisher and then show the view from their.
 like for group messages we need friendDictionary i think but let us check i thknk we will need it because even if the main view do not use the firendDictionary the child view will mostly likely use it.
  and what shloud we do if a user taps on another push notification while on a push notificaiton view? then we might need to have a view just like mentionedTapView. and for message PN we will also need to make tabView swipe towards the AllMessages i think
 */

extension PushNotificationVM  {
static var publisher =  CurrentValueSubject<UNNotificationContent, Never>(UNNotificationContent())
 static let pushNotificationTapped = Foundation.Notification.Name("pushNotificationTapped")

}
 
typealias PNType = PushNotificationVM.NotificationType




extension PushNotificationVM {
    func inAppPushNotification(notificationInfo: NotificationBanner) {
        switch notificationInfo.notificationType {
        case .newComment, .newCommentLike, .newPostLike, .newPostMention, .newCommentMention:
            showOpenedPostView(postID: notificationInfo.resourceID, authorID: notificationInfo.authorID)
        case .newGroupMessage,.newPrivateMessage:
            showMessageView(chatUID: notificationInfo.resourceID)
        case .newPost:
            showOpenedPostView(postID: notificationInfo.resourceID, authorID: notificationInfo.authorID)
        case .newFriendRequest:
            showUserProfileView(userId: notificationInfo.userID)
            
        case .newEvent:
            showOpenedEvent(eventID: notificationInfo.resourceID, notificationType: .newEvent)
        case .newEventMessage:
            showOpenedEvent(eventID: notificationInfo.resourceID, notificationType: .newEventMessage)
        }
    }
    
    func newPushNotificationNotINUSE(content: UNNotificationContent) {
        guard let userInfo = content.userInfo["detail"] as? [String : Any] else { return }
        
        if let userId = userInfo["userID"] as? String{
            showUserProfileView(userId: userId)
        }else if let postID = userInfo["postID"] as? String,
                 let postAuthorID = userInfo["authorID"] as? String{
            showOpenedPostView(postID: postID, authorID: postAuthorID)
        }else if let chatUID = userInfo["chatUID"] as? String {
            showMessageView(chatUID: chatUID)
        }
    }
}
//
enum NotificationViewType: String {
    case event
    case message
    case groupMessage
    case strangerProfile
}

struct NotificationViewTrigger: Identifiable {
    let id = UUID()
    let type: NotificationViewType
}
