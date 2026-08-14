//
//  HomeOT.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//

import SwiftUI
import Combine
import Firebase
import SDWebImageSwiftUI
import Shimmer

struct TimelineRow : View {
   @State var hasBeenLiked = false
   @Binding var friendProfileSelectedItem: String
   @Binding var FriendProfileMatchedGeometry: String
   @Binding var isDeletePostAlertShowing: Bool
   @Binding var deletedPost : PostModel?
   @Binding var OpenedPhotoMatchedGeometry: String
   @Binding var OpenedPhotoSelectedItem: URL?
   @Binding var isFirstResponder: Bool
   @Binding var LongPostMatchedGeometry: String
   @Binding var showUpdatePost : PostModel?
   @StateObject var savePost = SavePostFunction()
   @StateObject var commentLikeVM : CommentLikeVM
   @ObservedObject var myTags: MyTagsOO
   @ObservedObject var mentionedUserVM : MentionedUserVM
   @ObservedObject var postVM: PostVM
   @EnvironmentObject var friendsDictionary: FriendsDictionary
   @EnvironmentObject var timelinePosts: TimelinePostsOO
   @Binding var show: Bool
   @State var isPreloadedMoment = false
    @Binding var buttonAlertType: ButtonAlertType
//    @AppStorage("likeOrComment") var likeOrCommentAlert : Bool = false
    @AppStorage("addAFriend") var addAFriendAlert : Bool = false
    @Binding var lockedMomentAlert : Bool
    @ObservedObject var themeController: ThemeController

   var id: String {
       commentLikeVM.post.id
   }
   var item: PostModel{
       commentLikeVM.post
   }
   var body: some View {

       TimelineMoment2(id: item.id,
                      friendProfileSelectedItem: $friendProfileSelectedItem,
                      FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,
                      friendsDictionary: timelinePosts.friendsDictionary,
                      myTags: myTags,
                      isDeletePostAlertShowing: $isDeletePostAlertShowing,
                      deletedPost: $deletedPost,
                      OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry,
                      OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,
                      commentLikeVM : commentLikeVM.getSelf(),
                      isFirstResponder: $isFirstResponder,
                      mentionedUserVM: mentionedUserVM,
                      LongPostMatchedGeometry: $LongPostMatchedGeometry,
                       postVM: postVM, show: $show, buttonAlertType: $buttonAlertType, lockedMomentAlert: $lockedMomentAlert, themeController: themeController) {
               ///user can only open post if it has been sent.
               guard item.status != .sending  else{
                   return
               }
           withAnimation {
               postVM.openPost(commentLikeVM: commentLikeVM)
               isFirstResponder = false
               show.toggle()
           }
//                commentLikeVM.readPost(postID: item.postID)
               //                                }
           }
       
           .onAppear {
               DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                   withAnimation {
                       if addAFriendAlert == false && buttonAlertType != .firstMoment {
                           buttonAlertType = .addAFriend
                           DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                               addAFriendAlert = true
                           }
                       }
                   }
               }
               if isPreloadedMoment != true {
                   timelinePosts.getNextPageIfNeeded(post: item)
               }
           }
           .listRowInsets(EdgeInsets(top: 0, leading: screenWidth < 376 ? 12 : 8, bottom: 5, trailing: 0))
           .overlay(
                   Color.clear
                   .contextMenu {
                       VStack {
                           if item.id == currentUserID {
                               
//                               Button("Edit") {
//                                   guard commentLikeVM.allowContextMenu else { return }
//                                   showUpdatePost = item
//                               } .font(.headline)
                             
                               Button("Delete") {
                                   guard commentLikeVM.allowContextMenu else { return }
                                   isDeletePostAlertShowing = true
                                   deletedPost = item
                               }.font(.headline)
                                      
                           }else {
                               Button("Save") {
                                   guard commentLikeVM.allowContextMenu else { return }
                                   savePost.savePost(postID: item.postID, postAuthor: item.id)
                               }.font(.headline)
                                
                           }
                            
                           commentLikeVM.post.hasSubscribed?.falseIsNil.map { _ in
                               Button("Pause Notifications") {
                                   commentLikeVM.unSubcribePost()
                               }.font(.headline)
                                .buttonStyle(.borderless)
                           }
                           
                       }
                   }.id(commentLikeVM.post.postID + String(describing: commentLikeVM.post.hasSubscribed))
           )
           .overlay(
               commentLikeVM.post.isDummy.falseIsNil.map { _ in
                   ZStack{
                       Color.red.opacity(0.0001)
                       ProgressViewPurpleCircular(color: themeController.theme.accent).scaleEffect(1)
                           .frame(width: screenWidth/4)
                           .offset(x: screenWidth/4)
//                           .rightInHStack
                   }
               })
   }
}

/*
 we need to add selectedCommentLikeVM
 */
struct TimelineMoment: View {
   @State var id: String
   @Binding var friendProfileSelectedItem: String
   @Binding var FriendProfileMatchedGeometry: String
   @ObservedObject var friendsDictionary: FriendsDictionary
//    @State var postData: PostModel
   @Environment(\.colorScheme) var colorScheme
   @State var progressBarValue : CGFloat = 0
   @ObservedObject var myTags: MyTagsOO
   @State var isFromProfile = false
   var postDeletePublisher : PassthroughSubject<String,Never>! = nil
   @Binding var isDeletePostAlertShowing: Bool
   @Binding var deletedPost : PostModel?
   @Binding var OpenedPhotoMatchedGeometry: String
   @Binding var OpenedPhotoSelectedItem: URL?
//    @ObservedObject var commentLikeVM : CommentLikeVM
   @StateObject var commentLikeVM : CommentLikeVM
   @State private var circleSize = 0.0
   @State private var circleInnerBorder = 35
   @State private var circleHue = 200
   @State var hasBeenLiked = false
//    @ObservedObject var hasBeenLikedOO: HasPostBeenLikedOO
   @StateObject var likeFunction = SendLikeFunction()
   @State var isFromOpenedPost = false
   @Binding var isFirstResponder: Bool
   @ObservedObject var mentionedUserVM : MentionedUserVM
   @Binding var LongPostMatchedGeometry: String
   @ObservedObject var postVM: PostVM
    @StateObject var themeController = ThemeController()
   var postData: PostModel {
       commentLikeVM.post
   }

