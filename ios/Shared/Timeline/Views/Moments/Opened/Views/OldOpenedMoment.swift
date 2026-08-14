//
//  OldOpenedMoment.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 10/17/22.
//

import Foundation
import SwiftUI
import Combine
import Firebase
import FirebaseFirestore
import SDWebImageSwiftUI
import Introspect
   


struct OpenedPost3: View {
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
    var postData: PostModel {
        commentLikeVM.post
    }
    
    var id: String {
        postData.id
    }
    
    var likeCapsule: some View {
        
        ZStack {
            if commentLikeVM.likesCount < 7 {
                if commentLikeVM.likesCount != 0 {
        Capsule()
            .frame(width: 34 + CGFloat((commentLikeVM.sevenUserLikes.count * 26 + 3)), height: 32)
            .foregroundColor(Color.mainColorInverse.opacity(1))
        Capsule()
            .frame(width: 31 + CGFloat((commentLikeVM.sevenUserLikes.count * 26 + 3)), height: 30)
            .foregroundColor(Color.speakerPurple.opacity(0.27))
            .overlay (
                HStack (spacing: 1) {
                    Text("💜")
                        .font(.headline)
                        .padding(.leading, 3)
                    ForEach(commentLikeVM.sevenUserLikes, id: \.id) { item in
                        ZStack {
                            Circle()
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color.white)
                            WebImage(url: item.profileURL)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 23, height: 23)
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
            )
                }
            } else {
                if commentLikeVM.likesCount == 6 {
                Capsule()
                    .frame(width: 34 + CGFloat((commentLikeVM.sevenUserLikes.count * 26 + 3)), height: 32)
                    .foregroundColor(Color.mainColorInverse.opacity(1))
                Capsule()
                    .frame(width: 31 + CGFloat((commentLikeVM.sevenUserLikes.count * 26 + 3)), height: 30)
                    .foregroundColor(Color.speakerPurple.opacity(0.27))
                    .overlay (
                        HStack (spacing: 1) {
                            Text("💜")
                                .font(.headline)
                                .padding(.leading, 3)
                            ForEach(commentLikeVM.sevenUserLikes, id: \.id) { item in
                                ZStack {
                                    Circle()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(Color.white)
                                    WebImage(url: item.profileURL)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 23, height: 23)
                                        .clipShape(Circle())
                                }
                            }
                            Spacer()
                        }
                    )
                } else {
                    Capsule()
                    .frame(width: 60 + CGFloat((commentLikeVM.sevenUserLikes.count * 26 + 3)), height: 32)
                    .foregroundColor(Color.mainColorInverse.opacity(1))
                Capsule()
                    .frame(width: 57 + CGFloat((commentLikeVM.sevenUserLikes.count * 26 + 3)), height: 30)
                    .foregroundColor(Color.speakerPurple.opacity(0.27))
                    .overlay (
                        HStack (spacing: 1) {
                            Text("💜")
                                .font(.headline)
                                .padding(.leading, 3)
                            ForEach(commentLikeVM.sevenUserLikes, id: \.id) { item in
                                ZStack {
                                    Circle()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(Color.white)
                                    WebImage(url: item.profileURL)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 23, height: 23)
                                        .clipShape(Circle())
                                }

                            }
                            ZStack {
                                Circle()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color.mainColorInverse)
                                Circle()
                                    .frame(width: 23, height: 23)
                                    .foregroundColor(Color.speakerPurple.opacity(0.2))
                                Text("+\(commentLikeVM.likesCount - 6)")
                                    .font(.subheadline)
                                    .foregroundColor(Color.white)
                            }
                            Spacer()
                        }
                    )
                }
            }
        }
    }
    

    
    var presentableViews : some View{
        Group{
            if isShowingMentions == true {
                MutualFriendsForMentions(content: $message, mutualFriends: MutualFriendsOO(id: id, tagMembers: members.people), mentionCount: $mentionCount, themeController: ThemeController())
            }

            if FriendProfileMatchedGeometry != "" {
                if friendsDictionary.friendsDictionary[FriendProfileMatchedGeometry] != nil {
//                    FriendProfileHomeTabView(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: FriendProfileMatchedGeometry, isFromOpenedPost: true)
//                    //                    .padding(.horizontal, 20)
//                        .padding(.top, iOS15 ? 0 : (screenHeight > 800 ? 10 : 10) )
//
//                        .onAppear(perform: postVM.removeViewInfo)
//                        .onDisappear(perform: postVM.setViewInfo)
                    if FriendProfileMatchedGeometry != currentUserID {
                    OpenedConversationTabView(OpenedConversationMatchedGeometry: $FriendProfileMatchedGeometry, id: FriendProfileMatchedGeometry, isFromOpenedMoment: true, isFirstResponder: false)
                    } else {
                        CurrentUserProfileTabView(ProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: currentUserID ?? "",  signOut: .constant(false), friendsDictionary: friendsDictionary)
                            .padding(.top, iOS15 ? 0 : (screenHeight > 800 ? 10 : 10) )
                    }
                } else {
                    StrangerProfileTabView(ProfileMatchedGeometry: $FriendProfileMatchedGeometry, person: StrangerProfileSelectedUser , id: FriendProfileMatchedGeometry)
                        .onAppear(perform: postVM.removeViewInfo)
                        .onDisappear(perform: postVM.setViewInfo)
                }
                
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
            if LikesProfileMatchedGeometry != "" {
                //                LikesTabView(LikesProfileMatchedGeometry: $LikesProfileMatchedGeometry, likes: likes)
                Likes2(LikesMatchedGeometry: $LikesProfileMatchedGeometry, likes: likes, id: postData.id, FriendProfileMatchedGeometry: FriendProfileMatchedGeometry, friendsDictionary: timelinePosts.friendsDictionary, myTags: myTags, isDeletePostAlertShowing: $isDeletePostAlertShowing, deletedPost: $deletedPost, OpenedPhotoMatchedGeometry: OpenedPhotoMatchedGeometry,OpenedPhotoSelectedItem: OpenedPhotoSelectedItem, commentLikeVM: commentLikeVM,
                       isFirstResponder: isFirstResponder, mentionedUserVM: mentionedUserVM, LongPostMatchedGeometry:$LongPostMatchedGeometry, postVM: postVM)
                .onAppear(perform: postVM.removeViewInfo)
                .onDisappear(perform: postVM.setViewInfo)
            }
            
            if postVM.openedTags.isNotEmpty {
                OpenedFriendTag(members: OpenedTagOO(tagIDs: postVM.openedTags,post: postData,friendsDictionary: timelinePosts.friendsDictionary),
                                id: postData.id, FriendProfileMatchedGeometry: FriendProfileMatchedGeometry, friendsDictionary: timelinePosts.friendsDictionary, myTags: myTags, isDeletePostAlertShowing: $isDeletePostAlertShowing, deletedPost: $deletedPost, OpenedPhotoMatchedGeometry: OpenedPhotoMatchedGeometry,OpenedPhotoSelectedItem: OpenedPhotoSelectedItem, commentLikeVM: commentLikeVM,
                                isFirstResponder: isFirstResponder, mentionedUserVM: mentionedUserVM, LongPostMatchedGeometry:$LongPostMatchedGeometry, postVM: postVM, themeController: ThemeController())
                .onAppear(perform: postVM.removeViewInfo)
                .onDisappear(perform: postVM.setViewInfo)
            }
            
            if LongPostMatchedGeometry != "" {
                OpenedLongPostTabView(OpenedLongPostMatchedGeometry: $LongPostMatchedGeometry, friendsDictionary: friendsDictionary, postData: postData, id: id, isFromProfile: isFromProfile, mentionedUserVM: mentionedUserVM)
                    .onAppear(perform: postVM.removeViewInfo)
                    .onDisappear(perform: postVM.setViewInfo)
            }
            
            if mentionedUserVM.presentTapView{
                UserMentionTabView(mentionedUserVM: mentionedUserVM, isFromOpenedProfile: isFromProfile, themeController: ThemeController())
                    .onAppear(perform: postVM.removeViewInfo)
                    .onDisappear(perform: postVM.setViewInfo)
            }
            
            if CommentLikesMatchedGeometry != "" {
                CommentLikesTabView2(LikesMatchedGeometry: $CommentLikesMatchedGeometry, likes: CommentLikesOO(id: id, postID: postData.postID, commentID: CommentLikesMatchedGeometry), comments: comments, comment: comment, friendsDictionary: friendsDictionary)
                    .onAppear(perform: postVM.removeViewInfo)
                    .onDisappear(perform: postVM.setViewInfo)
            }
            
        }
    }
    
    
    var selectedAudioView: some View {
        selectedMedia?.audioUrl.map {_ in
        HStack {
            ZStack {
                Rectangle()
                    .frame(width: 105, height: 120)
                    .foregroundColor(Color.mainColorInverse.opacity(0.4))
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
                                    .foregroundColor(Color.speakerPurple.opacity(0.2))
                                AnimatedWaveformView(color: Color.white, renderingMode: .hierarchical, animated: true, doesHaveOutterRing: false)
                                .frame(width: 60, height: 60)
                                .scaledToFit()
                            }
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(Color.speakerPurple.opacity(0.2))
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
                        .foregroundColor(Color.speakerPurple.opacity(1))
                }  .buttonStyle(.borderless)
                    .padding(.leading, 90)
                    .padding(.bottom, 100)
            }
            .padding(.leading)
            Spacer()
        }
        .frame(height: 125)
        .background(Color.speakerPurple.opacity(0.2))
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
                        .padding(.leading)
                    Button(action: {
                        selectedMedia?.deleteCacheOfSelectedMediaIfAny()
                        selectedMedia = nil
                    }) {
                        Image(systemName: "clear")
                            .foregroundColor(Color.speakerPink.opacity(1))
                    }  .buttonStyle(.borderless)
                        .padding(.leading, 95)
                        .padding(.bottom, 95)
                }
                Spacer()
            }
            .frame(height: 125)
            .background(Color.speakerPurple.opacity(0.2))
        }
    }
    
     
    
    var sendPhotoButton : some View {
        Image(systemName: "photo")
            .font(.system(size: 22))
          .foregroundColor(Color.mainColor)
            .padding(.vertical, 12)
            .padding(.leading, 12)
            .padding(.trailing, 12)
            .background(Color.mainColorInverse.opacity(0.6))
            .clipShape(Circle())
            .onTapGesture {
                ShowPhotoImagePicker = true
            }
            .presentMediaPicker(isPresented: $ShowPhotoImagePicker, selectedMedia: $selectedMedia,text: $message, parentView: .message)
            
    }
    var sendGifButton : some View {
        
        Image(colorScheme == .light ? "gifSticker" : "gifStickerWhite")
            .resizable()
            .frame(width: 30, height: 30)
          .foregroundColor(Color.mainColor)
            .padding(.vertical, 9)
            .padding(.leading, 9)
            .padding(.trailing, 9)
            .background(Color.mainColorInverse.opacity(0.6))
            .clipShape(Circle())
            .onTapGesture {
                isShowingGIFkeyboard = true
            }
            .popover(isPresented: $isShowingGIFkeyboard, content: {
                GIFController(url: $gifURL, present: $isShowingGIFkeyboard)
                    .offset(y: 35)
            })
    }
    var textField: some View {
        VStack {
            //we can look into it later as we will set audioUrl in the newMedia so we can check easily that do we have audio selected
            if selectedMedia == nil{
//          if newMedia?.image == nil && !soundManager.audios.isEmpty {
            Rectangle()
                   .frame(width: screenWidth, height: 1)
                   .foregroundColor(Color.mainColorInverse)
            }
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
                    .background(Color.mainColorInverse.opacity(0.6))
                    }
                        if soundManager.isRecording {
                            Audio(soundManager: soundManager)
                                    .frame(width: screenWidth - 21, height: 58)
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
                        
                        if id != "ctgg158KOnajMBuFZ5GyHLyRYPE3" {
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
                        }
                    }){
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color.mainColor)
                            // Rotating paperplane
                            .rotationEffect(.init(degrees: 45))
                            // Padding Shape
                            .padding(.vertical, 10)
                            .padding(.leading, 12)
                            .padding(.trailing, 17)
                            .background(Color.mainColorInverse.opacity(0.6))
                            .clipShape(Circle())
                    } // BUTTON
                    .padding(.leading, -18)
                }
            } // HSTACK
    //                .background(Color.speakerPink.opacity(0.2))
            .ignoresSafeArea(.keyboard)
    //                        .padding(.bottom, 54)
    //                        .animation(.easeOut)
            .padding(.bottom,  keyboard.bottomPadding )
            }
            .padding(.top, 15)
            .onReceive(Just(message)) { content in
                if content.contains("@") {
                    isShowingMentions = true
                } else {
                    mentionCount.removeAll()
                    isShowingMentions = false
                }
            }
            .padding(.bottom, iOS15 ? 0 : 60)
            .background(Color.speakerPurple.opacity(0.2).ignoresSafeArea(.all))
        }
    }
    
    var body: some View {
        ZStack {
            Color.mainColorInverse
                .ignoresSafeArea(.all)
                .onChange(of: isCurrentViewVisible, perform: stopAndDeleteRecordingIfAny)
            VStack (spacing: 0){
                if keyboard.value == 0 || FriendProfileMatchedGeometry != ""  {
                TimelineMoment(id: postData.id, friendProfileSelectedItem: $friendProfileSelectedItem, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,
                               friendsDictionary: timelinePosts.friendsDictionary , myTags: myTags, isFromProfile: isFromProfile, isDeletePostAlertShowing: $isDeletePostAlertShowing, deletedPost:
                                $deletedPost, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,commentLikeVM : commentLikeVM ,  isFromOpenedPost: true,isFirstResponder: $isFirstResponder, mentionedUserVM : mentionedUserVM, LongPostMatchedGeometry: $LongPostMatchedGeometry, postVM: postVM)
                    .ignoresSafeArea(.all, edges: .top)
                    .contextMenu {
                        VStack {
                            if postData.id == currentUserID {
                                
                                Button("Edit") {
                                    guard commentLikeVM.allowContextMenu else { return }
                                    showUpdatePost = postData
                                    postVM.dismissOpenedPost()
                                } .font(.headline)
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
                }
                Spacer()
                ZStack (alignment: .topLeading) {
                    Color.speakerPurple.opacity(0.2)
               

                    VStack {
//                        if !comments.sortedComments.isEmpty {
                        List() {
                       
                                ForEach(comments.sortedComments.reversed(), id: \.self) { item in
                             NewComment(comments: comments,
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
                                        comment2: $comment, OpenedGIFMatchedGeometry: $OpenedGIFMatchedGeometry, OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,
                                        OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry)
                                        .id(item.commentID)
                                        .listRowInsets(EdgeInsets(top: -20, leading: 15, bottom: 0, trailing: 0))
                                 .scaleEffect(x: 1, y: -1, anchor: .center)
//                                 .contextMenu {
//
//                                     if let userId = Auth.auth().currentUser?.uid,
//                                        item.id == userId || userId == id {
//                                         VStack {
//                                             Button(action: {
//                                                 comments.deleleComment(comment: item)
//                                             }) {
//                                                 Text("Delete")
//                                             }.buttonStyle(.borderless)
//
//                                         }
//                                     }
//                                 }

                   
                    } .environmentObject(mentionedUserVM)
                            .padding(.top, 30)
                            .padding(.leading, -10)
                        }
                        .offset(y: id == TristanUserID && screenHeight > 880 && comments.sortedComments.count < 5 ? 25 : 0)
                        .padding(.leading,-15)
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
//                        } else {
//                            Spacer()
//                        }
                    }
                    likeCapsule
                        .padding(.leading, 10)
                        .offset(x: 0, y: -5)
                        .onTapGesture {
                            LikesProfileMatchedGeometry = "0"
                        }
            
                }
                
//                .padding(.top, iOS15 ? -49 : 0)
//                .padding(.top, keyboard.value > 0 && iOS15 && newMedia?.image != nil ? 8 : 0)
                ZStack (alignment: .bottom) {
                    VStack() {
                        selectedAudioView
                        selectedMediaView
                        textField
                    }

                    HStack {
                        if postData.postID.isNotEmpty{
                            
                            TypingIndicatorController(people: TypingIndicatorOO(type: .OpenedMoment, resourceID: postData.postID, authorID: id), isFromOpenedPost: true, currentView: .OpenedMoment, themeController: ThemeController())
                                .padding(.leading, 20)
                                .animation(.easeInOut(duration: 0.3))
                        }
                        Spacer()
                        if selectedMedia?.newMedia == nil {
                        RecordNewAudioView(soundManager: soundManager, selectedMedia: $selectedMedia, isFromMessages: false, audioCommentAlert: .constant(false), buttonAlertType: .constant(.none), themeController: ThemeController())
                            .offset(x: message != "" || selectedMedia != nil ? 14 : 0)
                            .padding(.trailing, 3)
                        }
                        if selectedMedia?.audioUrl == nil && !soundManager.isRecording {
                        sendGifButton
                            .offset(x: message != "" || selectedMedia?.image != nil ? 14 : 0)
                        sendPhotoButton
                            .offset(x: message != "" || selectedMedia?.image != nil ? 14 : 0)
                        }
                    }
                    .padding(.bottom, keyboard.bottomPadding)
                    .offset(x: -16, y: -60 + keyboard.value)
                    .offset(y: iOS15 ? 0 : -screenHeight/13.5)
                    .offset(y: keyboard.value > 0 ? -keyboard.value : 0)
                    .offset(y: -30)

                }
                
            }
            .padding(.top, isFromProfile && iOS15 != true ? 60 : 0)
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
        .edgesIgnoringSafeArea(.top)
        .padding(.top, iOS15 ? 0 : -60)
        .onReceive(timelinePosts.getAccessTagPublisher(postTags: postData.tags)) { isDisabled in
            if  self.isDisabled != isDisabled {
                self.isDisabled = isDisabled
            }
        }
        .blur(radius: isDisabled ? 10 : 0)
        .disabled(isDisabled)
        
        
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


struct OpenedLongPost: View {
    @ObservedObject var friendsDictionary: FriendsDictionary
    @State var postData: PostModel
    @State var id: String
    @Environment(\.colorScheme) var colorScheme
    @StateObject var screenCaptureVM = OpenedPostScreenCaptureVM()
    @Binding var OpenedLongPostMatchedGeometry: String
    @State var isFromProfile = false
    @ObservedObject var mentionedUserVM : MentionedUserVM
    var body: some View {
        ZStack {
            Color.mainColorInverse
                .ignoresSafeArea(.all)
            Color.speakerPurple.opacity(0.2)
                .ignoresSafeArea(.all)
                .onAppear {
                    screenCaptureVM.startScreenCaptureListener(postID: postData.postID, postAuthor:  postData.id)
                }
            VStack (alignment: .leading) {
                HStack (spacing: 10) {
                    WebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 55, height: 55)
                        .clipShape(Circle())
                    
                    HStack(alignment: .top) { // necessary to align timestamp with name
                        VStack(alignment: .leading, spacing: 2) {
                            Text(friendsDictionary.friendsDictionary[id]?.name ?? "")
                                .fontWeight(.bold)
                            Text(friendsDictionary.friendsDictionary[id]?.username ?? "")
                                .font(.caption)
                        } // VSTACK
                        Spacer()
                        Text(postData.timeString)
                            .font(.caption)
                            .padding(.horizontal, screenWidth > 375 ? 16 : 10)
                    } // HSTACK
                    .foregroundColor(.mainColor)
                } // HSTACK
                ScrollView (showsIndicators: false) {
                    VStack {
//                    Text(postData.content)
//                        .font(.title3)
//                       .foregroundColor(Color.mainColor)
//
                    let PostText = Text(postData.content)
                        .font(.title3)

                    if postData.content.indicesOf(string: "@").count != 0 {
                        PostText
                            .hidden()
                            .overlay(
                                GeometryReader { proxy in
                                    PostLabel(width: proxy.size.width - 25, content: postData.content){
                                        name in mentionedUserVM.menionedTapped(username: name)
                                        print(" mentionedUserVM ")
                                    }
                                }
                            )
                        
                    } else {
                        PostText
                    }
                    Spacer()
                    }
                }
            }
            .padding(.vertical, 6)
            .padding(.top, iOS15 ? 0 : 60)
            .padding(.top, isFromProfile && iOS15 != true ? 60 : 0)
            .padding(.horizontal, screenWidth > 375 ? 16 : 10)
        }
    }
}

struct OpenedLongPostTabView: View {
    @Binding var OpenedLongPostMatchedGeometry: String
    @ObservedObject var friendsDictionary: FriendsDictionary
    @State var postData: PostModel
    @State var id: String
    @State var emptyStringBinding: String = ""
    @State var selectedTab = "likes"
    @State var isFromProfile = false
    @ObservedObject var mentionedUserVM : MentionedUserVM
    var body: some View {
        if selectedTab == "likes" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    OpenedLongPost(friendsDictionary: friendsDictionary, postData: postData, id: id, OpenedLongPostMatchedGeometry: $OpenedLongPostMatchedGeometry, isFromProfile: isFromProfile, mentionedUserVM: mentionedUserVM)
                        .tag("likes")
                    
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    OpenedLongPostMatchedGeometry = ""
                }
            
        }
    }
}



struct OpenedPostTabView: View {
    @State var selectedTab = "openedPost"
    @State var isFirstResponder = false
    var isFromProfile: Bool = false
    @StateObject var commentLikeVM : CommentLikeVM
    @ObservedObject var postVM : PostVM
    @Binding var showUpdatePost: PostModel?
    @ObservedObject var myTags: MyTagsOO
    var postData: PostModel {
        commentLikeVM.post
    }
    var body: some View {
        if selectedTab == "openedPost" {
            ZStack {
                let openedPost = OpenedPostController(myTags: myTags, comments: CommentsOO(id: postData.id, postID: postData.postID),
                    likes: LikesOO(id: postData.id, postID: postData.postID),
                    hasBeenLikedOO: HasPostBeenLikedOO(id: postData.id, postID: postData.postID),
                    isFromProfile: isFromProfile,
                    isFirstResponder: isFirstResponder,
                    commentLikeVM: commentLikeVM,
                                                      postVM: postVM, showUpdatePost: $showUpdatePost, show: .constant(false), buttonAlertType: .constant(.none), lockedMomentAlert: .constant(false), themeController: ThemeController())
                
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    openedPost
                        .tag("openedPost")
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
#elseif os(macOS)
                openedPost
#endif
            }
            .ignoresSafeArea(edges: .top)
            
        } else {
            //            Ho me(signOut: $emptyBoolBinding)
            EmptyView()
                .onAppear() {
                    postVM.dismissOpenedPost()
                }
            
        }
    }
}

