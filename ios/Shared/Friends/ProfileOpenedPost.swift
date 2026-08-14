//
//  ProfileOpenedPost.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/18/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import AVKit

struct ProfileOpenedPost: View {
    @Namespace var namespace
    @ObservedObject var comments : CommentsOO
    @StateObject var likes = LikesOO(id: "", postID: "")
    @State var message = ""
    @State var id: String
    @Binding var returnToPreviousViewNavigationButton: String
    @Binding var profileViewNavigation: String
    @State var LikesProfileMatchedGeometry: String = ""
    @State var OpenedPhotoMatchedGeometry: String = ""
    @State var OpenedPhotoSelectedItem: URL?
    @State var LongPostMatchedGeometry: String = ""
    @State var emptyBindingVariable = false
    @State var hasBeenLiked = false
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @State var postData: PostModel
    @StateObject var hasBeenLikedOO = HasPostBeenLikedOO(id: "", postID: "")
    @State var textHeight: CGFloat = 0
    @StateObject var keyboard = KeyboardOO()
    @StateObject var functions = SendCommentFunction()
    @StateObject var likeFunction = SendLikeFunction()
    @StateObject var replyFunction = ReplyToCommentFunction()
    @State var OpenedProfileFromCommentsMatchedGeometry = ""
    @Environment(\.colorScheme) var colorScheme
    @State var CommentLikesMatchedGeometry = ""
    @State var CommentReplyLikesMatchedGeometry = ""
    @State var CommentReplyLikesOriginalCommentID = ""
    @State var textFieldPlaceholder = "Comment"
    @State var nameOfPersonReplyingTo = ""
    @State var IDofPersonReplyingTo = ""
    @State var commentID = ""
    @State var friendsWhoReplied = [""]
    @State var OpenedStrangerProfileFromCommentReplyMatchedGeometry = ""
    @State var OpenedStrangerProfileFromCommentReply = Person(id: "", username: "", name: "", bio: "", imageurl: "")
    @State var canSendReply = true
    @State var isShowingMentions = false
    @State var mentionCount = [""]
    var body: some View {
        return GeometryReader { proxy in
            if proxy.size.width > 375 && phoneHeight > 800 { // regular/big phones, excluding iphone 8 and 8+
                ZStack (alignment: .top) {
                    Color.mainColorInverse
                        .edgesIgnoringSafeArea(.all)
                    Image("ez1")
                        .resizable()
                        .frame(width: phoneWidth - 50, height: phoneHeight - 150)
                        .padding(.top, 70)
                        .padding(.trailing, 20)
                        .opacity(0.01)
                    VStack {
                        VStack {
                            HStack (spacing: 10) {
                                
                                WebImage(url: friendsDictionary.friendsDictionary[id]?.webLink)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 55, height: 55)
                                    .background(Color.lightGray)
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
                                        .padding(.horizontal)
                                } // HSTACK
                                .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 1 : 0.6))
                            } // HSTACK
                            VStack {
                                HStack {
                                    Text(postData.content)
                                        .font(.title3)
                                        .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 1 : 0.6))
                                    Spacer()
                                } // HSTACK
                                if postData.photo != nil && keyboard.value == 0 {
                                    WebImage(url: postData.photo)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: phoneWidth - 30, height: phoneWidth - 30)
                                        .background(Color.lightGray)
                                        .clipShape(RoundedRectangle(cornerRadius: 10)) 
                                        .onTapGesture {
                                            withAnimation(.easeIn(duration: 0.3)) {
                                                OpenedPhotoMatchedGeometry = "0"
                                                OpenedPhotoSelectedItem = postData.photo
                                            }
                                        }
                                }
                                
