//
//  FileCacheManager.swift
//  speakEZ
//
//  Created by Ahmad naeem on 5/24/22.
//

import Foundation
import AVFoundation
import Photos
import Combine

#if os(iOS)
import AssetsLibrary
#endif

/*
 so each time we will save a file we will create a new folder and using object id. and file name would be the token. now if we already have a file with same token we will not save it. but if folder is the same but token is different we will remove the old file or we can also just replace it with new file
 */
class FileCacheManager : MediaCacheDirectoryProtocol {
    
    var directoryFolderName : String {
        fatalError("Must Override")
    }
    
    var fileType : CacheAbleFileType {
        fatalError("Must Override")
    }
    ///we will remove it
    var possibleExtraStringInName : String {
        fatalError("Must Override")
    }
    
    private lazy var mainDirectoryUrl: URL? = {
        getMainDirectory(folderName: directoryFolderName)
    }()
    
    private let fileManager = FileManager.default
    private var allRequests : RequestsObserver = RequestsObserver()
    private var requestSubscribers :  [URL : AnyCancellable] =  [ : ]
    
    func getFileDirURLUsing(fileFirebaseURL: URL, callback: @escaping (_ url : URL?,  _  error : Error?) -> Void ){
        if allRequests.contains(fileFirebaseURL) {
            addListenerAndWaitForDownLoading(fileFirebaseURL: fileFirebaseURL,callback: callback)
        }else{
            getFileWith(fileFirebaseURL: fileFirebaseURL,callback: callback)
        }
    }
    
    private func addListenerAndWaitForDownLoading(fileFirebaseURL: URL, callback: @escaping (_ url : URL?,  _  error : Error?) -> Void ){
        DispatchQueue.main.async {[weak self] in
            self?.requestSubscribers[fileFirebaseURL]?.cancel()
            self?.requestSubscribers[fileFirebaseURL] = self?.allRequests
                .getRequestPublisherFor(fileFirebaseURL)
                .sink {[weak self] _ in
                    self?.getFileWith(fileFirebaseURL: fileFirebaseURL,callback: callback)
                }
        }
    }
    
    private func getFileWith(fileFirebaseURL: URL, callback: @escaping (_ url: URL?, _ error: Error?) -> Void ) {
        
        DispatchQueue.global(qos:.background).async { [weak self]  in
            guard let self = self, !self.allRequests.contains(fileFirebaseURL) else { return  }
            self.removeSubcriberIfExist(fileFirebaseURL)
            
            guard let fileDirURL = self.destinationURL(firebaseFileURL: fileFirebaseURL) else{
                callback(nil,"destinationURL was nil".asError)
                return
            }
            
            guard fileDirURL.doesNotExist else {
                callback(fileDirURL,nil)
                return
            }
            
            self.allRequests.append(fileFirebaseURL)
            URLSession.shared.downloadTask(with: fileFirebaseURL) { [weak self]  (location, response, error ) in
                guard  let location = location else {
                    self?.allRequests.remove(fileFirebaseURL)
                    callback(nil,error)
                    return
                }
                self?.moveFileFrom(locationUrl: location, to: fileDirURL) { error in
                    callback(fileDirURL,error)
                    self?.allRequests.remove(fileFirebaseURL)
                    if error == nil{
                        self?.checkAndRemoveOldFilesIfExist(newFileURL: fileDirURL, fileFirebaseURL: fileFirebaseURL)
                    }
                }
            }.resume()
        }
    }
    
