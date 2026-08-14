//
//  PostCommentAndLikesViews.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 10/5/21.
//

import SwiftUI
import SDWebImageSwiftUI
import SDWebImage
import Firebase
import Combine


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
            FriendProfileHomeTabView(FriendProfileMatchedGeometry: $OpenProfileMatchedGeometry, id: OpenProfileMatchedGeometry, isFromOpenedPost: true)
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
