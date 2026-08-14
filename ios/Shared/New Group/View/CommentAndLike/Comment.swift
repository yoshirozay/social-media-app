//
//  Comment.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 4/28/21.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI
import SDWebImage 
import Firebase

struct Comment: View {
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
    
    // Like animation
    @State private var circleSize = 0.0
    @State private var circleInnerBorder = 35
    @State private var circleHue = 200
    //
    @EnvironmentObject var mentionedUserVM : MentionedUserVM
    var body: some View {
        VStack {
            DummyComment(comments: comments, commentReplies: commentReplies, comment: $comment)
            HStack (alignment: .top) {
                ZStack {
                    Circle()
                        .frame(width: 43, height: 43)
                        .foregroundColor(comments.personDict[comment.id]?.profileCircle)
//                                .foregroundColor(Color.mainColor)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                        .clipShape(Circle())
                WebImage(url: comments.personDict[comment.id]?.profilePicLink)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .background(Color.lightGray)
                    .clipShape(Circle())
                    .onTapGesture {
                        OpenedProfileFromCommentsMatchedGeometry = comment.id
                    }
                }
                HStack (alignment: .top){
                    VStack (alignment: .leading, spacing: 2) {
                        HStack {
                            Text(comments.personDict[comment.id]?.name ?? "")
                                .fontWeight(.medium)
                            Button(action: {
                                guard comment.status == .successfull else{
                                    return
                                }
                                textFieldPlaceholder = "Reply"
                                message = ""
                                nameOfPersonReplyingTo = comments.personDict[comment.id]?.name ?? ""
                                IDofPersonReplyingTo = comment.id
                                commentID = comment.commentID
                                friendsWhoReplied = commentReplies.friendsWhoCommented

                                
                            }){
                                Text("Reply")
                                    .font(.caption2)
                                    .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 0.7 : 0.4))
                                
                            }.buttonStyle(.borderless)
                            .offset(x: -3, y: 1)
                            .disabled(comment.status != .successfull)
                            if hasBeenLiked || hasCommentBeenLiked.doesThePostHaveLikes {
                                Text("|")
                                    .font(.caption2)
                                    .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 0.7 : 0.4))
                                    .offset(y: 1)
                                Text("Likes")
                                    .font(.caption2)
                                    .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 0.7 : 0.4))
                                    .offset(y: 1)
                                    .onTapGesture {
                                        guard comment.status == .successfull else{
                                            return
                                        }
                                        CommentLikesMatchedGeometry = comment.commentID
                                    }.disabled(comment.status != .successfull)
                            }
                        }
                        let commentText =
                             Text(comment.comment)
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                            .padding(.trailing)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if comment.comment.indicesOf(string: "@").count != 0 {
                            ZStack{
                                commentText .hidden()
                                GeometryReader { proxy in
                                    CommentLabel(width: proxy.size.width, content: comment.comment) { mentionedUserVM.menionedTapped(username: $0) }
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        } else {
                            commentText
                        }
                        
                        Text(comment.timeString)
                            .font(.caption2)
                            //                        .padding(.horizontal, phoneWidth > 375 ? 16 : 10)
                            .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 0.5 : 0.3))
                    }
                    Spacer()
                    
                    ZStack {
                    Button(action: {
                        guard comment.status == .successfull else{
                            return
                        }
                        hasBeenLiked.toggle()
                        circleSize = 1.3
                        circleInnerBorder = 0
                        circleHue = 300
#if os(iOS)
                        let impactLight = UIImpactFeedbackGenerator(style: .soft)
                                        impactLight.impactOccurred()
#endif
                       
                        guard let userId = Auth.auth().currentUser?.uid,
                              let webLink = (friendsDictionary.friendsDictionary[userId]?.webLink) else{ return }
                        
                        functions.likeComment(sentBy: userId, commentID: comment.commentID, postID: postID, webLink: webLink , postOwnerID: postOwnerID, otherUserID: comment.id, token: friendsDictionary.friendsDictionary[comment.id]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "")
                    }) {
                            let likedImageName = (colorScheme == .light ? "heartLightMode" : "heartDarkMode")
                            Image(hasBeenLiked || hasCommentBeenLiked.hasBeenLikedByMe ? "heartFilled" : likedImageName)
                                .resizable()
                                .frame(width: 15, height: 15)
                                .opacity(hasBeenLiked || hasCommentBeenLiked.hasBeenLikedByMe ? 1 : 0.5)
                    }.buttonStyle(.borderless)
                        Circle()
                            .strokeBorder(lineWidth:  CGFloat(circleInnerBorder))
                            .animation(Animation.easeInOut(duration: 0.5).delay(0.1))
                            .frame(width: 22, height: 22, alignment: .center)
                            .foregroundColor(Color(.systemPink))
                            .hueRotation(Angle(degrees: Double(circleHue)))
                            .scaleEffect(CGFloat(circleSize))
                            .animation(Animation.easeInOut(duration: 0.5))
                    }
                    .padding(.trailing)
                    .padding(.top)
                    .disabled(comment.status != .successfull)
                }
            } // HSTACK
           .foregroundColor(Color.mainColor)
            if commentReplies.comments.count != 0 {
                ForEach(commentReplies.comments.sorted(by: {$0.time.dateValue().timeIntervalSinceNow < $1.time.dateValue().timeIntervalSinceNow}), id: \.self) { item in
                    CommentReplies(commentReplies: commentReplies, comment: item, OpenedStrangerProfileFromCommentReplyMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry, originalCommentID: comment.commentID, originalCommentIDMatchedGeometry: $CommentReplyLikesOriginalCommentID, postID: postID, postOwnerID: postOwnerID, hasCommentReplyBeenLiked: HasCommentReplyBeenLikedOO(id: postOwnerID, postID: postID, originalCommentID: comment.commentID, commentID: item.commentID), CommentReplyLikesMatchedGeometry: $CommentReplyLikesMatchedGeometry, textFieldPlaceholder: $textFieldPlaceholder, nameOfPersonReplyingTo: $nameOfPersonReplyingTo, IDofPersonReplyingTo: $IDofPersonReplyingTo, message: $message, commentID: $commentID, friendsWhoReplied: $friendsWhoReplied)
                        .padding(.leading, screenWidth/20)
                        .contentShape(Rectangle())
                        .contextMenu {
                            if item.id == Auth.auth().currentUser?.uid || Auth.auth().currentUser?.uid == postOwnerID {
                        VStack {
                            
                            Button(action: {
                                commentReplies.deleleReplyComment(comment: item)
                            }) {
                                Text("Delete")
                            }
                        }
                        }
                    }
                }
            }
            
            if shouldAddProgressBar {
                progressBarView
                    .animation(.easeInOut(duration: 0.3))
            }
        }  .onAppear {
            if comment.status == .sending {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
                    withAnimation() {
                    shouldAddProgressBar = true
                    }
                }
            }
//            addSubscriptionForReplyComment()
        }//.animation( comment.status == .successfull ? .none : .spring() )
    }
    
//    func addSubscriptionForReplyComment() {
//        guard commentReplies.subscription == nil else {
//            return
//        }
//        let replyPublisher = comments.getRawReplyCommentPublisher(commentID: comment.commentID)
//        commentReplies.setSubscription(publisher: replyPublisher)
//    }
    
    
    var progressBarView : some View{
        VStack{
            ProgressView( value: progressBarValue, total: 100)
                .accentColor(Color.speakerPurple)
                .padding(.horizontal,10)
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

/*
 
 now when user write and tap to send comment reply publisher will be fired and the commentsReplyOO subscription will get the value. from there we will just use the same fallow as the commentOO and update view and call the cloud func to send comment reply
 */