    /// we will also have to call this func when current user will send media.
    func checkAndRemoveOldFilesIfExist(newFileURL: URL,fileFirebaseURL: URL) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5)  {
            do {
                let folderURL = newFileURL.deletingLastPathComponent()
                let fileURLs = try FileManager.default.contentsOfDirectory(at: folderURL,
                                                                           includingPropertiesForKeys: [],
                                                                           options: [ .skipsSubdirectoryDescendants,
                                                                                      .skipsPackageDescendants,
                                                                                      .skipsHiddenFiles ])
                if fileURLs.count > 1{
                    let newFileName = newFileURL.lastPathComponent
                    fileURLs.forEach { url in
                        if url.lastPathComponent != newFileName{
                            print(" url.delete = \(url.delete.descriptionIfAny)")
                        }
                    }
                }
            } catch let error{
                print(" \(error.localizedDescription)")
            }
        } 
    }
    
    private func destinationURL(firebaseFileURL: URL) -> URL? {
        if let mainDirectoryUrl = mainDirectoryUrl,
           let fileName = fileName(firebaseUrl: firebaseFileURL),
           let folderName = folderName(firebaseUrl: firebaseFileURL) {
            let destinationURL = createDirectoryIfNotExist(folderName: folderName, documentDirectoryURL: mainDirectoryUrl)?
                .appendingPathComponent(fileName)
            return destinationURL
        }
        return nil
    }
    
    private func fileName(firebaseUrl: URL) -> String?{
        if let filename = firebaseUrl.token{
            return filename + fileType()
        }
        return nil
    }
    
    private func folderName(firebaseUrl: URL) -> String?{
        firebaseUrl.secondLastComponent?.removePrefix(possibleExtraString: possibleExtraStringInName)
    }
    
    func saveInFileCache(tempFileURL: URL, firebaseFileURL: URL, callback : @escaping ( _  error : Error?) -> Void = {_ in}) {
        
        guard let destinationURL = destinationURL(firebaseFileURL: firebaseFileURL),
              destinationURL.doesNotExist else {
            callback(nil)
            return
        }
        do {
            try FileManager.default.copyItem(at: tempFileURL, to: destinationURL)
            callback(nil)
        } catch {
            callback(error)
            print("Result.failure(error)",error.localizedDescription)
        }
    }
    
    private func deleteAndReCreate(directoryUrl: URL,callback : @escaping ( _  error : Error?) -> Void = {_ in}){
        do {
            try FileManager.default.removeItem(at: directoryUrl)
            try FileManager.default.createDirectory(atPath: directoryUrl.path, withIntermediateDirectories: true, attributes: nil)
            callback(nil)
        } catch let error {
            callback(error)
        }
    }
    
    func removeCacheDirectory(callback : @escaping ( _  error : Error?) -> Void) {
        guard let mainDirectoryUrl = mainDirectoryUrl else {
            return
        }
        deleteAndReCreate(directoryUrl: mainDirectoryUrl, callback: callback)
    }
    
    func removeSubcriberIfExist(_ fileFirebaseURL: URL){
        
        DispatchQueue.main.async {[weak self] in
            if let _ = self?.requestSubscribers[fileFirebaseURL]   {
                self?.requestSubscribers[fileFirebaseURL]?.cancel()
                self?.requestSubscribers[fileFirebaseURL] = nil
            }
        }
    }
    
    func clearTmpDirectory() {
        cleanTmpDirectory(url: FileManager.default.temporaryDirectory, delay: 12)
    }
    
    func removeTmpFile(dirURL: URL){
        let error = FileManager.default.removefileIfExist(path: dirURL.path)
        print("tmp file deleted  \(error?.localizedDescription ?? "successfully")")
    }
    
    func cleanTmpDirectory(url: URL,delay: Int) {
        guard delay > 0 else {
            deleteAndReCreate(directoryUrl: url)
            return
        }
        let today = Date()
        DispatchQueue.main.asyncAfter(deadline: .now() +  TimeInterval(delay)) {
            let keys : Set<URLResourceKey> = [.creationDateKey]
            try? FileManager.default
                .contentsOfDirectory(at: url, includingPropertiesForKeys: keys.getArray(), options:.skipsHiddenFiles)
                .forEach { url in
                    if let creationDate = (try? url.resourceValues(forKeys: keys))?.creationDate,creationDate < today{
                        try? FileManager.default.removeItem(at: url)
                    }
                }
        }
    }
    
    private func moveFileFrom(locationUrl : URL, to destinationUrl : URL , callback: @escaping (_ error : Error?) -> Void) {
        
        do {
            try FileManager.default.moveItem(at: locationUrl, to: destinationUrl)
            callback(nil)
        } catch {
            callback(error)
            print("Result.failure(error)",error.localizedDescription)
        }
        
    }
    func getUpdatedCount(firebaseURL : URL) -> Int?{
        if let storageFileName = firebaseURL.secondLastComponent,
           let firstRange = storageFileName.range(of: possibleExtraStringInName){
                let key =  String(storageFileName[..<firstRange.lowerBound])
                let count = Int(key)
                return count
                
            }
        return nil
    }
}

