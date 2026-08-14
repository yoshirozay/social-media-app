//
//  OpenedM.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//

import Foundation
import SwiftUI
import Combine
import Firebase
import FirebaseFirestore
import SDWebImageSwiftUI
import Introspect
   
struct OpenedPostController: View {
    @ObservedObject var myTags: MyTagsOO
    @EnvironmentObject var timelinePostsOO : TimelinePostsOO
    @StateObject var comments : CommentsOO
    @StateObject var likes : LikesOO
    @StateObject var hasBeenLikedOO : HasPostBeenLikedOO
    var isFromProfile = false
    @State var isFirstResponder = false
    @ObservedObject var commentLikeVM : CommentLikeVM
    @ObservedObject var postVM : PostVM
    @Binding var showUpdatePost: PostModel?
    @Binding var show: Bool
    @Binding var buttonAlertType: ButtonAlertType
    @Binding var lockedMomentAlert : Bool
    @ObservedObject var themeController: ThemeController
    var body: some View {
        
        OpenedPost4(comments: comments,
                    likes: likes,
                    hasBeenLikedOO: hasBeenLikedOO,
                    myTags: myTags,
                    isFirstResponder: isFirstResponder,
                    friendProfileSelectedItem: .constant(""),
                    isDeletePostAlertShowing: .constant(false),
                    deletedPost: .constant(nil),
                    commentLikeVM : commentLikeVM,
                    mentionedUserVM: MentionedUserVM(friendsDictionary: timelinePostsOO.friendsDictionary),
                    isFromProfile: isFromProfile,
                    postVM: postVM, showUpdatePost: $showUpdatePost, members: OpenedTagOO(tagIDs: commentLikeVM.post.tags, post: commentLikeVM.post,friendsDictionary: timelinePostsOO.friendsDictionary), show: $show, buttonAlertType2: $buttonAlertType, lockedMomentAlert: $lockedMomentAlert, themeController: themeController)
        .onAppear(){
            commentLikeVM.startAllListenersIfNeeded()
        }
        
    }
}


struct OpenedPost4: View {
    @Namespace var namespace
    @ObservedObject var comments : CommentsOO
    @StateObject var likes = LikesOO(id: "", postID: "")
    @State var message = ""
    @State var FriendProfileSelectedID: String = ""
    @State var FriendProfileMatchedGeometry: String = ""
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @State var OpenedPhotoMatchedGeometry: String = ""
    @State var OpenedPhotoSelectedItem: URL?
    @State var OpenedGIFMatchedGeometry: String = ""
    @StateObject var keyboard = KeyboardViewModel(showDismissAnimation: false)
    @State var LongPostMatchedGeometry: String = ""
    @StateObject var hasBeenLikedOO = HasPostBeenLikedOO(id: "", postID: "")
    @State var hasBeenLiked = false
    @StateObject var functions = SendCommentFunction()
    @StateObject var likeFunction = SendLikeFunction()
    @StateObject var replyFunction = ReplyToCommentFunction()
    @StateObject var screenCaptureVM = OpenedPostScreenCaptureVM()
    @State var StrangerProfileSelectedUser = Person(id: "")
    @Environment(\.colorScheme) var colorScheme
    @State var LikesProfileMatchedGeometry: String = ""
    @State var OpenedProfileFromCommentsMatchedGeometry = ""
    @State var CommentLikesMatchedGeometry = ""
    @State var CommentLikeNavigation: String = ""
    @State var MomentLikesNavigation: String = ""
    @State var MomentLockNavigation: String = ""
    @State var CommentReplyLikesMatchedGeometry = ""
    @State var CommentReplyLikesOriginalCommentID = ""
    @State var textFieldPlaceholder = "Comment"
    @State var nameOfPersonReplyingTo = ""
    @State var IDofPersonReplyingTo = ""
    @State var commentID = ""
    @State var friendsWhoReplied = [""]
    @State var OpenedStrangerProfileFromCommentReplyMatchedGeometry = ""
    @State var OpenedStrangerProfileFromCommentReply = Person(id: "", username: "", name: "", bio: "", imageurl: "", accountCreationDate: Timestamp(), profileCircle: .clear)
    @State var canSendReply = true
    @State var isShowingMentions = false
    @State var mentionCount = [""]
    @State var OpenedTagNavigation = ""
    @State var emptyStringBinding = ""
    @State var emptyStringArrayBinding = [""]
    @ObservedObject var myTags: MyTagsOO
    // Like animation
    @State private var circleSize = 0.0
    @State private var circleInnerBorder = 35
    @State private var circleHue = 200
    //
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    @State var isFirstResponder = true
    @Binding var friendProfileSelectedItem: String
    @Binding var isDeletePostAlertShowing: Bool
    @Binding var deletedPost : PostModel?
    @State var deletedPost2 : PostModel?
    @State var list: UITableView?
    @State var textViewMaxHeight: CGFloat = screenHeight*0.3 - 150
//    @State var newMedia123: NewMedia?
    @State var ShowPhotoImagePicker = false
    @State var isDeletePostShowing = false
    @ObservedObject var commentLikeVM: CommentLikeVM
    @StateObject var mentionedUserVM : MentionedUserVM
    let isFromProfile: Bool
    @ObservedObject var postVM : PostVM
    @State var comment: CommentModel = CommentModel(id: "", commentID: "", comment: "", time: Timestamp())
    @Binding var showUpdatePost : PostModel?
    @StateObject var members: OpenedTagOO
    @State var isTyping = false
    @State var isShowingGIFkeyboard = false
    @State var gifURL: String = ""
    @StateObject var soundManager = SoundManager()
//    @State var isAudioSessionOn = false
    @StateObject var audioPlayerVM = RecordedAudioPlayerVM()
    @State var isDisabled = false
    @State var selectedMedia : SelectedMedia?
    @Binding var show: Bool
    @State var commentLikedBy: [Person]?
    @State var deleteComment: Bool = false
    @AppStorage("notifications") var notificationsAlert : Bool = false
    @AppStorage("activeMoments") var activeMomentsAlert : Bool = false
    @AppStorage("audioComment") var audioCommentAlert : Bool = false
    @AppStorage("cameraComment") var cameraCommentAlert : Bool = false
    @AppStorage("anonymousModeAlert") var anonymousModeAlert : Bool = false
//    @State var anonymousModeAlert : Bool = false
    @State var buttonAlertType: ButtonAlertType = .none
    @Binding var buttonAlertType2: ButtonAlertType
    @Binding var lockedMomentAlert : Bool
    @ObservedObject var themeController: ThemeController
    var postData: PostModel {
        commentLikeVM.post
    }
    
