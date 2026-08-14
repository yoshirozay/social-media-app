//
//  HomeC.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//

import SwiftUI
import SDWebImageSwiftUI
import Combine
import Firebase
import LinkPresentation

struct NewComment: View {
    
    @ObservedObject var comments : CommentsOO
    @State var comment: CommentModel
    @State var isShowing = false
    @Environment(\.colorScheme) var colorScheme
    @Binding var OpenedProfileFromCommentsMatchedGeometry: String
    @Binding var OpenedStrangerProfileFromCommentReplyMatchedGeometry: String
    @State var hasBeenLiked = false
    @StateObject var functions = LikeCommentFunction()
    @State var postID: String
    @State var postOwnerID: String
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @StateObject var hasCommentBeenLiked: HasCommentBeenLikedOO
    @Binding var CommentLikesMatchedGeometry: String
    @Binding var CommentReplyLikesMatchedGeometry: String
    @Binding var CommentReplyLikesOriginalCommentID: String
    @Binding var textFieldPlaceholder: String
    @Binding var nameOfPersonReplyingTo: String
    @Binding var IDofPersonReplyingTo: String
    @Binding var message: String
    @Binding var commentID: String
    @Binding var friendsWhoReplied: [String]
    @StateObject var commentReplies : CommentRepliesOO
    @StateObject var commentLikes: CommentLikesOO
    // Like animation
    @State private var circleSize = 0.0
    @State private var circleInnerBorder = 35
    @State private var circleHue = 200
    //
    @StateObject var likeComment = LikeCommentFunction()
    @State var hasMessageBeenLiked = false
    @State var doubleTap = [Int]()
    @Binding var isDeletePostShowing: Bool
    @State var isCurrentUser = false
    @EnvironmentObject var mentionedUserVM : MentionedUserVM
    @Binding var StrangerProfileSelectedUser: Person
    @Binding var FriendProfileMatchedGeometry: String
    
