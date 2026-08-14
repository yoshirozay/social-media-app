//
//  TempWeblinkCacheManager.swift
//  speakEZ
//
//  Created by Ahmad naeem on 11/6/21.
//


import Foundation
import SDWebImage.SDImageCache
import SDWebImage.SDWebImageManager

struct TempWeblinkCacheManager {
    static let shared = TempWeblinkCacheManager()
    enum Constant : String {
    case ProfileDummyImage = "ProfileDummyImage.png"
    }
  private  var tempImageDocumentDirURL : URL? {
        let directoryPath = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let url : URL = directoryPath.appendingPathComponent(Constant.ProfileDummyImage()) as URL
        return url
    }
    
    func addImageAndPostTempLinkNotification(image: UIImage){
        deleteImage()
        if let dummyImageLink = saveImage(image: image) {
           SDImageCache.shared.removeImage(forKey: dummyImageLink.absoluteString) {
                let _ = UIImage(contentsOfFile: dummyImageLink.absoluteString)
               NotificationCenter.default.post(name: UserProfile.userProfileNotification, object: dummyImageLink)
            }
        }
    }
    
    func isExistPostNotification() {
        if let url = tempImageDocumentDirURL,
           FileManager.default.fileExists(atPath: url.path) {
            SDWebImageManager.shared.loadImage(with: url,  progress: nil) {  image, data, error, cachyType, bol, url in
                if let _ = image {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: UserProfile.userProfileNotification, object: url)
                    }
                }
            }
        }
    }
    
    func doesExist() -> Bool {
        if let urlString = tempImageDocumentDirURL,
           FileManager.default.fileExists(atPath: urlString.path) {
            return true
        }
        return false
    }
    
      func saveImage(image: UIImage) -> URL? {
          guard let url = tempImageDocumentDirURL else { return nil  }
        if !FileManager.default.fileExists(atPath: url.path),
           let imageData = image.jpegData(compressionQuality: 1.0) {
            do {
                try imageData.write(to: url)
                print ("Image Added Successfully")
                return url
            } catch {
                print ("Image Not added")
                return nil
            }
        }else{
            print(" image already exist ")
             deleteImage()
            return nil
        }
   
    }
        ///i thnk we should also delete it from the sdwebimage cache as well
      func deleteImage() {
          guard  let url = tempImageDocumentDirURL else { return   }
//        print("Image path : \(url)")
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
                print ("Image Added Successfully")
            } catch {
                print ("Image Not added")
            }
        }
    }
    
    func removeImageFromBothCache() {
        deleteImage()
        if let urlString = tempImageDocumentDirURL  {
            SDImageCache.shared.removeImage(forKey: urlString.absoluteString)
        }
    }
}
