//
//  ModifyPostFunctions.swift
//  speakEZ
//
//  Created by Ahmad naeem on 6/5/22.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFunctions
import SDWebImage
/*
 first of all we will check does the oldPostMedia have any selectedMedia or newMedia. if yes
 then we will check oldPost for any kind of media. if found any we will add the delete<MeidaType> and oldFoldername in teh dict.
 
 now if we do not get any media from oldPostMEdia. then we will compare its urls with old post. if found any missing, we will add delete<mediaType> + oldFolderName in the dict.
 so now fist let us implement this
 */
class ModifyPostFunctions: CloudFunction {
    struct DeleteInfo {
        let oldFolderName: String
        let mediaKind: NewMedia.Kind
        var deletedMedia : String{
            switch mediaKind {
            case .video:
                return "deleteVideo"
            case .image:
                return "deletePhoto"
            case .audio:
                return "deleteAudio"
            }
        }
        var dict: [String : Any] { [deletedMedia: true, "oldFolderName": oldFolderName] }
    }
    
   class func modifyMoment(rawPostModel: PostModel.Raw,oldPost: PostModel, oldPostMedia: OldPostMedia, callback : @escaping ( _  error : Error?) -> Void ) {
       // photoLink: URL?, thumbnailUrl: URL?, videoUrl: URL?,
    
       var deleteInfo: DeleteInfo?
       if let mediaKind = oldPost.mediaKind,
          oldPostMedia.mediaKind != mediaKind,
          let firebaseFolderName = oldPost.firebaseFolderName {
           deleteInfo = DeleteInfo(oldFolderName: firebaseFolderName, mediaKind: mediaKind)
       }
     
       let timeintervals = String(Date().timeIntervalSince1970)
       let mediaVersionStr = timeintervals+"+"+String(oldPost.mediaVersion+1)
         
       if let newMedia = rawPostModel.newMedia {
           updateMediaPost(rawPostModel: rawPostModel, newMedia: newMedia, mediaVersionStr: mediaVersionStr, deleteInfo: deleteInfo, callback: callback)
       }else if let newAudioDirURL = rawPostModel.audioDirURL {
           updateAudioPost(rawPostModel: rawPostModel,
                           audioDirURL: newAudioDirURL,
                           mediaVersionStr: mediaVersionStr,
                           deleteInfo: deleteInfo,
                           callback: callback)
       } else {
           
           var postInformation = rawPostModel.modifiedPostInformation
           if let deleteInfo = deleteInfo{
               postInformation.merge(deleteInfo.dict){ (_, new) in new } 
           }else {
               if let photoLink = oldPost.photoLink {
                   postInformation["photoLink"] = photoLink.absoluteString
               }else if let thumbnailUrl = oldPost.thumbnailUrl, let videoUrl = oldPost.videoUrl {
                   postInformation["thumbnailUrl"] = thumbnailUrl.absoluteString
                   postInformation["videoUrl"] = videoUrl.absoluteString
               } else if let audioUrl = oldPost.audioUrl {
                   postInformation["audioUrl"] = audioUrl.absoluteString
               }
           }
           // so now if user has selected any type of media, we will check the old post media, and mark it true in the
           modifyMomentCloudFunction(postInformation: postInformation, isPostTagged: rawPostModel.isPostTagged, callback: callback)
       }
       
   }
    /*
     so we have 4 typs of posts.
     1. text only
     2. image
     3. video
     4. audio
     but mainly we have two types of post
     1. without any media
     2. a media post (image/video/audio)
     
     so now user can convert one type of post to another type of post and we need to think for all scenarios
     2^2=4
    
     */
   
    class func updateMediaPost(rawPostModel: PostModel.Raw,
                               newMedia: NewMedia,
                               mediaVersionStr: String,
                               deleteInfo: DeleteInfo?,
                               callback: @escaping (Error?) -> Void) {
       
      if let VideoFirebaseUrl = newMedia.videoUrl  {
           updateVideoPost(rawPostModel: rawPostModel,
                           thumbnailImage: newMedia.image,
                           videoDirURL: VideoFirebaseUrl,
                           mediaVersionStr: mediaVersionStr,
                           deleteInfo: deleteInfo,
                           callback: callback)
           return
       }
       
       let updateImagePost = {
           let imageFileName = "\(mediaVersionStr)+\(rawPostModel.postID)"
           let image = newMedia.image
           let storage = Storage.storage().reference()
               .child(rawPostModel.id)
               .child("TimelinePostPhotos")
               .child(imageFileName)
               .child("newPost.jpeg")
           Self.uploadImage(image: image, storageRef: storage) { url, error in
               let funcName : Constant = rawPostModel.isPostTagged ? .modifyTaggedMomentCloundFunc : .modifyMomentCloudFunc
               var informationDict = rawPostModel.modifiedPostInformation
               if let deleteInfo = deleteInfo{
                   informationDict.merge(deleteInfo.dict){ (_, new) in new }
               }
               Self.callWithImageInfo(funcName: funcName(),
                                      informationDict: informationDict,
                                      image: image,
                                      imageURL: url,
                                      doHaveFailedManager: false,
                                      callback:callback)
           }
       }
       updateImagePost()
   }
    
