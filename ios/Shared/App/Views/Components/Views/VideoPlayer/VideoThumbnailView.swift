//
//  VideoThumbnailView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 5/9/21.
//
 
import SwiftUI
import Combine
//import YPImagePicker
//import CLImageEditor
import AVKit
import FirebaseStorage
import Firebase
import SDWebImageSwiftUI
  

struct VideoThumbnailView: View {
    @StateObject var videoThumbnailVM : VideoThumbnailVM
    var doubleTapAction : (()->())? = nil
    var body: some View {
        ZStack {
            if let _ = videoThumbnailVM.videoDocURL {
                VideoPlayButtonView(size : 50)
            }else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.speakerPurple))
                    .scaleEffect(3.0)
            }
        }
        .frame(width: 177.5, height: 200)
        .background(Color.black.opacity(0.001))
        .if(doubleTapAction != nil){  $0.onCustomTapGesture(count: 2, perform: doubleTapAction ?? {})  }
        .onCustomTapGesture {
            videoThumbnailVM.presentVideoPlayer()
        }
        .mutualFullScreenCover (isPresented: $videoThumbnailVM.showVideoPlayer, content: {
            if let _ = videoThumbnailVM.videoDocURL{
                VideoPlayerView().animation(.none)
            }
        }) 
    }
    
}

struct VideoPlayButtonView: View {
    var size : CGFloat = 50
    var body: some View {
    Image(systemName: "play.circle.fill")
        .font(Font.system(size: size, weight: .semibold, design: .rounded))
        .foregroundColor(Color(#colorLiteral(red: 0.2941176471, green: 0.2941176471, blue: 0.2941176471, alpha: 1)))
        .background(Color.white.frame(width: size*0.6, height: size*0.6))
    }
}
 
