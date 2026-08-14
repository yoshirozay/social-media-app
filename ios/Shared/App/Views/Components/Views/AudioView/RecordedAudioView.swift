//
//  RecordedAudioView.swift
//  speakEZ
//
//  Created by Ahmad naeem on 5/26/22.
//

import SwiftUI

struct RecordedAudioView : View {
    @Binding var newMedia: SelectedMedia?
    @StateObject private var audioPlayerVM: RecordedAudioPlayerVM = RecordedAudioPlayerVM()
    @ObservedObject var soundManager: SoundManager
    @State var isFromMessages = false
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeController: ThemeController
    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .frame(width: 105, height: 120)
                    .foregroundColor(themeController.theme.secondary)
                    .clipShape(Rectangle())
                    .cornerRadius(10)
                Button(action: {
                    audioPlayerVM.playRecordingIfNotPlaying(audioUrl: newMedia?.audioUrl)
                }){
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 60 - 10, height: 60 - 10)
                            .foregroundColor(themeController.theme.primary)
                        if audioPlayerVM.playRecording {
                            AnimatedWaveformView(color: .white, renderingMode: .hierarchical, animated: true, doesHaveOutterRing: false )
                                .frame(width: 60, height: 60)
                                .scaledToFit()
                        } else {
                            AnimatedWaveformView(color: .white, renderingMode: .hierarchical, animated: false, doesHaveOutterRing: false)
                                .frame(width: 60, height: 60)
                                .scaledToFit()
                        }
                    }
                }.disabled(soundManager.isRecording)
                Button(action: {
                    withAnimation {
                    audioPlayerVM.stopAndDelete(audioDirURL:  newMedia?.audioUrl)
                    newMedia = nil
                    }
                }) {
                    Image(systemName: "clear")
                        .contentShape(Rectangle())
                        .foregroundColor(themeController.theme.accent.opacity(1))
                }  .buttonStyle(.borderless)
                    .padding(.leading, 90)
                    .padding(.bottom, 100)
            }
            .padding(.leading, 8)
            Spacer()
        }
        .frame(height: 125)
        .onAppear() {
            audioPlayerVM.playRecordingIfNotPlaying(audioUrl: newMedia?.audioUrl)
        }
    }
}