    @Binding var comment2: CommentModel
    @Binding var OpenedGIFMatchedGeometry: String
    var likeCapsule: some View {
        ZStack {
            if commentLikes.postLikes.count < 11 {
                if commentLikes.postLikes.count != 0 {
                    ZStack {
                        Capsule()
                            .frame(width: 32 + CGFloat((commentLikes.postLikes.count * 17)), height: 24)
                            .foregroundColor(Color.mainColorInverse.opacity(1))
                        Capsule()
                            .frame(width: 30 + CGFloat((commentLikes.postLikes.count * 17)), height: 22)
                        
                            .foregroundColor(Color.speakerPurple.opacity(0.18))
                            .overlay (
                                
                                HStack (spacing: 1) {
                                    Text("💜")
                                        .font(.caption2)
                                        .padding(.leading, 3)
                                    ForEach(commentLikes.postLikes, id: \.self) { item in
                                        ZStack {
                                            Circle()
                                                .frame(width: 17, height: 17)
                                                .foregroundColor(Color.white)
                                                .clipShape(Circle())
                                            WebImage(url: item.profilePicLink)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 16, height: 16)
                                                .clipShape(Circle())
                                        }
                                    }
                                    
                                    Spacer()
                                }
                            )
                    }
                    .offset(x: 10, y: 17)
                }
            } else {
                ZStack {
                    Capsule()
                        .frame(width: 59 + CGFloat((commentLikes.firstTenLikes.count * 17)), height: 24)
                        .foregroundColor(Color.mainColorInverse.opacity(1))
                    Capsule()
                        .frame(width: 56 + CGFloat((commentLikes.firstTenLikes.count * 17)), height: 22)
                    
                        .foregroundColor(Color.speakerPurple.opacity(0.18))
                        .overlay (
                            HStack (spacing: 1) {
                                Text("💜")
                                    .font(.caption2)
                                    .padding(.leading, 3)
                                ForEach(commentLikes.firstTenLikes, id: \.self) { item in
                                    ZStack {
                                        Circle()
                                            .frame(width: 17, height: 17)
                                            .foregroundColor(Color.white)
                                            .clipShape(Circle())
                                        WebImage(url: item.profilePicLink)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 16, height: 16)
                                            .clipShape(Circle())
                                    }
                                }
                                ZStack {
                                    Circle()
                                        .frame(width: 17, height: 17)
                                        .foregroundColor(Color.mainColorInverse)
                                    Circle()
                                        .frame(width: 16, height: 16)
                                        .foregroundColor(Color.speakerPurple.opacity(0.2))
                                    Text("+\(commentLikes.postLikes.count - 3)")
                                        .font(.footnote)
                                        .foregroundColor(Color.white)
                                }
                                Spacer()
                            }
                        )
                }
                .offset(x: 10, y: 17)
            }
        }
    }
    var body: some View {
        ZStack (alignment: .bottomLeading) {
            DummyComment(comments: comments, commentReplies: commentReplies, comment: $comment)
            if comment.comment != "" {
                VStack {
                    ZStack (alignment: .leading) {
                        Color.mainColorInverse.opacity(isCurrentUser ? 0.5 : 0.5)
                        VStack (alignment: .leading) {
                            
                            HStack {
                                if comments.personDict[comment.id]?.anonymousMode == true && friendsDictionary.friendsDictionary[comment.id] == nil {
                                    HStack {
                                        Image(systemName: "questionmark")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 35, height: 35)
                                            .scaledToFill()
                                            .clipShape(Circle())
                                        Text ("Anonymous")
                                            .font(.headline)
                                            .foregroundColor(Color.mainColor)
                                    }
                                } else {
                                    HStack {
                                        WebImage(url: comments.personDict[comment.id]?.profilePicLink)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 35, height: 35)
                                            .scaledToFill()
                                            .clipShape(Circle())
                                            .contentShape(Circle())
                                            .onTapGesture {
                                                
                                                if friendsDictionary.friendsDictionary[comment.id] != nil {
                                                    FriendProfileMatchedGeometry = comment.id
                                                } else {
                                                    FriendProfileMatchedGeometry = comment.id
                                                    StrangerProfileSelectedUser = comments.personDict[comment.id] ?? Person(id: "")
                                                }
                                                
                                            }
                                        Text (comments.personDict[comment.id]?.name ?? "")
                                            .font(.headline)
                                            .foregroundColor(Color.mainColor)
                                    }
                                    
                                    
                                }
                                Spacer()
                                Text(comment.timeString)
                                    .font(.caption2)
                                    .foregroundColor(Color.mainColor.opacity(0.3))
                                    .offset(y: 3)
                                    .padding(.trailing, 16)
                            }
                            .padding(.leading, 5)
                            if comment.isGIF == true {
                                gifView
                                
                            } else {
                                let commentText = Text(comment.comment)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .font(.body)
                                    .foregroundColor(Color.mainColor)
                                    .padding(.leading, 10)
                                    .multilineTextAlignment(.leading)
                                    .offset(x: -3, y: -5)
                                    .padding(.trailing, 10)
                                    .padding(.bottom, comment.photoLink != nil || comment.thumbnailUrl != nil ? -4 : -2)
                                
                                if comment.hasMention {
                                    ZStack{
                                        commentText .hidden()
                                        GeometryReader { proxy in
                                            CommentLabel2(width: proxy.size.width, content: comment.comment) {mentionedUserVM.menionedTapped(username: $0)}
                                                .fixedSize(horizontal: false, vertical: true)
                                                .offset(x: -3, y: -5)
                                                .padding(.leading, 10)
                                                .padding(.trailing, 5)
                                                .padding(.bottom, comment.photoLink != nil || comment.thumbnailUrl != nil ? -4 : 8)
                                        }
                                    }
                                } else {
                                    commentText
                                }
                                mediaView
    
                            }
                        }
                        .offset(x: 5, y: 2)
                        //            .offset(x: -10, y: -30)
                    }
                    
                    
                    //        .contextMenu {
                    //
                    //            if let userId = Auth.auth().currentUser?.uid,
                    //               comment.id == userId || userId == postOwnerID {
                    //                VStack {
                    //                    Button(action: {
                    //                        comments.deleleComment(comment: comment)
                    //                    }) {
                    //                        Text("Delete")
                    //                    }.buttonStyle(.borderless)
                    //
                    //                }
                    //            }
                    //        }
                    //        .frame(width: phoneWidth - 100, height: 80)
                    .clipShape(ChatBubbleShape(direction: .left))
                }
            } else {
                ZStack (alignment: .leading) {
                    Color.mainColorInverse.opacity(isCurrentUser ? 0.4 : 0.5)
                    VStack (alignment: .leading, spacing: 5) {
                        
                        HStack {
                            WebImage(url: comments.personDict[comment.id]?.profilePicLink)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 35, height: 35)
                                .scaledToFill()
                                .clipShape(Circle())
                            Text (comments.personDict[comment.id]?.name ?? "")
                                .font(.headline)
                                .foregroundColor(Color.mainColor)
                            Spacer()
                            Text(comment.timeString)
                                .font(.caption2)
                                .foregroundColor(Color.mainColor.opacity(0.3))
                                .offset(y: 3)
                                .padding(.trailing, 16)
                        }
                        .padding(.leading, 5)
                        mediaView
                    }
                    .padding(.all, 5)
                }
                .clipShape(ChatBubbleShape(direction: .left))
            }
            
            likeCapsule
                .onTapGesture {
                    CommentLikesMatchedGeometry = comment.commentID
                    comment2 = comment
                }
                .animation(Animation.linear.speed(0.6))
                .onChange(of: commentLikes.postLikes.isEmpty) { isEmpty in
                    if !isEmpty,bottomPadding == 0{
                        withAnimation(Animation.linear.speed(0.6)) {
                            bottomPadding = 15
                        }
                    }
                }
        }
        .onCustomTapGesture(count: 2,perform: doubleTapped)
        //            .padding(.top, 0 - bottomPadding)
        .padding(.bottom, 0 + bottomPadding)
    }
    
    @State var bottomPadding: Double = 0
    
    func doubleTapped(){
        print(" doubleTapped")
        if postOwnerID != TristanUserID {
            hasMessageBeenLiked = true
            if commentLikes.postLikes.contains(friendsDictionary.friendsDictionary[currentUserID ?? ""] ?? Person(id: "")) == false, comment.status == .successfull {
#if os(iOS)
                let impactLight = UIImpactFeedbackGenerator(style: .heavy)
                impactLight.impactOccurred()
#endif
                guard let userId = currentUserID,
                      let webLink = (friendsDictionary.friendsDictionary[userId]?.webLink) else{ return }
                functions.likeComment(sentBy: userId, commentID: comment.commentID, postID: postID, webLink: webLink , postOwnerID: postOwnerID, otherUserID: comment.id, token: friendsDictionary.friendsDictionary[comment.id]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "")
            }
        }
    }
    
    @Binding var OpenedPhotoSelectedItem: URL?
    @Binding var OpenedPhotoMatchedGeometry: String
    var mediaView : some View {
        ZStack{
            if let audioUrl = comment.audioUrl{
                CacheAudioPlayer(audioUrl: audioUrl, isDummy: comment.isDummy, color: Color.white, backgroundColor: Color.mainColorInverse.opacity(0.2))
                    .padding(.leading, 5)
                    .padding(.bottom, 10)
                    .padding(.top, comment.comment == "" ? 5 : -10)
            }else{
                comment.kind.map { _ in
                    HStack{
                        ZStack(alignment: .center) {
                            if let photoURL = comment.photoLink  {
                                WebImage(url: photoURL)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .onCustomTapGesture(count : 2,perform: doubleTapped)
                                    .onCustomTapGesture {
                                        OpenedPhotoSelectedItem = photoURL
                                        OpenedPhotoMatchedGeometry = "0"
                                        hideKeyboard()
                                    }
                            }else if let image = comment.tempImage {
                                ZStack{
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                    if comment.videoUrl != nil {
                                        VideoPlayButtonView(size: 50)
                                    }
                                }
                            }
                            
                            if let videoUrl =  comment.videoUrl,
                               let thumbnailUrl = comment.thumbnailUrl {
                                ZStack(alignment: .center) {
                                    WebImage(url: thumbnailUrl)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .overlay( VideoThumbnailView(videoThumbnailVM : VideoThumbnailVM(videoFirebaseURL : videoUrl ), doubleTapAction : doubleTapped)
                                        )
                                }
                            }
                        }
                        .frame(width: screenHeight/5, height: screenHeight/5)
                        .background(Color.mainColor.opacity(0.1))
                        .clipShape(ChatBubbleShape(direction: .left))
                        if let _ = comment.tempImage{
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.speakerPurple))
                                .padding(.leading,10)
                        }
                        Spacer()
                    }
                    //            .padding([.bottom,.trailing])
                }
            }
        }
    }
    
    
    var gifView: some View {
        HStack{
            ZStack(alignment: .center) {
                AnimatedImage(url: URL(string: comment.comment))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .onCustomTapGesture(count : 2,perform: doubleTapped)
                    .onCustomTapGesture {
                        OpenedGIFMatchedGeometry = comment.comment
                        hideKeyboard()
                    }
            }
            .frame(width: screenHeight/5, height: screenHeight/5)
            .background(Color.mainColor.opacity(0.1))
            .clipShape(ChatBubbleShape(direction: .left))
            if let _ = comment.tempImage{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.speakerPurple))
                    .padding(.leading,10)
            }
            Spacer()
        }
        .padding(.top, -6)
        .padding(.bottom, 8)
    }
}

