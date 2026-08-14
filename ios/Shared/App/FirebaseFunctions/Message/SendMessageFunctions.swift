//
//  SendMessageFunctions.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 2/18/21.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFunctions
import FirebaseFirestore
import FirebaseStorage
import SDWebImage

class SendMessageFunctions: ObservableObject , CloudFunction {
    
   
    
    class func sendNewMessage(messageRaw: MessageModel.Raw, isAResend: Bool = false, callback: @escaping (_ error : Error?) -> Void) {
//
        if  messageRaw.isContentEmpty {
            callback(NSError.getWith(description: "user tap on send button, before it changes back to photo icon"))
            return
        }
      
        if !isAResend  {
           messageRaw.saveInCache()
        }
//        return
        
        if let audioDirURL = messageRaw.audioDirURL {
            sendAudio(messageRaw: messageRaw,
                      audioDirURL: audioDirURL){ error in
                messageRaw.updateCacheCopy(isSentSuccessfully: error == nil)
                callback(error)
            }
        }else if let newMedia = messageRaw.newMedia {
            sendMessageWith( isFirstMessage: messageRaw.isFirstMessage,
                             newMedia: newMedia,
                             chatUID: messageRaw.chatUID,
                             messageUID: messageRaw.messageUID,
                             messageInformation: messageRaw.messageInformation){ error in
                messageRaw.updateCacheCopy(isSentSuccessfully: error == nil)
                callback(error)
            }
        } else {
            Self.sendMessageUsingCouldFunc( isFirstMessage: messageRaw.isFirstMessage,
                                            messageInformation: messageRaw.messageInformation){ error in
                messageRaw.updateCacheCopy(isSentSuccessfully: error == nil)
                callback(error)
            }
        }
    }
    
    class private func sendMessageWith(isFirstMessage : Bool ,newMedia : NewMedia,chatUID : String, messageUID : String,  messageInformation : [String:Any],callback : @escaping ( _  error : Error?) -> Void ) {
         
        if let VideoFirebaseUrl = newMedia.videoUrl  {
            sendVideoMessage(isFirstMessage: isFirstMessage,
                             thumbnailImage: newMedia.image,
                             videoDirURL: VideoFirebaseUrl,
                             chatUID: chatUID,
                             messageUID: messageUID,
                             messageInformation: messageInformation,
                             callback: callback)
            return
        }
          
        let messagePhoto = newMedia.image
        guard let imageData = messagePhoto.highestQualityJPEGNSData else {
                callback(NSError.getWith(description: "Image highestQualityJPEGNSData Failed"))
                return
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        var storage = Storage.storage().reference()
        storage = storage
            .child(chatUID)
            .child(messageUID)
            .child("newPost.jpeg")
        
        storage.putData(imageData, metadata: metadata) { (meta, error) in
                if let error = error {
                    callback(error)
                    return
                } else {
                    storage.downloadURL { url, error in
                        if let downloadedURL = url {
                            var messageInformation = messageInformation
                            SDImageCache.shared.add(image: messagePhoto, url: downloadedURL)
                            messageInformation["photoLink"] = downloadedURL.absoluteString
                            Self.sendMessageUsingCouldFunc(isFirstMessage: isFirstMessage, messageInformation: messageInformation ){ error in
                                if let _ = error  {
                                    SDImageCache.shared.removeImage(forKey: downloadedURL.absoluteString)
                                }
                                callback(error)
                            }
                        }
                       
                    }
                }
            }
    }
    
