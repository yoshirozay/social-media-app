//
//  EditProfileFunction.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 2/17/21.
//

import SwiftUI
import Firebase
import FirebaseFunctions
import FirebaseStorage
import SDWebImage
#if os(iOS)

import UIKit.UIImage
#endif

typealias UpdateProfileFunction = EditProfileFunction
class EditProfileFunction: ObservableObject,CloudFunction {
    
    func updateProfile(updatedProfile: UserProfile){
        Self.updateProfile(updatedProfile : updatedProfile)
    }
    
    static func updateProfile(updatedProfile: UserProfile, isAResend : Bool = false , callback : @escaping (  _  error : Error?) -> Void = {_ in}){
        print("Updating Profile")
        //FIXME: we do not need userId here uid is already userId need to test
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        if !isAResend{
            updatedProfile.saveInCache(){error in
                print(" \(error?.localizedDescription ?? "")")
            }
        }
        
        if let image = updatedProfile.photo  {
            UserProfile.addImageInCacheAndPostTempLinkNotification(image: image)
        }
//        return
        var dispatchGroup : DispatchGroup?
        var path : String?
        var isProfileCreatedSuccessFully : Bool = false
        if let photo = updatedProfile.photo   {
            dispatchGroup = DispatchGroup()
        let storage = Storage.storage().reference()
        guard let imageData = photo.highestQualityJPEGNSData else {
                callback(NSError.getWith(description: "Image highestQualityJPEGNSData Failed"))
                return
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        dispatchGroup?.enter()
        storage
            .child(userId)
            .child("profilePhoto.jpeg")
            .putData(imageData, metadata: metadata) { (metaData, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }else if let UrlPath = metaData?.path{
                    path = UrlPath
                }
                dispatchGroup?.leave()
            }
        }
        var profileInformation = [String: Any]()
        profileInformation = [
            "name": updatedProfile.name,
            "username": updatedProfile.username.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
            "bio": updatedProfile.bio,
            "uid": updatedProfile.uid,
            "token": updatedProfile.token,
            "school": updatedProfile.school,
        ]
        dispatchGroup?.enter()
        Self.editProfileCloudFunc(postInformation: profileInformation) { error in
            if error == nil {
                isProfileCreatedSuccessFully = true
            }
            if dispatchGroup == nil{
                updatedProfile.updateCacheCopy(isSentSuccessfully: error == nil)
            }
            dispatchGroup?.leave()
        }
   
        dispatchGroup?.notify(queue: .main) {
            if let path = path ,
               isProfileCreatedSuccessFully {
                UpdateProfileFunction.updateProfileWebLink(path: path, userId: updatedProfile.uid,photo: updatedProfile.photo){ error in
                    updatedProfile.updateCacheCopy(isSentSuccessfully: error == nil)
                    callback(error)
                }
            }
        }
    }
    
  func checkUsername(_ username: String, callback : @escaping (_ success : Bool, _  error : Error?) -> Void){
      Self.checkUsername(username,callback : callback) 
  }
    
  static func checkUsername(_ username: String, callback : @escaping (_ success : Bool, _  error : Error?) -> Void){

        let usernameDetails = "@\(username.lowercased())"
        print("USERNAME DETAILS = \(usernameDetails)")
        Functions.functions().httpsCallable("checkUserName-checkUserNameAvailability").call(usernameDetails) { (result, error) in
            if let error = error as NSError? {
                callback(false,error)
                if error.domain == FunctionsErrorDomain {
                    print("\(error)")
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
            } else {
                if let data = result?.data,
                   let dict = data as? [String:Any],
                   let firstValue = dict.first?.value as? Int,
                   firstValue == 1 {
                    //                self.isUsernameAvailable = true
                    callback(true,nil)
                }else{
                    callback(false,nil)
                }
            }
            print("123 \(String(describing: result?.data))")
        }
    
    }
    
    class func editProfileCloudFunc(postInformation: [String : Any],callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        print(postInformation)
        Self.call(funcName: Constant.editProfileFuncName(), informationDict: postInformation,callback: callback)
    }
      
    class func updateNotificationTokenCloudFunc(newToken : String,userId : String,callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        let userInformation = [Constant.token() : newToken, Constant.uid() : userId]
        Self.call(funcName: Constant.updateTokenFuncName(), informationDict: userInformation,callback: callback)
    }
    
    enum Constant : String {
        case token
        case uid
        case editProfileFuncName = "editProfile-editProfile"
        case updateTokenFuncName = "updateToken-updateToken"
    }
}
extension EditProfileFunction {
   func updateProfileWebLink(path : String,userId : String,photo: UIImage? = nil) {
       Self.updateProfileWebLink(path : path,userId : userId,photo : photo)
   }
   
   class func updateProfileWebLink(path : String,userId : String,photo: UIImage? = nil,callback : @escaping (  _  error : Error?) -> Void = {_ in}) {
//        print("updateProfileWebLink called for userId = ",userId)
       var  profileInformation : [String: Any] = ["uid" : userId]
       let photoRef = Storage.storage().reference().child(path)
       
       photoRef.downloadURL { (url, error) in
           if let url = url {
               if let photo = photo {
                   SDImageCache.shared.add(image: photo, url: url)
               }
               let webLink = url.absoluteString
               profileInformation["webLink"] = webLink
               Self.call(funcName: "uploadWebLink-uploadWebLink", informationDict: profileInformation){ error in
                   if let _ = error ,let _ = photo  {
                       SDImageCache.shared.removeImage(forKey: webLink)
                   }
                   callback(error)
               }
           }else{
               callback(NSError.getWith(description: error?.localizedDescription ??  "got no downloadURL for UpdateProfileFunction"))
               print(error?.localizedDescription ??  "got no downloadURL for UpdateProfileFunction" )
           }
       }
       
   }
   
   class func updatePhoneNumberOf(userId : String,phoneNumber : String,callback : @escaping (  _  error : Error?) -> Void = {_ in}) {
       guard phoneNumber.count > 6 else {
             print("phoneNumber is in correct")
           return
       }
       let  profileInformation : [String: Any] = ["uid": userId, "phoneNumber": phoneNumber] 
       Self.call(funcName: "editPhoneNumber-editPhoneNumber", informationDict: profileInformation,callback : callback)
       
   }
}
