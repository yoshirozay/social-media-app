//
//  DynamicLinkManager.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/10/21.
//

import Firebase
import FirebaseAuth
import Combine
import FirebaseDynamicLinks
import UIKit.UIImage

import SwiftUI
import FirebaseMessaging
import FirebaseFirestore

class DynamicLinkManager {
   private init( ) {  }
   enum Contant : String{
       case dynamicLinkDomain = "speakez.cloud"
       case dynamicLinkURL = "https://speakez.cloud"
       case appStoreID = "1558577008"
       case userId
       case eventID
    enum socialMeta : String {
        case title = "Add me on speakEZ"
        case descriptionText = "speakEZ is the best way to get closer and stay connected with friends."
        case imageURL = """
        https://firebasestorage.googleapis.com/v0/b/YOUR_FIREBASE_PROJECT_ID.appspot.com/o/DynamicLink%2Fimage.jpeg?alt=media&token=1ee89c12-cb41-456d-ab84-8d768d4da53e
        """
    }
   }
   // {"applinks":{"apps":[],"details":[{"appID":"5VVF8T96M9.com.carsonosullivan.speakEZ","paths":["NOT /_/*","/*"]}]}}
  static let shared = DynamicLinkManager()
   
    private func getDynamicLinkURL(currentUserId : String, isAnEvent: Bool) -> URL?{
       var componnets =  URLComponents()
        componnets.scheme = "https"
        componnets.host = Contant.dynamicLinkDomain.rawValue
        componnets.path = "/data"
        let qItem1 = URLQueryItem(name: isAnEvent ? Contant.eventID.rawValue : Contant.userId.rawValue, value: currentUserId)
        componnets.queryItems = [qItem1]
        let link = componnets.url
       return link
   }
    
    func createAndSaveDynamicLinkIfNotExist(isAnEvent: Bool){
        guard let userId = currentUserID else{ return }
        createShortDynamicLinkURL(currentUserId: userId, isAnEvent: isAnEvent){_,_ in}
    }
    
    func createShortDynamicLinkURL(currentUserId : String = "", isAnEvent: Bool, callback : @escaping (_ url : URL?,  _  error : Error?) -> Void)  {
        
        if isAnEvent == false, let url = self.savedDynamicLink {
            callback(url,nil)
            return
        }
        
        guard let link = getDynamicLinkURL(currentUserId: currentUserId, isAnEvent: isAnEvent) else { return }
        let dynamicLinksDomainURIPrefix = Contant.dynamicLinkURL.rawValue
        
        guard let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix) ,
              let myBundleId = Bundle.main.bundleIdentifier,
              let imageURL = URL(string: Contant.socialMeta.imageURL()) else { return }
        
        linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
        linkBuilder.iOSParameters?.appStoreID = Contant.appStoreID.rawValue
        
        linkBuilder.navigationInfoParameters = DynamicLinkNavigationInfoParameters()
        linkBuilder.navigationInfoParameters?.isForcedRedirectEnabled = true
        
        linkBuilder.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        linkBuilder.socialMetaTagParameters?.title = isAnEvent ? "I'm planning an event, you're invited!": Contant.socialMeta.title()
        linkBuilder.socialMetaTagParameters?.descriptionText = isAnEvent ? "I hope you can attend :)" : Contant.socialMeta.descriptionText()
        linkBuilder.socialMetaTagParameters?.imageURL = imageURL
        
        guard let longDynamicLink = linkBuilder.url else {
            print("The  URL incorrect")
            callback(nil,NSError.getWith(description: "The  linkBuilder.url incorrect"))
            return
        }
        print("The long URL is: \(longDynamicLink)")
        linkBuilder.shorten(completion: { (url, strs, error) in
            callback(url,error)
            if let url = url, isAnEvent == false {
            
                self.savedDynamicLink = url
                print("The shorten URL is: ",url)
            }
        })
    }
//   https://firebasestorage.googleapis.com/v0/b/YOUR_FIREBASE_PROJECT_ID.appspot.com/o/DynamicLink%2Fimage.jpeg?alt=media&token=b47ad3c6-e416-49b2-9f54-76ec129a48d4
   
   func parseToDeepLink(url : URL,callback : @escaping (_ deepLink : DeepLink?) -> Void) {
       print(" url exist =",url) 
           let linkHandlerbolean = DynamicLinks.dynamicLinks().handleUniversalLink(url) {[weak self] dynamicLink, error in
             if let dynamicLinkURL = dynamicLink?.url{
                print("dynamicLinkURL ",dynamicLinkURL)
                 if let deepLink = DeepLink(dynamicLinkURL: dynamicLinkURL) {
                    callback(deepLink) 
                  }
               }else{
                   callback(nil)
                   print(error?.localizedDescription ?? "")
               }
           }
           print("linkHandlerbolean",linkHandlerbolean)
 
   }
   
   enum DeepLink: Equatable {
       case profileCreation 
       case stranger(userID: String)
       case event(eventID: String)
       
       init?(dynamicLinkURL url: URL) {
           // 1
           guard url.scheme == "https" else {
               return nil
           }
           // 2
           
           guard url.pathComponents.contains("data") else {
               return nil
           }
           var deepLink : DeepLink = .profileCreation
           
           
//           if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
//              let userId = queryItems.first?.value{
//               deepLink = .stranger(userID: userId)
//           }
           if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
              let resourceID = queryItems.first?.value{
               if queryItems.first?.name == "userId" {
               deepLink = .stranger(userID: resourceID)
               } else if queryItems.first?.name == "eventID" {
                   deepLink = .event(eventID: resourceID)
               } else {
                   deepLink = .stranger(userID: resourceID)
               }
           }
           self = deepLink
       }
   }
    static func updateDynamicLinkImage(callback : @escaping (_ url : URL?,  _  error : Error?) -> Void){
         
           let messagePhoto = UIImage(named: "DynamicLinkImage")!
           var storageRef = Storage.storage().reference()
           guard let imageData = messagePhoto.highestQualityJPEGNSData else {
                callback(nil,NSError.getWith(description: "Image highestQualityJPEGNSData Failed"))
                return
           }
           let metadata = StorageMetadata()
           metadata.contentType = "image/jpeg"
         
           storageRef = storageRef
               .child("DynamicLink")
               .child("image.jpeg")
           storageRef.putData(imageData, metadata: metadata) { (meta, error) in
               if let error = error {
                   print(error.localizedDescription)
      
               } else {
                   storageRef.downloadURL { url, error in
                       if let url = url {
                              print("DynamicLink image",url)
                       }
                      
                   }
               }
           }
        
    }
    
     var savedDynamicLink : URL? {
        get {
            UserDefaults.standard.url(forKey: Key.savedDynamicLink())
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.savedDynamicLink())
        }
    }
    
    enum Key : String {
       case savedDynamicLink
    }
    
    func clearUserDefaults(){
        savedDynamicLink = nil
    }
    
}

