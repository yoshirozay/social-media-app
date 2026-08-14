//
//  SoundManager.swift
//  speakEZ
//
//  Created by Ahmad naeem on 5/18/22.
//
  
import AVFoundation
import Combine
import UIKit.UIApplication
 

///as we user can only record one recording at a time , but there can be more then one recorded audio waiting to be sent or which are still uploading.  so we need a
///we can add time intervals as id for saving audio Date().timeIntervalSince1970
class SoundManager : NSObject,ObservableObject {
    @Published private var recorder : AVAudioRecorder?
    @Published private (set) var isRecording = false
    @Published private (set) var soundSamples = [Float]()
    private var subs = Set<AnyCancellable>()
    private var timer = Timer()
    private var currentSample = Int()
    private var avPlayer: AVPlayer  {
        AVPlayer.shared
    }
    let numberOfSamples: Int = 30
    let recoredAudioURLPublisher = PassthroughSubject<URL?,Never>()
    
    ///need to show error in case user has not granted app permission
    func recordAudio(callback : @escaping (_ error : Error?) -> Void = {_ in}) {
        guard recorder?.isRecording != true else {
            stopRecording()
            return
        } 
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.recordPermission == .granted {
            startAudioRecording(callback: callback)
        }else{
            audioSession.requestRecordPermission { [weak self]  (isGranted) in
                if !isGranted {
                    callback("You need to allow audio recording".asError)
                }else{
                    DispatchQueue.main.async {
                        self?.startAudioRecording(callback: callback)
                    }
                }
            }
        }
    }
    
    func startAudioRecording(callback : @escaping (_ error : Error?) -> Void ) {
        if  avPlayer.isPlayingAudioOnly{
            avPlayer.replaceCurrentItem(with: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.startRecording(callback: callback)
            }
        }else{
            startRecording(callback: callback)
        }
    }
    
    func startRecording(callback : @escaping (_ error : Error?) -> Void ) {
           guard let url = tmpAudiosDirUrl else {
               callback("tmp Audios Dir Url was nil".asError)
               return
           }
        
            self.soundSamples = [Float](repeating: .zero, count: numberOfSamples)
            self.currentSample = 0
             
            let fileName = String(Date().timeIntervalSince1970)+".m4a"
            let fileURL = url.appendingPathComponent(fileName)
            let settings = [
                AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey : 48000,
                AVNumberOfChannelsKey : 1,
                AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
            ]
        
        do{
            self.recorder = try AVAudioRecorder(url: fileURL, settings: settings)
            self.recorder?.delegate = self
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
            startRecorder()
            startMonitoring()
            addlisteners()
        }catch{
            callback(error)
        }
    }
    
    func addlisteners(){
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification).sink { [weak self] _ in
                self?.stopAndDelete()
            }.store(in: &subs)
        
        avPlayer.publisher(for: \.timeControlStatus).filter({$0 == .playing}).sink { [weak self]  _ in
                    self?.stopAndDelete()
            }.store(in: &subs)
    }
    
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {[weak self] (timer) in
            guard let self = self else { return  }
            self.recorder?.updateMeters()
            self.soundSamples[self.currentSample] = self.recorder?.averagePower(forChannel: 0) ?? 0
            self.currentSample = (self.currentSample + 1) % self.numberOfSamples
        }
    }
    
    func startRecorder(){
        recorder?.isMeteringEnabled = true
        isRecording = true
        recorder?.record(forDuration: recordingMaxDuration)
    }
    
    deinit {
        stopAndDelete()
    }
    
    var tmpAudiosDirUrl : URL? {
        AudioCacheManager.shared.tmpAudiosDirUrl
    }
    
 let recordingMaxDuration : TimeInterval = 120
}

//MARK: - All recording stopping funcs
extension SoundManager {
    func stopRecorder(){
        recorder?.stop()
        isRecording = false
    }
    
    @discardableResult
    private func stopRecording() -> URL? {
           let recordedFileURL = recorder?.url
           stopRecorder()
           timer.invalidate() 
           recorder = nil
           subs.cancelAll()
           return recordedFileURL
       }
       
       func stopAndDelete(){
           if self.recorder?.isRecording == true{
               let oldRecorder = self.recorder
               oldRecorder?.delegate = nil
               ///so we are sending nil, because if there was a audioUrl in the selectedMedia then its file is deleted so we should also mark selectedMedia nil as well.
               recoredAudioURLPublisher.send(nil)
               stopRecording()
               oldRecorder?.deleteRecording()
           }
       }
}
 
extension SoundManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            stopAndDelete()
        }else if let url = stopRecording(){
            recoredAudioURLPublisher.send(url)
//            print("123# before recorder?.currentTime \(recorder.currentTime)")
//            let url = recorder.url
//            let audioAsset = AVURLAsset.init(url: url, options: nil)
//            let duration = audioAsset.duration
//            print("123# after duration \(duration.seconds)")
        }
    }
     
}
