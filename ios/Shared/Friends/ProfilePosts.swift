//
//  ProfilePosts.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/16/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct ProfilePosts: View {
    @Namespace var namespace
    @State var DeletePostMatchedGeometry = ""
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @State var postData: PostModel
    @State var id: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.mainColorInverse
            VStack {
                VStack {
                    HStack (spacing: 10) {
                        
//                            ZStack {
//                              if let photoRef = friendsDictionary.friendsDictionary[id]?.photoRef {
//                                    User ProfileCacheImageView(cacheImage: CacheImage(photoRef: photoRef))
//                                        .onTapGesture {
//                                        }
//                                }
//                            }
                        WebImage(url: friendsDictionary.friendsDictionary[id]?.webLink)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 55, height: 55)
                            .background(Color.lightGray)
                            .clipShape(Circle())
                            .onTapGesture {
                            }
                        
                        HStack(alignment: .top) { // necessary to align timestamp with name
                            VStack(alignment: .leading, spacing: 2) {
                                Text(friendsDictionary.friendsDictionary[id]?.name ?? "")
                                    .fontWeight(.bold)
                                Text(friendsDictionary.friendsDictionary[id]?.username ?? "")
                                    .font(.caption)
                            } // VSTACK
                            Spacer()
                            VStack(alignment: .trailing) {
                            Text(postData.timeString)
                                .font(.caption)
                                .padding(.horizontal)
                                
                                if id == Auth.auth().currentUser!.uid {
                                Text("...")
                                    .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 1 : 0.6))
                                    .font(.headline)
                                   .fontWeight(.heavy)
                                    .padding(.horizontal)
                                    .matchedGeometryEffect(id: UUID(), in: namespace)
                                    .onTapGesture {
                                        DeletePostMatchedGeometry = "0"
                                    }
                                }
                            }
                        } // HSTACK
                        .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 1 : 0.6))
                        
                    } // HSTACK
                    .padding(.horizontal, phoneWidth > 375 ? 16 : 10)
                    .padding(.vertical, 6)
                    VStack {
                    HStack {
                        if postData.content.indicesOf(string: "@").count != 0 {
                            PostLabel(width: phoneWidth, content: postData.content)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal)
                        } else {
                            Text(postData.content)
                                .font(.title3)
                                .padding(.horizontal, 16)
                                .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 1 : 0.6))
                        }
                        Spacer()
                    }
                        if let photoRef = postData.photoRef {
                        PostCacheImageView(cacheImage: CacheImage(photoRef: photoRef))
                    }else if let photoURL = postData.photo  {
                            WebImage(url: photoURL)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: phoneWidth - 30, height: phoneWidth - 30)
                                .background(Color.lightGray)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .scaledToFit()
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
                                    .disabled(true) 
                            }
                        }
                    } // HSTACK
                }
                .foregroundColor(Color.mainColor.opacity(colorScheme == .light ? 1 : 0.6))
                .padding(.vertical, 10)
                Spacer()
            }
            if DeletePostMatchedGeometry != "" {
                DeletePostSheet(DeletePostMatchedGeometry: $DeletePostMatchedGeometry, postID: postData.postID, isThereAPhoto: postData.photo == nil ? false : true)
            }
        }
    }
}

struct DeletePostSheet: View {
    @Binding var DeletePostMatchedGeometry: String
    @State var postID: String
    @State var isThereAPhoto: Bool
    @StateObject var functions = DeletePostFunctions()
    @StateObject var timeline = TimelinePostsOO()
    @State var isDeleted = false
    var body: some View {
        ZStack {
            Color.mainColorInverse
        VStack(spacing: 20) {
            Text("Delete this post?")
                .fontWeight(.bold)
            HStack (spacing: 30) {
                Button(action: {
                    functions.deletePost(postID: postID, isThereAPhoto: isThereAPhoto)
                    timeline.deletePost(deletedPostID: postID)
                    isDeleted = true
                }) {
                    Text("Yes")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .frame(width: phoneWidth - 300)
                        .foregroundColor(Color.mainColorInverse)
                    
                    
                } .background(
                    LinearGradient(gradient: .init(colors: [Color.speakerPurple.opacity(1), Color.speakerPink.opacity(1)]), startPoint: .leading, endPoint: .trailing)).cornerRadius(10).shadow(radius: 20)
                .background(Color.white.cornerRadius(10))
                Button(action: {
                    DeletePostMatchedGeometry = ""
                }) {
                    Text("No")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .frame(width: phoneWidth - 300)
                        .foregroundColor(.white)
                    
                    
                } .background(
                    LinearGradient(gradient: .init(colors: [Color.orange.opacity(1), Color.orange.opacity(1)]), startPoint: .leading, endPoint: .trailing)).cornerRadius(10).shadow(radius: 20)
                .background(Color.white.cornerRadius(10))
            }
        } .opacity(isDeleted == true ? 0 : 1)
        .padding()
        }
    }
}