                                if let videoUrl =  postData.videoUrl,
                                   let thumbnailUrl = postData.thumbnailUrl {
                                    ZStack {
                                        WebImage(url: thumbnailUrl)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: phoneWidth - 30, height: phoneWidth - 30)
                                            .background(Color.lightGray)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .scaledToFit()
                                       
                                        let vm = VideoThumbnailVM(videoFirebaseURL : videoUrl)
                                        PostVideoThumbnailView(VideoThumbnailVM : vm  )
                                    }
                                }
                            }
                            if postData.content.count > 400 {
                                Button(action: {
                                    LongPostMatchedGeometry = "0"
                                }){
                                    Text(". . .")
                                        .foregroundColor(Color.purple.opacity(0.7))
                                        .font(.largeTitle)
                                        .fontWeight(.heavy)
                                        .matchedGeometryEffect(id: UUID(), in: namespace)
                                }
                                .padding(.bottom, -5)
                                .padding(.top, -25)
                            }
                            Divider()
                                .frame(width: phoneWidth - 35)
                        }
                        HStack {
                            Button(action: {
                                if hasBeenLiked == false {
                                    if id != "QS8VPsJQWTXdTeSPOrW5hiZ4N3o2" {
                                        likeFunction.sendLike(sentBy: Auth.auth().currentUser!.uid, postID: postData.postID, otherUserID: id, token: friendsDictionary.friendsDictionary[id]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[id]?.name ?? "")
                                    }
                                }
                                hasBeenLiked.toggle()
                            }) {
                                if colorScheme == .light {
                                Image(hasBeenLikedOO.hasBeenLiked || hasBeenLiked ? "heartFilled" : "heartLightMode")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                } else {
                                    Image(hasBeenLikedOO.hasBeenLiked || hasBeenLiked ? "heartFilled" : "heartDarkMode")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                            }
                            if likes.postLikes.count == 1 {
                                Button(action: {
                                    LikesProfileMatchedGeometry = "0"
                                }){
                                    (Text("Liked by ") + Text("\(likes.postLikes[0].name) ").bold())
                                        .font(.caption)
                                        .padding(.leading, 9)
                                        .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 1 : 0.6))
                                }
                                .matchedGeometryEffect(id: UUID(), in: namespace)
                            }
                            if likes.postLikes.count > 1 {
                                Button(action: {
                                    LikesProfileMatchedGeometry = "0"
                                }){
                                    (Text("Liked by ") + Text("\(likes.postLikes[0].name) ").bold() + Text("and ") + Text("others").bold())
                                        .font(.caption)
                                        .padding(.leading, 9)
                                        .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 1 : 0.6))
                                }
                                .matchedGeometryEffect(id: UUID(), in: namespace)
                            }
                            
                            Spacer()
                        } // Likes
                        .frame(height: 25)
                        .padding(.leading, 9)
                        ZStack (alignment: .bottomTrailing) {
                            ScrollView(showsIndicators: false) { // Comments
                                
                                VStack() {
                                    ForEach(Array(comments.comments.sorted(by: {$0.time.dateValue().timeIntervalSinceNow < $1.time.dateValue().timeIntervalSinceNow})), id: \.self) { item in
                                        Comment(comments: comments, comment: item, OpenedProfileFromCommentsMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry, OpenedStrangerProfileFromCommentReplyMatchedGeometry: $OpenedStrangerProfileFromCommentReplyMatchedGeometry, postID: postData.postID, postOwnerID: id, hasCommentBeenLiked: HasCommentBeenLikedOO(id: id, postID: postData.postID, commentID: item.commentID), CommentLikesMatchedGeometry: $CommentLikesMatchedGeometry, CommentReplyLikesMatchedGeometry: $CommentReplyLikesMatchedGeometry, CommentReplyLikesOriginalCommentID: $CommentReplyLikesOriginalCommentID, textFieldPlaceholder: $textFieldPlaceholder, nameOfPersonReplyingTo: $nameOfPersonReplyingTo, IDofPersonReplyingTo: $IDofPersonReplyingTo, message: $message, commentID: $commentID, friendsWhoReplied: $friendsWhoReplied, commentReplies: CommentRepliesOO(id: id, postID: postData.postID, commentID: item.commentID))

                                        
                                    }
                                } .padding(.top, 10)
                            } // Comments
                            
                        }
                        
                        Spacer()
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
                                            commentID = ""
                                        }) {
                                            Image(systemName: "clear")
                                                .foregroundColor(Color.mainColor.opacity(0.5))
                                        } .padding(.horizontal, phoneWidth/7.5)
                                    }
                                    .padding(.vertical, 5)
                                    .background(Color.mainColor.opacity(0.03))
                                    .padding(.horizontal, -20)
                            }
                        HStack(spacing: 0) {
                            HStack(spacing: 15) {
                                HStack  {
                                    TextField(textFieldPlaceholder, text: $message)
                                        .padding(.horizontal, phoneWidth > 375 ? 16 : 10)
                                        .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 1 : 0.6))
                                }
                                
                                Button(action: {
                                    
                                }){
                                    Image(systemName: "paperclip.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.gray)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal)
                                        .opacity(message == "" ? 1 : 0)
                                }
                                
                            } // HSTACK
                            
                            .background(Color.mainColor.opacity(colorScheme == .light ? 0.03 : 0.07))
                            .clipShape(ChatBubbleShape(direction: .right))
                            if message != "" {
                                
                                Button(action: {
                                    
                                        guard let userId = Auth.auth().currentUser?.uid else{
                                            return
                                        }
                                    
                                    if id != "QS8VPsJQWTXdTeSPOrW5hiZ4N3o2" {
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
                                                                                  comment: message,
                                                                                  postID:  postData.postID,
                                                                                  otherUserID: id,
                                                                                  friendIDs: comments.friendsWhoCommented,
                                                                                  token: friendsDictionary.friendsDictionary[id]?.token ?? "",
                                                                                  nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "")
                                                
                                            comments.sendNewComment(rawComment: rawComment, mentionedIDs: mentionCount, postID: postData.postID)
                                            
//                                        functions.sendComment(sentBy: Auth.auth().currentUser!.uid, comment: message, postID: postData.postID, otherUserID: id, friendIDs: comments.friendsWhoCommented, token: friendsDictionary.friendsDictionary[id]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[Auth.auth().currentUser!.uid]?.name ?? "")
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
                                                                    comment: message,
                                                                    commentID: commentID,
                                                                    postID: postData.postID,
                                                                    webLink: webLink,
                                                                    postOwnerID: id,
                                                                    otherUserID: IDofPersonReplyingTo,
                                                                    token: friendsDict[IDofPersonReplyingTo]?.token ?? "",
                                                                    postOwnerToken: friendsDict[id]?.token ?? "",
                                                                    nameOfSendingUser: friendsDict[userId]?.name ?? "",
                                                                    friendIDs: comments.friendsWhoCommented,
                                                                    friendIDs2: friendsWhoReplied)
                                            comments.rawReplyComment = rawReplyComment

//                                            replyFun ction.replyToComment(sentBy: Auth.auth().currentUser!.uid, comment: message, commentID: commentID, postID: postData.postID, webLink: (friendsDictionary.friendsDictionary[Auth.auth().currentUser!.uid]?.webLink)!, postOwnerID: id, otherUserID: IDofPersonReplyingTo, token: friendsDictionary.friendsDictionary[IDofPersonReplyingTo]?.token ?? "", postOwnerToken: friendsDictionary.friendsDictionary[id]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[Auth.auth().currentUser!.uid]?.name ?? "", friendIDs: comments.friendsWhoCommented, friendIDs2: friendsWhoReplied)
                                        }
                                    }
                                    message = ""
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        hideKeyboard()
                                        textFieldPlaceholder = "Comment"
                                        IDofPersonReplyingTo = ""
                                        nameOfPersonReplyingTo = ""
                                        commentID = ""
                                    }
                                }){
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(Color.mainColor.opacity(0.7))
                                        // Rotating paperplane
                                        .rotationEffect(.init(degrees: 45))
                                        // Padding Shape
                                        .padding(.vertical, 12)
                                        .padding(.leading, 12)
                                        .padding(.trailing, 17)
                                        .background(Color.mainColor.opacity(0.07))
                                        .clipShape(Circle())
                                } // BUTTON
                            }
                        } // HSTACK
                        .ignoresSafeArea(.keyboard)
                        .padding(.bottom, 54)
                        .animation(.easeOut)
                        .padding(.bottom, (keyboard.value) + 15)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .padding(.top, 60)
                    
                    Group {
                    if LikesProfileMatchedGeometry != "" {
                        LikesTabView(LikesProfileMatchedGeometry: $LikesProfileMatchedGeometry, likes: likes)
                    }
                    if OpenedPhotoMatchedGeometry != "" {
                        OpenedPhoto(photo: OpenedPhotoSelectedItem)
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    OpenedPhotoMatchedGeometry = ""
                                }
                            }
                    }
                    if LongPostMatchedGeometry != "" {
                        OpenedLongPost(postData: postData, id: id)
                            .matchedGeometryEffect(id: UUID(), in: namespace)
                            .onTapGesture {
                                LongPostMatchedGeometry = ""
                            }
                    }
                    if OpenedStrangerProfileFromCommentReplyMatchedGeometry != "" {
                        if friendsDictionary.friendsDictionary[OpenedStrangerProfileFromCommentReplyMatchedGeometry] == nil {
                            StrangerProfileTabView(ProfileMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry, person: OpenedStrangerProfileFromCommentReply, id: OpenedProfileFromCommentsMatchedGeometry)
                        } else {
                            FriendProfile(FriendProfileMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry, postData: FriendsPostsOO(id: OpenedProfileFromCommentsMatchedGeometry), id: OpenedProfileFromCommentsMatchedGeometry)
                                .ignoresSafeArea(.all)
                                .padding(.top, 60)
                        }
                    }
                    if OpenedProfileFromCommentsMatchedGeometry != "" { // Not including FriendProfile is on purpose
                        let dictionary = comments.personDict[OpenedProfileFromCommentsMatchedGeometry]!
                        
                        StrangerProfileTabView(ProfileMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry, person: dictionary, id: OpenedProfileFromCommentsMatchedGeometry)
                        
                    }
                    if CommentLikesMatchedGeometry != "" {
                        CommentLikesTabView(LikesProfileMatchedGeometry: $CommentLikesMatchedGeometry, likes: CommentLikesOO(id: id, postID: postData.postID, commentID: CommentLikesMatchedGeometry))
                    }
                    if CommentReplyLikesMatchedGeometry != "" {
                        CommentReplyLikesTabView(LikesProfileMatchedGeometry: $CommentLikesMatchedGeometry, likes: CommentReplyLikesOO(id: id, postID: postData.postID, originalCommentID: CommentReplyLikesOriginalCommentID, commentID: CommentReplyLikesMatchedGeometry))
                    }
                    if isShowingMentions == true {
    //                    EmptyView()
                        MutualFriendsForMentions(content: $message, mutualFriends: MutualFriendsOO(id: id), mentionCount: $mentionCount)
    //                            .offset(y: 300)
                    }
                    }
                }
                .padding(.top, -60)
            }  else {
                ZStack (alignment: .top) {
                    Color.mainColorInverse
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        VStack {
                            HStack (spacing: 10) {
                                
                                WebImage(url: friendsDictionary.friendsDictionary[id]?.webLink)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 55, height: 55)
                                    .background(Color.lightGray)
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
                                        .padding(.horizontal)
                                } // HSTACK
                                .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 1 : 0.6))
                            } // HSTACK
                            VStack {
                                HStack {
                                    Text(postData.content)
                                        .font(.title3)
                                        .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 1 : 0.6))
                                    Spacer()
                                } // HSTACK
                                if postData.photo != nil && keyboard.value == 0 {
                                    WebImage(url: postData.photo)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: phoneWidth - 30, height: phoneWidth - 30)
                                        .background(Color.lightGray)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .onTapGesture {
                                            withAnimation(.easeIn(duration: 0.3)) {
                                                OpenedPhotoMatchedGeometry = "0"
                                                OpenedPhotoSelectedItem = postData.photo
                                            }
                                        }
                                }
                                
                                if let videoUrl =  postData.videoUrl,
                                   let thumbnailUrl = postData.thumbnailUrl {
                                    ZStack {
                                        WebImage(url: thumbnailUrl)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: phoneWidth - 30, height: phoneWidth - 30)
                                            .background(Color.lightGray)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .scaledToFit()
                                       
                                        let vm = VideoThumbnailVM(videoFirebaseURL : videoUrl)
                                        PostVideoThumbnailView(VideoThumbnailVM : vm  )
                                    }
                                }
                            }
                            if postData.content.count > 400 {
                                Button(action: {
                                    LongPostMatchedGeometry = "0"
                                }){
                                    Text(". . .")
                                        .foregroundColor(Color.purple.opacity(0.7))
                                        .font(.largeTitle)
                                        .fontWeight(.heavy)
                                        .matchedGeometryEffect(id: UUID(), in: namespace)
                                }
                                .padding(.bottom, -5)
                                .padding(.top, -25)
                            }
                            Divider()
                                .frame(width: phoneWidth - 35)
                        }
                        HStack {
                            Button(action: {
                                if hasBeenLiked == false {
                                    if id != "QS8VPsJQWTXdTeSPOrW5hiZ4N3o2" {
                                        likeFunction.sendLike(sentBy: Auth.auth().currentUser!.uid, postID: postData.postID, otherUserID: id, token: friendsDictionary.friendsDictionary[id]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[id]?.name ?? "")
                                    }
                                }
                                hasBeenLiked.toggle()
                            }) {
                                if colorScheme == .light {
                                Image(hasBeenLikedOO.hasBeenLiked || hasBeenLiked ? "heartFilled" : "heartLightMode")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                } else {
                                    Image(hasBeenLikedOO.hasBeenLiked || hasBeenLiked ? "heartFilled" : "heartDarkMode")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                            }
                            
                            if likes.postLikes.count == 1 {
                                Button(action: {
                                    LikesProfileMatchedGeometry = "0"
                                }){
                                    (Text("Liked by ") + Text("\(likes.postLikes[0].name) ").bold())
                                        .font(.caption)
                                        .padding(.leading, 9)
                                        .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 1 : 0.6))
                                }
                                .matchedGeometryEffect(id: UUID(), in: namespace)
                            }
                            if likes.postLikes.count > 1 {
                                Button(action: {
                                    LikesProfileMatchedGeometry = "0"
                                }){
                                    (Text("Liked by ") + Text("\(likes.postLikes[0].name) ").bold() + Text("and ") + Text("others").bold())
                                        .font(.caption)
                                        .padding(.leading, 9)
                                        .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 1 : 0.6))
                                }
                                .matchedGeometryEffect(id: UUID(), in: namespace)
                            }
                            
                            
                            Spacer()
                        } // Likes
                        .frame(height: 25)
                        .padding(.leading, 9)
                        ZStack (alignment: .bottomTrailing) {
                            ScrollView(showsIndicators: false) { // Comments
                                VStack() {
                                    ForEach(Array(comments.comments.sorted(by: {$0.time.dateValue().timeIntervalSinceNow < $1.time.dateValue().timeIntervalSinceNow})), id: \.self) { item in
                                        Comment(comments: comments, comment: item, OpenedProfileFromCommentsMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry, OpenedStrangerProfileFromCommentReplyMatchedGeometry: $OpenedStrangerProfileFromCommentReplyMatchedGeometry, postID: postData.postID, postOwnerID: id, hasCommentBeenLiked: HasCommentBeenLikedOO(id: id, postID: postData.postID, commentID: item.commentID), CommentLikesMatchedGeometry: $CommentLikesMatchedGeometry, CommentReplyLikesMatchedGeometry: $CommentReplyLikesMatchedGeometry, CommentReplyLikesOriginalCommentID: $CommentReplyLikesOriginalCommentID, textFieldPlaceholder: $textFieldPlaceholder, nameOfPersonReplyingTo: $nameOfPersonReplyingTo, IDofPersonReplyingTo: $IDofPersonReplyingTo, message: $message, commentID: $commentID, friendsWhoReplied: $friendsWhoReplied, commentReplies: CommentRepliesOO(id: id, postID: postData.postID, commentID: item.commentID))

                                        
                                    }
                                } .padding(.top, 10)
                            } // Comments
                          
                        }
                        Spacer()
                        if phoneHeight > 800 { // excludes iphone 8 & 8+
                            Group {
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
                                                    commentID = ""
                                                }) {
                                                    Image(systemName: "clear")
                                                        .foregroundColor(Color.mainColor.opacity(0.5))
                                                } .padding(.horizontal, phoneWidth/7.5)
                                            }
                                            .padding(.vertical, 5)
                                            .background(Color.mainColor.opacity(0.03))
                                            .padding(.horizontal, -20)
                                    }
                                HStack(spacing: 0) {
                                    HStack(spacing: 15) {
                                        HStack  {
                                            TextField(textFieldPlaceholder, text: $message)
                                                .padding(.horizontal, phoneWidth > 375 ? 16 : 10)
                                                .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 1 : 0.6))
                                        }
                                        
                                        Button(action: {
                                            
                                        }){
                                            Image(systemName: "paperclip.circle.fill")
                                                .font(.system(size: 22))
                                                .foregroundColor(.gray)
                                                .padding(.vertical, 12)
                                                .padding(.horizontal)
                                                .opacity(message == "" ? 1 : 0)
                                        }
                                        
                                    } // HSTACK
                                    
                                    .background(Color.mainColor.opacity(colorScheme == .light ? 0.03 : 0.07))
                                    .clipShape(ChatBubbleShape(direction: .right))
                                    
                                    if message != "" {
                                        
                                        Button(action: {
                                            
                                            guard let userId = Auth.auth().currentUser?.uid else{
                                                return
                                            }
                                            
                                            if id != "QS8VPsJQWTXdTeSPOrW5hiZ4N3o2" {
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
                                                                                          comment: message,
                                                                                          postID:  postData.postID,
                                                                                          otherUserID: id,
                                                                                          friendIDs: comments.friendsWhoCommented,
                                                                                          token: friendsDictionary.friendsDictionary[id]?.token ?? "",
                                                                                          nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "")
                                                        
                                                    comments.sendNewComment(rawComment: rawComment, mentionedIDs: mentionCount, postID: postData.postID)
                                                    
//                                                functions.sendComment(sentBy: Auth.auth().currentUser!.uid, comment: message, postID: postData.postID, otherUserID: id, friendIDs: comments.friendsWhoCommented, token: friendsDictionary.friendsDictionary[id]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[Auth.auth().currentUser!.uid]?.name ?? "")
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
                                                                            comment: message,
                                                                            commentID: commentID,
                                                                            postID: postData.postID,
                                                                            webLink: webLink,
                                                                            postOwnerID: id,
                                                                            otherUserID: IDofPersonReplyingTo,
                                                                            token: friendsDict[IDofPersonReplyingTo]?.token ?? "",
                                                                            postOwnerToken: friendsDict[id]?.token ?? "",
                                                                            nameOfSendingUser: friendsDict[userId]?.name ?? "",
                                                                            friendIDs: comments.friendsWhoCommented,
                                                                            friendIDs2: friendsWhoReplied)
                                                    comments.rawReplyComment = rawReplyComment
//                                                    replyFu nction.replyToComment(sentBy: Auth.auth().currentUser!.uid, comment: message, commentID: commentID, postID: postData.postID, webLink: (friendsDictionary.friendsDictionary[Auth.auth().currentUser!.uid]?.webLink)!, postOwnerID: id, otherUserID: IDofPersonReplyingTo, token: friendsDictionary.friendsDictionary[IDofPersonReplyingTo]?.token ?? "", postOwnerToken: friendsDictionary.friendsDictionary[id]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[Auth.auth().currentUser!.uid]?.name ?? "", friendIDs: comments.friendsWhoCommented, friendIDs2: friendsWhoReplied)
                                                }
                                            }
                                            message = ""
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                hideKeyboard()
                                                textFieldPlaceholder = "Comment"
                                                IDofPersonReplyingTo = ""
                                                nameOfPersonReplyingTo = ""
                                                commentID = ""
                                            }
                                        }){
                                            Image(systemName: "paperplane.fill")
                                                .font(.system(size: 22))
                                                .foregroundColor(Color.mainColor.opacity(0.7))
                                                // Rotating paperplane
                                                .rotationEffect(.init(degrees: 45))
                                                // Padding Shape
                                                .padding(.vertical, 12)
                                                .padding(.leading, 12)
                                                .padding(.trailing, 17)
                                                .background(Color.mainColor.opacity(0.07))
                                                .clipShape(Circle())
                                        } // BUTTON
                                    }
                                } // HSTACK
                                
                                .ignoresSafeArea(.keyboard)
                                .padding(.bottom, 60)
                                .animation(.easeOut)
                                .padding(.bottom, keyboard.value)
                            }
                            }
                        } else { // iphone 8 & 8+
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
                                            } .padding(.horizontal, phoneWidth/7.5)
                                        }
                                        .padding(.vertical, 5)
                                        .background(Color.mainColor.opacity(0.03))
                                        .padding(.horizontal, -20)
                                }
                            HStack(spacing: 0) {
                                HStack(spacing: 15) {
                                    HStack  {
                                        TextField(textFieldPlaceholder, text: $message)
                                            .padding(.horizontal, phoneWidth > 375 ? 16 : 10)
                                            .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 1 : 0.6))
                                    }
                                    
                                    Button(action: {
                                        
                                    }){
                                        Image(systemName: "paperclip.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(.gray)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal)
                                            .opacity(message == "" ? 1 : 0)
                                    }
                                    
                                } // HSTACK
                                
                                .background(Color.mainColor.opacity(colorScheme == .light ? 0.03 : 0.07))
                                .clipShape(ChatBubbleShape(direction: .right))
                                
                                if message != "" {
                                    
                                    Button(action: {
                                            guard let userId = Auth.auth().currentUser?.uid else{
                                                return
                                            }
                                        
                                        if id != "QS8VPsJQWTXdTeSPOrW5hiZ4N3o2" {
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
                                                                                      comment: message,
                                                                                      postID:  postData.postID,
                                                                                      otherUserID: id,
                                                                                      friendIDs: comments.friendsWhoCommented,
                                                                                      token: friendsDictionary.friendsDictionary[id]?.token ?? "",
                                                                                      nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "")
                                                    
                                                comments.sendNewComment(rawComment: rawComment, mentionedIDs: mentionCount, postID: postData.postID)
                                                
//                                            functions.sendComment(sentBy: Auth.auth().currentUser!.uid, comment: message, postID: postData.postID, otherUserID: id, friendIDs: comments.friendsWhoCommented, token: friendsDictionary.friendsDictionary[id]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[Auth.auth().currentUser!.uid]?.name ?? "")
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
                                                                        comment: message,
                                                                        commentID: commentID,
                                                                        postID: postData.postID,
                                                                        webLink: webLink,
                                                                        postOwnerID: id,
                                                                        otherUserID: IDofPersonReplyingTo,
                                                                        token: friendsDict[IDofPersonReplyingTo]?.token ?? "",
                                                                        postOwnerToken: friendsDict[id]?.token ?? "",
                                                                        nameOfSendingUser: friendsDict[userId]?.name ?? "",
                                                                        friendIDs: comments.friendsWhoCommented,
                                                                        friendIDs2: friendsWhoReplied)
                                                comments.rawReplyComment = rawReplyComment
//                                                replyFu nction.replyToComment(sentBy: Auth.auth().currentUser!.uid, comment: message, commentID: commentID, postID: postData.postID, webLink: (friendsDictionary.friendsDictionary[Auth.auth().currentUser!.uid]?.webLink)!, postOwnerID: id, otherUserID: IDofPersonReplyingTo, token: friendsDictionary.friendsDictionary[IDofPersonReplyingTo]?.token ?? "", postOwnerToken: friendsDictionary.friendsDictionary[id]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[Auth.auth().currentUser!.uid]?.name ?? "", friendIDs: comments.friendsWhoCommented, friendIDs2: friendsWhoReplied)
                                            }
                                        }
                                        message = ""
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            hideKeyboard()
                                            textFieldPlaceholder = "Comment"
                                            IDofPersonReplyingTo = ""
                                            nameOfPersonReplyingTo = ""
                                            commentID = ""
                                        }
                                    }){
                                        Image(systemName: "paperplane.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(Color.mainColor.opacity(0.7))
                                            // Rotating paperplane
                                            .rotationEffect(.init(degrees: 45))
                                            // Padding Shape
                                            .padding(.vertical, 12)
                                            .padding(.leading, 12)
                                            .padding(.trailing, 17)
                                            .background(Color.mainColor.opacity(0.07))
                                            .clipShape(Circle())
                                    } // BUTTON
                                }
                            } // HSTACK
                            
                            .ignoresSafeArea(.keyboard)
                            .padding(.bottom, 60)
                            .animation(.easeOut)
                            .padding(.bottom, keyboard.value - 35)
                            
                        }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .padding(.top, 50)
                    
                    Group {
                    if LikesProfileMatchedGeometry != "" {
                        LikesTabView(LikesProfileMatchedGeometry: $LikesProfileMatchedGeometry, likes: likes)
                    }
                    if OpenedPhotoMatchedGeometry != "" {
                        OpenedPhoto(photo: OpenedPhotoSelectedItem)
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    OpenedPhotoMatchedGeometry = ""
                                }
                            }
                    }
                    if LongPostMatchedGeometry != "" {
                        OpenedLongPost(postData: postData, id: id)
                            .matchedGeometryEffect(id: UUID(), in: namespace)
                            .onTapGesture {
                                LongPostMatchedGeometry = ""
                            }
                    }
                    if OpenedStrangerProfileFromCommentReplyMatchedGeometry != "" {
                        if friendsDictionary.friendsDictionary[OpenedStrangerProfileFromCommentReplyMatchedGeometry] == nil {

                            StrangerProfileTabView(ProfileMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry, person: OpenedStrangerProfileFromCommentReply, id: OpenedProfileFromCommentsMatchedGeometry)
                        } else {
                            FriendProfile(FriendProfileMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry, postData: FriendsPostsOO(id: OpenedProfileFromCommentsMatchedGeometry), id: OpenedProfileFromCommentsMatchedGeometry)
                                .ignoresSafeArea(.all)
                                .padding(.top, 60)
                        }
                    }
                    if OpenedProfileFromCommentsMatchedGeometry != "" {  // Not including FriendProfile is on purpose
                        let dictionary = comments.personDict[OpenedProfileFromCommentsMatchedGeometry]!
                        
                        StrangerProfileTabView(ProfileMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry, person: dictionary, id: OpenedProfileFromCommentsMatchedGeometry)
                        
                    }
                    if CommentLikesMatchedGeometry != "" {
                        CommentLikesTabView(LikesProfileMatchedGeometry: $CommentLikesMatchedGeometry, likes: CommentLikesOO(id: id, postID: postData.postID, commentID: CommentLikesMatchedGeometry))
                    }
                    if CommentReplyLikesMatchedGeometry != "" {
                        CommentReplyLikesTabView(LikesProfileMatchedGeometry: $CommentReplyLikesMatchedGeometry, likes: CommentReplyLikesOO(id: id, postID: postData.postID, originalCommentID: CommentReplyLikesOriginalCommentID, commentID: CommentReplyLikesMatchedGeometry))
                    }
                    if isShowingMentions == true {
    //                    EmptyView()
                        MutualFriendsForMentions(content: $message, mutualFriends: MutualFriendsOO(id: id), mentionCount: $mentionCount)
    //                            .offset(y: 300)
                    }
                    }
                }
                .padding(.top, -60)
            } // For smaller phones
        } // For smaller phones
    }
}

