//
//  IntroOO.swift
//  speakEZ
//
//  Created by Ahmad naeem on 11/24/21.
//

import Foundation
import AVFoundation
import Combine
import SwiftUI
 
class IntroVideoOO: ObservableObject {
    @Published private(set) var showVideo: Bool = false
    @Published var showIntroController: Bool = false
    @Published var bringToFront: Bool = false
    var cancelSet = Set<AnyCancellable>()
    
    lazy var avPlayer : AVPlayer = {
        AVPlayer()
    }()
    
    lazy var videoURL : URL = {
        Constant.mainVideoURL
    }()
     ///the only thing we need to check what will happened if user is offline
    init(profileHasCreatedPublisher: Published<Bool?>.Publisher) {
            print("123# IntroVideoOO")
                self.checkIntroForCurrentUser()

    }
    
    private func checkIntroForCurrentUser() {
        guard let userId = currentUserID else { return }
        UserDetail.getUserDetail(userId: userId) { [weak self] userDetail, error in
         
            if let error = error {
                print(" \(error.localizedDescription)")
                self?.showIntroController(userId: userId)
            }else{
                if let userDetail = userDetail{
                    if userDetail.hasDoneIntroduction == false {
                        self?.showIntroController(userId: userId)
                    }else{
                        UNUserNotificationCenter.current().getNotificationSettings { settings in
                            if settings.authorizationStatus == .notDetermined {
                                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {(_, error) in
                                    print("push notification permission = ", error?.localizedDescription ?? "was successfull")
                                 }
                            }
                        }
                    }
//                    self?.showIntroController(userId: userId)
                    if userDetail.hasWatchedMainVideo == false {
//                        self?.playVideoIfPossible(userId: userId)
                    }
                }else{
                    self?.showIntroController(userId: userId)
//                    self?.playVideoIfPossible(userId: userId)
                }
            }
        }
    }
    
    func showIntroController(userId: String) {
        self.showIntroController = true
    }
    
    var videoSub: AnyCancellable?
    ///IT will play intro video if intro view is not present or after introView get dismissed
    func playVideoIfPossible(userId: String) {
        if showIntroController {
            videoSub = $showIntroController.filter{!$0}.sink{[weak self] _ in
                self?.playVideo(userId: userId)
                self?.videoSub?.cancel()
            }
        }else{
            playVideo(userId: userId)
        }
    }
    
    private func playVideo(userId: String) {
        VideoPlayerSetting.shared.enableVideoPlayInSilentMode()
        let avPlayerItem = AVPlayerItem(url: self.videoURL)
        avPlayer.replaceCurrentItem(with: avPlayerItem)
        avPlayer.play() 
        
        avPlayer.publisher(for: \.timeControlStatus)
            .filter{$0 == .playing}
            .sink {[weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.bringToFront = true
                    DispatchQueue.main.async {
                        DeviceOrientationManager.lockOrientation(.all)
                    }
                }
                print(" IntroSeenStatusFuncs.hasWatchedMainVideo called")
                IntroSeenStatusFuncs.hasWatchedMainVideo(userId: userId) { error in
                    print(" UpdateIntroViewStatusFunction \(error?.localizedDescription ?? "")")
                }
                self?.addPlayToEndTimeListener()
                self?.showVideo = true
                
            }.store(in: &cancelSet)
    }
    
    func addPlayToEndTimeListener() {
        cancelSet.cancelAll()
        NotificationCenter.default.publisher(for: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
            .sink() {  [weak self] _ in
                self?.closePlayer()
            }
            .store(in: &cancelSet)
    }
    
    func closePlayer() {
        DeviceOrientationManager.lockOrientation(.portrait,andRotateTo: .portrait)
        withAnimation(.easeOut(duration: 0.3)) {
            avPlayer.pause()
            avPlayer.replaceCurrentItem(with: nil)
            showVideo = false
        }
        cancelSet.cancelAll()
    }
    
    deinit{
        cancelSet.cancelAll()
        avPlayer.pause()
        avPlayer.replaceCurrentItem(with: nil)
        DeviceOrientationManager.lockOrientation(.portrait,andRotateTo: .portrait)
        videoSub?.cancel()
    }
    
 
    struct Constant {
        static var mainVideoURL : URL { URL(string:"https://firebasestorage.googleapis.com/v0/b/YOUR_FIREBASE_PROJECT_ID.appspot.com/o/mainVideo.mov?alt=media&token=fa4c9153-2d90-471a-8cb0-f09540d1cbc7")!
        }
    }
} 
  
/*
  now mainVideo will be played for the user who did not have watched it.
 As we are playing it with using firebase storage url, it might take some seconds before it start playing that will depened on user internet speed, so how fast the video can buffer and such. after video end the video player will automatically dismiss it self.
 we can also change design of the IntroVideoView as we like
 */


//class IntroductionOO: ObservableObject {
//   @Published private(set) var showIntroductionView : Bool = false
//   func checkIntroForCurrentUser() {
//       guard let userId = currentUserID else { return }
//       UserDetail.getUserDetail(userId: userId) { [weak self] userDetail, error in
//           if let userDetail = userDetail{
//               if !userDetail.hasDoneIntroduction{
//                   self?.showIntroductionView = true
//               }
//           }else{
//
//           }
//       }
//   }
//}
