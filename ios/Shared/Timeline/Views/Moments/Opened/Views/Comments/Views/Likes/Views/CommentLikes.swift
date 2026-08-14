//
//  HomeCL.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//

import SwiftUI
import SDWebImageSwiftUI
import SDWebImage
import Firebase
import Combine

struct NewCommentLikes: View {
    @State var comment: CommentModel
    @ObservedObject var comments : CommentsOO
    @Binding var OpenProfileMatchedGeometry: String
    var body: some View {
        ZStack (alignment: .bottomLeading) {
            ZStack (alignment: .leading) {
                Color.mainColorInverse.opacity(0.5)
                VStack (alignment: .leading) {
                    
                    HStack {
                        WebImage(url: comments.personDict[comment.id]?.profilePicLink)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 35, height: 35)
                            .scaledToFill()
                            .clipShape(Circle())
                            .onTapGesture {
                                OpenProfileMatchedGeometry = comment.id
                            }
                        Text (comments.personDict[comment.id]?.name ?? "")
                            .font(.headline)
                            .foregroundColor(Color.mainColor)
                        //                        .rotationEffect(.degrees(180.0))
                        Spacer()
                        Text(comment.timeString)
                            .font(.caption2)
                            .foregroundColor(Color.mainColor.opacity(0.3))
//                                                    .offset(y: 3)
                            .padding(.trailing, 16)
                    }
                    
                    .padding(.leading, 5)
                    if comment.isGIF ?? false {
                        gifView
                    } else {
                    Text(comment.comment)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(4)
                        .font(.title3)
                        .foregroundColor(Color.mainColor)
                        .padding(.leading, 10)
                        .multilineTextAlignment(.leading)
                        .offset(x: -3, y: -5)
                        .padding(.trailing, 5)
                        .padding(.bottom, 8)
                    }
                }
                .offset(x: 5, y: 2)
                //            .offset(x: -10, y: -30)
            }
            .clipShape(ChatBubbleShape(direction: .left))

        }

    }
    var gifView: some View {
        HStack{
            ZStack(alignment: .center) {
                    AnimatedImage(url: URL(string: comment.comment))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
            }
            .frame(width: screenHeight/8, height: screenHeight/8)
            .background(Color.mainColor.opacity(0.1))
            .clipShape(ChatBubbleShape(direction: .left))
            Spacer()
        }
        .padding(.top, -6)
        .padding(.bottom, 8)
    }
}
struct CommentLikes2: View {
    @Binding var LikesMatchedGeometry: String
    @ObservedObject var likes: CommentLikesOO
    @Environment(\.colorScheme) var colorScheme
    @State var OpenProfileMatchedGeometry: String = ""
    @ObservedObject var comments : CommentsOO
    @State var comment: CommentModel
    @State var StrangerProfileSelectedUser: Person?
    @ObservedObject var friendsDictionary: FriendsDictionary
    var body: some View {
    ZStack {
        Color.mainColorInverse.edgesIgnoringSafeArea(.all)
        Color.speakerPurple.opacity(0.2).edgesIgnoringSafeArea(.all)
        VStack  {
//            Spacer()
            NewCommentLikes(comment: comment, comments: comments, OpenProfileMatchedGeometry: $OpenProfileMatchedGeometry)
                .frame(height: 100)
                .padding(.horizontal, 5)

            VStack {
                HStack {
                    Button(action: {
                        LikesMatchedGeometry = ""
                    }){
                        ZStack {
                        Image(systemName: "arrow.left")
                            .font(.title)
                            .foregroundColor(Color.white)
                        }
                        .frame(width: 40, height: 40)

                    }
                    .padding(.leading, 5)
                    HStack {

                    Text("LIKES")
                        .font(.headline)
                      .foregroundColor(Color.mainColor)
                    }
                    .padding(.leading, 5)
                    Spacer()
                }

                Rectangle()
                    .frame(width: screenWidth, height: 2)
                    .foregroundColor(Color.white)
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(likes.postLikes, id: \.self) { i in
                            
                            HStack {
                                WebImage(url: i.profilePicLink)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(i.name)
                                        .font(.headline)
                                    Text(i.username)
                                        .font(.caption)
                                        .padding(.top, -10)
                                } // VSTACK
                                Spacer()
                            }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    OpenProfileMatchedGeometry = i.id
                                    StrangerProfileSelectedUser = i
                                }
                                .padding(.horizontal, 10)
                            Rectangle()
                                .foregroundColor(Color.white.opacity(0.7))
                                .frame(width: screenWidth / 1.05 , height: 1)
                            
                        }
                    }
                }
            }
            .padding(.top, 20)
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.top, 20)
        .padding(.top, iOS15 ? 0 : 120)
        
        if OpenProfileMatchedGeometry != "" {
            if friendsDictionary.friendsDictionary[OpenProfileMatchedGeometry] != nil {
            FriendProfileHomeTabView(FriendProfileMatchedGeometry: $OpenProfileMatchedGeometry, id: OpenProfileMatchedGeometry, isFromOpenedPost: true, themeController: ThemeController())
            } else {
                StrangerProfileTabView(ProfileMatchedGeometry: $OpenProfileMatchedGeometry, person: StrangerProfileSelectedUser ?? Person(id: ""), id: OpenProfileMatchedGeometry)

            }

        }
    } .edgesIgnoringSafeArea(.bottom)
    }
}
struct CommentLikesTabView2: View {
    @Binding var LikesMatchedGeometry: String
    @StateObject var likes = CommentLikesOO(id: "", postID: "", commentID: "")
    @ObservedObject var comments : CommentsOO
    @State var comment: CommentModel
    @State var selectedTab = "likes"
    @ObservedObject var friendsDictionary: FriendsDictionary
    var body: some View {
        if selectedTab == "likes" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    CommentLikes2(LikesMatchedGeometry: $LikesMatchedGeometry, likes: likes, comments: comments, comment: comment, friendsDictionary: friendsDictionary)
                        .tag("likes")
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    LikesMatchedGeometry = ""
                }
        }
    }
}

