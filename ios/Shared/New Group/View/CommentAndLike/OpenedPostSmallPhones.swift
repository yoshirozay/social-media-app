//
//  OpenedPostSmallPhones.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 4/28/21.
//

import SwiftUI
import SDWebImageSwiftUI
import SDWebImage
import FirebaseUI
import Firebase
import Combine

struct OpenedPostSmallPhones: View {
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
    @State var postData: PostModel
    @StateObject var keyboard = KeyboardOO()
    @State var LongPostMatchedGeometry: String = ""
    @StateObject var hasBeenLikedOO = HasPostBeenLikedOO(id: "", postID: "")
    @State var hasBeenLiked = false
    @StateObject var functions = SendCommentFunction()
    @StateObject var likeFunction = SendLikeFunction()
    @StateObject var replyFunction = ReplyToCommentFunction()
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
    @State var OpenedStrangerProfileFromCommentReply = Person(id: "", username: "", name: "", bio: "", imageurl: "")
    @State var canSendReply = true
    @State var isShowingMentions = false
    @State var mentionCount = [""]
    @State var OpenedTagNavigation = ""
    @State var emptyStringBinding = ""
    @State var emptyStringArrayBinding = [""]
    @ObservedObject var myTags: MyTagsOO
    @State var isOpenedFromProfile = false
    var body: some View {
        ZStack (alignment: .top) {
            Color.mainColorInverse
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                VStack {
                    HStack (spacing: 10) {
                        Button(action: {
                            if isOpenedFromProfile != true {
                            FriendProfileSelectedID = id
                            FriendProfileMatchedGeometry = "0"
                            }
                        }) {
//                            ZStack{
//                                if let photoRef =  friendsDictionary.friendsDictionary[id]?.photoRef {
//                                    User ProfileCacheImageView(cacheImage: CacheImage(photoRef: photoRef))
//                                }
//                            }
                            WebImage(url: friendsDictionary.friendsDictionary[id]?.webLink)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 55, height: 55)
                                .background(Color.lightGray)
                                .clipShape(Circle())
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
                                if postData.tags != [""] {
                                    HStack (spacing: 2) {
                                        ForEach(postData.tags, id: \.self) { item in
                                            if myTags.tags[item] != nil {
                                                Text(myTags.tags[item]?.name ?? "")
                                                    .font(.caption)
                                                    .onTapGesture {
                                                        OpenedTagNavigation = item
                                                    }
                                            }
                                        }
                                    }
                                    .padding(.top, 3)
                                }

                            }
                                .padding(.horizontal)

                        } // HSTACK
                        .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 1 : 0.6))
                    } // HSTACK
                    .padding(.top, 10)
                    VStack {
                        HStack {
                            if postData.content.indicesOf(string: "@").count != 0 {
                                                         PostLabel(width: phoneWidth, content: postData.content)
                                                             .fixedSize(horizontal: false, vertical: true)
                                                     } else {
                                                     Text(postData.content)
                                                         .font(.title3)
                                                        .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 1 : 0.6))
                                                     }
                            Spacer()
                        } // HSTACK
                        //
                        
                        let onTap = {
                            withAnimation(.easeIn(duration: 0.3)) {
                                OpenedPhotoMatchedGeometry = "0"
                                OpenedPhotoSelectedItem = postData.photo
                            }
                        }
                        if keyboard.value == 0  {
                            
                          if let photoRef = postData.photoRef  {
                                PostCacheImageView(cacheImage: CacheImage(photoRef: photoRef))
                                    .onTapGesture {
                                        onTap()
                                    }
                            } else if let photoURL = postData.photo  {
                                WebImage(url: photoURL)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: phoneWidth - 30, height: phoneWidth - 30)
                                    .background(Color.lightGray)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .onTapGesture {
                                        onTap()
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
                        if hasBeenLiked == false || hasBeenLikedOO.hasBeenLiked == false {
                            if id != "QS8VPsJQWTXdTeSPOrW5hiZ4N3o2" {
                                likeFunction.sendLike(sentBy: Auth.auth().currentUser!.uid, postID: postData.postID, otherUserID: id, token: friendsDictionary.friendsDictionary[id]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[Auth.auth().currentUser!.uid]?.name ?? "")
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
                        }
//                        .padding(.top, 10)
                        
                    } // Comments
                   
                }
                Spacer()
                Divider()
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
                                            .onReceive(Just(message)) { message in
                                                                   if message.indicesOf(string: "@").count == mentionCount.count {
                                                                       isShowingMentions = true
                                                                   } else {
                                                                       isShowingMentions = false
                                                                   }
                                                               }
                                    }
                                    
                                } // HSTACK
                                .padding(.vertical, 12)
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
//                                                replyFunc tion.replyToComment(sentBy: Auth.auth().currentUser!.uid,
//                                                                             comment: message,
//                                                                             commentID: commentID,
//                                                                             postID: postData.postID,
//                                                                             webLink: (friendsDictionary.friendsDictionary[Auth.auth().currentUser!.uid]?.webLink)!,
//                                                                             postOwnerID: id, otherUserID: IDofPersonReplyingTo,
//                                                                             token: friendsDictionary.friendsDictionary[IDofPersonReplyingTo]?.token ?? "",
//                                                                             postOwnerToken: friendsDictionary.friendsDictionary[id]?.token ?? "",
//                                                                             nameOfSendingUser: friendsDictionary.friendsDictionary[Auth.auth().currentUser!.uid]?.name ?? "",
//                                                                             friendIDs: comments.friendsWhoCommented,
//                                                                             friendIDs2: friendsWhoReplied)
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
                                
                            } // HSTACK
                            .padding(.vertical, 12)
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
                if FriendProfileMatchedGeometry != "" {
                    FriendProfile(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, postData: FriendsPostsOO(id: FriendProfileSelectedID), id: FriendProfileSelectedID)
                        .padding(.top, 60)
                }
                if OpenedTagNavigation != "" {
                    OpenedTagTabView(OpenedTagToTagHomeNavigation: $OpenedTagNavigation, OpenedTagToNewPostNavigation: $emptyStringBinding, tagIDs: $emptyStringArrayBinding, myTags: MyTagsOO(), isOpenedFromPost: true, tagFriends: TagFriendsOO(tagID: OpenedTagNavigation))
                        .padding(.top, 60)
                }
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
                if OpenedProfileFromCommentsMatchedGeometry != "" {
                    if friendsDictionary.friendsDictionary[OpenedProfileFromCommentsMatchedGeometry] == nil {
                        let dictionary = comments.personDict[OpenedProfileFromCommentsMatchedGeometry]!
                        StrangerProfileTabView(ProfileMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry, person: dictionary, id: OpenedProfileFromCommentsMatchedGeometry)
                    } else {
                        FriendProfile(FriendProfileMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry, postData: FriendsPostsOO(id: OpenedProfileFromCommentsMatchedGeometry), id: OpenedProfileFromCommentsMatchedGeometry)
                            .ignoresSafeArea(.all)
                            .padding(.top, 60)
                    }
                }
                if CommentReplyLikesMatchedGeometry != "" {
                    CommentReplyLikesTabView(LikesProfileMatchedGeometry: $CommentLikesMatchedGeometry, likes: CommentReplyLikesOO(id: id, postID: postData.postID, originalCommentID: CommentReplyLikesOriginalCommentID, commentID: CommentReplyLikesMatchedGeometry))
                }
                if CommentLikesMatchedGeometry != "" {
                    CommentLikesTabView(LikesProfileMatchedGeometry: $CommentLikesMatchedGeometry, likes: CommentLikesOO(id: id, postID: postData.postID, commentID: CommentLikesMatchedGeometry))
                }
                if isShowingMentions == true {
//                    EmptyView()
                    MutualFriendsForMentions(content: $message, mutualFriends: MutualFriendsOO(id: id), mentionCount: $mentionCount)
//                            .offset(y: 300)
                }
            }
            
        }
        .padding(.top, -60)
    }
}
