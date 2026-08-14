//
//  NewPostFunctions.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 2/17/21.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFunctions
import SDWebImage
/*
 so in case of post, we need to update the T button text if from the  whats new label.
 */
class NewPostFunctions: ObservableObject, CloudFunction {
    init() {
          print(" NewPostFunctions ")
    }
     

    class func sendPost(rawPostModel : PostModel.Raw, callback : @escaping ( _  error : Error?) -> Void ) {
          
        print("Sending Post")
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let callBackClosure : ((Error?) -> Void) = { error in
            if error == nil { 
                DispatchQueue.main.async {
                    let informationDict = rawPostModel.getMentionDictInfo(currrentUserId: userId)
                    MentionFunctions.sendMentions(informationDict: informationDict)
                }
            }
            callback(error)
        }
        
        let postInformation = rawPostModel.postInformation
        
        if let audioDirURL = rawPostModel.audioDirURL {
            sendAudio(rawPostModel: rawPostModel, audioDirURL: audioDirURL, callback: callBackClosure)
        }else if let newMedia = rawPostModel.newMedia {
            sendPostWith(rawPostModel: rawPostModel, newMedia: newMedia, callback: callBackClosure)
        } else {
            sendPostCloudFunc(postInformation: postInformation, isPostTagged: rawPostModel.isPostTagged, callback: callBackClosure)
        }
    }
    class private func sendAudio(rawPostModel : PostModel.Raw,
                                 audioDirURL : URL,
                                 callback : @escaping (  _  error : Error?) -> Void) {
        
           let storageRef = Storage.storage().reference()
                .child("\(rawPostModel.id)")
                .child("TimelinePostAudios")
                .child(("\(rawPostModel.postID)/audio.m4a"))
        var postInformation = rawPostModel.postInformation
        uploadFile(fileDirURL: audioDirURL, fileType: .audio_m4a, storageRef: storageRef){ audioFirebaseUrl, error in
            if let _ = error   {
                print(error ?? "")
            }
                if let audioFirebaseUrl = audioFirebaseUrl {
                    postInformation["audioUrl"] = audioFirebaseUrl.absoluteString
                    sendPostCloudFunc(postInformation: postInformation, isPostTagged: rawPostModel.isPostTagged){ error in
                        if let _ = error {
                            AudioCacheManager.shared.removeTmpFile(dirURL: audioDirURL)
                            callback(error)
                        }
                        callback(error)
                    }
                    AudioCacheManager.shared.saveInFileCache(tempFileURL: audioDirURL, firebaseFileURL: audioFirebaseUrl) 
                } else{
                    callback(error ?? "Was not able to upload audio".asError)
                }        }
    }
    class private func sendPostWith(rawPostModel : PostModel.Raw,
                               newMedia : NewMedia,
                               callback : @escaping (  _  error : Error?) -> Void) {
        
        if let VideoFirebaseUrl = newMedia.videoUrl  {
            sendVideoPost(rawPostModel: rawPostModel,
                          thumbnailImage: newMedia.image,
                          videoDirURL: VideoFirebaseUrl,
                          callback: callback)
            return
        }
        
        //post have an image not a video
        let sendImagePost = {
            var postInformation = rawPostModel.postInformation
            let postID = rawPostModel.postID
            let postImage = newMedia.image
            var storage = Storage.storage().reference()
            guard let imageData = postImage.highestQualityJPEGNSData else {
                callback(NSError.getWith(description: "Image highestQualityJPEGNSData Failed"))
                return
            }
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            storage = storage
                .child("\(rawPostModel.id)")
                .child("TimelinePostPhotos")
                .child("\(postID)/newPost.jpeg")
            storage.putData(imageData, metadata: metadata) { (meta, error) in
                if let error = error {
                    callback(error)
                } else  {
                    storage.downloadURL { url, error in
                        if let imageURL = url {
                            SDImageCache.shared.add(image: postImage, url: imageURL)
                            postInformation["photoLink"] = imageURL.absoluteString
                            sendPostCloudFunc(postInformation: postInformation, isPostTagged: rawPostModel.isPostTagged){ error in
                                if let _ = error {
                                    SDImageCache.shared.removeImage(forKey: imageURL.absoluteString)
                                }
                                callback(error)
                            }
                        }else if let error = error {
                            callback(error)
                        }
                    }
                }
            }
        }//"C9D523A7-3B90-4E6A-A313-4656FEA01BCD"
        
         sendImagePost()
    }
     
