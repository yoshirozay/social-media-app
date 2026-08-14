//
//  AudioPlayerVM.swift
//  speakEZ
//
//  Created by Ahmad naeem on 5/18/22.
//

import AVFoundation
import Combine
class AudioCachePlayerVM : AudioPlayerController {
    var showProgress : Bool {
        audioCachedURL == nil
    }
    @Published private var audioCachedURL : URL? = nil
    private let audioFirebaseURL: URL
    
    init(audioFirebaseURL: URL) {
        self.audioFirebaseURL = audioFirebaseURL
        super.init()
        AudioCacheManager.shared.getFileDirURLUsing(fileFirebaseURL: audioFirebaseURL) { [weak self]  url,error in
            if let audioCachedURL = url{
                DispatchQueue.main.async {
                    self?.audioCachedURL = audioCachedURL
                } 
            }
        }
    }
    
    func playRecordingIfNotPlaying(){
        guard let audioCachedURL = audioCachedURL else { return }
        if playRecording == false {
            playAudio(url : audioCachedURL)
        }else{
            stop()
        }
    }
    
    deinit {
        AudioCacheManager.shared.removeSubcriberIfExist(audioFirebaseURL)
    }
}



 
class RecordedAudioPlayerVM : AudioPlayerController {
    //will remove this
    var isLoading : Bool {
        false
    }
    func playRecordingIfNotPlaying(audioUrl: URL?){
        
        if playRecording == false, let recordedFileURL = audioUrl {
            playAudio(url : recordedFileURL)
        }else{
            stop()
        }
    }
     
}




class AudioPlayerController : ObservableObject{
    @Published private(set) var playRecording: Bool = false
    fileprivate var subs = Set<AnyCancellable>()
    private var avPlayer: AVPlayer  {
        AVPlayer.shared
    }
    
    fileprivate func playAudio(url : URL){
        VideoPlayerSetting.shared.enableVideoPlayInSilentMode() 
        avPlayer.replaceCurrentItem(with: nil)
        playRecording = true
        let avPlayerItem = AVPlayerItem(url: url)
        avPlayer.replaceCurrentItem(with: avPlayerItem)
        avPlayer.play()
        startStatusListener()
        startListenerForAVPlayerItem()
    }
    
    private func startStatusListener(){
        avPlayer.publisher(for: \.timeControlStatus)
            .sink { [weak self]  timeControlStatus in
                guard let self = self else { return }
                self.playRecording = timeControlStatus != .paused
                if self.playRecording == false {
                    self.stop()
                }
            }.store(in: &subs)
    }
    
    private func startListenerForAVPlayerItem() {
        avPlayer.publisher(for: \.currentItem)
            .filter{$0 == nil}
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.stopPlayingAnimation()
            }.store(in: &subs)
    }
    
    private func stopPlayingAnimation(){
        subs.removeAll()
        playRecording = false
    }
    
    fileprivate func stop(audioDirURL: URL? = nil){
        stopPlayingAnimation()
        
        if let audioDirURL = audioDirURL,
           let url = (avPlayer.currentItem?.asset as? AVURLAsset)?.url,
           url != audioDirURL{
            print("some other message is playing audio so no need to pause avPlayer")
            return
        }
        
        avPlayer.pause()
        avPlayer.replaceCurrentItem(with: nil)
    }
    
    func stopAndDelete(audioDirURL: URL?){
        stop(audioDirURL: audioDirURL)
        if let audioDirURL =  audioDirURL{
            AudioCacheManager.shared.removeTmpFile(dirURL: audioDirURL)
        }
    }
    deinit {
        if playRecording{
            stop()
        }
        subs.cancelAll()
    }

}




