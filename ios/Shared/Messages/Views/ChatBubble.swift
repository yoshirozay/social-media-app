//
//  ChatBubble.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 5/15/21.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import FirebaseStorage
import Combine


struct ChatBubble: View {
    let message : MessageModel
    @State var myMessage: String
    @State var isTimeStampShowing = false
    @Binding var OpenedPhotoSelectedItem: URL?
    @Binding var OpenedPhotoMatchedGeometry: String
    @Binding var OpenedGIFMatchedGeometry: String
//    @ObservedObject var OpenedPhot oRef: StorageReferenceOO
    @State var hasMessageBeenLiked = false
    @State var doubleTap = [Int]()
    @StateObject var functions = LikeMessageFunction()
    let person : Person
    @State var chatUID: String
     
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @Environment(\.colorScheme) var colorScheme 
    @State var messageLink:  URL?
      ///sent message
    var senderWeblink : URL?? = nil
    var isAGroupMessage : Bool = false
    @ObservedObject var themeController: ThemeController
    var rightBubble: some View {
        // Pushing message to the right
        // Minimum space
         ZStack (alignment: .bottomTrailing) {
            VStack {
                if message.message.isNotEmpty {
                    let showProgresser = (message.status == .sending && message.tempImage == nil)
                    let progresser =   ZStack{
//                           if showProgresser{
//                               ProgressView()
//                                   .progressViewStyle(CircularProgressViewStyle(tint: Color.speakerPurple))
////                                   .scaleEffect(1)
//                                .frame(width : 15,alignment: .center)
//                                   .padding(.trailing,10)
//                           }
                       }
                    
                    HStack (spacing: 20) {
                        Spacer(minLength: showProgresser ? 0 : 25)
                        ZStack (alignment: .trailing) {
                            
                            HStack(spacing: 0){
                                progresser
                                if message.isGIF == true {
                                    AnimatedImage(url: URL(string: message.message))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 177.5, height: 200)
                                        .clipShape(ChatBubbleShape(direction: .right))
//                                        .onCustomTapGesture(count : 2, perform: doubleTapped)
                                        .onCustomTapGesture {
                                            OpenedGIFMatchedGeometry = message.message
                                            hideKeyboard()
                                        }
                                     
                                } else {
                                    ZStack {
//                                        let messageText =
//                                        Text(message.message)
                              
                                        if message.message.contains("https://") {
                                            MessageLabel(content: message.message, tappedMention: {_ in
                                                print("MENTION")
                                                //                                            mentionedUserVM.menionedTapped(username: $0)
                                            }, tappedLink: { link in
                                                messageLink = link
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    messageLink = nil
                                                }
                                                print("LINKKK ")
                                            })
                                            .fixedSize(horizontal: true, vertical: true)
                                        } else {
//                                            messageText
                                            Text(message.message)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 10)
                                    .background(themeController.theme.primary)
                                    .foregroundColor(.black)
                                    .clipShape(ChatBubbleShape(direction: .right))
                                    .opacity(isTimeStampShowing == true ? 0 : 1)
//                                    .onCustomTapGesture {
//                                        doubleTap.append(0)
//                                        if doubleTap.count == 2 {
//                                            hasMessageBeenLiked = true
//                                            if message.hasBeenLiked == false {
//                                                guard let userId = currentUserID else{ return }
//                                                functions.sendLike(sentBy: userId, messageID: message.id, otherUserID: person.id, chatUID: chatUID, token: "", nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "")
//                                            }
//                                            doubleTap.removeAll()
//                                        }
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                            doubleTap.removeAll()
//                                        }
//                                    }
#if os(macOS)
                                    .lineLimit(nil)
#endif
                                }
                            }
                            
                            Text(message.timeString)
                                .font(.caption)
                                .padding(.horizontal)
                                .opacity(isTimeStampShowing == true ? 1 : 0)
                                .foregroundColor(Color.mainColorInverse)
                                .onAppear() {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        isTimeStampShowing = false
                                    }
                                }
                        }
                    }
                    .padding(.leading, -16)

                    
                } // CONDITIONAL FOR PHOTO WITH NO MESSAGE
               
                    if message.alreadyViewOnce == true  {
                        HStack {
                            Spacer()
                            if message.didTakeScreenShot == true {
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 22, weight: .light))
                                   .foregroundColor(Color.mainColor)
                            }
                            Text("Seen")

                                .bold()
                                .chatBubble(direction : .right)
                        }
                    }else if let videoUrl =  message.videoUrl,
                       let thumbnailUrl = message.thumbnailUrl {
                        HStack {
                            Spacer()
                            ZStack {
                                MessageView(photoLink: thumbnailUrl, direction: .right)
                                VideoThumbnailView(videoThumbnailVM : VideoThumbnailVM(videoFirebaseURL : videoUrl))
                            }
//                            .padding(.bottom)
                            .overlay(
                                VStack{
                                    Spacer()
                                    HStack{
                                        if let viewOnce = message.alreadyViewOnce {
                                            Image(systemName: viewOnce ? "eye.fill" : "eye.slash.fill" )
                                                .foregroundColor(.white)
                                                .font(.system(size: 20, weight: .heavy))
                                                  .padding(.bottom,5)
                                                  .padding(.leading,5)
                                        }
                                        Spacer()
                                    }
                                
                                }
//                                    .padding(.bottom)
                            )
                        }
                    }else if let photoLink = message.photoLink {
                        HStack {
                            Spacer()
                            MessageView(photoLink: photoLink, direction: .right)
//                                .padding(.bottom)
                                .onCustomTapGesture {
                                    //now need to check what will happen here
                                    OpenedPhotoSelectedItem = message.photoLink
                                    OpenedPhotoMatchedGeometry = "0"
                                    hideKeyboard()
                                } .overlay(
                                    VStack{
                                        Spacer()
                                        HStack{
                                            if let viewOnce = message.alreadyViewOnce {
                                                Image(systemName: viewOnce ? "eye.fill" : "eye.slash.fill" )
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 20, weight: .heavy))
                                                      .padding(.bottom,5)
                                                      .padding(.leading,5)
                                            }
                                            Spacer()
                                        }
                                    
                                    }
//                                        .padding(.bottom)
                                )
                        }
                    } else if let audioUrl = message.audioUrl {
                        CacheAudioPlayer(audioUrl: audioUrl, isDummy: message.isDummy, color: Color.mainColorInverse.opacity(1), backgroundColor: Color.mainColorInverse.opacity(0.2), direction: .right)
                            .rightInHStack
//                            .padding(.trailing,10)
                    } else if let image = message.tempImage {
                        DummyMediaMessageView( image: image, videoURL:  message.videoUrl)
//                            .padding(.bottom)
                    }
                 
            } // VSTACK
