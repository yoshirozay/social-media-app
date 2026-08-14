//
//  SendCommentFunction.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 2/20/21.
//

import SwiftUI
import Firebase
import FirebaseFunctions
import FirebaseFirestore
import FirebaseStorage 
import SDWebImage

///now just like messange and post cloud func we will also save sending media in the cache and use it afterwards so we do not have to download our own sended media
class SendCommentFunction: ObservableObject ,CloudFunction {
     
    class func send(rawComment : CommentModel.Raw, callback : @escaping (_  error : Error?) -> Void) {
        if let newMedia = rawComment.newMedia  {
            sendMedia(rawComment: rawComment, newMedia: newMedia, callback: callback)
        }else if let audioUrl = rawComment.selectedMedia?.audioUrl {
            sendAudio(rawComment: rawComment, audioDirURL: audioUrl, callback: callback)
        }else{
            call(funcName: Constant.sendCommentTest(), informationDict: rawComment.commentInfo, callback: callback)
        }
    }
    
    class private func sendMedia(rawComment : CommentModel.Raw,  newMedia : NewMedia, callback : @escaping (  _  error : Error?) -> Void){
        if let VideoFirebaseUrl = newMedia.videoUrl{
            sendVideo(rawComment: rawComment,
                      thumbnailImage: newMedia.image,
                      videoDirURL: VideoFirebaseUrl,
                      callback: callback)
            return
        }
        let sendImageComment = {
            let  storage = Storage.storage().reference()
                .child("\(rawComment.sentBy)")
                .child("CommentPhotos")
                .child("\(rawComment.commentID)/comment.jpeg")
            Self.uploadImage(image: newMedia.image, storageRef: storage) { url, error in
                Self.callWithImageInfo(funcName: Constant.sendCommentTest(),
                                       informationDict: rawComment.commentInfo,
                                       image: newMedia.image,
                                       imageURL: url,
                                       doHaveFailedManager: false,
                                       callback:callback)
            }
        }
        sendImageComment()
        
    }
    
    class private func sendVideo(rawComment : CommentModel.Raw,
                                 thumbnailImage : UIImage,
                                 videoDirURL : URL,
                                 callback : @escaping (  _  error : Error?) -> Void) {
        
        var thumbnailFirebaseUrl : URL! = nil
        var VideoFirebaseUrl : URL! = nil
        let dispatchGroup = DispatchGroup()
        
        func getStorageRef(forVideo : Bool) -> StorageReference {
            Storage.storage().reference()
                .child(rawComment.sentBy)
                .child("CommmentVideos")
                .child("Video-"+rawComment.commentID)
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
            callWithVideoInfo(funcName: Constant.sendCommentTest(),
                              informationDict: rawComment.commentInfo,
                              VideoFirebaseUrl: VideoFirebaseUrl,
                              thumbnailFirebaseUrl: thumbnailFirebaseUrl,
                              videoDirURL: videoDirURL,
                              thumbnailImage: thumbnailImage,
                              doHaveFailedManager: false,
                              callback: callback)
        }
    }
    class private func sendAudio(rawComment : CommentModel.Raw,
                                 audioDirURL : URL,
                                 callback : @escaping (  _  error : Error?) -> Void) {
      
        
        
        func getStorageRef() -> StorageReference {
            Storage.storage().reference()
                .child(rawComment.sentBy)
                .child("CommmentAudio")
                .child("Audio-"+rawComment.commentID)
                .child("audio.m4a")
        }
         
        uploadAudio(audioDirURL: audioDirURL, storageRef: getStorageRef()) { audioFirebaseUrl, error in
                callWithAudioInfo(funcName: Constant.sendCommentTest(),
                                  informationDict: rawComment.commentInfo,
                                  audioFirebaseUrl: audioFirebaseUrl,
                                  audioDirURL: audioDirURL,
                                  callback: callback)
        }
    }
    enum Constant : String {
        case sendCommentTest = "sendCommentTest-sendCommentTest"
    }
}

extension SendCommentFunction{
    class func deleteComment(deletedRawComment: CommentModel.DeletedRaw,
                             callback : @escaping ( _  error : Error?) -> Void = {_ in }){
        let commentInformation = deletedRawComment.dictionary
        Self.call(funcName: "deleteComment-deleteComment", informationDict: commentInformation,callback: callback)
    }
}
//deleteComment-deleteComment, and deleteCommentReply-deleteCommentReply.

class SubscribeToPost: ObservableObject ,CloudFunction {
     
    class func subscribeToPostCloudFunction(postID: String, originalAuthor: String, callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        let postInformation = [
            "postID": postID,
            "originalAuthor": originalAuthor,
            "currentUser": Auth.auth().currentUser?.uid
        ]
        Self.call(funcName: "subscribeToPost-subscribeToPost", informationDict: postInformation){
            print("hello")
            callback($0)
        }
    }
    class func unsubscribeToPostCloudFunction(postID: String, originalAuthor: String, callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        let postInformation = [
            "postID": postID,
            "originalAuthor": originalAuthor,
            "currentUser": Auth.auth().currentUser?.uid
        ]
        Self.call(funcName: "unsubscribeToPost-unsubscribeToPost", informationDict: postInformation){
            print("hello")
            callback($0)
        }
    }
}