   var commentCapsule: some View {
       
       ZStack {
           if commentLikeVM.uniqueCommenterIds.count < 7 && commentLikeVM.commentCount != 0 {
//        Capsule()
//            .frame(width: 34 + CGFloat((commentLikeVM.sevenUserComment.count * 26 + 3)), height: 32)
//            .foregroundColor(Color.mainColorInverse.opacity(0.6))
        LinearGradient(gradient: .init(colors: [Color.white.opacity(0.2), Color.deepPurple.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
           .frame(width:CGFloat((commentLikeVM.sevenUserComment.count * 26 + 3)), height: 30)
           .clipShape(Capsule())
           .foregroundColor(Color.white.opacity(0.2))
           .overlay (
               HStack (spacing: 1) {
//                    Image(systemName: "bubble.right")
//                        .font(.title3)
//                        .foregroundColor(commentLikeVM.hasBeenCommented ? Color.speakerPurple : .white)
//                        .padding(.leading, 3)
                   ForEach(commentLikeVM.sevenUserComment, id: \.id) { item in
                       ZStack {
                           Circle()
                               .frame(width: 25, height: 25)
                               .foregroundColor(commentLikeVM.hasBeenCommented ? Color.speakerPurple : .white)
                           WebImage(url: item.profileURL)
                               .resizable()
                               .aspectRatio(contentMode: .fill)
                               .frame(width: 23, height: 23)
                               .clipShape(Circle())
                       }
                   }
                   Spacer()
               } .padding(.leading, 8)
           )
           .padding(.leading, 3)
           } else if commentLikeVM.uniqueCommenterIds.count == 6 {
//                Capsule()
//                    .frame(width: 34 + CGFloat((commentLikeVM.sevenUserComment.count * 26 + 3)), height: 32)
//                    .foregroundColor(Color.mainColorInverse.opacity(0.6))
               LinearGradient(gradient: .init(colors: [Color.white.opacity(0.2), Color.deepPurple.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                   .frame(width:  CGFloat((commentLikeVM.sevenUserComment.count * 26 + 3)), height: 30)
                   .clipShape(Capsule())
                   .foregroundColor(Color.white.opacity(0.2))
                   .overlay (
                       HStack (spacing: 1) {
//                            Image(systemName: "bubble.right")
//                                .font(.title3)
//                                .foregroundColor(commentLikeVM.hasBeenCommented ? Color.speakerPurple : .white)
//                                .padding(.leading, 3)
                           ForEach(commentLikeVM.sevenUserComment, id: \.id) { item in
                               ZStack {
                                   Circle()
                                       .frame(width: 25, height: 25)
                                       .foregroundColor(commentLikeVM.hasBeenCommented ? Color.speakerPurple : .white)
                                   WebImage(url: item.profileURL)
                                       .resizable()
                                       .aspectRatio(contentMode: .fill)
                                       .frame(width: 23, height: 23)
                                       .clipShape(Circle())
                               }
                           }
                           Spacer()
                       } .padding(.leading, 8)
                   )
                   .padding(.leading, 3)
           } else if commentLikeVM.uniqueCommenterIds.count > 6 {
//                    Capsule()
//                    .frame(width: 60 + CGFloat((commentLikeVM.sevenUserComment.count * 26 + 3)), height: 32)
//                    .foregroundColor(Color.mainColorInverse.opacity(0.6))
               LinearGradient(gradient: .init(colors: [Color.white.opacity(0.2), Color.deepPurple.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                   .frame(width: 26 + CGFloat((commentLikeVM.sevenUserComment.count * 26 + 3)), height: 30)
                   .clipShape(Capsule())
                   .foregroundColor(Color.white.opacity(0.2))
                   .overlay (
                       HStack (spacing: 1) {
//                            Image(systemName: "bubble.right")
//                                .font(.title3)
//                                .foregroundColor(commentLikeVM.hasBeenCommented ? Color.speakerPurple : .white)
//                                .padding(.leading, 3)
                           ForEach(commentLikeVM.sevenUserComment, id: \.id) { item in
                               ZStack {
                                   Circle()
                                       .frame(width: 25, height: 25)
                                       .foregroundColor(commentLikeVM.hasBeenCommented ? Color.speakerPurple : .white)
                                   WebImage(url: item.profileURL)
                                       .resizable()
                                       .aspectRatio(contentMode: .fill)
                                       .frame(width: 23, height: 23)
                                       .clipShape(Circle())
                               }

                           }
                           ZStack {
//                                Circle()
//                                    .frame(width: 25, height: 25)
//                                    .foregroundColor(Color.mainColorInverse)
                               Circle()
                                   .frame(width: 25, height: 25)
                                   .foregroundColor(commentLikeVM.hasBeenCommented ? Color.speakerPurple.opacity(0.2) : Color.white.opacity(0.2))
                               Text("+\(commentLikeVM.uniqueCommenterIds.count - 6)")
                                   .font(.subheadline)
                                   .foregroundColor(Color.white)
                           }
                           Spacer()
                       }
                           .padding(.leading, 8)
                   )
                   .padding(.leading, 3)
               }
       }
   }

   
    var pinlock: some View {
        //                if postData.tags.isNotEmpty, postData.photoLink == nil && postData.videoUrl == nil || isFromOpenedPost {
        VStack(){
            Spacer()
            HStack(){
                Spacer()
                ZStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.mainColorInverse.opacity(0.2))
                    if postData.tags.isNotEmpty {
                        Image(systemName: "lock.fill")
                            .foregroundColor(Color.white)
                            .font(.title)
                    } else {
                        Image(systemName: "lock.open.fill")
                            .foregroundColor(Color.white)
                            .font(.title)
                    }
//                    Image("whiteLock2")
//                        .resizable()
//                        .frame(width: 35, height: 35)
//                        .opacity(0.7)
                }
                .frame(width: 80, height: 80)
                .offset(y: 20)
                .onTapGesture {
                    let tags = (postData.tags != [""] && postData.tags.isNotEmpty) ?  postData.tags : ["0"]
                    postTap(tags: tags)
                }
                .padding(.bottom,10)
                .padding(.leading, 10)
                
                //                                .padding(.top,200)//155
                //                                .padding(.trailing,screenWidth/2.4 )
                //                    .overlay(Color.green.opacity(0.5))
                Spacer()
            } .padding(.leading,50)
            
            
        }
        .frame(width: screenWidth, height: 250)
        //                .overlay(Color.green.opacity(0.5))
        //            }
    }
    
    var onTap : (()->())?
    var body: some View {
        if let onTap = onTap{
            ZStack{
                mainBody
                    .onTapGesture(perform: onTap)
                pinlock
            }
        }else{
            ZStack{
                mainBody
                pinlock
            }
        }
    }
    
    func postTap(isFirstResponder : Bool? = false,tags : [String] = []){
        if tags.isEmpty {
            postVM.openPost(commentLikeVM: commentLikeVM)
        }else{
            postVM.openPost(commentLikeVM: commentLikeVM, withTags: tags)
        }
        if let isFirstResponder = isFirstResponder{
            self.isFirstResponder = isFirstResponder
        }
    }
    
    var postView : some View {
        
        ZStack  {
            if postData.mediaKind == nil  || (isFromOpenedPost && postData.content != "") {
                
                ZStack  {
                    //                       Color.mainColorInverse
                    //                       (postData.hasBeenRead ? Color.speakerBlue.opacity(0.13) :
                    //                           Color.speakerPurple.opacity(0.2))
//                    themeController.theme.secondary
                    Color.softWhite
                        .edgesIgnoringSafeArea(.all)
                    
                    
                    
                    
                    ZStack {
                        
                        let PostText = Text(postData.content)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.black)
                            .frame(width: screenWidth/2 - 25, height: 150)
                            .padding(.leading, 5)
                        if postData.content.indicesOf(string: "@").count != 0 {
                            PostText
                                .hidden()
                                .overlay(
                                    GeometryReader { proxy in
                                        PostLabel2(width: proxy.size.width/2 - 25, content: postData.content){
                                            name in mentionedUserVM.menionedTapped(username: name)
                                            print(" mentionedUserVM ")
                                        }
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(height: 150)
                                        .padding(.leading, 5)
                                    }
                                )
                            
                        } else {
                            PostText
                        }
                        if isFromOpenedPost  {
                            Color.mainColorInverse.opacity(0.001)
                                .onTapGesture {
                                    LongPostMatchedGeometry = "0"
                                }
                        }
                        if let photoURL = postData.photoLink  {
                            ShimerringWebImage(url: photoURL, themeController: themeController)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 65, height: 65)
                                .clipped()
                            //                                   .background(Color.lightGray)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .offset(x: screenWidth/6, y: 95)
                            //                                .scaledToFit()
                                .onTapGesture {
                                    OpenedPhotoMatchedGeometry = "0"
                                    OpenedPhotoSelectedItem = photoURL                            }
                        }
                        if let videoUrl =  postData.videoUrl,
                           let thumbnailUrl = postData.thumbnailUrl {
                            ZStack {
                                ShimerringWebImage(url: thumbnailUrl, themeController: themeController)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 65, height: 65)
                                    .clipped()
                                //                                       .background(Color.lightGray)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .offset(x: screenWidth/6, y: 95)
                                //                                    .scaledToFit()
                                //                                Image(systemName: "play")
                                //                                    .offset(x: screenWidth/6, y: 95)
                                
                                PostVideoThumbnailView(VideoThumbnailVM : VideoThumbnailVM(videoFirebaseURL : videoUrl), buttonSize: 20)
                                    .offset(x: screenWidth/6, y: 95)
                            }
                        }
                        if let audioUrl = postData.audioUrl {
                            CacheAudioPlayer(audioUrl: audioUrl,
                                             isDummy: postData.isDummy,
                                             width: 65,
                                             height: 65,
                                             color: .white,
                                             backgroundColor: Color.mainColorInverse.opacity(0.2),
                                             isFromTimelineMoment: true,
                                             direction: .right)
                            .clipped()
                            .offset(x: screenWidth/6 - 5, y: 90)
                        }
                        //                        }
                    }
                    
                    
                    
                }
                .frame(width: screenWidth/2 - 0, height: 250)
            } else {
                if let photoURL = postData.photoLink  {
                    ShimerringWebImage(url: photoURL, themeController: themeController)
                    //                           .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: screenWidth/2 - 0, height: 250)
                        .clipped()
                    //                           .background(Color.lightGray)
                    //                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    //                            .offset(x: screenWidth/6, y: 95)
                    //                                .scaledToFit()
                        .onTapGesture {
                            if isFromOpenedPost {
                                OpenedPhotoMatchedGeometry = "0"
                                OpenedPhotoSelectedItem = photoURL
                            } else {
                                postTap()
                            }
                        }
                    
                }
                if let videoUrl =  postData.videoUrl,
                   let thumbnailUrl = postData.thumbnailUrl {
                    ZStack {
                        ShimerringWebImage(url: thumbnailUrl, themeController: themeController)
                        //                               .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: screenWidth/2 - 0, height: 250)
                            .clipped()
                        //                               .background(Color.lightGray)
                            .onTapGesture {
                                //                                OpenedPhotoMatchedGeometry = "0"
                                //                                OpenedPhotoSelectedItem = photoURL
                                postTap()
                            }
                        //                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        //                                .offset(x: screenWidth/6, y: 95)
                        //                                    .scaledToFit()
                        //                                                            Image(systemName: "play")
                        //                                                                .offset(x: screenWidth/6, y: 95)
                        PostVideoThumbnailView(VideoThumbnailVM : VideoThumbnailVM(videoFirebaseURL : videoUrl), buttonSize: 50)
                        //                                .offset(x: screenWidth/6, y: 95)
                    }
                }
                if let audioUrl = postData.audioUrl {
                    ZStack {
                        Color.speakerPurple.opacity(0.2)
                            .edgesIgnoringSafeArea(.all)
                        CacheAudioPlayer(audioUrl: audioUrl,
                                         isDummy: postData.isDummy,
                                         width: 120,
                                         height: 120,
                                         color: Color.white,
                                         isFromTimelineMoment: true,
                                         direction: .right)
                    }
                    .frame(width: screenWidth/2 - 0, height: 250)
                    .clipped()
                    .onTapGesture {
                        postTap()
                    }
                }
            }
                
            commentLikeVM.isUpdating.falseIsNil.map { _ in
                ZStack{
                    Color.red.opacity(0.0001)
                    ProgressViewPurpleCircular().scaleEffect(3)
                }
            }
        }
    }
    
    var mainBody: some View {
        ZStack (alignment: .bottom) {
           HStack {
               ZStack (alignment: .bottomLeading) {
                   ZStack (alignment: .trailing) {
                       
                       ShimerringWebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink, themeController: themeController)
//                           .resizable()
                           .aspectRatio(contentMode: .fill)
                           .frame(width: screenWidth/2 - 0, height: 250)
                           .clipped()
                           .onTapGesture {
                               if isFromOpenedPost {
                                   if isFromProfile != true {
                               friendProfileSelectedItem = id
                               FriendProfileMatchedGeometry = id
                                   hideKeyboard()
                                   }
                               } else {
                                   postTap()
                               }
                           }
                       
                       VStack(spacing: 10) {
                           VStack (spacing: 0) {
                               ZStack {
                                   VStack {
                               Image(systemName: "heart")
                                   .font(.largeTitle)
                               Text("\(commentLikeVM.likesCount)")
                                   .font(.caption)
                                   .fontWeight(.bold)
                                   }
   //                                .foregroundColor(hasBeenLikedOO.hasBeenLiked || hasBeenLiked ? .speakerPink : .white)

                                   .foregroundColor( commentLikeVM.hasBeenLiked || hasBeenLiked ? .speakerPurple : .white)
                                       .onTapGesture {
                                           likePost()
                                           circleSize = 1.3
                                           circleInnerBorder = 0
                                           circleHue = 300
                                   }
                                   Circle()
                                       .strokeBorder(lineWidth:  CGFloat(circleInnerBorder))
                                       .animation(Animation.easeInOut(duration: 0.5).delay(0.1))
                                       .frame(width: 24, height: 24, alignment: .center)
                                       .foregroundColor(Color(.systemPink))
                                       .hueRotation(Angle(degrees: Double(circleHue)))
                                       .scaleEffect(CGFloat(circleSize))
                                       .animation(Animation.easeInOut(duration: 0.5))
                                       .offset(y: -10)
                               }
                           }
                           VStack(spacing: 0) {
                               Image(systemName: "bubble.middle.bottom")
                                   .font(.title)
                               Text("\(commentLikeVM.commentCount)")
                                   .font(.caption)
                                   .fontWeight(.bold)
                           }.foregroundColor(commentLikeVM.hasBeenCommented ? Color.speakerPurple : .white)
                           .onTapGesture {
                               postTap(isFirstResponder: nil)
                           }
                       }
                       .background(Color.white.opacity(0.2))
                       .foregroundColor(Color.white)
                       .padding(.bottom, -50)
                   }
                   (!isFromOpenedPost).falseIsNil.map { _ in
                     commentCapsule
                  }
               }
            
             postView

       }
       .frame(width: screenWidth, height: 250)
       .clipShape(RoundedRectangle(cornerRadius: 0))
            if isFromOpenedPost != true {
            Rectangle()
                    .foregroundColor(colorScheme == .light ? Color.plumWeb : Color.speakerPurple.opacity(0.4))

                .frame(width: screenWidth, height: 2)
                .offset(y: 5)
            }

    }
   }

   func likePost(){

       guard let userId = Auth.auth().currentUser?.uid else{ return }

       if commentLikeVM.hasBeenLiked == false {
           if id != "ctgg158KOnajMBuFZ5GyHLyRYPE3" {
               likeFunction.sendLike(sentBy: userId, postID: postData.postID, otherUserID: id, token: friendsDictionary.friendsDictionary[id]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "")
           }
       }
       hasBeenLiked = true
       circleSize = 1.3
       circleInnerBorder = 0
       circleHue = 300
#if os(iOS)
       let impactLight = UIImpactFeedbackGenerator(style: .soft)
                       impactLight.impactOccurred()
#endif
   }
}

struct TimelineMoment2: View { // on timeline
    @State var isShowingLongPost = false
    @State var id: String
    @Binding var friendProfileSelectedItem: String
    @Binding var FriendProfileMatchedGeometry: String
    @ObservedObject var friendsDictionary: FriendsDictionary
 //    @State var postData: PostModel
    @Environment(\.colorScheme) var colorScheme
    @State var progressBarValue : CGFloat = 0
    @ObservedObject var myTags: MyTagsOO
    @State var isFromProfile = false
    var postDeletePublisher : PassthroughSubject<String,Never>! = nil
    @Binding var isDeletePostAlertShowing: Bool
    @Binding var deletedPost : PostModel?
    @Binding var OpenedPhotoMatchedGeometry: String
    @Binding var OpenedPhotoSelectedItem: URL?
 //    @ObservedObject var commentLikeVM : CommentLikeVM
    @StateObject var commentLikeVM : CommentLikeVM

 //    @ObservedObject var hasBeenLikedOO: HasPostBeenLikedOO
    @State var isFromOpenedPost = false
    @Binding var isFirstResponder: Bool
    @ObservedObject var mentionedUserVM : MentionedUserVM
    @Binding var LongPostMatchedGeometry: String
    @ObservedObject var postVM: PostVM
    @Binding var show: Bool
    @Binding var buttonAlertType: ButtonAlertType
    @Binding var lockedMomentAlert : Bool
    @ObservedObject var themeController: ThemeController

    var postData: PostModel {
        commentLikeVM.post
    }
    var onTap : (()->())?
    
    var body: some View {
        ZStack (alignment: .leading) {
//            Color.backgroundColor
            themeController.theme.primary
            HStack {
                ZStack (alignment: .bottomTrailing) {
                    ZStack (alignment: .leading) {
                    themeController.theme.secondary
                        
                        ZStack (alignment: .bottomTrailing) {
                            HStack {
                                ShimerringWebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink, themeController: themeController)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 142, height: 169)
                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                                    .rotation3DEffect(.degrees(3), axis: (x: 0, y: 1, z: 0))
                                    .padding(.leading, 10)
                                    .shadow(color: .black.opacity(0.16), radius: 6, x: 0, y: 3)
                                
                                Spacer()
                                
                                if postData.content.isNotEmpty {
                                    let PostText =
                                    Text(postData.content)
                                        .font(.headline.weight(.regular))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Color.black)
                                        .offset(x: -2)
                                        .lineLimit(6)
                                        .offset(y: postData.content.count > 130 && (postData.photoLink != nil || postData.thumbnailUrl != nil || postData.audioUrl != nil) ? -20 : 0)
                                    
                                    if postData.content.indicesOf(string: "@").count != 0 || postData.content.contains("https://"){
                                        PostText
                                            .hidden()
                                            .overlay(
                                                GeometryReader { proxy in
//                                                    PostLabel3(width: screenWidth/2.2, content: postData.content, isFromOpenedPost: false){
//                                                        name in mentionedUserVM.menionedTapped(username: name)
//                                                        print(" mentionedUserVM ")
//                                                    }
                                                    PostLabel3(width: screenWidth/2.2, content: postData.content, isFromOpenedPost: false, tappedMention: {
                                                        name in mentionedUserVM.menionedTapped(username: name)
                                                        print(" mentionedUserVM ")
                                                    }, tappedLink: {link in
                                                        print("LINKKK")
                                                    })
  
                                                }
                                            )
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(Color.black)
                                            .offset(x: -2)
                                            .lineLimit(6)
                                            .offset(y: postData.content.count > 130 && (postData.photoLink != nil || postData.thumbnailUrl != nil || postData.audioUrl != nil) ? -20 : 0)
                                        
                                    } else {
                                        PostText
                                    }
                                } else {
                                    if let photoURL = postData.photoLink  {
                                        ZStack(alignment: .topTrailing) {
                                            ShimerringWebImage(url: photoURL, themeController: themeController)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 174, height: 205)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerSize: CGSize(width: 22, height: 22))
                                                        .stroke(Color.mainColorInverse, lineWidth: 3)
                                                )
                                            
                                            Image(systemName: "sparkles")
                                                .foregroundColor(themeController.theme.accent)
                                                .font(.title3)
                                                .offset(y: -5)
                                        }
                                        .onTapGesture {
                                            withAnimation(.linear(duration: 0.2)) {
                                                OpenedPhotoMatchedGeometry = "0"
                                                OpenedPhotoSelectedItem = photoURL
                                            }
                                        }
                                    }
                                    if let videoUrl =  postData.videoUrl,
                                       let thumbnailUrl = postData.thumbnailUrl   {
                                        ZStack(alignment: .topTrailing) {
                                            ShimerringWebImage(url: thumbnailUrl, themeController: themeController)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 174, height: 205)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerSize: CGSize(width: 22, height: 22))
                                                        .stroke(Color.mainColorInverse, lineWidth: 3)
                                                )
                                            
                                            Image(systemName: "sparkles")
                                                .foregroundColor(themeController.theme.accent)
                                                .font(.title3)
                                                .offset(y: -5)
                                            PostVideoThumbnailView(VideoThumbnailVM : VideoThumbnailVM(videoFirebaseURL : videoUrl), buttonSize: 40)
                                        }
                                    }
                                    if let audioUrl = postData.audioUrl {
                                        ZStack(alignment: .topTrailing) {
                                            ZStack {
                                                themeController.theme.primary
                                                    .edgesIgnoringSafeArea(.all)
                                                CacheAudioPlayer(audioUrl: audioUrl,
                                                                 isDummy: postData.isDummy,
                                                                 width: 120,
                                                                 height: 150,
                                                                 color: Color.white,
                                                                 isFromTimelineMoment: true,
                                                                 direction: .right)
                                                .offset(y: 15)
                                            }
                                            .frame(width: 174, height: 205)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .overlay(
                                                RoundedRectangle(cornerSize: CGSize(width: 22, height: 22))
                                                    .stroke(Color.mainColorInverse, lineWidth: 3)
                                            )
                                        }
                                    }
                                }
                                Spacer()
                                
                            }
                            .frame(height: 169)
                        }
                    }
                    .frame(width: screenWidth/1.1662, height: postData.content.isNotEmpty ? 190 : 230)
                    .cornerRadius(23)
                    .padding(.leading, 6)
                    if postData.content.isNotEmpty {
                    if let photoURL = postData.photoLink  {
                        ZStack {
                            ShimerringWebImage(url: photoURL, themeController: themeController)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 55, height: 59.5)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .overlay(
                                    RoundedRectangle(cornerSize: CGSize(width: 6, height: 6))
                                        .stroke(Color.mainColorInverse, lineWidth: 0.5)
                                )
                            
                            RoundedRectangle(cornerSize: CGSize(width: 6, height: 6))
                                .frame(width: 55, height: 59.5)
                                .foregroundColor(Color.black.opacity(0.2))
                        }
                        .offset(x: -16, y: 20)
                        .onTapGesture {
                            withAnimation(.linear(duration: 0.2)) {
                                OpenedPhotoMatchedGeometry = "0"
                                OpenedPhotoSelectedItem = photoURL
                            }
                        }
                    }
                    if let videoUrl =  postData.videoUrl,
                       let thumbnailUrl = postData.thumbnailUrl   {
                        ZStack {
                            ShimerringWebImage(url: thumbnailUrl, themeController: themeController)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 55, height: 59.5)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .overlay(
                                    RoundedRectangle(cornerSize: CGSize(width: 6, height: 6))
                                        .stroke(Color.mainColorInverse, lineWidth: 0.5)
                                )
                            
                            RoundedRectangle(cornerSize: CGSize(width: 6, height: 6))
                                .frame(width: 55, height: 59.5)
                                .foregroundColor(Color.black.opacity(0.2))
                            PostVideoThumbnailView(VideoThumbnailVM : VideoThumbnailVM(videoFirebaseURL : videoUrl), buttonSize: 20)
                        }
                        
                        .offset(x: -16, y: 20)
                    }
                        if let audioUrl = postData.audioUrl {
                            ZStack {
                                themeController.theme.primary
                                    .edgesIgnoringSafeArea(.all)
                                CacheAudioPlayer(audioUrl: audioUrl,
                                                 isDummy: postData.isDummy,
                                                 width: 50,
                                                 height: 54,
                                                 color: Color.white,
                                                 isFromTimelineMoment: true,
                                                 direction: .right)
                            }
                            .frame(width: 55, height: 59.5)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .overlay(
                                RoundedRectangle(cornerSize: CGSize(width: 6, height: 6))
                                    .stroke(Color.mainColorInverse, lineWidth: 0.5)
                            )
                            .offset(x: -16, y: 20)
                        }
                }
                }

                MomentVerticalControls(postData: postData, commentLikeVM: commentLikeVM, postVM: postVM, show: $show, isFirstResponder: $isFirstResponder, authorID: id, friendsDictionary: friendsDictionary, buttonAlertType: $buttonAlertType, lockedMomentAlert: $lockedMomentAlert, themeController: themeController)
            }

        }
        .frame(height: 240)
        .onTapGesture {
            if let onTap = onTap {
                onTap()
            }
        }
    }
    func postTap(isFirstResponder : Bool? = false,tags : [String] = []){
        if tags.isEmpty {
            postVM.openPost(commentLikeVM: commentLikeVM)
        }else{
            postVM.openPost(commentLikeVM: commentLikeVM, withTags: tags)
        }
        if let isFirstResponder = isFirstResponder{
            self.isFirstResponder = isFirstResponder
        }
    }

}