//            .padding(.top, -5)
//            .padding(.vertical,2.5)
            .padding(.trailing, -16)
             if hasMessageBeenLiked || message.hasBeenLiked {
                 Image("heartFilled")
                     .resizable()
                     .frame(width: 20, height: 20)
                     .offset(x: 6, y: 8)
//                     .opacity(hasMessageBeenLiked || message.hasBeenLiked ? 1 : 0)
             }
                     if messageLink != nil {
                         EmptyView()
                         .onAppear {
                             UIApplication.shared.open((messageLink ?? URL(string:"www.google.com"))!, options: [:], completionHandler: nil)
                         }
                         .onDisappear {
                             messageLink = nil
                             print("HELLO 2")
                         }
                     }
            }
         .onCustomTapGesture(count: 2,perform: doubleTapped)
         .onLongPressGesture {
             isTimeStampShowing.toggle()
             DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                 isTimeStampShowing = false
             }
         }.disabled(message.status == .sending)
    }
    
    ///received message
    var leftBubble: some View{
            // pushing message to left
            ZStack (alignment: .bottomLeading) {
            VStack {
                if message.message.isNotEmpty {
                HStack (spacing: 20) {
                    ZStack (alignment: .leading) {
                        Text(message.timeString)
                            .font(.caption)
                            .opacity(isTimeStampShowing == true ? 1 : 0)
                            .onAppear() {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    isTimeStampShowing = false
                                }
                            }
                        if message.isGIF == true {
                            AnimatedImage(url: URL(string: message.message))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 177.5, height: 200)
                                .clipShape(ChatBubbleShape(direction: .left))
                                .onCustomTapGesture {
                                    OpenedGIFMatchedGeometry = message.message
                                    hideKeyboard()
                                }
                             
                        } else {
                            ZStack {
                            if message.message.contains("https://") {
                                MessageLabel(content: message.message, tappedMention: {_ in
                                    print("MENTION")
                                    //                                            mentionedUserVM.menionedTapped(username: $0)
                                }, tappedLink: { link in
                                    messageLink = link
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        messageLink = nil
                                    }
                                    print("LINKKK ")
                                })
                                .fixedSize(horizontal: true, vertical: true)
                            } else {
                                //                                            messageText
                                Text(message.message)
                            }
                        }
//                            .onCustomTapGesture {
//                                doubleTap.append(0)
//                                if doubleTap.count == 2 {
//                                    hasMessageBeenLiked = true
//                                    if message.hasBeenLiked == false {
//
//                                        guard let userId = currentUserID else{ return }
//
//                                    functions.sendLike(sentBy: userId, messageID: message.id, otherUserID: person.id, chatUID: chatUID, token: person.token, nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "")
//                                    }
//                                    doubleTap.removeAll()
//                                }
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                    doubleTap.removeAll()
//                                }
//                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
//                            .background(colorScheme == .light ? Color.mainColorInverse.opacity(0.6) : Color.softWhite)
                            .foregroundColor(Color.black)
                            .background(Color.white.opacity(0.6))
                            .clipShape(ChatBubbleShape(direction: .left))
                            .opacity(isTimeStampShowing == true ? 0 : 1)
                    }
                    }
                    Spacer(minLength: 25)
                }
               .foregroundColor(Color.mainColor)
                } // CONDITIONAL FOR PHOTO WITH NO MESSAGE
              
                    if let alreadyViewOnce = message.alreadyViewOnce,
                       let mediaKind = message.kind {
                        if alreadyViewOnce , (isANewViewOnce == false || mediaKind == .image){
                            HStack {
                                Text("Seen")
                                   .foregroundColor(Color.mainColor)
                                    .bold()
                                    .chatBubble(direction : .left)
                                if message.didTakeScreenShot == true {
                                    Image(systemName: "camera.viewfinder")
                                        .font(.system(size: 22, weight: .light))
                                       .foregroundColor(Color.mainColor)
                                }
                                Spacer()
                            }
                        }else{
                            if isAGroupMessage{
                                ViewOnceGroupMessageView(videoOnceViewVM : VideoOnceViewVM(message : message),
                                                         openPhotoURL : $OpenedPhotoSelectedItem,
                                                         isANewViewOnce : $isANewViewOnce,
                                                         mediaKind: mediaKind)
                            }else{
                                ViewOnceMessageView(videoOnceViewVM : VideoOnceViewVM(message : message),
                                                    openPhotoURL : $OpenedPhotoSelectedItem,
                                                    isANewViewOnce : $isANewViewOnce,
                                                    mediaKind: mediaKind)
                            }
                        }
                    }else if let videoUrl =  message.videoUrl,
                       let thumbnailUrl = message.thumbnailUrl {
                        HStack {
                            ZStack {
                                MessageView(photoLink: thumbnailUrl, direction: .left) 
                                VideoThumbnailView(videoThumbnailVM : VideoThumbnailVM(videoFirebaseURL : videoUrl))
                            }
//                            .padding(.bottom)
                            Spacer()
                        }
                    }else if let photoLink = message.photoLink {
                        HStack {
                            MessageView(photoLink: photoLink, direction: .left)
//                                .padding(.bottom)
                                .onCustomTapGesture {
                                    //now need to check what will happen here
                                    OpenedPhotoSelectedItem = message.photoLink
                                    OpenedPhotoMatchedGeometry = "0"
                                    hideKeyboard()
                                }
                            Spacer()
                        }
                    } else if let audioUrl = message.audioUrl {
                        CacheAudioPlayer(audioUrl: audioUrl, isDummy: message.isDummy, color: Color.mainColor.opacity(0.85), backgroundColor: Color.mainColorInverse.opacity(0.2))
                            .leftInHStack
                    }
               
            } // VSTACK
