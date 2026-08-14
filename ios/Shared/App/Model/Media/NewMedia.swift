//
//  NewMedia.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 6/22/21.
//
  
#if os(iOS)
import UIKit
import YPImagePicker
import CLImageEditor
#endif

import AVKit
import RealmSwift
import SDWebImage.SDImageCache

///now we have added two ints, the reason is that because we need to make sure that both properties can not be nil at the same time.
struct SelectedMedia : Equatable{
    var newMedia : NewMedia?
    var audioUrl : URL?
    init(audioUrl : URL) {
        self.audioUrl = audioUrl
    }
    init(newMedia: NewMedia) {
        self.newMedia = newMedia
    }
    ///can only have one paramter, in case of give newMedia and audioUrl the init will return nil
//   private init?(newMedia: NewMedia?,audioUrl : URL?) {
//        if (newMedia == nil && audioUrl == nil) || (newMedia != nil &&  audioUrl != nil){
//            return nil
//        }
//        self.newMedia = newMedia
//        self.audioUrl = audioUrl
//    }
    
    var image : UIImage?{
        newMedia?.image
    }
    enum Kind : Int, Codable, PersistableEnum {
       case image
       case video
       case audio
   }
    
    func deleteCacheOfSelectedMediaIfAny(){
        if let audioDirURL = audioUrl{
            AudioCacheManager.shared.removeTmpFile(dirURL: audioDirURL)
        }else if let videoDirUrl = newMedia?.videoUrl{
            VideoCacheManager.shared.removeTmpFile(dirURL: videoDirUrl)
        }
    }
    
    static func deleteRealmObjectMediaFromCache(objectKey: String, kind: Kind) {
        if kind == .audio{
            AudioCacheManager.shared.removeFromTempCacheIfExist(key: objectKey)
        }else{
            NewMedia.deleteRealmObjectMediaFromCache(objectKey: objectKey, kind: kind)
        }
    }
    
    static func getSelectedMediaFromCacheFor(key: String,kind : Kind) -> SelectedMedia? {
        var selectedMedia : SelectedMedia?
        if kind == .audio{
            if let audioDirURL = AudioCacheManager.shared.getExisitngTempFileURL(key: key){
                selectedMedia =  SelectedMedia(audioUrl: audioDirURL)
            }
        }else if let newMedia = NewMedia.getMediaFromCacheFor(key: key, kind: kind) {
            selectedMedia = SelectedMedia(newMedia: newMedia)
        }
        return selectedMedia
    }
    static func isTempMediaCorrupted(objectKey: String,selectedMediaKind: Kind?) -> Bool {
        var isCorrupted = false
        if let selectedMediaKind = selectedMediaKind {
            if selectedMediaKind == .video {
                isCorrupted = !VideoCacheManager.shared.doesTmpFileExistFor(key: objectKey)
            }else if selectedMediaKind == .audio {
                isCorrupted = !AudioCacheManager.shared.doesTmpFileExistFor(key: objectKey)
            }
        }
        return isCorrupted
    }
}
/// i think we should not use audio in the NewMedai, because then we will have to mark image as nil and wil have to change it every where in the app we used teh image. And we have used image alot in the app.
struct NewMedia  : Equatable{
    //FIXME: - /// the image will should be nil when we will use recorded audio so for now we will just set a dummy image when we will use it for audio
   var image : UIImage
   var videoUrl : URL? = nil
   var description : String = ""
   var isFromCamera : Bool = false
    ///so as we kind is not a set property, so it is alright if we have more Kinds then image and video.
   var kind : Kind {
       return videoUrl == nil ?  .image : .video
   }
    typealias  Kind = SelectedMedia.Kind
}

//MARK:- saveInPhotosAlbum
 extension NewMedia     {
   func saveInPhotosAlbum( callback : @escaping ( _  error : Error?) -> Void) {
       NewMedia.saveInPhotosAlbum(newMedia: self, callback: callback)
   }
   
   static func saveInPhotosAlbum( newMedia : NewMedia , callback : @escaping ( _  error : Error?) -> Void) {
       MediaSaveManager.shared.saveInPhotosAlbum(newMedia: newMedia, completion: callback)
   }
   
   private class MediaSaveManager: NSObject {
       static var shared = MediaSaveManager()
       private var callback : (( _  error : Error?) -> Void)?
       func saveInPhotosAlbum(newMedia:NewMedia,completion : @escaping ( _  error : Error?) -> Void) {
           self.callback = completion
           
#if os(iOS)
           
           if let videoURL = newMedia.videoUrl {
               UISaveVideoAtPathToSavedPhotosAlbum(videoURL.path, self, #selector(videoSaved) , nil)
           }else {
               UIImageWriteToSavedPhotosAlbum(newMedia.image, self, #selector(imageSaved), nil)
           }
#endif
           
           
       }
       
       @objc private func imageSaved( _ image: UIImage?, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer?) {
           callback?(error)
           callback = nil
       }
       
       @objc private func videoSaved( video videoPath: String?, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer? ) {
           callback?(error)
           callback = nil
       }
   }
     func deleteFromRealm(objectKey : String){
         NewMedia.deleteRealmObjectMediaFromCache(objectKey: objectKey, kind: kind)
     }
 }

//MARK:- getMediaFromCacheFor
 extension NewMedia     {
       
    static fileprivate func getMediaFromCacheFor(key : String,kind : Kind) -> NewMedia? {
        if let image = UIImage.getFromCacheWith(key: key) {
            var newMedia  = NewMedia(image: image)
            if kind == .video {
//                if let videoUrl = VideoCacheManager.shared.tempDi rectoryFor(key: key) {
//                    if VideoCacheManager.shared.doesTmpFileExistFor(key: key) == false {
//                        assert(false, " what happend    ")
//                    }
              if let videoUrl = VideoCacheManager.shared.getExisitngTempFileURL(key: key) {
                    newMedia.videoUrl = videoUrl
                    return newMedia
                }else{
//                    assert(false, "nope ")
                }
            }
            return newMedia
        }else{
//            assert(false, "nope ")
            return nil
        }
    }
    ///NOTE:- it is onl
    static fileprivate func deleteRealmObjectMediaFromCache(objectKey : String,kind : Kind) {
          
        if kind == .video {
            VideoCacheManager.shared.removeFromTempCacheIfExist(key: objectKey)
        }
        SDImageCache.shared.removeImage(forKey: objectKey)
    }
   
     
}
//use in picker view
enum ParentView {
    case message
    case post
    case sendTo
    case userProfile
    case other
}