    var id: String {
        postData.id
    }
    
    var body: some View {
        ZStack {
            VStack (spacing: 0){
//                if keyboard.value == 0 || FriendProfileMatchedGeometry != ""  {
//                if FriendProfileMatchedGeometry.isEmpty  {
                    moment
 
//                }
//                Spacer()
                ZStack (alignment: .topLeading) {

                    messageList
                    HStack {
                        Spacer()
                        LikeButton(MomentLikesNavigation: $MomentLikesNavigation, authorID: id, commentLikeVM: commentLikeVM, friendsDictionary: friendsDictionary, buttonAlertType: $buttonAlertType, themeController: themeController)
                        
                    }
                    .padding(.trailing, postData.photoLink != nil || postData.audioUrl != nil ? 24 : 14.5)
            
                }
                Spacer()
                ZStack (alignment: .bottom) {
                    VStack() {
                        selectedAudioView
                        selectedMediaView
                        textField
                    }

                    HStack {
                        if postData.postID.isNotEmpty{
                            
                            TypingIndicatorController(people: TypingIndicatorOO(type: .OpenedMoment, resourceID: postData.postID, authorID: id), isFromOpenedPost: true, currentView: .OpenedMoment, themeController: themeController)
                                .padding(.leading, 20)
                                .animation(.easeInOut(duration: 0.3))
                        }
                        Spacer()
                        if selectedMedia?.newMedia == nil {
                        RecordNewAudioView(soundManager: soundManager, selectedMedia: $selectedMedia, isFromMessages: false, audioCommentAlert: $audioCommentAlert, buttonAlertType: $buttonAlertType, themeController: themeController)
                            .offset(x: message != "" || selectedMedia != nil ? 11 : 0)
//                            .padding(.trailing, 3)
                        }
                        if selectedMedia?.audioUrl == nil && !soundManager.isRecording {
                        sendGifButton
                            .offset(x: message != "" || selectedMedia?.image != nil ? 11 : 0)
                        sendPhotoButton
                            .offset(x: message != "" || selectedMedia?.image != nil ? 11 : 0)
                        }
                    }
                    .offset(x: -16, y: -82 + keyboard.value)
                    .offset(y: iOS15 ? 0 : -screenHeight/45)
                    .offset(y: keyboard.value > 0 ? -keyboard.value : 0)
                    .offset(y: iOS15 ? 0 : 20)
                }
//                .padding(.bottom, keyboard.bottomPadding)
                .padding(.bottom, keyboard.bottomPadding > 0 ? iOS15 ? (keyboard.bottomPadding - 66) : keyboard.bottomPadding : keyboard.bottomPadding)
                .animation(.linear(duration: 0.2), value: keyboard.value)
                
            }
            .blur(radius: CommentLikeNavigation != "" || MomentLikesNavigation != "" || MomentLockNavigation != "" || postVM.openedTags.isNotEmpty || buttonAlertType != .none ? 10 : 0)
            .disabled(CommentLikeNavigation != "" || MomentLikesNavigation != "" || MomentLockNavigation != ""  || postVM.openedTags.isNotEmpty || buttonAlertType != .none ? true : false)
//            .padding(.top, isFromProfile && iOS15 != true ? 60 : 0)
            presentableViews
 
        }
        
        .alert(isPresented: $isDeletePostShowing) {
            let destructionAction = deletePost
            let cancelAlertButton = Alert.Button.cancel()
            
            return Alert(
                title: Text("Delete this Moment?"),
                primaryButton: .destructive(Text("Delete"),action : destructionAction ),
                secondaryButton: cancelAlertButton
            )
        }
        .edgesIgnoringSafeArea(.all)
        .onReceive(timelinePosts.getAccessTagPublisher(postTags: postData.tags)) { isDisabled in
            if  self.isDisabled != isDisabled {
                self.isDisabled = isDisabled
            }
        }
        .blur(radius: isDisabled ? 10 : 0)
        .disabled(isDisabled)
        .onChange(of: isCurrentViewVisible, perform: stopAndDeleteRecordingIfAny)
        .background(themeController.theme.primary.ignoresSafeArea(.all))
        .animation(.linear(duration: 0.2), value: keyboard.value)
        .transition(.move(edge: .trailing))
        
    }
    var moment: some View {
        VStack(spacing: 10) {
            TimelineMoment3(id: postData.id, friendProfileSelectedItem: $friendProfileSelectedItem, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,
                           friendsDictionary: timelinePosts.friendsDictionary , myTags: myTags, isFromProfile: isFromProfile, isDeletePostAlertShowing: $isDeletePostAlertShowing, deletedPost:
                                $deletedPost, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,commentLikeVM : commentLikeVM ,  isFromOpenedPost: true,isFirstResponder: $isFirstResponder, mentionedUserVM : mentionedUserVM, LongPostMatchedGeometry: $LongPostMatchedGeometry, postVM: postVM, show: $show, MomentLockNavigation: $MomentLockNavigation, buttonAlertType: $buttonAlertType2, lockedMomentAlert: $lockedMomentAlert, themeController: themeController)
            .contextMenu {
                VStack {
                    if postData.id == currentUserID {
                        
//                        Button("Edit") {
//                            guard commentLikeVM.allowContextMenu else { return }
//                            showUpdatePost = postData
//                            postVM.dismissOpenedPost()
//                        } .font(.headline)
                        Button("Delete") {
                            guard commentLikeVM.allowContextMenu else { return }
                            isDeletePostShowing = true
                            deletedPost2 = postData
                        }.font(.headline)
                    }
                    
                    commentLikeVM.post.hasSubscribed?.falseIsNil.map { _ in
                        Button("Pause Notifications") {
                            commentLikeVM.unSubcribePost()
                        }.font(.headline)
                            .buttonStyle(.borderless)
                    }
                }
                
            }
            Rectangle()
                .frame(width: screenWidth, height: 5)
//                .foregroundColor(Color.mainColorInverse)
                .foregroundColor(.mainColorInverse)
        }
    }
    var messageList: some View {
        ZStack {
            if #available(iOS 16.0, *) {
                List() {
                    
                    ForEach(comments.sortedComments.reversed(), id: \.self) { item in
                        NewComment2(comments: comments,
                                    comment: item,
                                    OpenedProfileFromCommentsMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry,
                                    OpenedStrangerProfileFromCommentReplyMatchedGeometry: $OpenedStrangerProfileFromCommentReplyMatchedGeometry,
                                    postID: postData.postID,
                                    postOwnerID: id,
                                    hasCommentBeenLiked: HasCommentBeenLikedOO(id: id, postID: postData.postID, commentID: item.commentID),
                                    CommentLikesMatchedGeometry: $CommentLikesMatchedGeometry,
                                    CommentReplyLikesMatchedGeometry: $CommentReplyLikesMatchedGeometry,
                                    CommentReplyLikesOriginalCommentID: $CommentReplyLikesOriginalCommentID,
                                    textFieldPlaceholder: $textFieldPlaceholder,
                                    nameOfPersonReplyingTo: $nameOfPersonReplyingTo,
                                    IDofPersonReplyingTo: $IDofPersonReplyingTo,
                                    message: $message,
                                    commentID: $commentID,
                                    friendsWhoReplied: $friendsWhoReplied,
                                    commentReplies: CommentRepliesOO(id: id, postID: postData.postID, commentID: item.commentID), commentLikes: CommentLikesOO(id: id, postID: postData.postID, commentID: item.commentID), isDeletePostShowing: $isDeletePostShowing, isCurrentUser: item.id == Auth.auth().currentUser?.uid ? true : false, StrangerProfileSelectedUser: $StrangerProfileSelectedUser, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,
                                    comment2: $comment, OpenedGIFMatchedGeometry: $OpenedGIFMatchedGeometry, CommentLikeNavigation: $CommentLikeNavigation, commentLikedBy: $commentLikedBy, anonymousModeAlert: $anonymousModeAlert, buttonAlertType: $buttonAlertType, themeController: themeController, OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,
                                    OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry)
                        .id(item.commentID)
                        .scaleEffect(x: 1, y: -1, anchor: .center)
                        .listRowBackground(themeController.theme.primary)
//                        .animation(.easeIn(duration: 0.3))
//                        .padding(.top, commentLikeVM.likesCount ? 8 : 0)
                        
                    } .environmentObject(mentionedUserVM)
                        .padding(.top, -10)
                }
                .scrollDismissesKeyboard(.interactively)
                .offset(y: id == TristanUserID && screenHeight > 880 && comments.sortedComments.count < 5 ? 25 : 0)
                .padding(.horizontal, -16)
//                .padding(.horizontal, iOS16 ? -16 : 0)
                .scaleEffect(x: 1, y: -1, anchor: .center)
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        if  comments.sortedComments.isNotEmpty == true {
                            self.list?.scrollToBottom()
                            //                                    self.list?.scrollToRow(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
                        }
                    }
                }
                .onChange(of: comments.goToBottom) { (value) in
                    DispatchQueue.main.async {
                        if  comments.sortedComments.isNotEmpty == true {
                            self.list?.scrollToBottom()
                            //                                    self.list?.scrollToRow(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
                        }
                    }
                }
            } else {
                List() {
                    
                    ForEach(comments.sortedComments.reversed(), id: \.self) { item in
                        NewComment2(comments: comments,
                                    comment: item,
                                    OpenedProfileFromCommentsMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry,
                                    OpenedStrangerProfileFromCommentReplyMatchedGeometry: $OpenedStrangerProfileFromCommentReplyMatchedGeometry,
                                    postID: postData.postID,
                                    postOwnerID: id,
                                    hasCommentBeenLiked: HasCommentBeenLikedOO(id: id, postID: postData.postID, commentID: item.commentID),
                                    CommentLikesMatchedGeometry: $CommentLikesMatchedGeometry,
                                    CommentReplyLikesMatchedGeometry: $CommentReplyLikesMatchedGeometry,
                                    CommentReplyLikesOriginalCommentID: $CommentReplyLikesOriginalCommentID,
                                    textFieldPlaceholder: $textFieldPlaceholder,
                                    nameOfPersonReplyingTo: $nameOfPersonReplyingTo,
                                    IDofPersonReplyingTo: $IDofPersonReplyingTo,
                                    message: $message,
                                    commentID: $commentID,
                                    friendsWhoReplied: $friendsWhoReplied,
                                    commentReplies: CommentRepliesOO(id: id, postID: postData.postID, commentID: item.commentID), commentLikes: CommentLikesOO(id: id, postID: postData.postID, commentID: item.commentID), isDeletePostShowing: $isDeletePostShowing, isCurrentUser: item.id == Auth.auth().currentUser?.uid ? true : false, StrangerProfileSelectedUser: $StrangerProfileSelectedUser, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,
                                    comment2: $comment, OpenedGIFMatchedGeometry: $OpenedGIFMatchedGeometry, CommentLikeNavigation: $CommentLikeNavigation, commentLikedBy: $commentLikedBy, anonymousModeAlert: $anonymousModeAlert, buttonAlertType: $buttonAlertType, themeController: themeController, OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,
                                    OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry)
                        .id(item.commentID)
                        .scaleEffect(x: 1, y: -1, anchor: .center)
                        .listRowBackground(themeController.theme.primary)
                        
                        
                    } .environmentObject(mentionedUserVM)
                        .padding(.top, -10)
                }
                .offset(y: id == TristanUserID && screenHeight > 880 && comments.sortedComments.count < 5 ? 25 : 0)
                .padding(.horizontal, -16)
                .scaleEffect(x: 1, y: -1, anchor: .center)
                .listStyle(SidebarListStyle())
                .introspectTableView(customize: { list in
                    if self.list == nil {
                        self.list = list
#if os(iOS)
                        list.allowsSelection = false
                        list.selectionFollowsFocus = false
                        list.keyboardDismissMode = .interactive
#endif
                    }
                })
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        if  comments.sortedComments.isNotEmpty == true {
                            self.list?.scrollToBottom()
                            //                                    self.list?.scrollToRow(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
                        }
                    }
                }
                .onChange(of: comments.goToBottom) { (value) in
                    DispatchQueue.main.async {
                        if  comments.sortedComments.isNotEmpty == true {
                            self.list?.scrollToBottom()
                            //                                    self.list?.scrollToRow(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
                        }
                    }
                }
            }
            }
    }
    var presentableViews : some View{
        Group{
            Group {

                if isShowingMentions == true {
                    MutualFriendsForMentions(content: $message, mutualFriends: MutualFriendsOO(id: id, tagMembers: members.people), mentionCount: $mentionCount, themeController: themeController)
                }
                
                
                if OpenedPhotoMatchedGeometry != "" {
                    OpenPhotoTabView(OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, photo: OpenedPhotoSelectedItem, isFromTimeline: true)
                        .onAppear(perform: postVM.removeViewInfo)
                        .onDisappear(perform: postVM.setViewInfo)
                    
                }
                if OpenedGIFMatchedGeometry != "" {
                    OpenedGIFTabView(OpenedGIFMatchedGeometry: $OpenedGIFMatchedGeometry)
                        .onAppear(perform: postVM.removeViewInfo)
                        .onDisappear(perform: postVM.setViewInfo)
                    
                }
                if CommentLikeNavigation != "" {
                    CommentLikeList (commentLikedBy: commentLikedBy, friendsDictionary: friendsDictionary, comment: comment,  StrangerProfileSelectedUser: $StrangerProfileSelectedUser, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, anonymousModeAlert: $anonymousModeAlert, buttonAlertType: $buttonAlertType, themeController: themeController) {
                        withAnimation {
                            CommentLikeNavigation = ""
                        }
                    }
                    .blur(radius: buttonAlertType != .none ? 10 : 0)
                    .disabled(buttonAlertType != .none ? true : false)
                }
                if MomentLikesNavigation != "" {
                    MomentLikeList(likes: likes, friendsDictionary: friendsDictionary, StrangerProfileSelectedUser: $StrangerProfileSelectedUser, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, anonymousModeAlert: $anonymousModeAlert, buttonAlertType: $buttonAlertType, themeController: themeController) {
                        withAnimation {
                            MomentLikesNavigation = ""
                        }
                    }
                    .blur(radius: buttonAlertType != .none ? 10 : 0)
                    .disabled(buttonAlertType != .none ? true : false)
                }
            }
            if MomentLockNavigation != "" || postVM.openedTags.isNotEmpty {
                MomentLockList(members: OpenedTagOO(tagIDs: postData.tags, post: postData, friendsDictionary: timelinePosts.friendsDictionary), friendsDictionary: friendsDictionary, isLocked: postData.tags.isNotEmpty ? true : false, authorID: id, StrangerProfileSelectedUser: $StrangerProfileSelectedUser, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, anonymousModeAlert: $anonymousModeAlert, buttonAlertType: $buttonAlertType, themeController: themeController) {
                    withAnimation {
                        MomentLockNavigation = ""
                        postVM.dismissOpenedFriendTag()
                    }
                }
                .blur(radius: buttonAlertType != .none ? 10 : 0)
                .disabled(buttonAlertType != .none ? true : false)
            }
            //            if postVM.openedTags.isNotEmpty {
            //                OpenedFriendTag(members: OpenedTagOO(tagIDs: postVM.openedTags,post: postData,friendsDictionary: timelinePosts.friendsDictionary),
            //                                id: postData.id, FriendProfileMatchedGeometry: FriendProfileMatchedGeometry, friendsDictionary: timelinePosts.friendsDictionary, myTags: myTags, isDeletePostAlertShowing: $isDeletePostAlertShowing, deletedPost: $deletedPost, OpenedPhotoMatchedGeometry: OpenedPhotoMatchedGeometry,OpenedPhotoSelectedItem: OpenedPhotoSelectedItem, commentLikeVM: commentLikeVM,
            //                                isFirstResponder: isFirstResponder, mentionedUserVM: mentionedUserVM, LongPostMatchedGeometry:$LongPostMatchedGeometry, postVM: postVM)
            //                .onAppear(perform: postVM.removeViewInfo)
            //                .onDisappear(perform: postVM.setViewInfo)
            //            }
            
//            if LongPostMatchedGeometry != "" {
//                OpenedLongPostTabView(OpenedLongPostMatchedGeometry: $LongPostMatchedGeometry, friendsDictionary: friendsDictionary, postData: postData, id: id, isFromProfile: isFromProfile, mentionedUserVM: mentionedUserVM)
//                    .onAppear(perform: postVM.removeViewInfo)
//                    .onDisappear(perform: postVM.setViewInfo)
//            }
            
            if mentionedUserVM.presentTapView{
                UserMentionTabView(mentionedUserVM: mentionedUserVM, isFromOpenedProfile: isFromProfile, themeController: themeController)
                    .onAppear(perform: postVM.removeViewInfo)
                    .onDisappear(perform: postVM.setViewInfo)
            }
            
//            if CommentLikesMatchedGeometry != "" {
//                CommentLikesTabView2(LikesMatchedGeometry: $CommentLikesMatchedGeometry, likes: CommentLikesOO(id: id, postID: postData.postID, commentID: CommentLikesMatchedGeometry), comments: comments, comment: comment, friendsDictionary: friendsDictionary)
//                    .onAppear(perform: postVM.removeViewInfo)
//                    .onDisappear(perform: postVM.setViewInfo)
//            }
            if FriendProfileMatchedGeometry != "" {
                if friendsDictionary.friendsDictionary[FriendProfileMatchedGeometry] != nil {
                    //
                    if FriendProfileMatchedGeometry != currentUserID {
                        FriendProfileHomeTabView(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: FriendProfileMatchedGeometry, isFromOpenedPost: true, themeController: themeController)
                        //                    .padding(.horizontal, 20)
                            .padding(.top, iOS15 ? 0 : (screenHeight > 800 ? 10 : 10) )
                        
                            .onAppear {
                                postVM.removeViewInfo()
                                MomentLockNavigation = ""
                                postVM.dismissOpenedFriendTag()
                            }
                            .onDisappear(perform: postVM.setViewInfo)
                        
                        //                    OpenedConversationTabView(OpenedConversationMatchedGeometry: $FriendProfileMatchedGeometry, id: FriendProfileMatchedGeometry, isFromOpenedMoment: true, isFirstResponder: false)
                    } else {
                        CurrentUserProfileTabView(ProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: currentUserID ?? "",  signOut: .constant(false), friendsDictionary: friendsDictionary, themeController: themeController)
                            .padding(.top, iOS15 ? 0 : (screenHeight > 800 ? 10 : 10) )
                            .onAppear {
                                postVM.removeViewInfo()
                                MomentLockNavigation = ""
                                postVM.dismissOpenedFriendTag()
                            }
                    }
                } else {
                    StrangerProfileTabView(ProfileMatchedGeometry: $FriendProfileMatchedGeometry, person: StrangerProfileSelectedUser , id: FriendProfileMatchedGeometry)
                        .onAppear(perform: postVM.removeViewInfo)
                        .onDisappear(perform: postVM.setViewInfo)
                }
                
            }
            if buttonAlertType != .none {
                ButtonTapAlertController(buttonAlertType: $buttonAlertType, themeController: themeController) 
            }
        }
    }
    
    
    var selectedAudioView: some View {
        selectedMedia?.audioUrl.map {_ in
        HStack {
            ZStack {
                Rectangle()
                    .frame(width: 105, height: 120)
                    .foregroundColor(themeController.theme.secondary)
                    .clipShape(Rectangle())
                    .cornerRadius(10)
                Button(action: {
                    audioPlayerVM.playRecordingIfNotPlaying(audioUrl: selectedMedia?.audioUrl)
                }){
                    ZStack {
                        if audioPlayerVM.playRecording {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(themeController.theme.primary)
                                AnimatedWaveformView(color: Color.white, renderingMode: .hierarchical, animated: true, doesHaveOutterRing: false)
                                .frame(width: 60, height: 60)
                                .scaledToFit()
                            }
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(themeController.theme.primary)
                                AnimatedWaveformView(color: Color.white, renderingMode: .hierarchical, animated: false, doesHaveOutterRing: false)
                                .frame(width: 60, height: 60)
                                .scaledToFit()
                            }
                        }
                    }
                }.disabled(soundManager.isRecording)
                Button(action: {
                    withAnimation {
                    audioPlayerVM.stopAndDelete(audioDirURL:  selectedMedia?.audioUrl)
                    selectedMedia = nil
                    }
                }) {
                    Image(systemName: "clear")
                        .foregroundColor(themeController.theme.accent)
                }  .buttonStyle(.borderless)
                    .padding(.leading, 90)
                    .padding(.bottom, 100)
            }
            .padding(.leading, 8)
            Spacer()
        }
        .frame(height: 125)
        .background(themeController.theme.primary)
        .onAppear() {
            audioPlayerVM.playRecordingIfNotPlaying(audioUrl: selectedMedia?.audioUrl)
        }
        }
    }
    
    var selectedMediaView: some View {
        (selectedMedia?.image).map  { image in
            HStack {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 105, height: 120)
                        .shadow(radius: 5, x: 0, y: -1)
                        .shadow(radius: 5, x: 0, y: 1)
                        .clipShape(Rectangle())
                        .cornerRadius(10)
                        .padding(.leading, 8)
                    Button(action: {
                        withAnimation {
                            selectedMedia?.deleteCacheOfSelectedMediaIfAny()
                            selectedMedia = nil
                        }
                    }) {
                        Image(systemName: "clear")
                            .foregroundColor(themeController.theme.accent.opacity(1))
                    }  .buttonStyle(.borderless)
                        .padding(.leading, 87)
                        .padding(.bottom, 95)
                }
                Spacer()
            }
            .frame(height: 125)
            .background(themeController.theme.primary)
        }
    }
    
     
    
    var sendPhotoButton : some View {
        Circle()
            .foregroundColor(themeController.theme.secondary)
            .shadow(color: .black.opacity(0.16), radius: 6, x: 0, y: 3)
            .frame(width: 46, height: 46)
            .overlay(
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundColor(.black)
            )
            .onTapGesture {
                if cameraCommentAlert == false {
                    withAnimation() {
                        buttonAlertType = .cameraComment
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            cameraCommentAlert = true
                        }
                    }
                } else  {
                    ShowPhotoImagePicker = true
                }

            }
            .presentMediaPicker(isPresented: $ShowPhotoImagePicker, selectedMedia: $selectedMedia,text: $message, parentView: .message)
            
    }
    var sendGifButton : some View {
        Circle()
            .foregroundColor(themeController.theme.secondary)
            .shadow(color: .black.opacity(0.16), radius: 6, x: 0, y: 3)
            .frame(width: 46, height: 46)
            .overlay(
                Image("gifSticker")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            )
            .onTapGesture {
                isShowingGIFkeyboard = true
            }
            .popover(isPresented: $isShowingGIFkeyboard, content: {
                GIFController(url: $gifURL, present: $isShowingGIFkeyboard)
                    .offset(y: 35)
            })
    }
    var textField: some View {
        VStack  (spacing: 16){
            //we can look into it later as we will set audioUrl in the newMedia so we can check easily that do we have audio selected
//            if selectedMedia == nil{
//          if newMedia?.image == nil && !soundManager.audios.isEmpty {
            Rectangle()
                   .frame(width: screenWidth, height: 5)
//                   .foregroundColor(Color.mainColorInverse)
                   .foregroundColor(.mainColorInverse)
//            }
            ZStack {
             
                HStack(alignment: .bottom, spacing: 0) {
                HStack(spacing: 15) {
                    ZStack {
                    HStack  {
    //                          TextField("Message", text: $message)
                        ZStack {
                            if message.isEmpty {

                                TextField("Comment",text :  $message)
                                    .foregroundColor(Color.gray)
                                    .padding(.leading,12)
                                    .animation(.none)
                                    .opacity(soundManager.isRecording ? 0 : 1)
                            }
                        ExpandingTextView(text: $message, maxHeight: $textViewMaxHeight, isFirstResponder: isFirstResponder )
                            .background(Color.clear)
                            .opacity(soundManager.isRecording ? 0 : 1)
                            .padding(.leading, 8)
                            .padding(.vertical, 10)
    //                        .background(Color.speakerPurple.opacity(0.2))
                            
                                  .onChange(of: gifURL, perform: { value in
                                      guard let userId = Auth.auth().currentUser?.uid else {
                                          return
                                      }
                                      
                                      if id != TristanUserID {
                                          if IDofPersonReplyingTo == "" {
                                              let rawComment = CommentModel.Raw(sentBy: userId,
                                                                                comment: gifURL,
                                                                                postID:  postData.postID,
                                                                                otherUserID: id,
                                                                                friendIDs: comments.friendsWhoCommented.getArray(),
                                                                                token: friendsDictionary.friendsDictionary[id]?.token ?? "",
                                                                                nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "",
                                                                                isGIF: true)

                                              comments.sendCommentTest(rawComment: rawComment, mentionedIDs: mentionCount )
                                              commentLikeVM.subcribeToPost()
                                              
                                          } else {
                                              guard canSendReply else {
                                                  return
                                              }
                                              canSendReply = false
                                              Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (_) in
                                                  canSendReply = true
                                              }
                                          }
                                      }
                                      TypingIndicatorOO.isNotTypingInOPCloudFunc(
                                          originalAuthor: id, postID: postData.postID)
                                    
                                  })
                        .onReceive(Just(message)) { content in
                            if content.contains("@") {
                                isShowingMentions = true
                            } else {
                                mentionCount.removeAll()
                                isShowingMentions = false
                            }
                        }
                        .onReceive(Just(message)) { content in
                            if content.isNotEmpty {
                                if isTyping == false {
                                    TypingIndicatorOO.isTypingInOPCloudFunc(
                                        originalAuthor: id, postID: postData.postID)
                                }
                                isTyping = true
                            } else {
                                if isTyping == true {
                                    TypingIndicatorOO.isNotTypingInOPCloudFunc(
                                        originalAuthor: id, postID: postData.postID)
                                    isTyping.toggle()
                                } else {
                                    isTyping = false
                                }
                            }
                        }
                    }
    //                    .padding(.vertical, 10)
                        .background(soundManager.isRecording ? Color.mainColorInverse.opacity(0.001) : themeController.theme.secondary)
                    }
                        if soundManager.isRecording {
                            Audio(soundManager: soundManager)
                                    .frame(width: screenWidth - 21, height: 50)
                                    .background(Color.mainColorInverse.opacity(0.6))
                        }
                }
                } // HSTACK
                .clipShape(ChatBubbleShape(direction: .right))
                .padding(.trailing, 16)
                .padding(.leading, 5)

                    if  soundManager.isRecording == false, message.isNotEmpty || selectedMedia != nil  {

                    Button(action: {
                        guard let userId = Auth.auth().currentUser?.uid else {
                            return
                        }
                        
                        if id != TristanUserID {
                            if !mentionCount.isEmpty {
                                             for item in mentionCount {
                                                 if message.contains(friendsDictionary.friendsDictionary[item]?.username ?? "") {
                                                 } else {
                                                     if let firstIndex = mentionCount.firstIndex(of: item) {
                                                     mentionCount.remove(at: firstIndex)
                                                     }
                                                 }
                                             }
                            }
                            if IDofPersonReplyingTo == "" {
                                comments.send(comment: message.trimWhitespacesAndNewlines(),
                                              selectedMedia: selectedMedia,
                                              token: friendsDictionary.friendsDictionary[id]?.token ?? "",
                                              nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "",
                                              mentionedIDs: mentionCount)
                                commentLikeVM.subcribeToPost()
                                
                            } else {
                                guard canSendReply else {
                                    return
                                }
                                canSendReply = false
                                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (_) in
                                    canSendReply = true
                                }
                            }
                        }
                    
                        message = ""
                        selectedMedia = nil
//                        soundManager.clearAudios()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            hideKeyboard()

                            commentID = ""
                            mentionCount = [""]
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation() {
                                    if notificationsAlert == false {
                                        buttonAlertType = .notifications
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            notificationsAlert = true
                                        }
                                    } else if activeMomentsAlert == false {
                                        buttonAlertType = .activeMoments
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            activeMomentsAlert = true
                                        }
                                    }
                                }
                            }
                        }
                    }){
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color.black)
                            // Rotating paperplane
                            .rotationEffect(.init(degrees: 45))
                            // Padding Shape
                            .padding(.vertical, 10)
                            .padding(.leading, 12)
                            .padding(.trailing, 17)
                            .background(themeController.theme.secondary)
                            .clipShape(Circle())
                        
                    } // BUTTON
                    .padding(.leading, -18)
                    
                }
            } // HSTACK

            }
            .offset(y: -8)