//            .padding(.vertical,2.5)
                if hasMessageBeenLiked || message.hasBeenLiked {
                    Image("heartFilled")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .offset(x: 10, y: 8)
                }
                if messageLink != nil {
                    EmptyView()
                    .onAppear {
                        UIApplication.shared.open((messageLink ?? URL(string:"www.google.com"))!, options: [:], completionHandler: nil)
                    }
                    .onDisappear {
                        messageLink = nil
                        print("HELLO 2")
                    }
                }
//                    .opacity(hasMessageBeenLiked || message.hasBeenLiked ? 1 : 0)
            
            }
            .onCustomTapGesture(count: 2,perform: doubleTapped)
            .onLongPressGesture {
                isTimeStampShowing.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isTimeStampShowing = false
                }
            }
    }
    @State var isANewViewOnce = false
    var body: some View {
        
        HStack (alignment: .top, spacing: 10) {
            if myMessage == currentUserID {
                rightBubble
            } else  {
                if isAGroupMessage {
                senderImageView
                }
                leftBubble
            }
            Spacer() // to fill content shape
        }
//        .padding(.horizontal, -5)
        
    }
    
    private var senderImageView: some View {
        senderWeblink.map({ profilePicLink in
            VStack{
                Spacer()
                WebImage(url: profilePicLink)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 35, height: 35)
                    .background(Color.mainColor.opacity(0.1))
                    .clipShape(Circle()) 
            }
            .padding(.trailing, -10)
//             .offset(x:-10)
             
//             .padding(.leading,-10)
        })
    }
    func doubleTapped(){

            hasMessageBeenLiked = true
            if message.hasBeenLiked == false {
#if os(iOS)
            let impactLight = UIImpactFeedbackGenerator(style: .heavy)
            impactLight.impactOccurred()
#endif
                guard let userId = currentUserID else{ return }
                
            functions.sendLike(sentBy: userId, messageID: message.id, otherUserID: person.id, chatUID: chatUID, token: person.token, nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "")
            }


    }
}

struct DummyMediaMessageView : View {
    var image : UIImage
    var videoURL : URL?
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.speakerPurple))
                .padding(.trailing,10)
            
            ZStack{
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 177.5, height: 200)
                    .clipShape(ChatBubbleShape(direction: .right))
                
                if videoURL != nil {
                    VideoPlayButtonView(size: 50)
                }
                
            }
        }
    }
    
}
 

struct MessageView : View {
    var photoLink : URL
    var direction : ChatBubbleShape.Direction
    
    var body: some View {
        ZStack {
            WebImage(url: photoLink)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 177.5, height: 200)
                .background(Color.lightGray)
                .clipShape(ChatBubbleShape(direction: direction))
        }
    }
}

