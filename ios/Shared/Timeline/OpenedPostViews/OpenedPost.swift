//
//  OpenPostTabViewTest.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/16/21.
//

import SwiftUI
import SDWebImageSwiftUI
import SDWebImage 
import Firebase
import Combine


/*
 so the post is opened and user has lost the access. now to check that we will have a func that will return a publisher to which openedpost view will listener to. the publisher will only be fired when user will lose the access. and we will disable activity
 */

 
struct OpenedPost: View {
    @Namespace var namespace
    @ObservedObject var comments : CommentsOO
    @StateObject var likes = LikesOO(id: "", postID: "")
    @State var message = ""
    @State var FriendProfileSelectedID: String = ""
    @State var FriendProfileMatchedGeometry: String = ""
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @State var id: String = ""
    @Binding var OpenedPostMatchedGeometry: String
    @State var OpenedPhotoMatchedGeometry: String = ""
    @State var OpenedPhotoSelectedItem: URL?
      var postData: PostModel
    @StateObject var keyboard = KeyboardOO()
    @State var LongPostMatchedGeometry: String = ""
    @StateObject var hasBeenLikedOO = HasPostBeenLikedOO(id: "", postID: "")
    @State var hasBeenLiked = false
    @StateObject var functions = SendCommentFunction()
    @StateObject var likeFunction = SendLikeFunction()
    @StateObject var replyFunction = ReplyToCommentFunction()
    @StateObject var screenCaptureVM = OpenedPostScreenCaptureVM()
    
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
    @State var isOpenedFromProfile = false
    // Like animation
    @State private var circleSize = 0.0
    @State private var circleInnerBorder = 35
    @State private var circleHue = 200
    //
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    @State var isFirstResponder = true
    @StateObject var mentionedUserVM : MentionedUserVM
    var commentView : some View {
         
        ZStack (alignment: .bottomTrailing) {
            ScrollView(showsIndicators: false) {
                
                VStack() {
                    ForEach(comments.sortedComments, id: \.self) { item in
                        
                        Comment(comments: comments,
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
                                commentReplies: CommentRepliesOO(id: id, postID: postData.postID, commentID: item.commentID)
                        )
                            .contentShape(Rectangle())
                            .contextMenu {
                                 
                                if let userId = Auth.auth().currentUser?.uid,
                                   item.id == userId || userId == id {
                                    VStack { 
                                        Button(action: {
                                            comments.deleleComment(comment: item)
                                        }) {
                                            Text("Delete")
                                        }.buttonStyle(.borderless)
                                        
                                    }
                                }
                            }
                            .environmentObject(mentionedUserVM)
                    }
                }

//                .padding(.top, 10)
            } // Comments
          
        }
    }
    @State var textViewMaxHeight: CGFloat = screenHeight*0.4 - 120
    var expandingTextView : some View {
        
        ZStack {
//            let _ = print("ExpandingTextView " )
            if message.isEmpty {

                TextField(textFieldPlaceholder,text : .constant(""))
                    .foregroundColor(Color.gray)
                    .padding(.leading,5)
                    .animation(.none)
#if os(macOS)
                    .textFieldStyle(.plain) 
#endif
              }
  
            ExpandingTextView(text: $message, maxHeight: $textViewMaxHeight, isFirstResponder: isFirstResponder )
           
        }.padding(.horizontal, screenWidth > 375 ? 16 : 10)
       .foregroundColor(Color.mainColor)
    }
    
