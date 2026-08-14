//
//  TimelineMoment.swift
//  speakEZ
//
//  Created by Ahmad naeem on 4/11/22.
//


import SwiftUI
import Combine
import Firebase
import SDWebImageSwiftUI
import Shimmer
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
                    Color.speakerPurple.opacity(0.2)
                        .edgesIgnoringSafeArea(.all)
                    
                    
                    
                    
                    ZStack {
                        
                        let PostText = Text(postData.content)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        
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
                            ShimerringWebImage(url: photoURL)
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
                                ShimerringWebImage(url: thumbnailUrl)
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
                    ShimerringWebImage(url: photoURL)
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
                        ShimerringWebImage(url: thumbnailUrl)
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
                       
                       ShimerringWebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink)
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