    class private func sendVideoMessage(isFirstMessage : Bool ,
                                thumbnailImage : UIImage,
                                 videoDirURL : URL,
                                 chatUID : String,
                                 messageUID : String,
                                 messageInformation : [String:Any],
                                 callback : @escaping (  _  error : Error?) -> Void = {  _ in}){
        
        
        guard let userId = Auth.auth().currentUser?.uid else{
            return
        }
        
        var messageInformation = messageInformation
        var thumbnailFirebaseUrl : URL! = nil
        var VideoFirebaseUrl : URL! = nil
        let dispatchGroup = DispatchGroup()
        /*
         CurrentUserID/QuickPhotos/MediaUUID
         */
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
                .child(userId)
                .child("QuickPhotos")
                .child(messageUID)
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
//            storageRef = storageRef
//                .child(chatUID)
//                .child("Video-\(messageUID)")
//                .child("video.mov")
            
            storageRef = storageRef
                .child(userId)
                .child("QuickPhotos")
                .child(messageUID)
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
                messageInformation[MessageModel.Constant.thumbnailUrl()] = thumbnailUrl.absoluteString
                messageInformation[MessageModel.Constant.videoUrl()] = videoUrl.absoluteString
                Self.sendMessageUsingCouldFunc(isFirstMessage: isFirstMessage, messageInformation: messageInformation ){ error in
                    if let error = error {
                        print(error.localizedDescription)
                        VideoCacheManager.shared.removeFromTempCacheIfExist(fileFirebaseURL: videoUrl)
                        SDImageCache.shared.removeImage(forKey: thumbnailUrl.absoluteString)
                    }
                    callback(error)
                }
                
                SDImageCache.shared.add(image: thumbnailImage, url: thumbnailUrl)
                VideoCacheManager.shared.saveInFileCache(tempFileURL: videoDirURL, firebaseFileURL: videoUrl)
                
            }else{
               let error = NSError.getWith(description: "Sending Message Failed")
                callback(error)
            }
        }
    }
    ///replace this func with the cloudFunc one
    ///
    class private func sendAudio(messageRaw: MessageModel.Raw,
                                 audioDirURL : URL,
                                 callback : @escaping (  _  error : Error?) -> Void) {
        
           let storageRef = Storage.storage().reference()
                .child(messageRaw.chatUID)
                .child(messageRaw.messageUID)
                .child("audio.m4a")
 
        let funcName = messageRaw.funcName
        uploadFile(fileDirURL: audioDirURL, fileType: .audio_m4a, storageRef: storageRef){ audioFirebaseUrl, error in
                callWithAudioInfo(funcName: funcName,
                                  informationDict: messageRaw.messageInformation,
                                  audioFirebaseUrl: audioFirebaseUrl,
                                  audioDirURL: audioDirURL,
                                  doHaveFailedManager: true,
                                  callback: callback)
        }
    }

    class private func sendMessageUsingCouldFunc(isFirstMessage : Bool  ,
                                                 messageInformation: [String : Any],
                                                 callback : @escaping ( _  error : Error?) -> Void ) {
        var isViewOnceMessage : Bool = false
        let isGroupMessage : Bool = messageInformation[MessageModel.Constant.otherUserID()] == nil
        
        if let _ = messageInformation[MessageModel.Constant.alreadyViewOnce()] as? Bool{
            isViewOnceMessage = true //messageInformation[MessageModel.Constant.alreadyViewOnce()] != nil
        }
        let funcName = CloudFuncName.getFuncName(isFirstMessage: isFirstMessage, isViewOnceMessage: isViewOnceMessage, isGroupMessage: isGroupMessage)
        Self.call(funcName: funcName, informationDict: messageInformation){
            callback($0)
        }
    }
     
    enum CloudFuncName : String {
        case sendMessage = "sendMessage-sendMessage"
//        case sendFirstMessage = "sendFirstMessage-sendFirstMessage"
        case didViewMessage = "didViewMessage-didViewMessage"
        case sendViewOnceMessage = "sendViewOnceMessage-sendViewOnceMessage"
//        case sendFirstMessageViewOnce = "sendFirstMessageViewOnce-sendFirstMessageViewOnce"
        case didTakeScreenshot  = "didTakeScreenshot-didTakeScreenshot"
        
        case sendGroupMessage = "sendGroupMessage-sendGroupMessage"
        case sendViewOnceGroup = "sendViewOnceGroup-sendViewOnceGroup"
         
        
        static func getFuncName(isFirstMessage : Bool, isViewOnceMessage : Bool, isGroupMessage : Bool) -> String {
            let funcName : String
            if isGroupMessage {
//                funcName = (isViewOnceMessage ? sendViewOnceGroup : sendGroupMessage)()
                  funcName = sendGroupMessage()
            } else {
                if isViewOnceMessage {
                    funcName = (sendViewOnceMessage)()
                }else{
                    funcName = (sendMessage)()
                }
            }
            return funcName
        }
        
    }
}