    class private func sendVideoPost(rawPostModel : PostModel.Raw,
                                     thumbnailImage : UIImage,
                                     videoDirURL : URL,
                                     callback : @escaping (  _  error : Error?) -> Void){
        
        var postInformation = rawPostModel.postInformation
        var thumbnailFirebaseUrl : URL! = nil
        var VideoFirebaseUrl : URL! = nil
        let dispatchGroup = DispatchGroup()
        
        let uploadImage = {
            let messagePhoto = thumbnailImage
            var storageRef = Storage.storage().reference()
            guard let imageData = messagePhoto.highestQualityJPEGNSData else {
                callback(NSError.getWith(description: "Image highestQualityJPEGNSData Failed"))
                return
            }
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            dispatchGroup.enter()
            storageRef = storageRef
                
                .child("\(rawPostModel.id)")
                .child("TimelinePostVideos")
                .child("Video-\(rawPostModel.postID)")
                .child("thumbnail.jpeg")
            storageRef.putData(imageData, metadata: metadata) { (meta, error) in
                if let error = error {
                    print(error.localizedDescription)
                    dispatchGroup.leave()
                } else {
                    
                    storageRef.downloadURL { url, error in
                        if let url = url {
                            thumbnailFirebaseUrl = url
                        }
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        let uploadVideo = {
           
            var storageRef = Storage.storage().reference()
            let metadata = StorageMetadata()
            metadata.contentType = "video/quicktime"
            dispatchGroup.enter()
            storageRef = storageRef
                .child("\(rawPostModel.id)")
                .child("TimelinePostVideos")
                .child("Video-\(rawPostModel.postID)")
                .child("video.mov")
            storageRef.putFile(from: videoDirURL, metadata: metadata ) { (meta, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        dispatchGroup.leave()
                    } else {
                        storageRef.downloadURL { url, error in
                            if let url = url {
                                VideoFirebaseUrl = url
                            }
                            dispatchGroup.leave()
                        }
                     }
                }
        }
        
        uploadImage()
        uploadVideo()
        
        dispatchGroup.notify(queue: .main) {
            if let videoUrl = VideoFirebaseUrl ,
               let thumbnailUrl = thumbnailFirebaseUrl  {
                postInformation["thumbnailUrl"] = thumbnailUrl.absoluteString
                postInformation["videoUrl"] = videoUrl.absoluteString
                sendPostCloudFunc(postInformation: postInformation, isPostTagged: rawPostModel.isPostTagged){ error in
                    if let _ = error   {
                        VideoCacheManager.shared.removeFromTempCacheIfExist(fileFirebaseURL: videoUrl)
                        SDImageCache.shared.removeImage(forKey: thumbnailUrl.absoluteString)
                    }
                    callback(error)
                }
                SDImageCache.shared.add(image: thumbnailImage, url: thumbnailUrl)
                VideoCacheManager.shared.saveInFileCache(tempFileURL: videoDirURL, firebaseFileURL: videoUrl)
            }else{
                callback(NSError.getWith(description: "was not able to upload video"))
            }
        }
    }
     
    class private func sendPostCloudFunc(postInformation: [String : Any], isPostTagged: Bool ,callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        print("calling sendPost-sendPost with informationDict")
        print(postInformation)
        
        var cloudFunc = Constant.sendPostCloudFunc()
        if isPostTagged {
            cloudFunc = Constant.sendTaggedPostCloudFunc()
        }
        Self.call(funcName: cloudFunc, informationDict: postInformation, callback: callback) 
    }
   
    
    enum Constant : String {
        case sendPostCloudFunc = "sendPostTest-sendPostTest"
        case sendTaggedPostCloudFunc = "sendTaggedPost-sendTaggedPost"
        case modifyMomentCloudFunc = "modifyMoment-modifyMoment"
        case modifyTaggedMomentCloundFunc = "modifyTaggedMoment-modifyTaggedMoment"
    }
    
}
 
  
///post func when user change bio
extension NewPostFunctions {
    
    func sendChangedBioPost (content: String) {
        Self.sendChangedBioPost(content: content)
    }
    
    class func sendChangedBioPost (content: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        print("Sending Post")
        var postInformation = [String: Any]()
        let postID = "\(UUID())"
        
        postInformation = [
            "sentBy": userId,
            "content": content.trimWhitespacesAndNewlines(),
            "postID": postID
        ]
        sendPostCloudFunc(postInformation: postInformation, isPostTagged: false)
    }
     
}

extension NewPostFunctions {
        
    class func didTakeScreenShotOf(postID: String,
                                   postAuthor : String,
                                   currentUser : String,
                                     callback: @escaping (Error?) -> Void = {_ in }){
        let informationDict : [String : Any] =
            ["postID" : postID,
             "postAuthor" : postAuthor,
             "currentUser": currentUser,
             "didTakePostScreenshot" : true]
        Self.call(funcName: "didTakePostScreenshot-didTakePostScreenshot" , informationDict: informationDict, callback: callback)
    }
    ///we will also need to check the content if there are user name i think
    class func edit(postID : String,author : String, content : String,
                    callback: @escaping (Error?) -> Void = {_ in }){
        let newPostInformation : [String : Any] =
            ["postID" : postID,
             "currentUser" : author,
             "content": content ]
    //    modifyMoment-modifyMoment
//        const newPostInformation = {
//        currentUser: postInformation[" currentUser"],
//        postID: postInformation["postID"],
//        content: postInformation["content"],
//        }:
//        modifyMoment.modifyMoment({newPostInformation})
        Self.call(funcName: "modifyMoment-modifyMoment" , informationDict: newPostInformation, callback: callback)
    }
    
    class func updateExistingPost(post : PostModel, callback: @escaping (Error?) -> Void = {_ in }){
    
        let dateFormat = DateFormatter()
       
        dateFormat.dateFormat = "YYYY/MM/d HH:mm:ssZ"
        let updatedAt = dateFormat.string(from: post.time.dateValue())
        
        let newPostInformation : [String : Any] =
        ["postID" : post.postID,
         "userID" : post.id,
         "updatedAt" : updatedAt] 
        //  updateAt.seconds  updateAt.nanoseconds
        Self.call(funcName: "updateUpdatedAt-updateUpdatedAt" , informationDict: newPostInformation, callback: callback)

    }
    
}
 /*
  so for now we need a view were we can update a post from
  */ 