//class AudioPlayerVM : ObservableObject {
//   /// we can listene to the AVPlayer.shared status and update this property. but we do not, because we use to keep track of the current object
//    @Published private(set) var playRecording: Bool = false
//    @Published private(set) var isLoading : Bool = false
//    private var subs = Set<AnyCancellable>()
//    private var avPlayer: AVPlayer  {
//        AVPlayer.shared
//    }
//
//    private var audioFirebaseURL: URL?
//    func playRecordingIfNotPlaying(audioUrl: URL?){
//
//        if playRecording == false, let recordedFileURL = audioUrl {
//                playAudio(url : recordedFileURL)
//        }else{
//            stop()
//        }
//    }
//
//    fileprivate func playAudio(url : URL){
//        avPlayer.replaceCurrentItem(with: nil)
//        playRecording = true
//        let avPlayerItem = AVPlayerItem(url: url)
//        avPlayer.replaceCurrentItem(with: avPlayerItem)
//        avPlayer.volume = 90
//        avPlayer.play()
//        startStatusListener()
//        startListenerForAVPlayerItem()
//    }
//    private func startStatusListener(){
//        avPlayer.publisher(for: \.timeControlStatus)
//            .sink { [weak self]  timeControlStatus in
//                guard let self = self else { return }
//                self.isLoading = timeControlStatus == .waitingToPlayAtSpecifiedRate
//                self.playRecording = timeControlStatus != .paused
//                if self.playRecording == false {
//                    self.stop()
//                }
//            }.store(in: &subs)
//    }
//
//    private func startListenerForAVPlayerItem() {
//        avPlayer.publisher(for: \.currentItem)
//            .filter{$0 == nil}
//            .sink { [weak self] _ in
//                guard let self = self else { return }
//                self.stopPlayingAnimation()
//            }.store(in: &subs)
//    }
//
//    private func stopPlayingAnimation(){
//        subs.removeAll()
//        isLoading = false
//        playRecording = false
//    }
//
//    fileprivate func stop(audioDirURL: URL? = nil){
//        stopPlayingAnimation()
//
//        if let audioDirURL = audioDirURL,
//           let url = (avPlayer.currentItem?.asset as? AVURLAsset)?.url,
//           url != audioDirURL{
//            print("some other message is playing audio so no need to pause avPlayer")
//            return
//        }
//
//        avPlayer.pause()
//        avPlayer.replaceCurrentItem(with: nil)
//    }
//
//    func stopAndDelete(audioDirURL: URL?){
//        stop(audioDirURL: audioDirURL)
//        if let audioDirURL =  audioDirURL{
//            AudioCacheManager.shared.removeTmpFile(audioDirURL: audioDirURL)
//        }
//    }
//
//    //also need to check when we dismiss the view does file get deleted by the soung manger
//    deinit {
//        if playRecording{
//            stop()
//        }
//        subs.cancelAll()
//    }
//}


/*
 now we will start work on the AudioCacheManager. first we will see how do we hanlde the vidoe and then we will start work on the audio.
 one thing we need to cehck do we copy video to a tmp dir when user tap on send? or does we just use the url that pod give us.
 
 other than that i think we can use teh same VideoCacheManager for the
 
 //Users/apple/Library/Developer/CoreSimulator/Devices/9EC49B62-B067-429C-9DF1-F3A2C796A7FC/data/Containers/Data/Application/A9D91336-4D95-446E-B38E-7BA6A4CD61E6/tmp/EF946D71-96D3-4F8D-BDC7-5CAC54AB5E32.mov
 //Users/apple/Library/Developer/CoreSimulator/Devices/9EC49B62-B067-429C-9DF1-F3A2C796A7FC/data/Containers/Data/Application/7A720666-FFDA-4919-94F4-65B671E14AF4/Documents/Videos/8ADCF868-2649-4CCD-81C9-184F69CD57C2
 
 so we does use the same url as given by the pod. but we do save the video in the cache as well. so we would not have to fetch it after we send it. and if the video upload fails we just delete that video file from the cache dir.
 
 now the only issue is that in case of pod, it takes care of removing the selected video from its tmp dir.
 
 hmm
 for the comments we will go with this ,
 1. we will save the recorded audio in the temp. and will set it as audioUrl in the tmp folder just like the pod.
 2. now for removing uploaded files, we will delete it from the tmp like we delete the video from the cache. in this case we do not have a cached yet as we do not use a failedManager for the comments. so we will delete the audio file from the tmp on callback of the cloud func. we will add the func to delete the file in the  NewMedia .
 3. we will also clean tmp on app launch
 4. when we will use audio for objects with failed media we will just cahce them like video files and flow accordingly
 
 //            audioPlayer.currentItem?.publisher(for: \.self).sink { [weak self]  output in
 //                print("123#   audioPlayer.currentItem? isFromOpenedPost =  \(self?.isFromOpenedPost)")
 //
 //            }.store(in: &subs)
 dismissing the recorded audio by tapping on small x also stop the audio been played by other message
 */