struct MomentVerticalControls: View {
    var postData: PostModel
    @ObservedObject var commentLikeVM : CommentLikeVM
    @ObservedObject var postVM: PostVM
    @State var hasBeenLiked = false
    @Binding var show: Bool
    @Binding var isFirstResponder: Bool
    @State private var circleSize = 0.0
    @State private var circleInnerBorder = 35
    @State private var circleHue = 200
    @State var authorID: String
    @StateObject var likeFunction = SendLikeFunction()
    @ObservedObject var friendsDictionary: FriendsDictionary
    @Binding var buttonAlertType: ButtonAlertType
    @Binding var lockedMomentAlert : Bool
    @ObservedObject var themeController: ThemeController
    @State var isLoading = true
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .foregroundColor(themeController.theme.secondary)
                    .frame(width: 40, height: 40)
                if postData.tags.isNotEmpty {
                    Image(systemName: "lock.fill")
                        .foregroundColor(Color.white)
                        .font(.title2)
                } else {
                    Image(systemName: "lock.open.fill")
                        .foregroundColor(Color.white)
                        .font(.title2)
                }
                
            }
            .onTapGesture {
                if lockedMomentAlert == false {
                    withAnimation() {
                        buttonAlertType = .lockedMoment
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            lockedMomentAlert = true
                        }
                    }
                } else {
                    let tags = (postData.tags != [""] && postData.tags.isNotEmpty) ?  postData.tags : ["0"]
                    postTap(tags: tags)
                }
            }
            ZStack {
                ZStack {
                    Circle()
                        .foregroundColor(themeController.theme.secondary)
                        .frame(width: 40, height: 40)
                    ZStack {
                        Image(systemName: "heart")
                            .font(.title2)
                            .foregroundColor( commentLikeVM.hasBeenLiked || hasBeenLiked ? themeController.theme.accent : .white)
                        Circle()
                            .strokeBorder(lineWidth:  CGFloat(circleInnerBorder))
                            .animation(Animation.easeInOut(duration: 0.5).delay(0.1))
                            .frame(width: 26, height: 26, alignment: .center)
                            .foregroundColor(Color(.systemPink))
                            .hueRotation(Angle(degrees: Double(circleHue)))
                            .scaleEffect(CGFloat(circleSize))
                            .animation(Animation.easeInOut(duration: 0.5))
                    }
                }
                Text("\(commentLikeVM.likesCount)")
                    .font(.caption2)
                    .foregroundColor( commentLikeVM.hasBeenLiked || hasBeenLiked ? themeController.theme.accent : .white)
            }
