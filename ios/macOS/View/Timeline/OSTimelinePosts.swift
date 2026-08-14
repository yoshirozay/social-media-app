////
////  Posts.swift
////  speakEZ crossplatform (macOS)
////
////  Created by Carson O'Sullivan on 1/31/21.
////
import Foundation
import SwiftUI
import SDWebImageSwiftUI
//
struct OSTimelinePosts: View {
    @State var id: String
    @Binding var FriendProfileMatchedGeometry: String
    @State var hasBeenLiked = false
    @State var isPostOpened = false
    @State var postData: PostModel
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    var body: some View {
        if isPostOpened == false {
        ZStack {
            Color.mainColorInverse.opacity(0.3)
                .ignoresSafeArea(.all)
            VStack {
                VStack {
                    HStack (spacing: 10) {
//
                        WebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                                .onTapGesture {
                                    FriendProfileMatchedGeometry = id
                                }
                        
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
                                .padding(.horizontal, 10)
                        } // HSTACK
                        .foregroundColor(.mainColor)
                        
                    } // HSTACK
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    HStack {
                        Text(postData.content)
                            .font(.title3)
                            .padding(.horizontal, 16)
                        Spacer()
                    } // HSTACK
                    if let photoLink = postData.photoLink  {
                        WebImage(url: photoLink)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 355, height: 400, alignment: .center)
                            .background(Color.mainColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                            .resizable()
//                            .frame(width: 355, height: 400, alignment: .center)
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                            .scaledToFill()
                            .onTapGesture {
                                withAnimation(.easeIn(duration: 0.3)) {
//                                    FriendProfileMatchedGeometry = id
                                }
                            }
                    }
                }
                .padding(.vertical, 10)
//                Spacer()
                    .foregroundColor(.mainColor)
            }

            
        } .background(BlurView())
        .contentShape(Rectangle())
        .onTapGesture {
            
            isPostOpened.toggle()
            
        }
     
        }  else {
            OSOpenedPost(id: id,
                         isPostOpened: $isPostOpened,
                         FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,
                         comments: CommentsOO(id: id, postID: postData.postID),
                         likes: LikesOO(id: id, postID: postData.postID),
                         postData: postData,
                         hasBeenLikedOO: HasPostBeenLikedOO(id: id, postID: postData.postID))
        }
    }
}
//
struct OSComment: View {
    
    @StateObject var comments : CommentsOO
    let comment : CommentModel
    
    var body: some View {
        HStack (alignment: .top) {
            WebImage(url: comments.personDict[comment.id]?.profilePicLink)// Cant use friends dictionary here, what if there is a comment from someone who is not your friend
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            HStack (alignment: .top){
                VStack (alignment: .leading, spacing: 2) {
                    
                    Text(comments.personDict[comment.id]?.name ?? "")
                        .fontWeight(.medium)
                    Text(comment.comment  )
                        .font(.caption)
                        .foregroundColor(.mainColor)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Text(comment.timeString)
                    .font(.caption)
                    .foregroundColor(.mainColor)
                    
            }
        } // HSTACK
        .padding(.horizontal)
    }
}

//struct OSComment: View {
//    @State var id: Int = 0
//    @StateObject var comments = CommentsOO(id: "", postID: "")
//    @State var dictionaryID: String
//    var body: some View {
//        HStack (alignment: .top) {
//            WebImage(url: comments.personDict[dictionaryID]?.webLink)// Cant use friends dictionary here, what if there is a comment from someone who is not your friend
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: 40, height: 40)
//                .clipShape(Circle())
//            HStack (alignment: .top){
//                VStack (alignment: .leading, spacing: 2) {
//
//                    Text(comments.personDict[dictionaryID]?.name ?? "")
//                        .fontWeight(.medium)
//                    Text(comments.commentDict[dictionaryID]?.comment ?? "")
//                        .font(.caption)
//                        .foregroundColor(.mainColor)
//                        .multilineTextAlignment(.leading)
//                }
//                Spacer()
//                Text(comments.commentDict[dictionaryID]?.timeString ?? "")
//                    .font(.caption)
//                    .foregroundColor(.mainColor)
//
//            }
//        } // HSTACK
//        .padding(.horizontal)
//    }
//}
//
struct OSOpenedPost: View {
    @Namespace var namespace
    @State var id: String
    @State var LikesProfileMatchedGeometry: String = ""
    @State var hasBeenLiked = false
    @Binding var isPostOpened: Bool
    @Binding var FriendProfileMatchedGeometry: String
    @State var text = ""
    @StateObject var comments : CommentsOO
    @StateObject var likes : LikesOO
    @State var postData : PostModel
    @StateObject var hasBeenLikedOO : HasPostBeenLikedOO
    @StateObject var likeFunction = SendLikeFunction()
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @EnvironmentObject var timelinePosts : TimelinePostsOO
    @Environment(\.colorScheme) var colorScheme
    