struct DummyComment: View {
    
    @ObservedObject var comments : CommentsOO
    @ObservedObject var commentReplies : CommentRepliesOO
    
    @Binding var comment: CommentModel
    init(comments :  CommentsOO,commentReplies : CommentRepliesOO,comment: Binding<CommentModel>) {
        self.comments = comments
        self.commentReplies = commentReplies
        self._comment = comment
        addSubscriptionForReplyComment()
    }
    
    var body: some View {
        EmptyView()
    }
    
    func addSubscriptionForReplyComment() {
        guard commentReplies.subscription == nil else {
            return
        }
        let replyPublisher = comments.getRawReplyCommentPublisher(commentID: comment.commentID)
        commentReplies.setSubscription(publisher: replyPublisher)
    }
}


struct NewComment2: View {
    
    @ObservedObject var comments : CommentsOO
    @State var comment: CommentModel
    @State var isShowing = false
    @Environment(\.colorScheme) var colorScheme
    @Binding var OpenedProfileFromCommentsMatchedGeometry: String
    @Binding var OpenedStrangerProfileFromCommentReplyMatchedGeometry: String
    @State var hasBeenLiked = false
    @StateObject var functions = LikeCommentFunction()
    @State var postID: String
    @State var postOwnerID: String
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @StateObject var hasCommentBeenLiked: HasCommentBeenLikedOO
    @Binding var CommentLikesMatchedGeometry: String
    @Binding var CommentReplyLikesMatchedGeometry: String
    @Binding var CommentReplyLikesOriginalCommentID: String
    @Binding var textFieldPlaceholder: String
    @Binding var nameOfPersonReplyingTo: String
    @Binding var IDofPersonReplyingTo: String
    @Binding var message: String
    @Binding var commentID: String
    @Binding var friendsWhoReplied: [String]
    @StateObject var commentReplies : CommentRepliesOO
    @StateObject var commentLikes: CommentLikesOO
    // Like animation
    @State private var circleSize = 0.0
    @State private var circleInnerBorder = 35
    @State private var circleHue = 200
    //
    @StateObject var likeComment = LikeCommentFunction()
    @State var hasMessageBeenLiked = false
    @State var doubleTap = [Int]()
    @Binding var isDeletePostShowing: Bool
    @State var isCurrentUser = false
    @EnvironmentObject var mentionedUserVM : MentionedUserVM
    @Binding var StrangerProfileSelectedUser: Person
    @Binding var FriendProfileMatchedGeometry: String
    