//            .opacity(isLoading ? 0 : 1)
            .onTapGesture {
                likePost()
            }
            ZStack {
                ZStack {
                    Circle()
                        .foregroundColor(themeController.theme.secondary)
                        .frame(width: 40, height: 40)
                    Image(systemName: "bubble.middle.bottom")
                        .font(.title2)
                        .foregroundColor(commentLikeVM.hasBeenCommented ? themeController.theme.accent : .white)
                        .offset(y: 2)
                    
                }
                Text("\(commentLikeVM.commentCount)")
                    .font(.caption2)
                    .foregroundColor(commentLikeVM.hasBeenCommented ? themeController.theme.accent : .white)
            }
//            .opacity(isLoading ? 0 : 1)
            .onTapGesture {
                postTap()
            }
        }
        .offset(x: -3)
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                withAnimation() {
//                    isLoading = false
//                }
//            }
//        }
    }
    func postTap(tags : [String] = []){
        if tags.isEmpty {
            postVM.openPost(commentLikeVM: commentLikeVM)
            withAnimation {
                show = true
                isFirstResponder = true
            }
        }else{
            postVM.openPost(commentLikeVM: commentLikeVM, withTags: tags)
            withAnimation {
                show = true
                isFirstResponder = false
            }
        }
    }
    func likePost(){

        guard let userId = Auth.auth().currentUser?.uid else{ return }

        if commentLikeVM.hasBeenLiked == false {
            if authorID != TristanUserID {
                likeFunction.sendLike(sentBy: userId, postID: postData.postID, otherUserID: authorID, token: friendsDictionary.friendsDictionary[authorID]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "")
            }
            hasBeenLiked = true
            circleSize = 1.3
            circleInnerBorder = 0
            circleHue = 300
#if os(iOS)
            let impactLight = UIImpactFeedbackGenerator(style: .soft)
            impactLight.impactOccurred()
#endif
        }
    }
}