    func likePost(){
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        if hasBeenLikedOO.hasBeenLiked == false {
            if id != "ctgg158KOnajMBuFZ5GyHLyRYPE3" {
                likeFunction.sendLike(sentBy: userId, postID: postData.postID, otherUserID: id, token: friendsDictionary.friendsDictionary[id]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "")
            }
        }
        
        hasBeenLiked.toggle()
        circleSize = 1.3
        circleInnerBorder = 0
        circleHue = 300
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .soft)
                        impactLight.impactOccurred()
#endif
    }
    
    func sendTypedComment(){
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
                let rawComment = CommentModel.Raw(sentBy: userId,
                                                  comment: message.trimWhitespacesAndNewlines(),
                                                  postID:  postData.postID,
                                                  otherUserID: id,
                                                  friendIDs: comments.friendsWhoCommented.getArray(),
                                                  token: friendsDictionary.friendsDictionary[id]?.token ?? "",
                                                  nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "")
                
//              comments.sendNewComment(rawComment: rawComment, mentionedIDs: mentionCount, postID: postData.postID, originalAuthor: id)
                comments.sendCommentTest(rawComment: rawComment, mentionedIDs: mentionCount)
                
            } else {
                guard canSendReply else {
                    return
                }
                canSendReply = false
                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (_) in
                    canSendReply = true
                }
                
                guard let webLink = (friendsDictionary.friendsDictionary[userId]?.webLink) else {
                    return
                }
                var friendsDict : [String : Person]  {
                   return friendsDictionary.friendsDictionary
                }
               
              let rawReplyComment = CommentModel.Raw.Reply(sentBy: userId,
                                                           comment: message.trimWhitespacesAndNewlines(),
                                       commentID: commentID,
                                       postID: postData.postID,
                                       webLink: webLink,
                                       postOwnerID: id,
                                       otherUserID: IDofPersonReplyingTo,
                                       token: friendsDict[IDofPersonReplyingTo]?.token ?? "",
                                       postOwnerToken: friendsDict[id]?.token ?? "",
                                       nameOfSendingUser: friendsDict[userId]?.name ?? "",
                                       friendIDs: comments.friendsWhoCommented.getArray(),
                                       friendIDs2: friendsWhoReplied,
                                       mentionIDs: mentionCount)
                comments.rawReplyComment = rawReplyComment
            }
        }
        message = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            hideKeyboard()
            textFieldPlaceholder = "Comment"
            IDofPersonReplyingTo = ""
            nameOfPersonReplyingTo = ""
            commentID = ""
            mentionCount = [""]
        }
    }
      
    var body: some View {
        ZStack (alignment: .top) {
            Color.mainColorInverse
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    screenCaptureVM.startScreenCaptureListener(postID: postData.postID, postAuthor:  postData.id)
                }
            VStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    
#if os(macOS)
//                    dismissButton
                    MacOsDismissButton(matchedGeometry: $OpenedPostMatchedGeometry)
#endif
  
                    HStack (spacing: 10) {
                        ZStack {
                            Circle()
                                .frame(width: 59, height: 59)
                                .foregroundColor(friendsDictionary.friendsDictionary[id]?.profileCircle)
    //                                .foregroundColor(Color.mainColor)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                                .clipShape(Circle())
                        Button(action: {
                            if isOpenedFromProfile != true {
                            FriendProfileSelectedID = id
                            FriendProfileMatchedGeometry = "0"
                            }
                        }) {
                            
//                            ZStack {
 
                                if let webLink =  friendsDictionary.friendsDictionary[id]?.profilePicLink{
                                    WebImage(url:webLink)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 55, height: 55)
                                        .background(Color.lightGray)
                                        .clipShape(Circle())
                                }
//                            }
                        }.buttonStyle(.borderless)
                        }
                        HStack(alignment: .top) { // necessary to align timestamp with name
                            VStack(alignment: .leading, spacing: 2) {
                                Text(friendsDictionary.friendsDictionary[id]?.name ?? "")
                                    .fontWeight(.bold)
                                Text(friendsDictionary.friendsDictionary[id]?.username ?? "")
                                    .font(.caption)
                            } // VSTACK
                            Spacer()
                            VStack (spacing: 0) {
                            Text(postData.timeString)
                                .font(.caption)
                                .padding(.top, 3.5)
                                if postData.tags != [""] {
                                    HStack (spacing: 2) {
                                        ForEach(postData.tags, id: \.self) { item in
                                            if myTags.tags[item] != nil {
                                                Text(myTags.tags[item]?.name ?? "")
                                                    .font(.caption)
                                                    .onTapGesture {
                                                        if id == Auth.auth().currentUser?.uid {
                                                        OpenedTagNavigation = item
                                                        }
                                                    }
                                            }
                                        }
                                    }
                                    .padding(.top, 3)
                                }

                            }
                                .padding(.horizontal)
                        } // HSTACK
                       .foregroundColor(Color.mainColor)
                    } // HSTACK
                    .padding(.top, 10)