    @Binding var comment2: CommentModel
    @Binding var OpenedGIFMatchedGeometry: String
    @Binding var CommentLikeNavigation: String
    @Binding var commentLikedBy: [Person]?
    @State var deleteComment: Bool = false
    @Binding var anonymousModeAlert: Bool
    @Binding var buttonAlertType: ButtonAlertType
    @ObservedObject var themeController: ThemeController
    @State var commentLink:  URL?
    var body: some View {
        ZStack (alignment: .topTrailing) {
            ZStack (alignment: .bottomLeading) {
                DummyComment(comments: comments, commentReplies: commentReplies, comment: $comment)
                ZStack (alignment: .leading) {
                    
                    VStack (alignment: .leading, spacing: 5) {
                        
                        HStack {
                            if comments.personDict[comment.id]?.anonymousMode == true && friendsDictionary.friendsDictionary[comment.id] == nil {
                                HStack {
                                    Image(systemName: "questionmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 35, height: 35)
                                        .scaledToFill()
                                        .clipShape(Circle())
                                    Text ("Anonymous")
                                        .font(.headline)
                                        .foregroundColor(Color.mainColor)
                                }
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                                        withAnimation() {
                                            if anonymousModeAlert == false {
                                                buttonAlertType = .anonymousMode
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    anonymousModeAlert = true
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                HStack {
//                                    Button(action: {
//
//                                        if friendsDictionary.friendsDictionary[comment.id] != nil {
//                                            FriendProfileMatchedGeometry = comment.id
//                                        } else {
//                                            FriendProfileMatchedGeometry = comment.id
//                                            StrangerProfileSelectedUser = comments.personDict[comment.id] ?? Person(id: "")
//                                        }
//                                    }){
                                        WebImage(url: comments.personDict[comment.id]?.profilePicLink)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 35, height: 35)
                                            .scaledToFill()
                                            .clipShape(Circle())
                                            .onTapGesture {
                                                if friendsDictionary.friendsDictionary[comment.id] != nil {
                                                    FriendProfileMatchedGeometry = comment.id
                                                } else {
                                                    FriendProfileMatchedGeometry = comment.id
                                                    StrangerProfileSelectedUser = comments.personDict[comment.id] ?? Person(id: "")
                                                }
                                            }
//                                    }
                                }
                                Text (comments.personDict[comment.id]?.name ?? "")
                                    .font(.headline)
                                    .foregroundColor(Color.black)
                            }
                            Text(comment.timeString)
                                .font(.caption2)
                                .foregroundColor(Color.black.opacity(0.3))
                                .offset(y: 1)
                                .padding(.trailing, 16)
                        }
                        .padding(.leading, 5)
                        .padding(.top, 2)
                        if comment.isGIF == true {
                            gifView
                            
                        } else {
                            //                            if let comment = comment.comment {
                            if comment.comment.isNotEmpty {
                                let CommentText =
                                Text(comment.comment)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .font(.subheadline.weight(.light))
                                    .foregroundColor(Color.black)
                                    .padding(.leading, 5)
                                    .multilineTextAlignment(.leading)
                                    .padding(.trailing, 10)
                                if comment.comment.indicesOf(string: "@").count != 0 || comment.comment.contains("https://") {
//                                    GeometryReader { geometry in
                                    CommentLabel3(content: comment.comment, tappedMention: {
                                        mentionedUserVM.menionedTapped(username: $0)
                                    }, tappedLink: { link in
                                        commentLink = link
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            commentLink = nil
                                        }
                                        print("LINKKK ")
                                    })
                                        .fixedSize(horizontal: true, vertical: true)
                                    .padding(.leading, 5)
                                    .padding(.trailing, 10)
//                                }

                                } else {
                                    CommentText
                                }
                            }
                        }
                        HStack(alignment: .top) {
                            mediaView
                                .padding(.trailing)
                            if comment.linkMetaData != nil {
                                LinkPreview(metaData: comment.linkMetaData!)
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(15)
                                    .offset(x: -18)
                             }
                        }
                    }
                    .padding(.bottom, 12)
                    .offset(x: 5, y: 2)
                }
                .background(themeController.theme.secondary)
                .clipShape(ChatBubbleShape(direction: .left))
                
                if commentLikes.postLikes.isNotEmpty {
                    CommentLikeButton(commentLikes: commentLikes, themeController: themeController) {
                        withAnimation {
                            CommentLikeNavigation = "0"
                            commentLikedBy = commentLikes.postLikes
                            comment2 = comment
                        }
                    }
                }
            }
            
            if deleteComment && (comment.id == currentUserID ?? "" || postOwnerID == currentUserID ?? ""){
                DeleteCommentMenu(comment: comment, commentModel: comments, deleteComment: $deleteComment, themeController: themeController, authorID: postOwnerID)
            }
            if commentLink != nil {
                EmptyView()
                .onAppear {
                    UIApplication.shared.open((commentLink ?? URL(string:"www.google.com"))!, options: [:], completionHandler: nil)
                }
                .onDisappear {
                    commentLink = nil
                }
            }
        }

        .padding(.top, -5)
        .padding(.bottom, commentLikes.postLikes.isNotEmpty ? 8 : 0)
//        .padding(.bottom, commentLikes.postLikes.isNotEmpty || comment.id == (currentUserID ?? "") ? 8 : 0)
//        .onTapGesture {}
        .onCustomTapGesture(count: 2,perform: doubleTapped)
        .onLongPressGesture {
            if (comment.id == currentUserID ?? "" || postOwnerID == currentUserID ?? "") {
                withAnimation(.linear(duration: 0.2)) {
                    deleteComment.toggle()
                    let impactLight = UIImpactFeedbackGenerator(style: .soft)
                    impactLight.impactOccurred()
                }
            }
        }
        //        .onTapGesture { }
    }
    
    @State var bottomPadding: Double = 0
    func doubleTapped(){
        print(" doubleTapped")
        if postOwnerID != TristanUserID {
            hasMessageBeenLiked = true
            if commentLikes.postLikes.contains(friendsDictionary.friendsDictionary[currentUserID ?? ""] ?? Person(id: "")) == false, comment.status == .successfull {
#if os(iOS)
                let impactLight = UIImpactFeedbackGenerator(style: .heavy)
                impactLight.impactOccurred()
#endif
                guard let userId = currentUserID,
                      let webLink = (friendsDictionary.friendsDictionary[userId]?.webLink) else{ return }
                functions.likeComment(sentBy: userId, commentID: comment.commentID, postID: postID, webLink: webLink , postOwnerID: postOwnerID, otherUserID: comment.id, token: friendsDictionary.friendsDictionary[comment.id]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "")
            }
        }
    }
    
    @Binding var OpenedPhotoSelectedItem: URL?
    @Binding var OpenedPhotoMatchedGeometry: String
    var mediaView : some View {
        ZStack{
            if let audioUrl = comment.audioUrl{
                CacheAudioPlayer(audioUrl: audioUrl, isDummy: comment.isDummy, color: Color.white, backgroundColor: themeController.theme.primary.opacity(0.2))
                    .padding(.leading, 5)
                    .padding(.bottom, 10)
                    .padding(.top, comment.comment == "" ? 5 : -10)
            }else{
                comment.kind.map { _ in
                    HStack{
                        ZStack(alignment: .center) {
                            if let photoURL = comment.photoLink  {
                                WebImage(url: photoURL)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .onCustomTapGesture(count : 2,perform: doubleTapped)
                                    .onCustomTapGesture {
                                        withAnimation(.linear(duration: 0.2)) {
                                            OpenedPhotoSelectedItem = photoURL
                                            OpenedPhotoMatchedGeometry = "0"
                                            hideKeyboard()
                                        }
                                    }
                            }else if let image = comment.tempImage {
                                ZStack{
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                    if comment.videoUrl != nil {
                                        VideoPlayButtonView(size: 50)
                                    }
                                }
                            }
                            
                            if let videoUrl =  comment.videoUrl,
                               let thumbnailUrl = comment.thumbnailUrl {
                                ZStack(alignment: .center) {
                                    WebImage(url: thumbnailUrl)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .overlay( VideoThumbnailView(videoThumbnailVM : VideoThumbnailVM(videoFirebaseURL : videoUrl ), doubleTapAction : doubleTapped)
                                        )
                                }
                            }
                        }
                        .frame(width: screenHeight/5, height: screenHeight/5)
                        .background(Color.mainColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                        .offset(x: 5)
                        .padding(.top, 5)
                        if let _ = comment.tempImage{
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: themeController.theme.accent))
                                .padding(.leading,10)
                        }
                        
                        //                        Spacer()
                    }
                    //            .padding([.bottom,.trailing])
                }
            }
        }
    }
    
    
    var gifView: some View {
        HStack{
            ZStack(alignment: .center) {
                AnimatedImage(url: URL(string: comment.comment))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .onCustomTapGesture(count : 2,perform: doubleTapped)
                    .onCustomTapGesture {
                        withAnimation(.linear(duration: 0.2)) {
                            OpenedGIFMatchedGeometry = comment.comment
                        }
                        hideKeyboard()
                    }
            }
            .frame(width: screenHeight/5, height: screenHeight/5)
            .background(Color.mainColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
            .offset(x: 5, y: 2)
            .padding(.top, 5)
            if let _ = comment.tempImage{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: themeController.theme.accent))
                    .padding(.leading,10)
            }
        }
    }
}

