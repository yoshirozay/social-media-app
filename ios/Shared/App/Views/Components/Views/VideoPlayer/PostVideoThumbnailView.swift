//
//  PostVideoThumbnailView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 5/13/21.
//

import Foundation 
import SwiftUI
import Combine
import AVKit

struct PostVideoThumbnailView: View {
    //now this will be only showing play button and the progresser when downloading the video .
    @StateObject var VideoThumbnailVM : VideoThumbnailVM
    @State var showVideoPlayer: Bool = false
    @State var url: URL?
    @State var buttonSize: CGFloat = 70
    var body: some View {
        ZStack {
            if VideoThumbnailVM.videoDocURL != nil {
                VideoPlayButtonView(size : buttonSize)
            }else {
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.speakerPurple))
                    .scaleEffect(2.5)
            }
        }
//        .frame(width: screenWidth-30, height: screenWidth-30)
        .background(Color.black.opacity(0.001))
        .onTapGesture {
            if let videoDocUrl = VideoThumbnailVM.videoDocURL{
                let avPlayerItem = AVPlayerItem(url: videoDocUrl)
                AVPlayer.shared.replaceCurrentItem(with: nil)
                AVPlayer.shared.replaceCurrentItem(with: avPlayerItem)
//                print("VideoThumbnailView tapped\(videoDocUrl.lastPathComponent)")
                //                    videoDocURL = videoDocUrl
                url = videoDocUrl
                showVideoPlayer = true
            }
        }
        .mutualFullScreenCover (isPresented: $showVideoPlayer, content: {
            if let _ = VideoThumbnailVM.videoDocURL{
                VideoPlayerView().animation(.none)
            }
        })
    }
}

struct RegularVideoThumbnailView: View {
    //now this will be only showing play button and the progresser when downloading the video .
    @State var thumbnail: UIImage
    @State var showVideoPlayer: Bool = false
    @State var url: URL?
    @State var buttonSize: CGFloat = 70
    @State var selectedMedia: SelectedMedia?
    var body: some View {
        ZStack {
                VideoPlayButtonView(size : buttonSize)
        }
//        .frame(width: screenWidth-30, height: screenWidth-30)
        .background(Color.black.opacity(0.001))
        .onTapGesture {
            if let videoUrl = selectedMedia?.newMedia?.videoUrl {
                let avPlayerItem = AVPlayerItem(url: videoUrl)
                AVPlayer.shared.replaceCurrentItem(with: nil)
                AVPlayer.shared.replaceCurrentItem(with: avPlayerItem)
                url = videoUrl
                showVideoPlayer = true
            }
        }
        .mutualFullScreenCover (isPresented: $showVideoPlayer, content: {
            if let _ = selectedMedia?.newMedia?.videoUrl {
                VideoPlayerView().animation(.none)
            }
        })
    }
}

