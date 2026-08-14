//
//  ViewOnceMessageView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/19/21.
//
 
import SwiftUI
import Combine

//struct ViewOnceMessageTextView : View {
//    var body: some View {
//        Text("Tap to see")
//            .bold()
//            .chatBubble(direction : .left).onCustomTapGesture {
//                 
//            }
//    }
//}
struct ViewOnceMessageView : View {
    
    @EnvironmentObject var allMessages: OpenedConversationOO
    @StateObject var videoOnceViewVM : VideoOnceViewVM
    @Binding var openPhotoURL: URL?
    @Binding var isANewViewOnce: Bool
    let mediaKind: NewMedia.Kind
    
    var body: some View {
        HStack{
            let text = Text("Tap to see")
                .bold()
                .chatBubble(direction : .left)
             if videoOnceViewVM.isMediaDownloaded == false{
                HStack{
                    text
                    ProgressViewPurpleCircular()
                        .padding(.leading,5)
                }
            } else  {
                text.onCustomTapGesture(perform: onTap)
            }
            Spacer()
        }.mutualFullScreenCover(isPresented: $videoOnceViewVM.showVideoPlayer, onDismiss: {
            isANewViewOnce = false
        }, content: {
            if let _ = videoOnceViewVM.videoDocURL{
                VideoPlayerView().animation(.none)
            }
        }).onAppear{
            isANewViewOnce = true 
        }
    }
    
    func onTap(){ 
        if mediaKind == .image{
            openPhotoURL = videoOnceViewVM.message.photoLink
            hideKeyboard()
            //need a better solution if possible
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                openPhotoURL = nil
            }
        }else {
            videoOnceViewVM.presentVideoPlayer()
        }
        videoOnceViewVM.userTappedToViewMedia()
        //now need to check what will happen here
        allMessages.userDidViewMesssage(id: videoOnceViewVM.message.id)
    }
}
/*
 so when user tap on view once media. and teh didViewMessage func is called, it takes time to mark the message alreadyViewOnce false
 */

struct ProgressViewPurpleCircular : View {
    @State var color : Color = Color.speakerPurple
    var body: some View {
        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: color))
    }
}

extension View {
  func chatBubble(direction: ChatBubbleShape.Direction) -> some View {
       self.padding(.horizontal)
           .padding(.vertical, 10)
           .background(direction == .left ? Color.mainColor.opacity(0.06) : Color.speakerPurple)
           .if(direction == .right){$0.foregroundColor(.mainColorInverse)}
//           .foregroundColor(.mainColorInverse)
           .clipShape(ChatBubbleShape(direction: direction))
   }
}

struct ViewOnceGroupMessageView : View {
   
   @EnvironmentObject var allMessages: OpenedGroupConversationOO
   @StateObject var videoOnceViewVM : VideoOnceViewVM
   @Binding var openPhotoURL: URL?
   @Binding var isANewViewOnce: Bool
   let mediaKind: NewMedia.Kind
   
   var body: some View {
       HStack{
           let text = Text("Tap to see")
               .bold()
               .chatBubble(direction : .left)
            if videoOnceViewVM.isMediaDownloaded == false{
               HStack{
                   text
                   ProgressViewPurpleCircular()
                       .padding(.leading,5)
               }
           } else  {
               text.onCustomTapGesture(perform: onTap)
           }
           Spacer()
       }.mutualFullScreenCover(isPresented: $videoOnceViewVM.showVideoPlayer, onDismiss: {
           isANewViewOnce = false
       }, content: {
           if let _ = videoOnceViewVM.videoDocURL{
               VideoPlayerView().animation(.none)
           }
       }).onAppear{
           isANewViewOnce = true
       }
   }
   
   func onTap(){
       if mediaKind == .image{
           openPhotoURL = videoOnceViewVM.message.photoLink
           hideKeyboard()
           //need a better solution if possible
           DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
               openPhotoURL = nil
           }
       }else {
           videoOnceViewVM.presentVideoPlayer()
       }
       videoOnceViewVM.userTappedToViewMedia()
       //now need to check what will happen here
       allMessages.userDidViewMesssage(id: videoOnceViewVM.message.id)
   }
}
