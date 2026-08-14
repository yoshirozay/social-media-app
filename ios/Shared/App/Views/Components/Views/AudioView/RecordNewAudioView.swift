//
//  RecordNewAudioView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 5/27/22.
//

import SwiftUI

struct RecordNewAudioView : View {
    @StateObject var soundManager = SoundManager()
    @Binding var selectedMedia : SelectedMedia?
    @Environment(\.colorScheme) var colorScheme
    @State var isFromMessages = false
    @Binding var audioCommentAlert: Bool
    @Binding var buttonAlertType: ButtonAlertType
    @ObservedObject var themeController: ThemeController
    var backgroundColor : Color{

        isFromMessages ?
            soundManager.isRecording ? themeController.theme.accent.opacity(0.6) : themeController.theme.messageList : soundManager.isRecording ? themeController.theme.accent.opacity(0.6) : themeController.theme.secondary
            
//            soundManager.isRecording ? Color.speakerPurple.opacity(0.6) : (colorScheme == .light ? .softWhite : .backgroundColor)) : (
//                soundManager.isRecording ? Color.speakerPurple.opacity(0.6) : .softWhite)
    }
    var body: some View {
        
        ZStack {
            Circle()
                .frame(width: 46, height: 46)
                .foregroundColor(backgroundColor)
                .shadow(color: .black.opacity(0.16), radius: 6, x: 0, y: 3)
            
            if soundManager.isRecording {
                AnimatedWaveformView(color: .black, animated: true, doesHaveOutterRing: false)
                .frame(width: 46, height: 46)
//                .onTapGesture {
//                    withAnimation {
//#if os(iOS)
//        let impactLight = UIImpactFeedbackGenerator(style: .soft)
//                        impactLight.impactOccurred()
//#endif
//                        soundManager.stopRecorder()
//                    }
//                }
            } else {
                AnimatedWaveformView(color: .black, animated: false, doesHaveOutterRing: false)
                    .frame(width: 46, height: 46)
//                    .onTapGesture {
//                        withAnimation {
//#if os(iOS)
//        let impactLight = UIImpactFeedbackGenerator(style: .soft)
//                        impactLight.impactOccurred()
//#endif
//                            selectedMedia?.newMedia = nil
//                            selectedMedia?.deleteCacheOfSelectedMediaIfAny()
//                            soundManager.recordAudio()
//
//                        }
//                    }
            }
    }
        .onTapGesture {

            withAnimation {

#if os(iOS)
    let impactLight = UIImpactFeedbackGenerator(style: .soft)
                    impactLight.impactOccurred()
#endif
            if soundManager.isRecording {
                soundManager.stopRecorder()
             }else{
                 //as we know if user has sent the comment with audio, then we has set selectedMedia as nill while doing that so now we will only have selectedMedia if previous recorded media was not sent
                 if audioCommentAlert != false {
                     selectedMedia?.newMedia = nil
                     selectedMedia?.deleteCacheOfSelectedMediaIfAny()
                     soundManager.recordAudio()
                 } else {
                     withAnimation {
                         buttonAlertType = .audioComment
                         audioCommentAlert = false
                         DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                             audioCommentAlert = true
                         }
                     }
                 }
            }
        }
        }
        .onReceive(soundManager.recoredAudioURLPublisher) { recordedAudioURL in
                        if let recordedAudioURL = recordedAudioURL{
                            selectedMedia = SelectedMedia(audioUrl: recordedAudioURL)
                        }else if let _ = selectedMedia?.audioUrl {
                            selectedMedia = nil
                        }
                    }
    }
}