struct TimelineMoment3: View { // openedMoment
    @State var isShowingLongPost = false
    @State var id: String
    @Binding var friendProfileSelectedItem: String
    @Binding var FriendProfileMatchedGeometry: String
    @ObservedObject var friendsDictionary: FriendsDictionary
    @Environment(\.colorScheme) var colorSchem
    @ObservedObject var myTags: MyTagsOO
    @State var isFromProfile = false
    var postDeletePublisher : PassthroughSubject<String,Never>! = nil
    @Binding var isDeletePostAlertShowing: Bool
    @Binding var deletedPost : PostModel?
    @Binding var OpenedPhotoMatchedGeometry: String
    @Binding var OpenedPhotoSelectedItem: URL?
    @StateObject var commentLikeVM : CommentLikeVM
    @State private var circleSize = 0.0
    @State private var circleInnerBorder = 35
    @State private var circleHue = 200
    @State var hasBeenLiked = false
    @StateObject var likeFunction = SendLikeFunction()
    @State var isFromOpenedPost = false
    @Binding var isFirstResponder: Bool
    @ObservedObject var mentionedUserVM : MentionedUserVM
    @Binding var LongPostMatchedGeometry: String
    @ObservedObject var postVM: PostVM
    @Binding var show: Bool
    @Binding var MomentLockNavigation: String
    @Binding var buttonAlertType: ButtonAlertType
    @Binding var lockedMomentAlert : Bool
    @ObservedObject var themeController: ThemeController
    @State var postLink:  URL?
    var postData: PostModel {
        commentLikeVM.post
    }
    var hasMedia: Bool {
        momentHasMedia()
    }
    func momentHasMedia() -> Bool{
        if postData.photoLink != nil || postData.thumbnailUrl != nil {
                 return true
              } else {
                return false
              }
    }
    var onTap : (()->())?
    