struct CommentReplyLikes: View {
    @Namespace var namespace
    @Binding var LikesProfileMatchedGeometry: String
    @StateObject var likes = CommentReplyLikesOO(id: "", postID: "", originalCommentID: "", commentID: "")
    @Environment(\.colorScheme) var colorScheme
    @State var OpenedProfileFromCommentsMatchedGeometry: String = ""
    var body: some View {
        ZStack {
            Color.mainColorInverse
                .ignoresSafeArea(.all)
            VStack {
#if os(macOS)
                MacOsDismissButton(matchedGeometry: $LikesProfileMatchedGeometry)
                    .padding(.top,-10)
                    .padding(.leading,15)
#endif
                HStack {
                    Text("Likes")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                }
                .padding(.leading, 5)
                Spacer()
                List(likes.postLikes) { i in
                    HStack {
                        WebImage(url: i.profilePicLink)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 12) {
                            Text(i.name)
                                .font(.headline)
                            Text(i.username)
                                .font(.caption)
                                .padding(.top, -10)
                        } // VSTACK
                       .foregroundColor(Color.mainColor)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        OpenedProfileFromCommentsMatchedGeometry = i.id
                    }
                    //                    .padding(.horizontal)
                }
                
                
                Spacer()
            }
            .padding(.top, 100)
            if OpenedProfileFromCommentsMatchedGeometry != "",
               let firstIndex = likes.postLikes.firstIndex(where: { $0.id == OpenedProfileFromCommentsMatchedGeometry }){
                StrangerProfileTabView(ProfileMatchedGeometry: $OpenedProfileFromCommentsMatchedGeometry, person: likes.postLikes[firstIndex], id: OpenedProfileFromCommentsMatchedGeometry)
            }
        }
        .padding(.top, -60)
    }
}

struct CommentReplyLikesTabView: View {
    @Binding var LikesProfileMatchedGeometry: String
    @StateObject var likes = CommentReplyLikesOO(id: "", postID: "", originalCommentID: "", commentID: "")
    @State var emptyStringBinding: String = ""
    @State var selectedTab = "likes"
    var body: some View {
        if selectedTab == "likes" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    CommentReplyLikes(LikesProfileMatchedGeometry: $LikesProfileMatchedGeometry, likes: likes)
                        .tag("likes")
                    
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    LikesProfileMatchedGeometry = ""
                }
        }
    }
}
