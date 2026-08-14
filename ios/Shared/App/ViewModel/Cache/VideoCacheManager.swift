//
//  VideoCacheManager.swift
//  testingSwiftUI
//
//  Created by Ahmad naeem on 5/6/21.
//

import Foundation 
 
class VideoCacheManager : FileCacheManager   {
    static let shared = VideoCacheManager() 
 
    override var fileType : CacheAbleFileType {
        .video
    }
    
    override var directoryFolderName : String {
        "Videos"
    }
    
    override var possibleExtraStringInName : String {
        "Video-"
    }
    override func removeCacheDirectory(callback : @escaping ( _  error : Error?) -> Void) {
        super.removeCacheDirectory(callback: callback)
        cleanTmpDirectory(url: FileManager.default.temporaryDirectory, delay: 0)
    }
} 

