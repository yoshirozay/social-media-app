//
//  VideoPlayerSetting.swift
//  speakEZ
//
//  Created by Ahmad naeem on 3/11/22.
//
 
import AVKit

class VideoPlayerSetting {
  static let shared = VideoPlayerSetting()
    private init(){ }
    
    var canPlayInSilentMode : Bool = false
    func enableVideoPlayInSilentMode() {
        guard canPlayInSilentMode == false else {return}
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            canPlayInSilentMode = true
        } catch {
            print(error)
        }
    }
}