//            .padding(.top, 15)
            .onReceive(Just(message)) { content in
                if content.contains("@") {
                    isShowingMentions = true
                } else {
                    mentionCount.removeAll()
                    isShowingMentions = false
                }
            }

            
        }
    }

    
    var isCurrentViewVisible: Bool {
        FriendProfileMatchedGeometry.isEmpty &&
        CommentLikesMatchedGeometry.isEmpty &&
        LikesProfileMatchedGeometry.isEmpty &&
        OpenedPhotoMatchedGeometry.isEmpty &&
        OpenedGIFMatchedGeometry.isEmpty &&
        LongPostMatchedGeometry.isEmpty &&
        postVM.openedTags.isEmpty &&
        !mentionedUserVM.presentTapView &&
        !ShowPhotoImagePicker &&
        !isShowingGIFkeyboard
    }
    
    func stopAndDeleteRecordingIfAny(isCurrentViewVisible: Bool){
        if isCurrentViewVisible == false {
            if soundManager.isRecording {
                soundManager.stopAndDelete()
//                isAudioSessionOn = false
            }
        }
    }
    
    func deletePost(){
        if let post = deletedPost2{
            timelinePosts.delete(post: post)
            
        }
        isDeletePostShowing = false
        DispatchQueue.main.async {
        postVM.dismissOpenedPost()
        }
           print("Deleting...")
        
       }
}
struct LikeButton: View {
    @State private var circleSize = 0.0
    @State private var circleInnerBorder = 35
    @State private var circleHue = 200
    @State var hasBeenLiked = false
    @Binding var MomentLikesNavigation: String
    @State var authorID: String
    @ObservedObject var commentLikeVM : CommentLikeVM
    @ObservedObject var friendsDictionary: FriendsDictionary
    @StateObject var likeFunction = SendLikeFunction()
    @AppStorage("likedMoment") var likedMomentAlert : Bool = false
    @Binding var buttonAlertType: ButtonAlertType
    @ObservedObject var themeController: ThemeController
    var postData: PostModel {
        commentLikeVM.post
    }
    var body: some View {

        HStack(spacing: 0) {
            //
            ZStack {
                Circle()
                    .frame(width: 27, height: 27)
                    .foregroundColor(hasBeenLiked || commentLikeVM.hasBeenLiked ? themeController.theme.accent : themeController.theme.secondary)
//                    .foregroundColor(themeController.theme.accent)
                Circle()
                    .frame(width: 26, height: 26)
//                    .foregroundColor(themeController.theme.secondary)
                    .foregroundColor(hasBeenLiked || commentLikeVM.hasBeenLiked ? themeController.theme.accent : themeController.theme.secondary)
                ZStack {
                    Text(hasBeenLiked || commentLikeVM.hasBeenLiked ? "💝" : "👍🏼")
                        .font(.caption2)
                        .offset(x: hasBeenLiked || commentLikeVM.hasBeenLiked ? 0.5 : 0, y: hasBeenLiked || commentLikeVM.hasBeenLiked ? 0.5 : 0)
//
//                        .font(hasBeenLiked || commentLikeVM.hasBeenLiked  ? .caption2 : .footnote)
                    Circle()
                        .strokeBorder(lineWidth:  CGFloat(circleInnerBorder))
                        .animation(Animation.easeInOut(duration: 0.5).delay(0.1))
                        .frame(width: 26, height: 26, alignment: .center)
                        .foregroundColor(Color(.systemPink))
                        .hueRotation(Angle(degrees: Double(circleHue)))
                        .scaleEffect(CGFloat(circleSize))
                        .animation(Animation.easeInOut(duration: 0.5))
                }
            }
//            .shadow(color: Color.mainColorInverse.opacity(0.16), radius: 6, x: 0, y: 3)

        }
        .onTapGesture {
            likePost()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                withAnimation() {
                    if likedMomentAlert == false {
                        buttonAlertType = .likedMoment
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            likedMomentAlert = true
                        }
                    }
                }
            }
        }
        .onLongPressGesture {
            withAnimation {
                MomentLikesNavigation = "0"
            }
            let impactLight = UIImpactFeedbackGenerator(style: .heavy)
            impactLight.impactOccurred()
        }
        .offset(y: 8)
    }
    func likePost(){

        guard let userId = Auth.auth().currentUser?.uid else{ return }

        if commentLikeVM.hasBeenLiked == false {
            if authorID != TristanUserID {
                likeFunction.sendLike(sentBy: userId, postID: postData.postID, otherUserID: authorID, token: friendsDictionary.friendsDictionary[authorID]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "")
            }
            hasBeenLiked = true
            circleSize = 1.3
            circleInnerBorder = 0
            circleHue = 300
#if os(iOS)
            let impactLight = UIImpactFeedbackGenerator(style: .soft)
            impactLight.impactOccurred()
#endif
        }
    }
}