struct ProfileOpenedPostTabView: View {
    @StateObject var comments = CommentsOO(id: "", postID: "")
    @StateObject var likes = LikesOO(id: "", postID: "")
    @State var id: String
    @Binding var profileViewNavigation: String
    @Binding var returnToPreviousViewNavigationButton: String
    @State var emptyIntBinding = 10
    @StateObject var hasBeenLikedOO = HasPostBeenLikedOO(id: "", postID: "")
    @State var emptyBoolBinding = false
    @State var emptyStringBinding = ""
    @State var selectedTab = "openedPost"
    @State var postData: PostModel
    
    var body: some View {
        if selectedTab == "openedPost" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    ProfileOpenedPost(comments: comments, likes: likes, id: id, returnToPreviousViewNavigationButton: $returnToPreviousViewNavigationButton, profileViewNavigation: $emptyStringBinding, postData: postData, hasBeenLikedOO: hasBeenLikedOO)
                        .tag("openedPost")
                    
                    
                }
                .edgesIgnoringSafeArea(.bottom)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .ignoresSafeArea(edges: .top)
        } else {
            FriendProfileHomeTabView(FriendProfileMatchedGeometry: $emptyStringBinding, postData: FriendsPostsOO(id: id), id: id)
                .onAppear() {
                    profileViewNavigation = ""
                }
            
        }
    }
}