   class private func updateVideoPost(rawPostModel : PostModel.Raw,
                                      thumbnailImage : UIImage,
                                      videoDirURL : URL,
                                      mediaVersionStr: String,
                                      deleteInfo: DeleteInfo?,
                                      callback : @escaping (  _  error : Error?) -> Void) {
      
      var thumbnailFirebaseUrl : URL! = nil
      var VideoFirebaseUrl : URL! = nil
      let dispatchGroup = DispatchGroup()
      func getStorageRef(forVideo : Bool) -> StorageReference {
           let fileName = "\(mediaVersionStr)+Video-\(rawPostModel.postID)"
         return Storage.storage().reference()
              .child(rawPostModel.id)
              .child("TimelinePostVideos")
          //               .child("EditVideo-\(rawPostModel.postID)")
              .child(fileName)
              .child(forVideo ? "video.mov" : "thumbnail.jpeg")
      }
      
      dispatchGroup.enter()
      uploadImage(image: thumbnailImage, storageRef: getStorageRef(forVideo : false)) { url, error in
          thumbnailFirebaseUrl = url
          dispatchGroup.leave()
      }
      
      dispatchGroup.enter()
      uploadVideo(videoDirURL: videoDirURL, storageRef: getStorageRef(forVideo : true)) { url, error in
          VideoFirebaseUrl = url
          dispatchGroup.leave()
      }
       
      dispatchGroup.notify(queue: .main) {
          let funcName : Constant = rawPostModel.isPostTagged ? .modifyTaggedMomentCloundFunc : .modifyMomentCloudFunc
          var informationDict = rawPostModel.modifiedPostInformation
          if let deleteInfo = deleteInfo{
              informationDict.merge(deleteInfo.dict){ (_, new) in new }
          }
          callWithVideoInfo(funcName: funcName(),
                            informationDict: informationDict,
                            VideoFirebaseUrl: VideoFirebaseUrl,
                            thumbnailFirebaseUrl: thumbnailFirebaseUrl,
                            videoDirURL: videoDirURL,
                            thumbnailImage: thumbnailImage,
                            doHaveFailedManager: false,
                            isAnEdit: true,
                            callback: callback)
      }
  }
 //    class private func updateAudioPost
    class private func updateAudioPost(rawPostModel : PostModel.Raw,
                                       audioDirURL : URL,
                                       mediaVersionStr: String,
                                       deleteInfo: DeleteInfo?,
                                       callback : @escaping (  _  error : Error?) -> Void) {
        
           let storageRef = Storage.storage().reference()
                .child(rawPostModel.id)
                .child("TimelinePostAudios")
                .child("\(mediaVersionStr)+\(rawPostModel.postID)")
                .child("audio.m4a")
        var postInformation = rawPostModel.postInformation

        uploadFile(fileDirURL: audioDirURL, fileType: .audio_m4a, storageRef: storageRef) { audioFirebaseUrl, error in
                if let audioFirebaseUrl = audioFirebaseUrl {
                    postInformation["audioUrl"] = audioFirebaseUrl.absoluteString
                    let funcName : Constant = rawPostModel.isPostTagged ? .modifyTaggedMomentCloundFunc : .modifyMomentCloudFunc
                    var informationDict = rawPostModel.modifiedPostInformation
                    if let deleteInfo = deleteInfo{
                        informationDict.merge(deleteInfo.dict){ (_, new) in new }
                    }
                    callWithAudioInfo(funcName: funcName(),
                                      informationDict: informationDict,
                                      audioFirebaseUrl: audioFirebaseUrl,
                                      audioDirURL: audioDirURL,
                                      doHaveFailedManager: false,
                                      isAnEdit: true,
                                      callback: callback)
                }
                if let _ = error   {
                    print(error ?? "")
                }
        }
    }
    
    class private func modifyMomentCloudFunction(postInformation: [String : Any], isPostTagged: Bool ,callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        print("calling modifyMoment-modifyMoment with informationDict")
        print(postInformation)
        
        var cloudFunc = Constant.modifyMomentCloudFunc()
        if isPostTagged {
            cloudFunc = Constant.modifyTaggedMomentCloundFunc()
        }
        Self.call(funcName: cloudFunc, informationDict: postInformation, callback: callback)
    }
    
    enum Constant : String {
        case modifyMomentCloudFunc = "modifyMoment-modifyMoment"
        case modifyTaggedMomentCloundFunc = "modifyTaggedMoment-modifyTaggedMoment"
    }
}
//if file does not exist in this path, then it means that cloud func have successfully written new file on the path of old file.
//
//but if file exist in this path, then it means that cloud func did
/*
 as we have decided we will update the file upload path for each update . for that we will add 2video,3video,4video
 */