struct MomentLikeList: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var likes: LikesOO
    @ObservedObject var friendsDictionary: FriendsDictionary
    @Binding var StrangerProfileSelectedUser: Person
    @Binding var FriendProfileMatchedGeometry: String
    @Binding var anonymousModeAlert: Bool
    @Binding var buttonAlertType: ButtonAlertType
    @ObservedObject var themeController: ThemeController
    var action: () -> ()
    var body: some View {
        
        ZStack (alignment: .topLeading){
            VStack (spacing: 0) {
                Rectangle()
                    .foregroundColor(themeController.theme.primary)
                    .cornerRadius(18, corners: [.topLeft, .topRight])
                    .frame(height: 90)
                    .overlay (
                            HStack {
                                Text("💝")
                                    .font(.custom("", size: 50))
                                    .shadow(color: themeController.theme.primary.opacity(0.16), radius: 6, x: 0 , y: 3)
                            }
                                .padding(.horizontal)
                    )
                ScrollView {
                    LazyVStack (spacing: 5) {
//                        ForEach(likes.postLikes.sorted(by: {$1.name.lowercased() > $0.name.lowercased()}), id: \.self) { item in
                        ForEach(likes.postLikes, id: \.self) { item in
                            SearchBarResultRow(person: item, size: 55, friendsDictionary: friendsDictionary, anonymousModeAlert: $anonymousModeAlert, buttonAlertType: $buttonAlertType)
                                .contentShape(Rectangle())
                                .padding(.horizontal, 8)
                                .onTapGesture {
                                    if (item.anonymousMode == true && friendsDictionary.friendsDictionary[item.id] != nil) || item.anonymousMode == false {
                                        if friendsDictionary.friendsDictionary[item.id] != nil {
                                            FriendProfileMatchedGeometry = item.id
                                        } else {
                                            FriendProfileMatchedGeometry = item.id
                                            StrangerProfileSelectedUser = item
                                            
                                        }
                                    }
                                }
                            Divider()
                                .padding(. horizontal, 5)
                        }
                    }
                    .padding(.top, 10)
                }
                .frame(height: screenHeight/1.747)
//                .frame(height: likes.postLikes.count > 7 ? 530 : ((CGFloat(likes.postLikes.count) * 65) + 10))
                .clipped()
                
            }
            .frame(width: screenWidth/1.1444)
            .padding(3)
            .background(
                Rectangle()
                    .foregroundColor(themeController.theme.secondary)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.16), radius: 6, x: 0, y:6))
            DoubleCircle(size1: 45, size2: 39,
                         themeController: themeController) {
                action()
            }
            .overlay (
                Image(systemName: "xmark")
                    .foregroundColor(.black)
                    .onTapGesture {
                        withAnimation {
                            action()
                        }
                    }
            )
            .offset(x: -10, y: -10)
        }
        .transition(.opacity)
    }
}