//                    ZStack {
                    VStack {
                        HStack {
                            let PostText = Text(postData.content)
                                .font(.title3)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                               .foregroundColor(Color.mainColor)
                                .padding(.leading, 6)
                            if postData.content.indicesOf(string: "@").count != 0 {
                                     PostText
                                        .hidden()
                                        .overlay(
                                            GeometryReader { proxy in 
                                                PostLabel(width: proxy.size.width, content: postData.content) {mentionedUserVM.menionedTapped(username: $0)}
                                            .fixedSize(horizontal: false, vertical: true)
                                            }
                                        )
                              /*
                               so here we want to take user to friend profile like we do when user taps on the profile pic in the post. but we also want to take user to stranger profile if user is not friend with current user
                               */
                            } else {
                                PostText
                            }
                            
                            Spacer()
                        } // HSTACK
                       
                        let onTap = {
                            withAnimation(.easeIn(duration: 0.3)) {
                                OpenedPhotoMatchedGeometry = "0"
                                OpenedPhotoSelectedItem = postData.photoLink
                            }
                        }
                        if keyboard.value == 0  {
 
                            if let photoURL = postData.photoLink  { 
                                WebImage(url: photoURL)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: screenWidth - 30, height: screenWidth - 30)
                                    .background(Color.lightGray)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .scaledToFit()
                                    .onTapGesture {
                                        onTap()
                                        
                                    }
                                    .clipped()
                            }
                            ///
                            if let videoUrl =  postData.videoUrl,
                               let thumbnailUrl = postData.thumbnailUrl {
                                ZStack {
                                    WebImage(url: thumbnailUrl)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: screenWidth - 30, height: screenWidth - 30)
                                        .background(Color.lightGray)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .scaledToFit()
                                        .clipped()
                                    
                                    PostVideoThumbnailView(VideoThumbnailVM : VideoThumbnailVM(videoFirebaseURL : videoUrl))
                                }
                            }
                            ////
                        }
                        
                    } .zIndex(-1)
                    
//                    }
                    if postData.content.count > 400 {
                        Button(action: {
                            LongPostMatchedGeometry = "0"
                        }){
                            Text(". . .")
                                .foregroundColor(Color.purple.opacity(0.7))
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .matchedGeometryEffect(id: UUID(), in: namespace)
                        }.buttonStyle(.borderless)
                        .padding(.bottom, -5)
                        .padding(.top, -25)
                    }
                    
                    Divider()
                        .frame(width: screenWidth - 35)
                }
                HStack {
                        Button(action : likePost ) {
                            ZStack {
                             
                            Image(hasBeenLikedOO.hasBeenLiked || hasBeenLiked ?
                                  "heartFilled" :
                                  (colorScheme == .light ? "heartLightMode" : "heartDarkMode")
                                 )
                                .resizable()
                                .frame(width: 20, height: 20)
                            
                                Circle()
                                    .strokeBorder(lineWidth:  CGFloat(circleInnerBorder))
                                    .animation(Animation.easeInOut(duration: 0.5).delay(0.1))
                                    .frame(width: 24, height: 24, alignment: .center)
                                    .foregroundColor(Color(.systemPink))
                                    .hueRotation(Angle(degrees: Double(circleHue)))
                                    .scaleEffect(CGFloat(circleSize))
                                    .animation(Animation.easeInOut(duration: 0.5))
                            } .frame(width: 60, height: 40)
                        .buttonStyle(.borderless)
                }
                    
                    if likes.postLikes.count == 1 {
                        Button(action: {
                            LikesProfileMatchedGeometry = "0"
                        }){
                            ZStack (alignment: .topLeading ){
                                HStack {
                            (Text("Liked by ") + Text("\(likes.postLikes[0].name) ").bold())
                                .font(.caption)
                                .padding(.leading, -9)
                               .foregroundColor(Color.mainColor)
                                    Spacer()
                                }
                            } .frame(width: screenWidth - 100, height: 40)
                        }.buttonStyle(.borderless)
                        .matchedGeometryEffect(id: UUID(), in: namespace)
                    }
                    if likes.postLikes.count > 1 {
                        Button(action: {
                            LikesProfileMatchedGeometry = "0"
                        }){
                            ZStack(alignment: .topLeading ) {
                                HStack {
                            (Text("Liked by ") + Text("\(likes.postLikes[0].name) ").bold() + Text("and ") + Text("others").bold())
                                .font(.caption)
                              .padding(.leading, -9)
                               .foregroundColor(Color.mainColor)
                                    Spacer()
                                }
                            }  .frame(width: screenWidth - 100, height: 40)
                        }.buttonStyle(.borderless)
                        .matchedGeometryEffect(id: UUID(), in: namespace)
                 
                    }
                    Spacer()
                } // Likes
                .zIndex(1)
                .frame(height: 40)
                .padding(.leading, -8)
                .padding(.top, -10)
                commentView
                    .padding(.top, -10)
                Spacer()
            }
                Divider()
                VStack {
                    if textFieldPlaceholder == "Reply" {
                        HStack {
                            Text("Replying to \(nameOfPersonReplyingTo)")
                                .font(.caption)
                                .foregroundColor(Color.mainColor.opacity(0.5))
                                .padding(.horizontal, 30)
                            Spacer()
                            Button(action: {
                                textFieldPlaceholder = "Comment"
                                IDofPersonReplyingTo = ""
                                nameOfPersonReplyingTo = ""
                                message = ""
                                commentID = ""
                            }) {
                                Image(systemName: "clear")
                                    .foregroundColor(Color.mainColor.opacity(0.5))
                            } .buttonStyle(.borderless)
                              .padding(.horizontal, screenWidth/7.5)
                        }
                        .padding(.vertical, 5)
                        .background(Color.mainColor.opacity(0.03))
                        .padding(.horizontal, -20)
                    }
                    HStack(spacing: 0) {
                        HStack(spacing: 15) {
                            HStack  {
                                expandingTextView
//                                TextField(textFieldPlaceholder, text: $message)
//                                    .padding(.horizontal, phoneWidth > 375 ? 16 : 10)
//                                   .foregroundColor(Color.mainColor)
                                    .onReceive(Just(message)) { message in
                                                           if message.indicesOf(string: "@").count == mentionCount.count && mentionCount.count != 0 {
                                                               isShowingMentions = true
                                                           } else {
                                                               isShowingMentions = false
                                                           }
                                                       }
                            }
                            
                        } // HSTACK
                        .padding(.vertical, 6)
#if os(macOS)
                        .padding(.vertical, 10)
#endif

                        .background(Color.mainColor.opacity(colorScheme == .light ? 0.03 : 0.07))
                        .clipShape(ChatBubbleShape(direction: .right))
                        
                        if message != "" {
                            
                            Button(action: sendTypedComment){
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 22))
                                  .foregroundColor(Color.mainColor)
                                    // Rotating paperplane
                                    .rotationEffect(.init(degrees: 45))
                                    // Padding Shape
                                    .padding(.vertical, 12)
                                    .padding(.leading, 12)
                                    .padding(.trailing, 17)
                                    .background(Color.mainColor.opacity(0.07))
                                    .clipShape(Circle())
                            } // BUTTON
                            .buttonStyle(.borderless)
                        }
                    } // HSTACK
    // this is the difference between phone screens
                    .ignoresSafeArea(.keyboard)
