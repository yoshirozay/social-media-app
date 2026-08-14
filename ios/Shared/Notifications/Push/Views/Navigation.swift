//
//  Navigation.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//

import SwiftUI


struct PushNotificationView : View {
   @ObservedObject var pushNotificationVM : PushNotificationVM
   @EnvironmentObject var timelinePosts: TimelinePostsOO
   @StateObject var postVM = PostVM(addListener: false)
    @ObservedObject var currentTab: CurrentTab
    @ObservedObject var myTags: MyTagsOO
    //i think we can have a dict with posiiont and
   var body: some View {
       ZStack {
//           Button(action:{
//               switch currentTab.currentTab {
//               case "house.fill":
//                   currentTab.changeTab(tab: "person")
//               case "person":
//                   currentTab.changeTab(tab: "plus")
//               case "plus":
//                   currentTab.changeTab(tab: "message")
//               case "message":
//                   currentTab.changeTab(tab: "calendar")
//               case "calendar":
//                   currentTab.changeTab(tab: "house.fill")
//               default:
//                   currentTab.changeTab(tab: "house.fill")
//               }
//           }) {
//               RoundedRectangle(cornerRadius: 10)
//                   .frame(width: screenWidth - 150, height: 100)
//                   .foregroundColor(Color.purple)
//                   .overlay(
//                   Text("SWITCH TAB")
//                   )
//                   
//           }
           strangerProfile
           
           openedPost
           
           privateChat
         
           groupChat
           
           eventInfo
           
       }
       .onReceive( pushNotificationVM.$post) { post in
           if let post : PostModel = post {
               postVM.openPost(commentLikeVM: CommentLikeVM(post: post, friendsDictionary: timelinePosts.friendsDictionary))
           }
       }
       .onReceive( postVM.$commentLikeVM) { commentLikeVM in
           if commentLikeVM == nil {
               pushNotificationVM.post = nil
           }
       }
   }
    var eventInfo: some View {
        ZStack {
        if pushNotificationVM.eventMatchedGeometry != "" {
            OpenedEventTabView(OpenedEventMatchedGeometry: $pushNotificationVM.eventMatchedGeometry, eventModel: pushNotificationVM.eventModel, event: $pushNotificationVM.event, friendsDictionary: timelinePosts.friendsDictionary, EventMatchedGeometryEffect: .constant(""), isFromInvitations: true, themeController: ThemeController())
                .id(pushNotificationVM.profileMatchedGeometry)
                .zIndex(pushNotificationVM.zIndex(.newEvent))
                .padding(.top, iOS15 ? 0 : -60)
        }
    }
    }
    var strangerProfile: some View{
         pushNotificationVM.strangerUser.map{ user in
            
            StrangerProfileTabView(ProfileMatchedGeometry: $pushNotificationVM.profileMatchedGeometry,
                                   person: user,
                                   id: pushNotificationVM.profileMatchedGeometry,addPNListener: false)
                .id(pushNotificationVM.profileMatchedGeometry)
                .zIndex(pushNotificationVM.zIndex(.newFriendRequest))
        }
    }
    
   //FIXME: - need to check what is the use of showUpdatePost
    @State var showUpdatePost: PostModel?
    var openedPost: some View{
         postVM.commentLikeVM.map{ commentLikeVM in
            OpenedPostTabView(commentLikeVM: commentLikeVM,
                              postVM: postVM,
                              showUpdatePost: $showUpdatePost, myTags: myTags)
            .id(commentLikeVM.post.postID)
            .zIndex(pushNotificationVM.zIndex(.newPost))
            .padding(.horizontal)
//            .padding(.top, iOS15 ? 0 : -60)
        }
    }
    
    var groupChat : some View{
        pushNotificationVM.selectedGroupChat.map { chatModel in
                OpenedGroupConversationTabView(selectedGroupChat: $pushNotificationVM.selectedGroupChat,
                                               isNewGroupChat: false,
                                               NewGroupChatMatchedGeometry: .constant(""),
                                               NewConversationMatchedGeometry: .constant(""),
                                               addPNListener: false)
                .id(chatModel.chatUID)
                .padding(.top, iOS15 ? (isLargeScreen ? -10 : -40) : (isLargeScreen ? -60 : -40))
                .zIndex(pushNotificationVM.zIndex(.newGroupMessage))
            }
    }
    
    var privateChat : some View{
        pushNotificationVM.otherUserID.isNotEmpty.falseIsNil.map { _ in
            OpenedConversationTabView(OpenedConversationMatchedGeometry: $pushNotificationVM.otherUserID,
                                      id: pushNotificationVM.otherUserID,
                                      addPNListener: false)
            .id(pushNotificationVM.otherUserID)
            .padding(.top, iOS15  ?  (isLargeScreen ? -10 : -40) :  -60 )
            .zIndex(pushNotificationVM.zIndex(.newPrivateMessage))
            
        }
    }
    
    let isLargeScreen = screenHeight > 800
}

struct EmptyPushNotificationView : View {
   @ObservedObject var pushNotificationVM : PushNotificationVM
    @ObservedObject var currentTab: CurrentTab
    var body: some View {
        ZStack {
        }
        .onReceive( pushNotificationVM.$post) { post in
            if let post : PostModel = post {
                if currentTab.currentTab != "house.fill" {
                    currentTab.changeTab(tab: "house.fill")
                }
            }
        }
        .onReceive(pushNotificationVM.$notificationTrigger) { trigger in
            if let trigger: NotificationViewTrigger = trigger {
                let notificationType = trigger.type
                switch notificationType {
                case .event:
                    if currentTab.currentTab != "calendar" {
                        currentTab.changeTab(tab: "calendar")
                    } else {
                        return
                    }
                case .message:
                    if currentTab.currentTab != "message" {
                        if pushNotificationVM.otherUserID != "" {
                            currentTab.changeTab(tab: "message")
                        }
                    } else {
                        return
                    }
                case .groupMessage:
                    if currentTab.currentTab != "message" {
                        if pushNotificationVM.selectedGroupChat != nil {
                            currentTab.changeTab(tab: "message")
                        }
                    } else {
                        return
                    }
                case .strangerProfile:
                    if currentTab.currentTab != "person" {
                        currentTab.changeTab(tab: "person")
                    } else {
                        return
                    }

                }
            }
            }
    }
}