    var body: some View {
            HStack (alignment: .top, spacing: 0) {

                ZStack (alignment: .bottomTrailing) {
                    ZStack (alignment: .topLeading) {
                        HStack (spacing: 0) {
                            Button(action: {
                                withAnimation {
                                    postVM.dismissOpenedPost()
                                    show.toggle()
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .padding(.leading, 8)
                                    .foregroundColor(Color.black)
                                    .font(.body.weight(.bold))
                            }
                            .offset(y: 5)
                            VStack (alignment: .leading, spacing: 5){
                                HStack (spacing: 5) {
                                    ShimerringWebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink, themeController: themeController)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 35, height: 35)
                                        .clipShape(Circle())
                                    Text(friendsDictionary.friendsDictionary[id]?.name ?? "")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                    Text(postData.timeString)
                                        .font(.caption2)
                                        .foregroundColor(Color.black.opacity(0.3))
                                        .offset(y: 1)
                                }
                                HStack {
                                    let PostText =
                                    Text(postData.content)
                                        .font(.subheadline.weight(.light))
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.black)
                                        .lineLimit(isShowingLongPost ? 13 : 4)
                                        .fixedSize(horizontal: false, vertical: true)
                                    if postData.content.indicesOf(string: "@").count != 0 || postData.content.contains("https://") {
                                        if isShowingLongPost {
                                            PostLabel3(width: screenWidth/1.4, content: postData.content, isFromLongPost: isShowingLongPost, isFromOpenedPost: true, tappedMention: {
                                                name in mentionedUserVM.menionedTapped(username: name)
//                                                print(" mentionedUserVM ")
                                                print("name = \(name)")
                                                print("hello 1")
                                            }, tappedLink: { link in
//                                                print(" mentionedUserVM ")
                                                postLink = link
                                                print("LINKKK ")
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    postLink = nil
                                                }
                                            })
//                                            {
//                                                name in mentionedUserVM.menionedTapped(username: name)
//                                                print(" mentionedUserVM ")
//                                            }
                                            .fixedSize()
                                        } else {
//                                            PostLabel3(width: screenWidth/1.4, content: postData.content, isFromLongPost: isShowingLongPost, isFromOpenedPost: true){
//                                                name in mentionedUserVM.menionedTapped(username: name)
//                                                print(" mentionedUserVM ")
//                                            }
                                            PostLabel3(width: screenWidth/1.4, content: postData.content, isFromLongPost: isShowingLongPost, isFromOpenedPost: true, tappedMention: {
                                                name in mentionedUserVM.menionedTapped(username: name)
                                                print(" mentionedUserVM ")
                                            }, tappedLink: {link in
//                                                print(" mentionedUserVM ")
                                            postLink = link
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    postLink = nil
                                                }
                                            print("LINKKK ")
                                            })
                                            .fixedSize()
                                        }
                                    } else {
                                        PostText
                                    }
                                }
                                
                            }
                            .padding(10)
                            .frame(width: screenWidth/1.293, alignment: .leading)
                            .padding(.top, -5)
                            .background(themeController.theme.secondary)
                            .clipShape(ChatBubbleShape(direction: .left))
                        }
                }
                    if postData.content.count > 180 {
                        Button(action: {
                            withAnimation {
                                isShowingLongPost.toggle()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(themeController.theme.primary)
                                Circle()
                                    .frame(width: 18, height: 18)
                                    .foregroundColor(themeController.theme.secondary)
                                Image(systemName: isShowingLongPost ? "chevron.up" : "chevron.down")
                                    .foregroundColor(Color.white)
                                    .font(.caption)
                            }
                            .contentShape(Circle())
                        }
       
                    .offset(x: -3, y: 10)
                    }
                    
                }
                
