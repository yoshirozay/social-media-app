//
//  VideoThumbnailVM.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 5/13/21.
//
 
 
import Combine
import AVFoundation

class VideoThumbnailVM : ObservableObject {
    @Published private (set) var videoDocURL : URL? = nil
    @Published var showVideoPlayer : Bool = false
    var videoFirebaseURL : URL?
    
    init(videoFirebaseURL : URL? = nil) {
        fetchVideoFrom(videoFirebaseURL : videoFirebaseURL)
    }
    //for running the selected video
    init(videoDirURL: URL) {
        self.videoDocURL = videoDirURL
    }
    
    func fetchVideoFrom(videoFirebaseURL : URL? = nil) {
        if let videoFirebaseURL = videoFirebaseURL{
            self.videoFirebaseURL = videoFirebaseURL
            VideoCacheManager.shared.getFileDirURLUsing(fileFirebaseURL: videoFirebaseURL) { [weak self]  url,error in
                DispatchQueue.main.async {
                    self?.videoDocURL = url
                }
            }
        }
    }
    
    func presentVideoPlayer(){
        if let videoDocUrl = videoDocURL{
            let avPlayerItem = AVPlayerItem(url: videoDocUrl)
            AVPlayer.shared.replaceCurrentItem(with: nil)
            AVPlayer.shared.replaceCurrentItem(with: avPlayerItem)
            showVideoPlayer = true
        }
    }
    
    deinit {
        if let  videoFirebaseURL  = videoFirebaseURL {
            VideoCacheManager.shared.removeSubcriberIfExist(videoFirebaseURL)
        }
        //       print("VideoThumbnailVM deinit")
    }
}

extension AVPlayer {
    static var shared = AVPlayer()
}