//                    .padding(.bottom, phoneWidth > 375 ? 54 : 60)
                    .animation(.easeOut)
#if os(macOS)
                    .padding(.bottom, 15)
#endif
//                    .padding(.bottom, (keyboard.value) + 15)
                    .padding(.bottom, keyboard.value)
//                    .padding(.bottom, phoneWidth > 375 ? 15 : 0)
                    .padding(.bottom, screenHeight < 800 && iOS15 == true ? 45 : 0)
                    .padding(.bottom, screenHeight < 800 && iOS15 == false ? 45 : 0)
                    .padding(.bottom, screenHeight > 800 && iOS15 == false ? 60 : 0)
//                    proxy.size.width > 375
     // this is the difference between phone screens
                }
            }
            .padding(.horizontal, 10)
#if os(iOS)
            .padding(.vertical, 6)
#endif
            .padding(.top, 50)
            
            Group {
//                if FriendProfileMatchedGeometry != "" {
//                    if FriendProfileSelectedID == "" {
//                        let  _ =   assert(false, " what happend FriendProfileSelectedID   ")
//                    }
//                    FriendProfile(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, postData: FriendsPostsOO(id: FriendProfileSelectedID), id: FriendProfileSelectedID)
//                        .padding(.top, 60)
//                }
                if OpenedTagNavigation != "" {
                    OpenedTagTabView(OpenedTagToTagHomeNavigation: $OpenedTagNavigation, OpenedTagToNewPostNavigation: $emptyStringBinding, tagIDs: $emptyStringArrayBinding, myTags: MyTagsOO(), isOpenedFromPost: true, tagFriends: TagFriendsOO(tagID: OpenedTagNavigation))
                        .padding(.top, 60)
                }
                if LikesProfileMatchedGeometry != "" {
                    LikesTabView(LikesProfileMatchedGeometry: $LikesProfileMatchedGeometry, likes: likes)
                }
                if OpenedPhotoMatchedGeometry != "" {
                    OpenPhotoTabView(OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, photo: OpenedPhotoSelectedItem, isFromTimeline: true)

                }

//                if LongPostMatchedGeometry != "" {
//                    OpenedLongPostTabView(OpenedLongPostMatchedGeometry: $LongPostMatchedGeometry, friendsDictionary: timelinePosts.friendsDictionary ,postData: postData, id: id)
//                        .matchedGeometryEffect(id: UUID(), in: namespace)
//                        .onTapGesture {
//                            LongPostMatchedGeometry = ""
//                        }
//                }
//                if OpenedStrangerProfileFromCommentReplyMatchedGeometry != "" {
//                    if friendsDictionary.friendsDictionary[OpenedStrangerProfileFromCommentReplyMatchedGeometry] == nil {
//
//                        StrangerProfileTabView(ProfileMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry, person: OpenedStrangerProfileFromCommentReply, id: OpenedProfileFromCommentsMatchedGeometry)
//                    } else {
//                        if OpenedProfileFromCommentsMatchedGeometry == "" {
//                            let  _ =   assert(false, " what happend OpenedProfileFromCommentsMatchedGeometry   ")
//                        }
//                        FriendProfile(FriendProfileMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry, postData: FriendsPostsOO(id: OpenedProfileFromCommentsMatchedGeometry), id: OpenedProfileFromCommentsMatchedGeometry)
//                            .ignoresSafeArea(.all)
//                            .padding(.top, 60)
//                    }
//                }
//                if OpenedProfileFromCommentsMatchedGeometry != "" {
//                    if friendsDictionary.friendsDictionary[OpenedProfileFromCommentsMatchedGeometry] == nil {
//                        if  let dictionary = comments.personDict[OpenedProfileFromCommentsMatchedGeometry] {
//                            StrangerProfileTabView(ProfileMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry, person: dictionary, id: OpenedProfileFromCommentsMatchedGeometry)
//                        }
//                    } else {
//                        if OpenedProfileFromCommentsMatchedGeometry == "" {
//                            let  _ =   assert(false, " what happend OpenedProfileFromCommentsMatchedGeometry   ")
//                        }
//                        FriendProfile(FriendProfileMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry, postData: FriendsPostsOO(id: OpenedProfileFromCommentsMatchedGeometry), id: OpenedProfileFromCommentsMatchedGeometry)
//                            .ignoresSafeArea(.all)
//                            .padding(.top, 60)
//                    }
//                }
                if CommentReplyLikesMatchedGeometry != "" {
                    CommentReplyLikesTabView(LikesProfileMatchedGeometry: $CommentReplyLikesMatchedGeometry, likes: CommentReplyLikesOO(id: id, postID: postData.postID, originalCommentID: CommentReplyLikesOriginalCommentID, commentID: CommentReplyLikesMatchedGeometry))
                }
                
                if CommentLikesMatchedGeometry != "" {
                    CommentLikesTabView(LikesProfileMatchedGeometry: $CommentLikesMatchedGeometry, likes: CommentLikesOO(id: id, postID: postData.postID, commentID: CommentLikesMatchedGeometry))
                }
//                if isShowingMentions == true {
////                    EmptyView()
//                    MutualFriendsForMentions(content: $message, mutualFriends: MutualFriendsOO(id: id), mentionCount: $mentionCount)
////                            .offset(y: 300)
//                }
            }
//            MentionTapView(mentionedUserVM: mentionedUserVM)
            
            if tutorialNumber == 16 {
                TapToLike16thTutorialView {
                    likePost()
                    tutorialNumber = 17
                }
            } else if tutorialNumber == 17 {
                TapToComment17thTutorialView(action : sendTypedComment)
                    .onAppear{
                    message = "My first comment!"
                }
            }else if tutorialNumber == 18 {
                SwipeToReturn18thTutorialView()
                    .onDisappear {
                        tutorialNumber = 19
                    }
            }
            
        }

#if os(iOS)
        .padding(.top, -60)
#elseif os(macOS)
        .padding(.top, -30)
#endif

        .if(postData.tags.isNotEmpty) {
            $0.onReceive(timelinePosts.getAccessTagPublisher(postTags: postData.tags)) { isDisabled in
                if  self.isDisabled != isDisabled {
                    self.isDisabled = isDisabled
                }
            }.disabled(isDisabled)
        }
//        .onAppear {
//            NewPostFunctions.updateExistingPost(post: postData)
//          
//        }
    }
     
    @State var isDisabled = false
}

 