struct CommentLikeButton: View {
    @ObservedObject var commentLikes: CommentLikesOO
    @ObservedObject var themeController: ThemeController
    var action: () -> ()
    var body: some View {
        DoubleCircle(size1: 20, size2: 18, themeController: themeController, isFromComment: true) {
            action()
        }
        .overlay (
            Text("+\(commentLikes.postLikes.count)")
                .foregroundColor(.black.opacity(0.25))
                .font(.caption2)
                .onTapGesture {
                    action()
                }
        )
        .offset(x: 10, y: 10)
    }
}
struct DeleteCommentMenu: View {
    @Environment(\.colorScheme) var colorScheme
    @State var comment: CommentModel
    @ObservedObject var commentModel : CommentsOO
    @Binding var deleteComment: Bool
    @State var isActive = false
    @ObservedObject var themeController: ThemeController
    @State var authorID: String
    var body: some View {
        ZStack {
            
            HStack {
                ZStack {
                    VStack (alignment: .leading) {
                        
                        Button(action: {
                            withAnimation() {
                                if isActive {
                                    deleteComment = false
                                    deleteComment(comment: comment)
                                    let impactLight = UIImpactFeedbackGenerator(style: .soft)
                                    impactLight.impactOccurred()
                                }
                            }
                        }){
                            HStack {
                                Text("Delete")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .offset(y: -1)
                                //                            .fontWeight(.light)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }.buttonStyle(.borderless)
                        Divider()
                        Button(action: {
                            withAnimation() {
                                    deleteComment = false
                            }
                        }){
                            HStack {
                                Text("Cancel")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .offset(y: 1)
                                //                            .fontWeight(.light)
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal)
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }.buttonStyle(.borderless)
                    }
                }
            }
            .frame(width: screenWidth/1.8, height: 90)
//            .background((colorScheme == .light ? Color.rosePink : Color.raisinBlack)
            .background(themeController.theme.accent
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))))
            .shadow(color: Color.black.opacity(0.16), radius: 6, x: 0, y: 3)
        }
        .offset(x: 10, y: 0)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isActive = true
            }
        }
    }
    func deleteComment(comment: CommentModel) {
        if comment.id == currentUserID ?? "" || authorID == currentUserID ?? "" {
            commentModel.deleleComment(comment: comment)
        }
    }
}