                Spacer()
                VStack {
                    if let photoURL = postData.photoLink  {
                        ShimerringWebImage(url: photoURL, themeController: themeController)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 65)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onTapGesture {
                                withAnimation(.linear(duration: 0.2)) {
                                    OpenedPhotoMatchedGeometry = "0"
                                    OpenedPhotoSelectedItem = photoURL
                                }
                            }
                    }
                    if let videoUrl =  postData.videoUrl,
                       let thumbnailUrl = postData.thumbnailUrl   {
                        ZStack {
                            ShimerringWebImage(url: thumbnailUrl, themeController: themeController)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 65)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            PostVideoThumbnailView(VideoThumbnailVM : VideoThumbnailVM(videoFirebaseURL : videoUrl), buttonSize: 20)
                        }
                    }
                    if let audioUrl = postData.audioUrl {
                        ZStack {
                            themeController.theme.secondary
                                .edgesIgnoringSafeArea(.all)
                            CacheAudioPlayer(audioUrl: audioUrl,
                                             isDummy: postData.isDummy,
                                             width: 50,
                                             height: 54,
                                             color: Color.white,
                                             isFromTimelineMoment: true,
                                             direction: .right)
                        }
                        .frame(width: 60, height: 65)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    ZStack {
                        Circle()
                            .foregroundColor(themeController.theme.secondary)
                            .frame(width: 40, height: 40)
                        if postData.tags.isNotEmpty {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Color.white)
                                .font(.title2)
                        } else {
                            Image(systemName: "lock.open.fill")
                                .foregroundColor(Color.white)
                                .font(.title2)
                        }
                            
                    }
                    .onTapGesture {
                        withAnimation {
                            if lockedMomentAlert == false {
                                    buttonAlertType = .lockedMoment
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        lockedMomentAlert = true
                                    }
                            } else {
                                MomentLockNavigation = "0"
                            }
                        }
                    }
                }
                .padding(.trailing, 8)
                .padding(.top, 8)
        }
        .padding(.top, 40)
        .background(themeController.theme.primary)
        .overlay (
            ZStack {
                if postLink != nil {
                    EmptyView()
                    .onAppear {
                        UIApplication.shared.open((postLink ?? URL(string:"www.google.com"))!, options: [:], completionHandler: nil)
                    }
                    .onDisappear {
                        postLink = nil
                        print("HELLO 2")
                    }
                }
            }
        )
    }
    func postTap(isFirstResponder : Bool? = false,tags : [String] = []){
        if tags.isEmpty {
            postVM.openPost(commentLikeVM: commentLikeVM)
        }else{
            postVM.openPost(commentLikeVM: commentLikeVM, withTags: tags)
        }
        if let isFirstResponder = isFirstResponder{
            self.isFirstResponder = isFirstResponder
        }
    }
    func likePost(){

        guard let userId = Auth.auth().currentUser?.uid else{ return }

        if commentLikeVM.hasBeenLiked == false {
            if id != TristanUserID {
                likeFunction.sendLike(sentBy: userId, postID: postData.postID, otherUserID: id, token: friendsDictionary.friendsDictionary[id]?.token ?? "", nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "")
            }
            hasBeenLiked = true
            circleSize = 1.3
            circleInnerBorder = 0
            circleHue = 300
#if os(iOS)
            let impactLight = UIImpactFeedbackGenerator(style: .soft)
            impactLight.impactOccurred()
#endif
        }
        }
}
