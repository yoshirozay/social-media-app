//
//  MediaCacheDirectoryProtocol.swift
//  speakEZ
//
//  Created by Ahmad naeem on 5/20/22.
//

import Foundation 

protocol MediaCacheDirectoryProtocol  {
    func getMainDirectory(folderName: String) -> URL?
}

extension MediaCacheDirectoryProtocol {
    func getMainDirectory(folderName: String) -> URL?{
        guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            return nil
        }
        return createDirectoryIfNotExist(folderName: folderName,documentDirectoryURL: documentDirectoryURL)
//        let documentUrl = documentDirectoryURL.appendingPathComponent(folderName)
//        if !FileManager.default.fileExists(atPath: documentUrl.path) {
//            do {
//                try FileManager.default.createDirectory(atPath: documentUrl.path, withIntermediateDirectories: true, attributes: nil)
//                return documentUrl
//            } catch {
//                print(error.localizedDescription)
//                return nil
//            }
//        }else{
//            return documentUrl
//        }
    }
    
    func createDirectoryIfNotExist(folderName: String,documentDirectoryURL: URL) -> URL?{
         
        let documentUrl = documentDirectoryURL.appendingPathComponent(folderName)
        if !FileManager.default.fileExists(atPath: documentUrl.path) {
            do {
                try FileManager.default.createDirectory(atPath: documentUrl.path, withIntermediateDirectories: true, attributes: nil)
                return documentUrl
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }else{
            return documentUrl
        }
    }
}