    // Like animation
    @State private var circleSize = 0.0
    @State private var circleInnerBorder = 35
    @State private var circleHue = 200
    //
    func likePost() {
        guard let userId = currentUserID else{ return }
        
        if hasBeenLiked == false || hasBeenLikedOO.hasBeenLiked == false {
            if id != "ctgg158KOnajMBuFZ5GyHLyRYPE3" {
                likeFunction.sendLike(sentBy: userId,
                                      postID: postData.postID,
                                      otherUserID: id,
                                      token: friendsDictionary.friendsDictionary[id]?.token ?? "",
                                      nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "")
            }
        }
        hasBeenLiked.toggle()
        circleSize = 1.3
        circleInnerBorder = 0
        circleHue = 300
//        let impactLight = UIImpactFeedbackGenerator(style: .soft)
//                        impactLight.impactOccurred()
    }
    
    var body: some View {
        ZStack {
            Color.mainColorInverse.opacity(0.3)
            VStack{
            VStack {
                VStack {
                    HStack (spacing: 10) {
//
                        WebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                                .onTapGesture {
                                    FriendProfileMatchedGeometry = id
                                }
                        
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
                                .padding(.horizontal, 10)
                        } // HSTACK
                        .foregroundColor(.mainColor)
                        
                    } // HSTACK
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    HStack {
                        Text(postData.content)
                            .font(.title3)
                            .padding(.horizontal, 16)
                        Spacer()
                    } // HSTACK
                    if let photoLink = postData.photoLink  {
                        WebImage(url: photoLink)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 355, height: 400, alignment: .center)
                            .background(Color.mainColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
//                            .resizable()
//                            .frame(width: 355, height: 400, alignment: .center)
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                            .scaledToFill()
                            .onTapGesture {
                                withAnimation(.easeIn(duration: 0.3)) {
//                                    OpenedPhotoMatchedGeometry = "0"
//                                    OpenedPhotoSelectedItem = postData.photo
                                }
                            }
                    }
                }
                .padding(.vertical, 10)
//                Spacer()
                    .foregroundColor(.mainColor)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isPostOpened.toggle()
                
            }
                Group {
                    HStack {
                        ZStack {
                        Button(action : likePost ) {
                            
                            let heartEmptyMode = colorScheme == .light ? "heartLightMode" : "heartDarkMode"
                                Image(hasBeenLikedOO.hasBeenLiked || hasBeenLiked ? "heartFilled" : heartEmptyMode)
                                    .resizable()
                                    .frame(width: 20, height: 20) 
                        }
                            Circle()
                                .strokeBorder(lineWidth:  CGFloat(circleInnerBorder))
                                .animation(Animation.easeInOut(duration: 0.5).delay(0.1))
                                .frame(width: 24, height: 24, alignment: .center)
                                .foregroundColor(Color(.systemPink))
                                .hueRotation(Angle(degrees: Double(circleHue)))
                                .scaleEffect(CGFloat(circleSize))
                                .animation(Animation.easeInOut(duration: 0.5))
                    }

//                            Image(systemName: "heart")
//                            .foregroundColor(hasBeenLikedOO.hasBeenLiked ? Color.red.opacity(0.7) : Color.mainColor.opacity(0.7))
//                            .onTapGesture( perform: likePost)
                                
                        
                        if likes.postLikes.count == 1 {
                        
                            (Text("Liked by ") + Text("\(likes.postLikes[0].name) ").bold())
                            .font(.caption)
                            .padding(.leading, 9)
                            .foregroundColor(.mainColor)
                                .onTapGesture{
                                    LikesProfileMatchedGeometry = "0"
                                }
                        
                        .matchedGeometryEffect(id: UUID(), in: namespace)
                        }
                        if likes.postLikes.count > 1 {
                    
                            (Text("Liked by ") + Text("\(likes.postLikes[0].name) ").bold() + Text("and ") + Text("others").bold())
                            .font(.caption)
                            .padding(.leading, 9)
                            .foregroundColor(.mainColor)
                                .onTapGesture{
                                    LikesProfileMatchedGeometry = "0"
                                }
                        
                        .matchedGeometryEffect(id: UUID(), in: namespace)
                        }
                        
                        Spacer()
                    } // Likes
                    .frame(height: 25)
                    .padding(.leading, 21)
//                    Color.mainColor.opacity(0.15)
//                        .frame(width: screenWidth/2.13, height: 2)
                    Divider()
                    
                ZStack (alignment: .bottomTrailing) {
                    LazyVStack() {
                        ForEach(Array(comments.comments), id: \.self) { item in
                              OSComment(comments: comments, comment: item)
                              Divider()
                          }
//                        ForEach(Array(comments.commentDict.keys), id: \.self) { item in
//                            OSComment(comments: comments, dictionaryID: item)
//                            Divider()
//                        }
                        HStack {
                        TextField("Comment", text: self.$text)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.mainColor)
                                // Rotating paperplane
                                .rotationEffect(.init(degrees: 45))
                                // Padding Shape
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
//                    .padding(.top, 10)
              
//                }
                }
                
                }
            
                Spacer()
            }
        
        } .background(BlurView())

    }
}

