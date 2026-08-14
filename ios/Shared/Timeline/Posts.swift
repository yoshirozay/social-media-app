//
//  TimelinePosts.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/15/21.
//

import SwiftUI
import Combine
import Firebase
import FirebaseAuth
import SDWebImageSwiftUI


/*
 so for the firebase image we do not know what the url is we need to download that and it takes time. even the image of url has been cached. so we can just set that image in the sb_setImage in a new imageView and then observe the image of the image View when we get that we can just also update our image as well
 */


struct TimelinePost: View {
    @State var id: String
    @Binding var friendProfileSelectedItem: String
    @Binding var FriendProfileMatchedGeometry: String
    @ObservedObject var friendsDictionary: FriendsDictionary
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    @State var postData: PostModel
    @Environment(\.colorScheme) var colorScheme
    @State var progressBarValue : CGFloat = 0
    @ObservedObject var myTags: MyTagsOO
    @State var isFromProfile = false
    var postDeletePublisher : PassthroughSubject<String,Never>! = nil
    @Binding var isDeletePostAlertShowing: Bool
    @Binding var deletedPost : PostModel?

    var CustomImageView : some View {
        VStack {
            HStack {
                
                let postText =  Text(postData.content)
                    .font(.title3)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
//                    .padding(.horizontal, 16)
//                   .foregroundColor(Color.mainColor)
                
                if postData.content.indicesOf(string: "@").count != 0 {
                    ZStack{
                        postText
                            .hidden()
                        TimelinePostLabel(content: postData.content,
                                          mentionedUserVM : MentionedUserVM(friendsDictionary:  timelinePosts.friendsDictionary))
                    }
                    .padding(.horizontal, 16)

                } else {
                    postText
                        .padding(.horizontal, 16)
                       .foregroundColor(Color.mainColor)
                        
                }
                Spacer()
            } // HSTACK
            
 
            if let photoURL = postData.photoLink  {
                WebImage(url: photoURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: screenWidth - 30, height: screenWidth - 30)
                    .background(Color.mainColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }else if let image = postData.tempImage {
                
                ZStack{
                    DummyPostImageView(image : image,videoURL : postData.videoUrl)
                    ///play button for video
                    
                }
            }
            
            if let videoUrl =  postData.videoUrl,
               let thumbnailUrl = postData.thumbnailUrl {
                ZStack {
                    WebImage(url: thumbnailUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenWidth - 30, height: screenWidth - 30)
                        .background(Color.mainColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .scaledToFit()
                    
                    PostVideoThumbnailView(VideoThumbnailVM : VideoThumbnailVM(videoFirebaseURL : videoUrl))
                        .disabled(true)
                }
            }
        }
    }
    var body: some View {
        ZStack {
            Color.mainColorInverse
            VStack {
                VStack {
                    HStack (spacing: 10) {
                        ZStack {
                            let width : CGFloat = 59// isiOS ?  59 : 109
                        Circle()
                                .frame(width: width, height: width)
                            .foregroundColor(friendsDictionary.friendsDictionary[id]?.profileCircle)
//                                .foregroundColor(Color.mainColor)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                            .clipShape(Circle())
                        Button(action: {
//                            if id == "" {
//                               let _ = assert(false, " what happend ")
//                            }
                            friendProfileSelectedItem = id
                            FriendProfileMatchedGeometry = "0"
                        }) {
                            ZStack {
                                let width : CGFloat = 55//isiOS ?  55 : 105
                                  WebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: width, height: width)
                                    .background(Color.mainColor.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }.buttonStyle(.borderless)
                        }
                        .disabled(isFromProfile == true ? true : false)
#if os(macOS)
        .padding(.leading,5)
#endif
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
//                                    .padding(.top, postData.tags != [""] ? 3 : 0)
                                    .padding(.top, 3.5)
                                if postData.tags != [""] {
                                    HStack (spacing: 2) {
                                        ForEach(postData.tags, id: \.self) { item in
                                            if myTags.tags[item] != nil {
                                                Text(myTags.tags[item]?.name ?? "")
                                                    .font(.caption)
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
//                    .padding(.horizontal, phoneWidth > 375 ? 16 : 10)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    CustomImageView
                    
                    if id == Auth.auth().currentUser?.uid && isFromProfile == true {
                    HStack {
                        Spacer()
                        Text("...")
                            .foregroundColor(Color.mainColor.opacity(0.6))
                            .font(.headline)
                           .fontWeight(.heavy)
                            .padding(.horizontal, 32)
//                            .matchedGeometryEffect(id: UUID(), in: namespace)
                            .onTapGesture {
                                isDeletePostAlertShowing = true
//                                deletedPostID = postData.postID
                                deletedPost = postData
                            }
                        }
                    .offset(y: -5)
                    .padding(.bottom, -10)
                    }
                    
                    if  shouldAddProgressBar {
                        progressBarView
                            .transition(.fade)
                    }
                }
               .foregroundColor(Color.mainColor)
                .padding(.vertical, 10)
                
                
                Spacer()
            }
            
        }.onAppear{
            if postData.status == .sending {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
                    withAnimation {
                    shouldAddProgressBar = true
                    }
                }
            }
        }
#if os(macOS)
        .padding(.horizontal,5)
#endif
        

    }
    
    struct DummyPostImageView : View {
        var image : UIImage
        var videoURL : URL?
        var body: some View {
            let mainWidth = screenWidth - 30
            ZStack {
                ZStack {
                    let shouldUseWidth = image.size.height < image.size.width
                    let image =  Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    if shouldUseWidth{
                        image
                            .frame(width: mainWidth )
                    }else{
                        image
                            .frame(height: mainWidth )
                    }
                }  .frame(width: mainWidth, height: mainWidth  )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                if videoURL != nil {
                    VideoPlayButtonView(size: 70) 
                }
            }
        }
    }
    
    var progressBarView : some View {
        VStack{
            ProgressView( value: progressBarValue, total: 100)
                .accentColor(Color.speakerPurple)
                .scaleEffect(y: 1.6, anchor: .center)
                .padding(.horizontal,16)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (_) in
                        withAnimation(.default) {
                            progressBarValue = 90
                        }
                    }
                }
        }
    }
    
    @State var shouldAddProgressBar : Bool = false
}

 
/*
 if a use delete post it willl always be his own. so if a user delete the post it will be
 */
//struct DeletePostSheet: View {
//    @Binding var DeletePostMatchedGeometry: String
//    var post: PostModel
//    @EnvironmentObject var timeline : TimelinePostsOO
//    @State var isDeleted = false
//    var postDeletePublisher : PassthroughSubject<String,Never>? = nil
//
//    var body: some View {
//        ZStack {
//            Color.mainColorInverse
//        VStack(spacing: 20) {
//            Text("Delete this post?")
//                .fontWeight(.bold)
//            HStack (spacing: 30) {
//                Button(action: {
//                    DeletePostFunctions.deletePost(post: post )
//                    timeline.removeDeleted(postId: post.postID)
//                    postDeletePublisher?.send(post.postID)
//                    isDeleted = true
//                }) {
//                    Text("Yes")
//                        .font(.headline)
//                        .fontWeight(.bold)
//                        .padding(.vertical)
//                        .frame(width: phoneWidth - 300)
//                        .foregroundColor(Color.mainColorInverse)
//
//
//                } .background(
//                    LinearGradient(gradient: .init(colors: [Color.speakerPurple.opacity(1), Color.speakerPink.opacity(1)]), startPoint: .leading, endPoint: .trailing)).cornerRadius(10)
//                .background(Color.white.cornerRadius(10))
//                Button(action: {
//                    DeletePostMatchedGeometry = ""
//                }) {
//                    Text("No")
//                        .font(.headline)
//                        .fontWeight(.bold)
//                        .padding(.vertical)
//                        .frame(width: phoneWidth - 300)
//                        .foregroundColor(.white)
//
//
//                } .background(
//                    LinearGradient(gradient: .init(colors: [Color.orange.opacity(1), Color.orange.opacity(1)]), startPoint: .leading, endPoint: .trailing)).cornerRadius(10)
//                .background(Color.white.cornerRadius(10))
//            }
//        } .opacity(isDeleted == true ? 0 : 1)
//        .padding()
//        }
//    }
//}
/*
 so when we delete a post first we will update thier time to latest and then we will delete it. this way even if the user is at page 5 of post and some one delete the post all online user will get notifi that post was deleted
 */

struct TimelinePostLabel: View {
    let content : String
    @StateObject var mentionedUserVM : MentionedUserVM
    var body : some View{
        GeometryReader { proxy in
            PostLabel(width: proxy.size.width, content: content) { mentionedUserVM.menionedTapped(username: $0) }
            .environmentObject(mentionedUserVM)
            .fixedSize(horizontal: false, vertical: true)
            .overlay(Color.green.opacity(0.5))
        }
    }
}
