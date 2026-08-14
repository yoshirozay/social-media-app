//
//  UserProfile.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/31/21.
//

import SwiftUI
import Firebase
import FirebaseFunctions
import FirebaseStorage
 
struct UserProfile  {
    var name: String
    var username: String
    var bio: String
    var uid: String
    var photo: UIImage?
    var token: String
    var school: String = ""
    var kind : NewMedia.Kind?
    var objectKey : String {
        uid
    }
    init(name: String, username: String, bio: String, uid: String, photo: UIImage?, token: String,school : String = ""){
        self.name = name
        self.username = username
        self.bio = bio
        self.uid = uid
        self.photo = photo
        self.token = token
        self.school = school
    }
    
    init?(realmUserProfile : RealmUserProfile) {
        self.name = realmUserProfile.name
        self.username = realmUserProfile.username
        self.bio = realmUserProfile.bio
        self.uid = realmUserProfile.uid 
        self.token = realmUserProfile.token
        self.school = realmUserProfile.school
        self.kind =  realmUserProfile.kind
        if let kind =  realmUserProfile.kind {
            if let image = SelectedMedia.getSelectedMediaFromCacheFor(key:  realmUserProfile.uid, kind: kind)?.image {
                self.photo = image
            }else{
                assert(false, "nope something went wrong")
                return nil
            }
        }
    }
    
    static func addImageInCacheAndPostTempLinkNotification(image: UIImage){
        TempWeblinkCacheManager.shared.addImageAndPostTempLinkNotification(image: image)
    }
}

extension UserProfile   {
    static let userProfileNotification = Foundation.Notification.Name("userProfileNotification")
    static let userTempWeblinkPublisher = {
        NotificationCenter.default.publisher(for: UserProfile.userProfileNotification)
        .compactMap{$0.object as? URL} 
    }()
}

extension UserProfile  : RealmCacheable {
    func saveInRealm(callback: @escaping (Error?) -> Void) {
        let realmUserProfile = RealmUserProfile(userProfile: self)
        realmUserProfile.saveInRealm(callback : callback)
    }
    
    func removeFailedObjectsFromCache(callback: @escaping (Error?) -> Void) {
        let kind : NewMedia.Kind? =  photo == nil ? nil : .image
        Self.removeFailedMessageFromCache(objectKey : objectKey, mediaKind: kind,callback: callback)

    }
    
   static func getFromRealm() -> UserProfile?  {
        if let realmUserProfile = RealmUserProfile.getOldest(),
           let userProfile = UserProfile(realmUserProfile: realmUserProfile) {
            return userProfile
        } else {
//            assert(false, "nope something went wrong")
        }
        return nil
    }
    
    func updateCacheCopy(isSentSuccessfully isSent : Bool){
        if isSent {
            removeFailedObjectsFromCache(callback: {_ in })
        } else {
            markAsFailedUserProfile()
        }
    }
    
    func markAsFailedUserProfile() {
        RealmUserProfile.markAs(failed: true, userId : uid)
    }
    
    func saveInCache(callback : @escaping ( _  error : Error?) -> Void = {_ in}) {
        RealmUserProfile.deleteAll()
        var newMedia : NewMedia?
        if let image = photo {
            newMedia =  NewMedia(image: image)
        }
        saveAsTemp(newMedia:newMedia,callback: callback)
    }
    static func removeFailedMessageFromCache(objectKey : String, mediaKind: NewMedia.Kind?, callback: @escaping (Error?) -> Void = {_ in}) {
        RealmUserProfile.deleteFromRealm(userId: objectKey) { error in
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
}