//MARK: - funcs for temp cache files
extension FileCacheManager {
    
    
    func saveInTempCache(fileDocURL: URL, objectKey key: String, replaceIfExist: Bool = false, callback : @escaping ( _  error : Error?) -> Void = {_ in}) {
        let key = key.removePrefix(possibleExtraString: possibleExtraStringInName) + fileType() 
        let destinationURL = tempDirectoryFor(key: key)
        guard let destinationURL = destinationURL, replaceIfExist || destinationURL.doesNotExist else {
            callback(nil)
            return
        }
        do {
            if replaceIfExist {
                let _ = try FileManager.default.replaceItemAt(destinationURL, withItemAt: fileDocURL)
            }else{
                try FileManager.default.copyItem(at: fileDocURL, to: destinationURL)
                
            }
            callback(nil)
        } catch {
            callback(error)
            print("Result.failure(error)",error.localizedDescription)
        }
        
    }
    
    func removeFromTempCacheIfExist(fileFirebaseURL: URL) {
        if let key = tempFileName(firebaseUrl: fileFirebaseURL){
            removeFromTempCacheIfExist(key: key)
        }
    }
    ///it is public because failedManager use this to delete files after they have been sent.
    func removeFromTempCacheIfExist(key: String) {
        guard let destinationURL = getExisitngTempFileURL(key: key) else {
            return
        }
        do {
            try fileManager.removeItem(atPath: destinationURL.path)
        } catch {
            print("fileManager.removeItem ",error.localizedDescription)
        }
    }
    
    func getExisitngTempFileURL(key: String) -> URL?{
        if let url = tempDirectoryFor(key: key), url.doesExist{
            return url
        }
        return nil
    }
    
    func doesTmpFileExistFor(key : String) -> Bool{
        tempDirectoryFor(key: key)?.doesExist == true
    }
    
    private func tempFileName(firebaseUrl: URL) -> String?{
        if let filename = firebaseUrl.secondLastComponent?.removePrefix(possibleExtraString: possibleExtraStringInName) {
            return filename + fileType()
        }
        return nil
    }
    
//    func parseKey(keyString: String) -> String {
//        if let firstRange = keyString.range(of: possibleExtraStringInName){
//            let key = String(keyString[firstRange.upperBound...])
//            return key
//        }
//        return keyString
//    }
    
    private func tempDirectoryFor(fileURL: URL) -> URL? {
        if  let fileURL = tempFileName(firebaseUrl: fileURL) {
            return tempDirectoryFor(key: fileURL)
        }
        return nil
    }
    
  private  func tempDirectoryFor(key: String) -> URL? {
        let key = key.contains(fileType()) ?  key : (key+fileType())
        return mainDirectoryUrl?.appendingPathComponent(key)
    }
    
}
//MARK: - Public funcs

/*
 the one thing we can do is we can also save the token of the vidoe in teh video title or we can create a new folder for each key and can give video id as token.
 hmm for realm we only save posts which are dummy means there is no firebase url. so
 first we should think of video then we can think of audio.
 
 as in future
 */
/*
 for now forget about using update post funcs
 only work on saving video in cache, and saving video for realm for failedManager.
 */

enum CacheAbleFileType : String{
    case video = ".mov"
    case audio = ".m4a"
}

/*
 
 now we need to handle to remove the updated video and also need to use this manager for audio as well. */
