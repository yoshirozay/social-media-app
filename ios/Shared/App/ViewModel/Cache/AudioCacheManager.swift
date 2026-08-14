//
//  AudioCacheManager.swift
//  speakEZ
//
//  Created by Ahmad naeem on 5/20/22.
//
 
import Foundation
import Combine
  
class AudioCacheManager : FileCacheManager   {
    static let shared = AudioCacheManager()
    
    override var fileType : CacheAbleFileType {
        .audio
    }
    override var directoryFolderName : String {
        "Audios"
    }
    override var possibleExtraStringInName : String {
        "Audio-"
    }
  
    private(set) lazy var tmpAudiosDirUrl: URL? = {
        getMainDirectory(folderName: "tmpAudios")
    }()
      
    override func clearTmpDirectory() {
        guard let tmpAudiosDirUrl = tmpAudiosDirUrl else { return }
       cleanTmpDirectory(url: tmpAudiosDirUrl, delay: 10)
    }
    
    override func removeCacheDirectory(callback : @escaping ( _  error : Error?) -> Void) {
        super.removeCacheDirectory(callback: callback) 
        if let tmpAudiosDirUrl = tmpAudiosDirUrl{
          cleanTmpDirectory(url: tmpAudiosDirUrl, delay: 0)
        }
    }
}
 
/*
 
 */