struct CommentLikeList: View {
    @State var commentLikedBy: [Person]?
    @ObservedObject var friendsDictionary: FriendsDictionary
    @State var comment: CommentModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var StrangerProfileSelectedUser: Person
    @Binding var FriendProfileMatchedGeometry: String
    @Binding var anonymousModeAlert: Bool
    @Binding var buttonAlertType: ButtonAlertType
    @ObservedObject var themeController: ThemeController
    var action: () -> ()
    var body: some View {
        if let commentLikes = commentLikedBy {
            ZStack (alignment: .topLeading){
                VStack (spacing: 0) {
                    Rectangle()
                        .foregroundColor(themeController.theme.primary)
                        .cornerRadius(18, corners: [.topLeft, .topRight])
                        .frame(height: 90)
                        .overlay (
                            VStack (alignment: .leading, spacing: 0) {
                                Text("💜")
                                    .font(.caption)
                                    .foregroundColor(Color.black)
                                    .offset(x: 37, y: -13)
                                CommentLikeComment(comment: comment, themeController: themeController)
                            }
                        )
                    ScrollView {
                        VStack (spacing: 5) {
                            ForEach(commentLikes, id: \.self) { item in
                                SearchBarResultRow(person: item, size: 55, friendsDictionary: friendsDictionary, anonymousModeAlert: $anonymousModeAlert, buttonAlertType: $buttonAlertType)
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
//                    .frame(height: commentLikes.count > 7 ? 530 : ((CGFloat(commentLikes.count) * 65) + 10))
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
}


struct CommentLikeComment: View {
    @State var comment: CommentModel
    @ObservedObject var themeController: ThemeController
    var body: some View {
        
        HStack {
            HStack {
                HStack {
                    if comment.isGIF ?? false {
                        
                    } else {
                        Text(comment.comment)
                            .lineLimit(1)
                            .font(.body.weight(.light))
                            .foregroundColor(Color.black)
                            .padding(.leading, 8)
                            .padding(.trailing, 10)
                            .padding(.vertical, 2)
                    }
                    
                }
                .padding(8)
                .background(themeController.theme.secondary)
                .clipShape(ChatBubbleShape(direction: .left))
            }
            Spacer()
        }
        .offset(x: 8, y: 2)
    }
}








struct CommentReplies: View {
    @ObservedObject var commentReplies : CommentRepliesOO
    @StateObject var functions = LikeCommentReplyFunction()
    @State var comment: CommentModel
    @Environment(\.colorScheme) var colorScheme
    @State var hasBeenLiked = false
    @Binding var OpenedStrangerProfileFromCommentReplyMatchedGeometry: String
    @State var originalCommentID: String
    @Binding var originalCommentIDMatchedGeometry: String
    @State var postID: String
    @State var postOwnerID: String
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @StateObject var hasCommentReplyBeenLiked: HasCommentReplyBeenLikedOO
    @Binding var CommentReplyLikesMatchedGeometry: String
    @State var OpenedStrangerProfileFromCommentReply = Person(id: "", username: "", name: "", bio: "", imageurl: "", accountCreationDate: Timestamp(), profileCircle: .clear)
    @Binding var textFieldPlaceholder: String
    @Binding var nameOfPersonReplyingTo: String
    @Binding var IDofPersonReplyingTo: String
    @Binding var message: String
    @Binding var commentID: String
    @Binding var friendsWhoReplied: [String]
    
    // Like animation
    @State private var circleSize = 0.0
    @State private var circleInnerBorder = 35
    @State private var circleHue = 200
    //
    @EnvironmentObject var mentionedUserVM : MentionedUserVM
    
    var body: some View {
        
        let commentReplyHStack = HStack (alignment: .top) {
            Image(systemName: "arrow.turn.down.right")
                .frame(width: 10, height: 10)
                .foregroundColor(Color.speakerPurple.opacity(0.3))
                .offset(y: 8)
            ZStack {
                Circle()
                    .frame(width: 38, height: 38)
                    .foregroundColor(commentReplies.personDict[comment.id]?.profileCircle)
                //                                .foregroundColor(Color.mainColor)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                    .clipShape(Circle())
                WebImage(url: commentReplies.personDict[comment.id]?.profilePicLink)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 35, height: 35)
                    .background(Color.lightGray)
                    .clipShape(Circle())
                    .onTapGesture {
                        
                        var replier : Person? {
                            commentReplies.personDict[comment.id]
                        }
                        
                        let person = Person(id: replier?.id ?? "",
                                            username:  replier?.username ?? "",
                                            name:  replier?.name ?? "",
                                            bio:  replier?.bio ?? "",
                                            imageurl:  replier?.imageurl ?? "",
                                            webLink: replier?.webLink,
                                            token:  replier?.token ?? "",
                                            accountCreationDate: replier?.accountCreationDate ?? Timestamp(),
                                            profileCircle: replier?.profileCircle ?? .clear)
                        
                        OpenedStrangerProfileFromCommentReply = person
                        OpenedStrangerProfileFromCommentReplyMatchedGeometry = comment.id
                    }
            }
            HStack (alignment: .top){
                VStack (alignment: .leading, spacing: 2) {
                    HStack {
                        Text(commentReplies.personDict[comment.id]?.name ?? "")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color.mainColor)
                        Button(action: {
                            guard comment.status == .successfull else{
                                return
                            }
                            textFieldPlaceholder = "Reply"
                            message = ""
                            nameOfPersonReplyingTo = commentReplies.personDict[comment.id]?.name ?? ""
                            friendsWhoReplied = commentReplies.friendsWhoCommented
                            commentID = originalCommentID
                            IDofPersonReplyingTo = comment.id
                            
                            
                        }){
                            Text("Reply")
                                .font(.caption2)
                                .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 0.7 : 0.4))
                            
                        }.buttonStyle(.borderless)
                            .offset(x: -3, y: 1)
                        if hasBeenLiked  || hasCommentReplyBeenLiked.doesThePostHaveLikes {
                            Text("Likes")
                                .font(.caption2)
                                .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 0.7 : 0.4))
                                .offset(y: 0)
                                .onTapGesture {
                                    CommentReplyLikesMatchedGeometry = comment.commentID
                                    originalCommentIDMatchedGeometry = originalCommentID
                                }
                                .disabled(comment.status != .successfull)
                        }
                    }
                    
                    let commentReplyLabelText = Text(comment.comment)
                        .font(.caption)
                        .foregroundColor(Color.mainColor)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if comment.comment.indicesOf(string: "@").count != 0 {
                        
                        ZStack{
                            commentReplyLabelText.hidden()
                            GeometryReader { proxy in
                                CommentReplyLabel(width: proxy.size.width, content: comment.comment) {mentionedUserVM.menionedTapped(username: $0)}
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    } else {
                        commentReplyLabelText
                    }
                    Text(comment.timeString)
                        .font(.caption2)
                        .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 0.5 : 0.3))
                    
                }
                Spacer()
                
                ZStack {
                    Button(action: {
                        
                        guard let userId = Auth.auth().currentUser?.uid else{ return }
                        
                        guard hasBeenLiked == false || hasCommentReplyBeenLiked.hasBeenLikedByMe == false else {
                            return
                        }
                        
                        guard let person = friendsDictionary.friendsDictionary[userId] else {
                            return
                        }
                        if let  webLink = person.webLink {
                            functions.likeComment(sentBy: userId,
                                                  originalCommentID: originalCommentID,
                                                  postID: postID,
                                                  webLink: webLink,
                                                  postOwnerID: postOwnerID,
                                                  otherUserID: comment.id,
                                                  token: friendsDictionary.friendsDictionary[comment.id]?.token ?? "",
                                                  commentID: comment.commentID,
                                                  nameOfSendingUser: person.name )
                            hasBeenLiked.toggle()
                            circleSize = 1.3
                            circleInnerBorder = 0
                            circleHue = 300
#if os(iOS)
                            
                            let impactLight = UIImpactFeedbackGenerator(style: .soft)
                            impactLight.impactOccurred()
#endif
                        }
                        
                    }) {
                        let likedImageName = (colorScheme == .light ? "heartLightMode" : "heartDarkMode")
                        Image(hasBeenLiked || hasCommentReplyBeenLiked.hasBeenLikedByMe ? "heartFilled" : likedImageName)
                            .resizable()
                            .frame(width: 12.5, height: 12.5)
                            .opacity(hasBeenLiked || hasCommentReplyBeenLiked.hasBeenLikedByMe ? 1 : 0.5)
                    }.buttonStyle(.borderless)
                    Circle()
                        .strokeBorder(lineWidth:  CGFloat(circleInnerBorder))
                        .animation(Animation.easeInOut(duration: 0.5).delay(0.1))
                        .frame(width: 19, height: 19, alignment: .center)
                        .foregroundColor(Color(.systemPink))
                        .hueRotation(Angle(degrees: Double(circleHue)))
                        .scaleEffect(CGFloat(circleSize))
                        .animation(Animation.easeInOut(duration: 0.5))
                }
                //                        .offset(y: -5)
                .padding(.horizontal)
                .padding(.top)
                .disabled(comment.status != .successfull)
                
            }
        }
        
        return VStack {
            commentReplyHStack
            if shouldAddProgressBar {
                progressBarView
            }
        }  .onAppear {
            if comment.status == .sending {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
                    shouldAddProgressBar = true
                }
            }
        }
        
    } // HSTACK
    
    var progressBarView : some View{
        VStack{
            ProgressView( value: progressBarValue, total: 100)
                .accentColor(Color.speakerPurple)
                .padding(.horizontal,10)
                .padding(.leading,20)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (_) in
                        withAnimation(.default) {
                            progressBarValue = 90
                        }
                    }
                }
        }
    }
    
    @State var progressBarValue : CGFloat = 0
    @State var shouldAddProgressBar : Bool = false
}

struct LinkPreview: UIViewRepresentable {
    
    var metaData: LPLinkMetadata
    
    func makeUIView(context: Context) -> LPLinkView {
        
        let preview = LPLinkView(metadata: metaData)
        
        return preview
    }
    
    func updateUIView(_ uiView: LPLinkView, context: Context) {
        
        uiView.metadata = metaData
    }
}