extension  SendMessageFunctions {
    
    class func didViewMessage(messageUID: String,
                                     chatUID : String,
                                     alreadyViewOnce : Bool = true,
                                     callback: @escaping (Error?) -> Void = {_ in }){
//        let informationDict : [String : Any] =
//            ["messageUID":messageUID,
//             "chatUID":chatUID,
//              "alreadyViewOnce" : alreadyViewOnce]
        let informationDict : [String : Any] =
            [MessageModel.Constant.messageUID() : messageUID,
             MessageModel.Constant.chatUID() : chatUID,
             MessageModel.Constant.alreadyViewOnce() : alreadyViewOnce]
        Self.call(funcName: CloudFuncName.didViewMessage(), informationDict: informationDict, callback: callback)
    }
    
    class func didTakeScreenShotOf(messageUID: String,
                                     chatUID : String,
                                    didTakeScreenShot : Bool = true,
                                     callback: @escaping (Error?) -> Void = {_ in }){ 
//        didTakeScreenshot-didTakeScreenshot is created. it needs the following fields: messageUID, chatUID, didTakeScreenShot
        let informationDict : [String : Any] =
            [MessageModel.Constant.messageUID() : messageUID,
             MessageModel.Constant.chatUID() : chatUID,
             MessageModel.Constant.didTakeScreenShot(): didTakeScreenShot]
        Self.call(funcName: CloudFuncName.didTakeScreenshot(), informationDict: informationDict, callback: callback)
    }
}

extension  SendMessageFunctions {
    class func sendFirstMessageFromTristanToCurrentUser() {
//        guard let userId = Auth.auth().currentUser?.uid else{ return }
//        let messageModelRaw = MessageModel.Raw(sentBy: TristanUserID,
//                                               message: "Welcome to speakEZ!",
//                                               chatUID: UUID().uuidString,
//                                               otherUserID: userId,
//                                               token: "",
//                                               nameOfSendingUser:  "",
//                                               newMedia: nil,
//                                               isFirstMessage: true)
//        SendMessageFunctions.sendNewMessage(messageRaw: messageModelRaw) {error  in
//            if let error = error{
////                  assert(false, " what happend   sendFirstMessageFromTristanToCurrentUser ")
//                print("sendMessageFirstMessageFromTristan failed error = ",error)
//            }else{
//                print("sendMessageFirstMessageFromTristan successfull")
//            }
//        }
    }
}
 
fileprivate extension MessageModel.Raw{
     var funcName : String{
         SendMessageFunctions.CloudFuncName.getFuncName(isFirstMessage: isFirstMessage, isViewOnceMessage: isViewOnceMessage, isGroupMessage: isGroupMessage)
     }
 }
 
/*
return loadMessage()
-then(() => {
const newMessageInformation = {
sentBy: messageInformation["sentBy"],
message: messageInformation["message"],
messageUID:messageInformation["messageUID"],
chatUID: messageInformation[" chatUID"],
thumbnailUrl:messageInformation["thumbnailUrl"],
videoUrl: messageInformation["videoUrl"],
photoLink: messageInformation["photoLink"],
1:
sendGroupMessage,sendGroupMessage({newMessageInformation})
-then ( (r) => console. log(r))
.catch( (err) => console.error(err)) :
return f
something:
"returned".
}:
7):
7):
*/
