//
//  AudioPlayerView.swift
//  speakEZ
//
//  Created by Ahmad naeem on 5/20/22.
//

import SwiftUI

struct LoadingAudioWave : View {
    let direction: ChatBubbleShape.Direction
    var progress: some View{
        ProgressViewPurpleCircular().scaleEffect(1)
    }
    var width: CGFloat
    var height: CGFloat
    var color = Color.speakerPurple
    var backgroundColor = Color.mainColorInverse.opacity(0.2)
    var isFromTimelineMoment = false
    var body : some View {
        ZStack{
            if direction == .right{
                progress
                    .offset(x: -width/2 - 10)
            }
            
            ZStack {
                if isFromTimelineMoment {
                    Circle()
                        .frame(width: width - 10, height: height - 10)
                        .foregroundColor(backgroundColor)
                } else {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: width - 10, height: height - 10)
                    .foregroundColor(backgroundColor)
                }
            AnimatedWaveformView(color: color, renderingMode: .hierarchical, animated: false, doesHaveOutterRing: false)
                .frame(width: width, height: height)
                .scaledToFit()
            }
            
            if direction == .left{
                progress
                    .offset(x: width/2 + 10)
            }
        }
    }
}

struct AudioPlayerView : View {
    @StateObject var audioCachePlayerVM : AudioCachePlayerVM
    let direction: ChatBubbleShape.Direction
    var width: CGFloat
    var height: CGFloat
    var color: Color
    var body : some View {
        ZStack {
            if audioCachePlayerVM.playRecording  {
                AnimatedWaveformView(color: color, renderingMode: .hierarchical, animated: true, doesHaveOutterRing: false)
                    .frame(width: width, height: height)
                    .scaledToFit()
            } else {
                ZStack{
                    if audioCachePlayerVM.showProgress, direction == .right{
                            progress
                            .offset(x: -width/2 - 10)
//                            .padding(.trailing,20)
                     }
                    
                AnimatedWaveformView(color: color, renderingMode: .hierarchical, animated: false, doesHaveOutterRing: false)
                    .frame(width: width, height: height)
                    .scaledToFit()
                
                    if audioCachePlayerVM.showProgress, direction == .left{
                            progress
                            .offset(x: width/2 + 10)
//                            .padding(.leading,20)
                    }
                }
            }
        }
        .onTapGesture {
            audioCachePlayerVM.playRecordingIfNotPlaying()
        }
    }
    var progress: some View{
        ProgressViewPurpleCircular().scaleEffect(1)
    }
}

struct CacheAudioPlayer : View {
    let audioUrl: URL
    let isDummy: Bool
    var width: CGFloat = 60
    var height: CGFloat = 60
    var color = Color.speakerPurple
    var backgroundColor = Color.mainColorInverse.opacity(0.2)
    var isFromTimelineMoment = false
    private(set) var direction: ChatBubbleShape.Direction = .left
    var body: some View {
        HStack {
            if isDummy {
                LoadingAudioWave(direction: direction, width: width, height: height, color: color, backgroundColor: backgroundColor, isFromTimelineMoment: isFromTimelineMoment)
            }else{
                ZStack {
//                    if isFromTimelineMoment {
//                        Circle()
//                            .frame(width: width - 10, height: height - 10)
//                            .foregroundColor(backgroundColor)
//                    } else {
//                    RoundedRectangle(cornerRadius: 10)
//                        .frame(width: width - 10, height: height - 10)
//                        .foregroundColor(backgroundColor)
//                    }
                AudioPlayerView(audioCachePlayerVM: AudioCachePlayerVM(audioFirebaseURL: audioUrl),direction: direction, width: width, height: height, color: color)
                }
            }
        }
    }
}

