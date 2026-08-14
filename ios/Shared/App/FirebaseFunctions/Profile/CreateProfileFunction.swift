//
//  CreateProfileFunction.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 3/2/21.
//

import SwiftUI
import Firebase
import FirebaseFunctions
import FirebaseStorage
import SDWebImage

class CreateProfileFunction: ObservableObject, CloudFunction {
    @Published var isUsernameAvailable = Bool()
    func createProfile(name: String, username: String, bio: String, uid: String, photo: UIImage?, token: String, school: String, city: String, age: String, appPassword: String,callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        print("CreateProfileFunction called")
//        return
        guard let userId = Auth.auth().currentUser?.uid else{
            callback(NSError.getWith(description: " currentUser is nill"))
            return }
        
        guard let secretPassword = SecretPasswordFunction.savedSecretPassword else {
            callback(NSError.getWith(description: " Secret Password does not exist"))
            return
        }
        print("secretPassword =",secretPassword)
        var dispatchGroup : DispatchGroup?
        var path : String?
        var isProfileCreatedSuccessFully : Bool = false
       
        if let photo = photo  {
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
                    }else if let UrlPath = metaData?.path{
                        path = UrlPath
                    }
                    dispatchGroup?.leave()
                }
        }
        
        var profileInformation = [String: Any]()
        profileInformation = [
            "name": name,
            "username": username.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
            "bio": bio,
            "uid": uid,
            "token": token,
            "school": school,
            "city": city,
            "age": age,
            "appPassword": appPassword,
            "webLink": UserDefaultPhotoWeblink.absoluteString
        ]
         
        dispatchGroup?.enter()
        Self.createProfileCloudFunc(postInformation: profileInformation) { error in 
            callback(error)
            if error == nil {
                isProfileCreatedSuccessFully = true 
            }
            dispatchGroup?.leave()
        }
         
        dispatchGroup?.notify(queue: .main) {
            if let path = path ,
               isProfileCreatedSuccessFully {
                UpdateProfileFunction.updateProfileWebLink(path: path, userId: uid,photo : photo){error in
//                    SecretPasswordFunction.savedSecretPassword = nil
                }
            }
        }
    }
    
    class private func createProfileCloudFunc(postInformation: [String : Any],callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        print(postInformation)
        Self.call(funcName: createProfileFuncName, informationDict: postInformation){ error in
            if error == nil,let _ = currentUserID{
                SendMessageFunctions.sendFirstMessageFromTristanToCurrentUser()
                DynamicLinkManager.shared.createAndSaveDynamicLinkIfNotExist(isAnEvent: false)
            }
            callback(error)
        }
    }
    
    static let createProfileFuncName = "createProfile-createProfile"
}


