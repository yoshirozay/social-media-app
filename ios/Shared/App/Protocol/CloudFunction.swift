//
//  CloudFunction.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 5/10/21.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFunctions
import SDWebImage

protocol CloudFunction { }

extension CloudFunction {
    
    static func call(funcName : String, informationDict : Any, callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
//                        Timer .scheduledTimer(withTimeInterval: 5, repeats: false) { (_) in
////                            let nsError = NSError(domain: "local", code: 00000, userInfo: [NSLocalizedDescriptionKey:" "])
////                            callback(nsError)
//                            callback(nil)
//                        }
        Functions.functions().httpsCallable(funcName).call(informationDict) { (result, error) in
            callback(error)
            if let error = error as NSError? {
                print("\(funcName) got error \(error)")
                if error.domain == FunctionsErrorDomain {
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            print("\(funcName) CloudFunction = \(String(describing: result?.data))")
        }
    }
    
    static func callWithVideoInfo(funcName : String,
                              informationDict : [String :Any],
                              VideoFirebaseUrl : URL?,
                              thumbnailFirebaseUrl : URL?, videoDirURL : URL,
                              thumbnailImage : UIImage,
                              doHaveFailedManager : Bool = true,
                              isAnEdit: Bool = false,
                              callback : @escaping ( _  error : Error?) -> Void = {_ in }){
        if let videoUrl = VideoFirebaseUrl,
           let thumbnailUrl = thumbnailFirebaseUrl  {
            var informationDict = informationDict
            informationDict["thumbnailUrl"] = thumbnailUrl.absoluteString
            informationDict["videoUrl"] = videoUrl.absoluteString
            call(funcName: funcName, informationDict: informationDict){ error in
                if let _ = error   {
                    VideoCacheManager.shared.removeFromTempCacheIfExist(fileFirebaseURL: videoUrl)
                    SDImageCache.shared.removeImage(forKey: thumbnailUrl.absoluteString)
                }else if doHaveFailedManager == false{
                    SDImageCache.shared.add(image: thumbnailImage, url: thumbnailUrl)
                    VideoCacheManager.shared.saveInFileCache(tempFileURL: videoDirURL, firebaseFileURL: videoUrl)
                }
                callback(error)
            }
            if doHaveFailedManager {
                SDImageCache.shared.add(image: thumbnailImage, url: thumbnailUrl)
                VideoCacheManager.shared.saveInFileCache(tempFileURL: videoDirURL, firebaseFileURL: videoUrl)
            }
        }else{
            callback(NSError.getWith(description: "Was not able to upload video"))
        }
    }
    static func callWithAudioInfo(funcName : String,
                                  informationDict : [String :Any],
                                  audioFirebaseUrl : URL?,
                                  audioDirURL : URL,
                                  doHaveFailedManager : Bool = true,
                                  isAnEdit: Bool = false,
                                  callback : @escaping ( _  error : Error?) -> Void = {_ in }){
        if let audioUrl = audioFirebaseUrl { 
            var informationDict = informationDict
            informationDict["audioUrl"] = audioUrl.absoluteString
            call(funcName: funcName, informationDict: informationDict){ error in
                if let _ = error   {
                    print(error ?? "")
                }else if doHaveFailedManager == false{
                    AudioCacheManager.shared.saveInFileCache(tempFileURL: audioDirURL, firebaseFileURL: audioDirURL) 
                }
                AudioCacheManager.shared.removeTmpFile(dirURL: audioDirURL)
                callback(error)
            }
            
            if doHaveFailedManager{
                AudioCacheManager.shared.saveInFileCache(tempFileURL: audioDirURL, firebaseFileURL: audioDirURL)
            }
        }else{
            callback(NSError.getWith(description: "Was not able to upload audio"))
        }
    }
    
    static func callWithImageInfo(funcName : String,
                                  informationDict : [String :Any],
                                  image : UIImage,
                                  imageURL : URL?,
                                  doHaveFailedManager : Bool = true,
                                  callback : @escaping ( _  error : Error?) -> Void = {_ in }){
        if let imageURL = imageURL   {
            var informationDict = informationDict
            informationDict["photoLink"] = imageURL.absoluteString
            call(funcName: funcName, informationDict: informationDict){ error in
                if let _ = error   {
                    SDImageCache.shared.removeImage(forKey: imageURL.absoluteString)
                }else if doHaveFailedManager == false{
                    SDImageCache.shared.add(image: image, url: imageURL)
                }
                callback(error)
            }
            if doHaveFailedManager{
                SDImageCache.shared.add(image: image, url: imageURL)
            }
        }else{
            callback( "Was not able to upload Image".asError)
        }
    }
    
    static func uploadImage(image: UIImage,storageRef: StorageReference,callback : @escaping (_ thumbnailFirebaseUrl : URL?,_  error : Error?) -> Void) {
        guard let imageData = image.highestQualityJPEGNSData else {
            callback(nil,"Image highestQualityJPEGNSData Failed".asError)
            return
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef.putData(imageData, metadata: metadata) { (meta, error) in
            if let error = error {
                callback(nil,error)
            } else {
                storageRef.downloadURL(completion:callback)
            }
        }
    }
    
    static func uploadVideo(videoDirURL: URL,storageRef: StorageReference,callback : @escaping (_ VideoFirebaseUrl : URL?,_  error : Error?) -> Void) {
        uploadFile(fileDirURL: videoDirURL,fileType: .video_quicktime,storageRef: storageRef,callback: callback)
    }
    
    static func uploadAudio(audioDirURL: URL,storageRef: StorageReference,callback : @escaping (_ AudioFirebaseUrl : URL?,_  error : Error?) -> Void) {
        uploadFile(fileDirURL: audioDirURL,fileType: .audio_m4a,storageRef: storageRef,callback: callback)
    }
    
    static func uploadFile(fileDirURL: URL,fileType: UploadingFileType,storageRef: StorageReference,callback : @escaping (_ fileFirebaseUrl : URL?,_  error : Error?) -> Void) {
        let metadata = StorageMetadata()
        metadata.contentType = fileType()
        storageRef.putFile(from: fileDirURL, metadata: metadata ) { (meta, error) in
            if let error = error {
                callback(nil,error)
            } else {
                storageRef.downloadURL(completion:callback)
            }
        }
    }
}
 enum UploadingFileType : String{
    case video_quicktime = "video/quicktime"
    case audio_m4a = "audio/m4a"
}
 

enum UploadModelType {
    case message
    case post
    case comment
    case profile
}
