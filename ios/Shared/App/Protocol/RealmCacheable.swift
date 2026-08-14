//
//  RealmCacheable.swift
//  speakEZ
//
//  Created by Ahmad naeem on 12/18/21.
//

import Foundation
import RealmSwift


protocol RealmCacheable {
   var objectKey : String { get }
   func saveAsTemp(newMedia: NewMedia?,audioDirURL: URL?,callback : @escaping ( _  error : Error?) -> Void  )
   func saveInRealm(callback: @escaping (Error?) -> Void )
   func removeFailedObjectsFromCache(callback : @escaping (_ error : Error?) -> Void  )
}

extension RealmCacheable {
   
    func saveAsTemp(newMedia: NewMedia?, audioDirURL: URL? = nil, callback : @escaping ( _  error : Error?) -> Void  = {_ in}) {
       
        let group = DispatchGroup()
        var someError: Error?
        if let audioDirURL = audioDirURL{
            group.enter()
            AudioCacheManager.shared.saveInTempCache(fileDocURL: audioDirURL, objectKey: self.objectKey) { error in
                someError = error == nil ? someError : error
                group.leave()
            }
        }else if let media = newMedia {
            if let videoUrl = media.videoUrl {
                 
                group.enter()
                VideoCacheManager.shared.saveInTempCache(fileDocURL: videoUrl, objectKey: self.objectKey){ error in
                    someError = error == nil ? someError : error
                    group.leave()
                }
            }
            group.enter()
            media.image.saveInCache(forKey: self.objectKey){
                group.leave()
            }
        }
        
        group.enter()
        self.saveInRealm { error in
            someError = ((error == nil) ? someError : error)
            group.leave()
        }
 
        group.notify(queue: .main){
            if let error = someError{
               self.removeFailedObjectsFromCache(){_ in}
                assert(false, " what happend   someError "+error.localizedDescription)
            }
            callback(someError)
        }
    }
}
