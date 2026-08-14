//
//  PushNotificationView.swift
//  speakEZ
//
//  Created by Ahmad naeem on 4/14/22.
//
  
import SwiftUI

struct PushNotificationView : View {
   @EnvironmentObject var pushNotificationVM : PushNotificationVM
   @EnvironmentObject var timelinePosts: TimelinePostsOO
   @StateObject var postVM = PostVM(addListener: false)
    //i think we can have a dict with posiiont and 
   var body: some View {
       ZStack {

           strangerProfile
           
           openedPost
           
           privateChat
         
           groupChat
           
       }.onReceive( pushNotificationVM.$post) { post in
           if let post : PostModel = post {
               postVM.openPost(commentLikeVM: CommentLikeVM(post: post, friendsDictionary: timelinePosts.friendsDictionary))
           } 
       }.onReceive( postVM.$commentLikeVM) { commentLikeVM in
           if commentLikeVM == nil {
               pushNotificationVM.post = nil
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
                              showUpdatePost: $showUpdatePost)
            .id(commentLikeVM.post.postID)
            .zIndex(pushNotificationVM.zIndex(.newPost))
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