struct MomentLockList: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var members: OpenedTagOO
    @ObservedObject var friendsDictionary: FriendsDictionary
    @State var isLocked = true
    var authorID: String
    @Binding var StrangerProfileSelectedUser: Person
    @Binding var FriendProfileMatchedGeometry: String
    @Binding var anonymousModeAlert: Bool
    @Binding var buttonAlertType: ButtonAlertType
    @ObservedObject var themeController: ThemeController
    var action: () -> ()
    var body: some View {
        
        ZStack (alignment: .topLeading){
            VStack (spacing: 0) {
                Rectangle()
                    .foregroundColor(themeController.theme.primary)
//                    .foregroundColor(colorScheme == .light ? .backgroundColor : .softWhite)
                    .cornerRadius(18, corners: [.topLeft, .topRight])
                    .frame(height: 90)
                    .overlay (
                        HStack (alignment: .top) {
                                VStack (alignment: .leading, spacing: 8) {
                                    if isLocked {
                                        Text("Locked")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        Text("This Moment is available to the following people")
                                            .font(.caption2)
                                            .fontWeight(.light)
                                    } else {
                                        Text("Unlocked")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        Text("This Moment is available to all of \(friendsDictionary.friendsDictionary[authorID]?.name ?? "")’s friends")
                                            .font(.caption2)
                                            .fontWeight(.light)
                                    }
                                }
                                .foregroundColor(.black)
                                .offset(y: 10)
                                Spacer()
                                Circle()
                                .foregroundColor(themeController.theme.secondary)
                                    .frame(width: 40, height: 40)
                                    .overlay (
                                        Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                    )
                            }
                                .padding(.horizontal)

                    )
                ScrollView {
                    LazyVStack (spacing: 5) {
//                        ForEach(members.people.sorted(by: {$1.name.lowercased() > $0.name.lowercased()}), id: \.self) { item in
                            ForEach(members.people, id: \.self) { item in
                            if item.id != TristanUserID {
                                SearchBarResultRow(person: item, size: 55, friendsDictionary: friendsDictionary, anonymousModeAlert: $anonymousModeAlert, buttonAlertType: $buttonAlertType)
                                    .contentShape(Rectangle())
                                    .padding(.horizontal, 8)
                                    .onTapGesture {
                                        if (item.anonymousMode == true && friendsDictionary.friendsDictionary[item.id] != nil) || item.anonymousMode == false {
                                            if friendsDictionary.friendsDictionary[item.id] != nil {
                                                FriendProfileMatchedGeometry = item.id
                                            } else {
                                                FriendProfileMatchedGeometry = item.id
                                                StrangerProfileSelectedUser = item
                                                
                                            }
                                        }
                                    }
                                Divider()
                                    .padding(. horizontal, 5)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                .frame(height: screenHeight/1.747)
//                .frame(height: members.people.count > 7 ? 530 : ((CGFloat(members.people.count) * 65) + 10))
                .clipped()
                
            }
            .frame(width: screenWidth/1.1444)
            .padding(3)
            .background(
                Rectangle()
//                    .foregroundColor(colorScheme == .light ? Color.white : Color.backgroundColor)
                    .foregroundColor(themeController.theme.secondary)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.16), radius: 6, x: 0, y:6))
            DoubleCircle(size1: 45, size2: 39,
                         themeController:themeController) {
                action()
            }
            .overlay (
                Image(systemName: "xmark")
                    .foregroundColor(.black)
                    .onTapGesture {
                        withAnimation {
                            action()
                        }
                    }
            )
            .offset(x: -10, y: -10)
        }
        .transition(.opacity)
    }
}

