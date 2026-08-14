//
//  FailedUserProfileManager.swift
//  speakEZ
//
//  Created by Ahmad naeem on 11/1/21.
//


import Combine
import RealmSwift
import FirebaseAuth
import Foundation
  
class FailedUserProfileManager : FailedManager,FailedObjectManagAble {
    
    
    typealias ResendAbleObject = UserProfile
    typealias RealmFailAbleObject = RealmUserProfile
     
    override init() {
        super.init()
        self.addNetworkAvailabilityListener()
        if let _ = ResendAbleObject.getOldestFromRealm()  {
            TempWeblinkCacheManager.shared.isExistPostNotification()
        }else{
            TempWeblinkCacheManager.shared.removeImageFromBothCache()
        }
    }
    
   func sendObjectUsingCloudFunc(obj: ResendAbleObject.RawResendAbleObject) {
       updateProfile(updatedProfile: obj) { [weak self] error in
           self?.cloudFuncCallBackResponse(obj: obj,error: error)
       }
   }
    
    
    static let shared = FailedUserProfileManager()
        
    static func configure() {
        ReachabilityService.configure()
        let _ = Self.shared
    }
     
    var currentUser : Person!
}

extension FailedUserProfileManager {
    
    func updateProfile(updatedProfile: UserProfile, callback: @escaping (Error?) -> Void){
        
        guard let userId = Auth.auth().currentUser?.uid else {
            callback(NSError.getWith(description: " Auth.auth().currentUser?.uid was nil"))
            return
        }
        
        fetchCurrentUser(userId: userId) {[weak self] currentUser, error in
            if let currentUser = currentUser {
                self?.currentUser = currentUser
                if currentUser.username == ("@"+updatedProfile.username){
                    EditProfileFunction.updateProfile(updatedProfile: updatedProfile,isAResend: true,callback : callback)
                }else{
                    EditProfileFunction().checkUsername( updatedProfile.username) { success, error in
                        if success{
                            EditProfileFunction.updateProfile(updatedProfile: updatedProfile,isAResend: true,callback : callback)
                        }else{
                            callback(error)
                        }
                    }
                }
            }else{
                callback(error)
            }
        }
        
    }
    
    func fetchCurrentUser(userId : String, callback: @escaping (Person?, Error?) -> Void){
        if let currentUser = currentUser,
           currentUser.id == userId{
            callback(currentUser,nil)
            return
        }
        
        Person.fetchFriend(id: userId, source: .cache)  { user, error in
            if let user = user{
                callback(user,error)
            }else {
                Person.fetchFriend(id: userId, source: .server,callback : callback)
            }
        }
    }
}
/*
 so first we will get the current user person object. for that we will get it from the cache then from the server. ass 99% times we will get user doc from the cache.
 now then we will cehck is the user name availabel if yes then we will call the update func
 */

/*
 so for user profile upate. we will need to task
 first failedManager= so for that as we do not have a raw person model. we will just create a raw editprofile request model.
 one for realm and one just raw.
 second updating the current user obect with dummy data. on done and on launch if it was unsucessfull
 
 now how we will know that user name has not been taken for that we will have to check name availablity first
 */
/*
 so right now the manager is working fine. but the issue is what if user changed the username. then we will have to check that does this still remain. for that we will also need to check users current name.
 */
/*
now we want to upate the profile.
 for that we need two thinks,
 first updating the user profile when user taps on done.
 updating user profile when user relaunch the app. for this i think we should do after delay of some seconds 
 
 
 */
