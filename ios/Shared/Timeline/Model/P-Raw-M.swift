//
//  T-Raw-M.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFunctions
import SDWebImage
/*
 so in case of post, we need to update the T button text if from the  whats new label.
 */
extension PostModel {
    struct Raw {
        let id: String
        let postID: String
        let time: Timestamp
        let content: String
        var tags: [String] = []
        var newMedia: NewMedia?
        var mentions: [RealmPostMention] = []
        var isPostTagged : Bool {
            tags.isNotEmpty
        }
        var kind: NewMedia.Kind?
        var nameOfCurrentUser: String = ""
        var hasBeenRead: Bool = false
        var audioDirURL : URL?
        var selectedMediaKind : NewMedia.Kind?{
            audioDirURL == nil ? newMedia?.kind : .audio
        }
    }
}

extension PostModel.Raw {
    init(post: PostModel, newMedia: NewMedia?, audioDirURL: URL?, realmPostMentions: [RealmPostMention]) {
        self.id = post.id
        self.postID = post.postID
        self.time = post.time
        self.tags = post.tags
        self.content = post.content
        self.newMedia = newMedia
        self.mentions = realmPostMentions
        self.nameOfCurrentUser = post.nameOfCurrentUser
        self.hasBeenRead = post.hasBeenRead
        self.audioDirURL = audioDirURL
    }
    
    var postInformation : [String : Any] {
        var postInformation : [String: Any] = [
            "sentBy": id,
            "content": content.trimWhitespacesAndNewlines(),
            "postID": postID,
            "nameOfCurrentUser": nameOfCurrentUser.trimWhitespacesAndNewlines()
            
        ]
        if isPostTagged {
            postInformation["tags"] = tags
        }
        return postInformation
    }
    var modifiedPostInformation : [String : Any] {
        let format = DateFormatter()
        format.dateFormat =  "yyyy/MM/d HH:mm:ssZ"
        let newTime =  format.string(from: time.dateValue())
        var postInformation : [String: Any] = [
            "sentBy": id,
            "content": content.trimWhitespacesAndNewlines(),
            "postID": postID,
            "time": newTime,
            "deletePhoto": false,
            "deleteVideo": false,
            "deleteAudio": false
        ]
        if isPostTagged {
            postInformation["tags"] = tags
        }
        return postInformation
    }
  
    func getMentionDictInfo(currrentUserId : String) -> [[String : String]] {
        return mentions.map({$0.getInfoDict(currentUserId: currrentUserId, postID: postID)})
    }
}

extension PostModel.Raw : RealmCacheable {
    
    var objectKey : String {
       return self.postID
    }
    
    init?(realmPost : RealmPost) {
        self.id = realmPost.id
        self.postID = realmPost.postID
        self.tags = realmPost.tags.map({$0})
        self.time = Timestamp(date:  realmPost.sendTime)
        self.content = realmPost.content
        self.mentions = realmPost.allMentions
        self.kind = realmPost.kind
        if let kind = kind {
            if let selectedMedia = SelectedMedia.getSelectedMediaFromCacheFor(key: objectKey, kind: kind){
                self.newMedia = selectedMedia.newMedia
                self.audioDirURL = selectedMedia.audioUrl
            }else{
                return nil
            }
        }
        self.nameOfCurrentUser = realmPost.nameOfCurrentUser
    }
    
    var realmPost : RealmPost{
        RealmPost(rawPostModel: self)
    }
    
    func saveInCache(callback : @escaping ( _  error : Error?) -> Void = {_ in}) {
        saveAsTemp(newMedia: newMedia,audioDirURL: audioDirURL,callback: callback)
    }
    
    internal func saveInRealm(callback: @escaping (Error?) -> Void = {_ in}) {
        DispatchQueue.main.async {
            self.realmPost.saveInRealm(callback: callback)
        }
     }
    
    ///it remove failed posts. and also attached media  from ther respactive cache as well. its not for the
    func removeFailedObjectsFromCache(callback : @escaping (_ error : Error?) -> Void = {_ in}) {
        Self.removeFailedPostFromCache(objectKey : objectKey, mediaKind: selectedMediaKind,callback: callback)
    }
    
    func updateCacheCopy(isSentSuccessfully isSent : Bool){
        if isSent {
            removeFailedObjectsFromCache()
        } else {
            markAsFailedPost()
        }
    }
    
    func markAsFailedPost() {
        RealmPost.markAs(failed: true, postID: postID)
    }
    
    static func removeFailedPostFromCache(objectKey : String, mediaKind: NewMedia.Kind?,callback : @escaping (_  error : Error?) -> Void) {
        RealmPost.deleteFromRealm(postID: objectKey) { error in
            callback(error)
            if let error = error {
                print(error.localizedDescription )
            }else{
                if let kind = mediaKind {
                    
                    SelectedMedia.deleteRealmObjectMediaFromCache(objectKey: objectKey, kind: kind)
                }
            }
        }
    }
    
//    static func getFromCache(objectKey : String) -> PostModel.Raw? {
//
//        if let rawPost =  RealmPost.getFromRealm(postID: objectKey)?.getRawPostModel() {
//            return rawPost
//        } else {
//            assert(false, "nope something went wrong")
//        }
//        return nil
//    }
    
    static func getOldestPostFromRealm() -> PostModel.Raw?  {
        return RealmPost.getOldest()?.getRawPostModel()
    }
}
