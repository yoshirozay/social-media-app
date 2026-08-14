//
//  LoopedVideoPlayerView.swift
//  testingSwiftUI
//
//  Created by Ahmad naeem on 6/3/21.
//
 
import UIKit
import AVFoundation

class LoopedVideoPlayerView: UIView {

   fileprivate var videoURL: URL?
   fileprivate var queuePlayer: AVQueuePlayer?
   fileprivate var playerLayer: AVPlayerLayer?
   fileprivate var playbackLooper: AVPlayerLooper?

   func prepareVideo(_ videoURL: URL) {
   
       let playerItem = AVPlayerItem(url: videoURL)
           
       self.queuePlayer = AVQueuePlayer(playerItem: playerItem)
       self.playerLayer = AVPlayerLayer(player: self.queuePlayer)
       guard let playerLayer = self.playerLayer else {return}
       guard let queuePlayer = self.queuePlayer else {return}
       self.playbackLooper = AVPlayerLooper.init(player: queuePlayer, templateItem: playerItem)
           
//    playerLayer.videoGravity = .resizeAspect.
       playerLayer.frame = self.frame
       self.layer.addSublayer(playerLayer)
    play()
   }

   func play() {
       self.queuePlayer?.play()
   }

   func pause() {
       self.queuePlayer?.pause()
   }

   func stop() {
       self.queuePlayer?.pause()
       self.queuePlayer?.seek(to: CMTime.init(seconds: 0, preferredTimescale: 1))
   }

   func unload() {
       self.playerLayer?.removeFromSuperlayer()
       self.playerLayer = nil
       self.queuePlayer = nil
       self.playbackLooper = nil
   }
   
   override init(frame: CGRect) {
       super.init(frame: frame)
    backgroundColor = .white
   }

   required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
   }

   override func layoutSubviews() {
       self.playerLayer?.frame = self.bounds
   }
}
