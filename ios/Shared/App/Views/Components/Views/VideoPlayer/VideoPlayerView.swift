//
//  VideoPlayerView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 5/9/21.
//

import SwiftUI
import AVKit
//we make the avPlayer a global var so we do not have to create AVPlayer each time a video is played
 
struct VideoPlayerView: View { 
    @State var showVideoPlayer: Bool = false
    @State private var scale: CGFloat = 1

//#if os(macOS)
    @Environment(\.presentationMode) var presentationMode
//#endif
    var body: some View {
        ZStack {
            if showVideoPlayer {
                AVPlayerControllerRepresented(player: AVPlayer.shared)
//                VideoPlayer(player: AVPlayer.shared)
                    .zoomable(scale: $scale)
                    .onAppear {
                        VideoPlayerSetting.shared.enableVideoPlayInSilentMode() 
                        AVPlayer.shared.play()
                    }

#if os(macOS)
                    .frame(width: screenWidth, height: screenWidth)
#endif
            }
            
    #if os(macOS)
            VStack{
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    MacOsDismissButton(matchedGeometry: .constant(""))
                }.buttonStyle(.borderless)
                Spacer()
            }
            .padding(.top,15)
            .padding(.leading,15)
    #endif
        }.background(Color.black)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                showVideoPlayer = true
            }
        }
        .onDisappear {
            AVPlayer.shared.pause()
            AVPlayer.shared.replaceCurrentItem(with: nil)
        }
        .edgesIgnoringSafeArea(.all)
        .highPriorityGesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                            .onEnded({ value in
            if value.translation.width > 80 {
                                       // right
                withAnimation(.easeOut(duration: 0.3)) {

                    presentationMode.wrappedValue.dismiss()
                }
                                   }
                                if value.translation.height > 80 {
                                    // down
                                    withAnimation(.easeOut(duration: 0.3)) {

                                        presentationMode.wrappedValue.dismiss()
                                    }

                                }
                            }))
    }
}

struct AVPlayerControllerRepresented : UIViewControllerRepresentable {
    var player : AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
}
