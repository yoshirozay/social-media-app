//
//  RealmUserProfile.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/31/21.
//

import Foundation

import RealmSwift
import Realm
import Combine

class RealmUserProfile : Object {
   
    @Persisted  var name: String
    @Persisted  var username: String
    @Persisted  var bio: String
    @Persisted  var uid: String
    @Persisted  var token: String
    @Persisted  var school: String = ""
    //so we need isfailed, because if isFailed is true the FailedManager will try to send it again. so we first add profile in the realm, then we will mark it as failed if it failed. if it successed we just delete it from the realm. so in case user call the func to update profile and close the app. now when user will open the app again it will makr it as isFailed all remainig userProfile.
    @Persisted  var isFailed : Bool = false 
    @Persisted  var kind : NewMedia.Kind?
  
  convenience init(userProfile : UserProfile) {
      self.init()
      self.name = userProfile.name
      self.username = userProfile.username
      self.bio = userProfile.bio
      self.uid = userProfile.uid
      self.token = userProfile.token
      self.school = userProfile.school
      self.kind = userProfile.photo == nil ? nil : .image
  }
    
}

extension RealmUserProfile : RealmFailAble {
//
    class func updateAllMsgsIsFailedProperty(to isFailed : Bool){
        guard let realm = try? Realm(),
              let realmRawMessages = getAllFailedObjectsResult() else { return  }
        
        DispatchQueue.main.async {
            do {
                try realm.write {
                    realmRawMessages.forEach({$0.isFailed = false})
                }
            } catch {
                assert(false, " what happend   saveInRealm \(error.localizedDescription)")
            }
        }
    }
    
    class func deleteAll(){
        guard let realm = try? Realm() else { return   }
        let results = realm.objects(RealmUserProfile.self)
        Self.deleteAll(realmObjects: results) { error in
            print(error?.localizedDescription ?? "deleteAll RealmUserProfile delete friend")
        }
    }
    
    class func save(userProfile : UserProfile) {
        let realmUserProfile = RealmUserProfile(userProfile : userProfile)
        realmUserProfile.saveInRealm()
    }
    
    class func getFromRealm(userId : String) -> RealmUserProfile? {
        guard let realm = try? Realm() else { return nil }
        let realmUserProfile = realm.objects(RealmUserProfile.self).filter("\(Constant.uid() ) == %@",userId).first
        return realmUserProfile
    }
     
    class func getOldest() -> RealmUserProfile? {
        guard let realm = try? Realm() else { return nil }
        let realmUserProfile = realm.objects(RealmUserProfile.self).first
        return realmUserProfile
    }
    
    class func deleteFromRealm(userId : String, callback : @escaping ( _ error : Error?) -> Void = {_ in}) {
        if let realmUserProfile = getFromRealm(userId: userId) {
            deleteFromRealm(realmObject: realmUserProfile,callback: callback)
        }
    }
    
    class func markAs(failed : Bool,userId : String){
        if let realmUserProfile = getFromRealm(userId: userId){
            realmUserProfile.markAs(failed: failed)
        }
    }
    
    func markAs(failed : Bool, callback : @escaping (_ error : Error?) -> Void = {_ in}) {
        if  let realm = try? Realm() {
            DispatchQueue.main.async {
                do {
                    try realm.write {
                        self.isFailed = failed
                    }
                } catch   {
                    callback(error)
                    assert(false, " what happend   saveInRealm \(error.localizedDescription)")
                }
            }
        }else{
            let error = NSError.getWith(description: " let realm = try? Realm()  failed")
            callback(error)
            assert(false, " what happend   saveInRealm ")
        }
    }
    
    enum Constant : String {
        case uid
        case isFailed
    }
}