//class FileCacheManager1 : MediaCacheDirectoryProtocol {
//
//    var directoryFolderName : String {
//        fatalError("Must Override")
//    }
//
//    var fileType : CacheAbleFileType {
//        fatalError("Must Override")
//    }
//    ///we will remove it
//    var possibleExtraStringInName : String {
//        fatalError("Must Override")
//    }
//
//     private lazy var mainDirectoryUrl: URL? = {
//        getMainDirectory(folderName: directoryFolderName)
//    }()
//
//    private let fileManager = FileManager.default
//    private var allRequests : RequestsObserver = RequestsObserver()
//    private var requestSubscribers :  [URL : AnyCancellable] =  [ : ]
//
//    func addListenerAndWaitForDownLoading(fileFirebaseURL: URL, callback: @escaping (_ url : URL?,  _  error : Error?) -> Void ){
//        DispatchQueue.main.async {[weak self] in
//            self?.requestSubscribers[fileFirebaseURL]?.cancel()
//            self?.requestSubscribers[fileFirebaseURL] = self?.allRequests
//                .getRequestPublisherFor(fileFirebaseURL)
//                .sink {[weak self] _ in
//                    self?.getFileWith(fileFirebaseURL: fileFirebaseURL,callback: callback)
//                }
//        }
//    }
//
//    func getFileDirURLUsing(fileFirebaseURL: URL, callback: @escaping (_ url : URL?,  _  error : Error?) -> Void ){
//        if allRequests.contains(fileFirebaseURL) {
//            addListenerAndWaitForDownLoading(fileFirebaseURL: fileFirebaseURL,callback: callback)
//        }else{
//            getFileWith(fileFirebaseURL: fileFirebaseURL,callback: callback)
//        }
//    }
//
//    func removeSubcriberIfExist(_ fileFirebaseURL: URL){
//        DispatchQueue.main.async {[weak self] in
//            self?.requestSubscribers[fileFirebaseURL]?.cancel()
//            self?.requestSubscribers[fileFirebaseURL] = nil
//        }
//    }
//
//    private  func getFileWith(fileFirebaseURL: URL, callback: @escaping (_ url : URL?,  _  error : Error?) -> Void ) {
//
//        DispatchQueue.global(qos:.background).async { [weak self]  in
//            guard let self = self else { return  }
//
//            //so the given fileFirebaseURL is going to be downloaded or will be get from the dir so no need to for the current calle to add a subscription for the update
//            self.removeSubcriberIfExist(fileFirebaseURL)
//
//            guard  let file = self.directoryFor(fileURL: fileFirebaseURL) else{
//                let error = NSError.getWith(description: "Can't get the last component from the given URL")
//                callback(nil,error)
//                return
//            }
//
//            //return file path if already exists in cache directory
//            guard !self.fileManager.fileExists(atPath: file.path)  else {
//                callback(file,nil)
//                return
//            }
//
//            guard let documentsDirectoryURL = self.mainDirectoryUrl else { return }
//
//            self.allRequests.append(fileFirebaseURL)
//            URLSession.shared.downloadTask(with: fileFirebaseURL) { [weak self]  (location, response, error ) in
//
//                guard let self = self else { return }
//                // use guard to unwrap your optional url
//                guard let location = location,
//                      let secondLastComponent = self.fileName(firebaseUrl: fileFirebaseURL) else {
//                    self.allRequests.remove(fileFirebaseURL)
//                    return
//                }
//
//                // create a deatination url with the server response suggested file name
//                let destinationURL = documentsDirectoryURL.appendingPathComponent(secondLastComponent)
//                self.moveFileFrom(locationUrl: location, to: destinationURL) { url,error in
//                    callback(url,error)
//                    self.allRequests.remove(fileFirebaseURL)
//                }
//            }.resume()
//        }
//    }
//
//
//    ///for files that current user sends
//    private func getFileDirURLFrom(fileFirebaseURL: URL) -> URL? {
//        if  let secondLastComponent = fileName(firebaseUrl: fileFirebaseURL)  {
//            return getFileDirURLFor(key: secondLastComponent)
//        }
//        return nil
//    }
//
//    private func getFileDirURLFor(key: String) -> URL? {
//        if let documentsDirectoryURL = self.mainDirectoryUrl {
//            let destinationURL = documentsDirectoryURL.appendingPathComponent(key)
//            return destinationURL
//        }
//        return nil
//    }
//
//    func removeFromCacheIfExist(fileFirebaseURL: URL) {
//        guard let key = fileName(firebaseUrl: fileFirebaseURL) else {
//            return
//        }
//        removeFromCacheIfExist(key: key)
//    }
//
//    func removeFromCacheIfExist(key: String) {
//        guard let destinationURL = getFileDirURLFor(key: key) else {
//            return
//        }
//        if fileManager.fileExists(atPath: destinationURL.path){
//            do {
//                try fileManager.removeItem(atPath: destinationURL.path)
//            } catch {
//                print("fileManager.removeItem ",error.localizedDescription)
//            }
//        }
//    }
//
//
//    func saveInCache(fileDocURL: URL, fileFirebaseURL: URL,replaceIfExist: Bool = false) {
//        guard  let secondLastComponent = fileName(firebaseUrl: fileFirebaseURL) else {
//            return
//        }
//        saveInCache(fileDocURL: fileDocURL, forKey  : secondLastComponent, replaceIfExist: replaceIfExist)
//    }
//
//    func saveInCache(fileDocURL: URL, objectKey : String,callback : @escaping ( _  error : Error?) -> Void) {
//        saveInCache(fileDocURL: fileDocURL, forKey: objectKey + fileType(), callback: callback)
//    }
//
//    private func saveInCache(fileDocURL: URL, forKey key: String, replaceIfExist: Bool = false, callback : @escaping ( _  error : Error?) -> Void = {_ in}) {
//        let key = key.replacingOccurrences(of: possibleExtraStringInName, with: "")
//          let doesFileExist = doesFileExistFor(key: key)
//        guard let destinationURL = getFileDirURLFor(key: key), replaceIfExist || !doesFileExist else {
//            callback(nil)
//            return
//        }
//        do {
//            if replaceIfExist {
//               let _ = try FileManager.default.replaceItemAt(destinationURL, withItemAt: fileDocURL)
//            }else{
//                try FileManager.default.copyItem(at: fileDocURL, to: destinationURL)
//
//            }
//            callback(nil)
//        } catch {
//            callback(error)
//            print("Result.failure(error)",error.localizedDescription)
//        }
//
//    }
//
//
//    private func moveFileFrom(locationUrl : URL, to destinationUrl : URL , callback: @escaping (_ url : URL?,  _  error : Error?) -> Void) {
//
//        do {
//            try FileManager.default.moveItem(at: locationUrl, to: destinationUrl)
//            callback(destinationUrl,nil)
//        } catch {
//            callback(nil,error)
//            print("Result.failure(error)",error.localizedDescription)
//        }
//
//    }
//
//    private func fileName(firebaseUrl: URL) -> String?{
//        if let filename = firebaseUrl.secondLastComponent?.replacingOccurrences(of: possibleExtraStringInName, with: ""){
//            return filename + fileType()
//        }
//        return nil
//    }
//
//    private func directoryFor(fileURL: URL) -> URL? {
//        if  let fileURL = fileName(firebaseUrl: fileURL) {
//            return directoryFor(key: fileURL)
//        }
//        return nil
//    }
//
//      func directoryFor(key: String) -> URL? {
//          var key = key.contains(fileType()) ?  key : (key+fileType())
//          return mainDirectoryUrl?.appendingPathComponent(key)
//    }
//
//    func doesFileExistFor(key : String) -> Bool{
//        if let fileUrl = directoryFor(key: key) ,
//           fileManager.fileExists(atPath: fileUrl.path)  {
//           return true
//        }
//        return false
//    }
//
//
//     func clearTmpDirectory() {
//         cleanTmpDirectory(url: FileManager.default.temporaryDirectory, delay: 12)
//    }
//
//
//
//    func removeCacheDirectory(callback : @escaping ( _  error : Error?) -> Void) {
//        guard let mainDirectoryUrl = mainDirectoryUrl else {
//            return
//        }
//        deleteAndReCreate(directoryUrl: mainDirectoryUrl, callback: callback)
//    }
//
//   private func deleteAndReCreate(directoryUrl: URL,callback : @escaping ( _  error : Error?) -> Void = {_ in}){
//        do {
//            try FileManager.default.removeItem(at: directoryUrl)
//            try FileManager.default.createDirectory(atPath: directoryUrl.path, withIntermediateDirectories: true, attributes: nil)
//            callback(nil)
//        } catch let error {
//            callback(error)
//        }
//    }
//
//    func removeTmpFile(dirURL: URL){
//        let error = FileManager.default.removefileIfExist(path: dirURL.path)
//        print("tmp file deleted  \(error?.localizedDescription ?? "successfully")")
//    }
//
//    func cleanTmpDirectory(url: URL,delay: Int) {
//        guard delay > 0 else {
//            deleteAndReCreate(directoryUrl: url)
//            return
//        }
//        let today = Date()
//        DispatchQueue.main.asyncAfter(deadline: .now() +  TimeInterval(delay)) {
//            let keys : Set<URLResourceKey> = [.creationDateKey]
//           try? FileManager.default
//                .contentsOfDirectory(at: url, includingPropertiesForKeys: keys.getArray(), options:.skipsHiddenFiles)
//                .forEach { url in
//                    if let creationDate = (try? url.resourceValues(forKeys: keys))?.creationDate,creationDate < today{
//                        try? FileManager.default.removeItem(at: url)
//                    }
//                }
//
//        }
//    }
//}
