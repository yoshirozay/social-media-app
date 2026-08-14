//
//  CreateEventFunction.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 7/30/22.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFunctions
import FirebaseStorage
import SDWebImage

class EventFunctions: ObservableObject {
 
    func createEvent(startTime: Date, eventName: String, eventDescription: String, invitedUsers: [String], hostIDs: [String], location: String, nameOfSendingUser: String, eventID: String) {
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        var tempHostIDs = [String]()
        tempHostIDs = hostIDs
        tempHostIDs.append(userId)
      
        let conversationID = UUID().uuidString
        var eventInfo = [String: Any]()
        
        let format = DateFormatter()
        format.dateFormat =  "YYYY/MM/d HH:mm:ssZ"
        let newStartTime =  format.string(from: startTime)
        eventInfo = [
            "createdBy": userId,
            "hostIDs": tempHostIDs,
            "eventID": eventID,
            "eventName": eventName,
            "eventDescription": eventDescription,
            "eventTimeStart": newStartTime,
            "invitedUsers": invitedUsers,
            "conversationID": conversationID,
            "location": location,
            "nameOfSendingUser": nameOfSendingUser
        ]
        Functions.functions().httpsCallable("createEvent-createEvent").call(eventInfo) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    print("\(error)")
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            print("123 \(String(describing: result?.data))")
        }
        
    }
    func sendEventInvitation(eventID: String, userID: [String], nameOfSendingUser: String, eventName: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else{ return }
        var newUserIDs = [String]()
       newUserIDs = userID
        if let firstIndex = newUserIDs.firstIndex(of: currentUserId) {
            newUserIDs.remove(at: firstIndex)
        }
        if let firstIndex = newUserIDs.firstIndex(of: "") {
            newUserIDs.remove(at: firstIndex)
        }
        var eventInfo = [[String: Any]]()
        for item in newUserIDs {
            var individualInviteInfo = [String: Any]()
            individualInviteInfo = [
                "sentBy": currentUserId,
                "eventID": eventID,
                "userID": item,
                "nameOfSendingUser": nameOfSendingUser,
                "eventName": eventName,
            ]
            eventInfo.append(individualInviteInfo)
        }
        
        Functions.functions().httpsCallable("sendEventInvitation-sendEventInvitation").call(eventInfo) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    print("\(error)")
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            print("123 \(String(describing: result?.data))")
        }
        
    }
    func addEventHost(eventID: String, userID: [String:String], nameOfSendingUser: String, eventName: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else{ return }
        var newUserIDs = [String:String]()
       newUserIDs = userID

        var hostInfo = [[String: Any]]()
        for item in newUserIDs {
            if item.key != "" {
            var individualInviteInfo = [String: Any]()
            individualInviteInfo = [
                "sentBy": currentUserId,
                "eventID": eventID,
                "eventName": eventName,
                "userID": item.key,
                "token": item.value,
                "nameOfSendingUser": nameOfSendingUser,
            ]
            hostInfo.append(individualInviteInfo)
            }
        }
        
        Functions.functions().httpsCallable("addEventHost-addEventHost").call(hostInfo) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    print("\(error)")
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            print("123 \(String(describing: result?.data))")
        }
        
    }
    func acceptEventInvitation(eventID: String, sentBy: String, sentByToken: String, nameOfSendingUser: String, eventName: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else{ return }
 
            var eventInfo = [String: Any]()
        eventInfo = [
                "sentBy": sentBy,
                "eventID": eventID,
                "eventName": eventName,
                "userID": currentUserId,
                "sentByUserToken": sentByToken,
                "nameOfSendingUser": nameOfSendingUser,
            ]
        
        Functions.functions().httpsCallable("acceptEventInvitation-acceptEventInvitation").call(eventInfo) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    print("\(error)")
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            print("123 \(String(describing: result?.data))")
        }
        
    }
    func declineEventInvitation(eventID: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else{ return }
 
            var eventInfo = [String: Any]()
        eventInfo = [
                "sentBy": " ",
                "eventID": eventID,
                "userID": currentUserId,
            ]
        
        Functions.functions().httpsCallable("declineEventInvitation-declineEventInvitation").call(eventInfo) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    print("\(error)")
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            print("123 \(String(describing: result?.data))")
        }
        
    }
    func sendEventMessage(eventID: String, selectedMedia: SelectedMedia?, message: String, nameOfCurrentUser: String, eventConversationID: String, isGIF: Bool, messageID: String, eventName: String, attendingFriendTokens: [String]) {
        guard let currentUserId = Auth.auth().currentUser?.uid else{ return }
            var messageInfo = [String: Any]()
        messageInfo = [
                "sentBy": currentUserId,
                "eventID": eventID,
                "message": message,
                "messageID": messageID,
                "userID": currentUserId,
                "nameOfSendingUser": nameOfCurrentUser,
                "conversationID": eventConversationID,
                "isGIF": isGIF,
                "eventName": eventName,
                "attendingFriendTokens": attendingFriendTokens
            ]
        
        if let audioUrl = selectedMedia?.audioUrl {
            sendAudioMessage(audioUrl: audioUrl, informationDict: messageInfo) { error in
            }
        } else if let newMedia = selectedMedia?.newMedia {
            sendMediaMessage(newMedia: newMedia, eventID: eventID, messageID: messageID, informationDict: messageInfo) { error in
            }
        } else {
            sendRegularMessage(informationDict: messageInfo)
        }
        
        func sendRegularMessage(informationDict: [String: Any]) {
            Functions.functions().httpsCallable("sendEventMessage-sendEventMessage").call(informationDict) { (result, error) in
                if let _ = error   {
                    print(error ?? "")
                }
            }
        }
        
        func sendAudioMessage(audioUrl: URL,informationDict: [String: Any],
                       callback : @escaping (  _  error : Error?) -> Void) {
            let storageRef = Storage.storage().reference()
                .child(eventID)
                .child(messageID)
                .child("audio.m4a")
            let funcName = "sendEventMessage-sendEventMessage"
            
            uploadFile(fileDirURL: audioUrl, fileType: .audio_m4a, storageRef: storageRef){ audioFirebaseUrl, error in
                callWithAudioInfo(funcName: funcName,
                                  informationDict: informationDict,
                                  audioFirebaseUrl: audioFirebaseUrl,
                                  audioDirURL: audioUrl,
                                  doHaveFailedManager: false,
                                  callback: callback)
            }
            
            func uploadFile(fileDirURL: URL,fileType: UploadingFileType,storageRef: StorageReference,callback : @escaping (_ fileFirebaseUrl : URL?,_  error : Error?) -> Void) {
                let metadata = StorageMetadata()
                metadata.contentType = fileType()
                storageRef.putFile(from: fileDirURL, metadata: metadata ) { (meta, error) in
                    if let error = error {
                        callback(nil,error)
                    } else {
                        storageRef.downloadURL(completion:callback)
                    }
                }
            }
            func callWithAudioInfo(funcName : String,
                                   informationDict : [String :Any],
                                   audioFirebaseUrl : URL?,
                                   audioDirURL : URL,
                                   doHaveFailedManager : Bool = true,
                                   isAnEdit: Bool = false,
                                   callback : @escaping ( _  error : Error?) -> Void = {_ in }){
                if let audioUrl = audioFirebaseUrl {
                    var informationDict = informationDict
                    informationDict["audioUrl"] = audioUrl.absoluteString
                    Functions.functions().httpsCallable("sendEventMessage-sendEventMessage").call(informationDict) { (result, error) in
                        if let _ = error   {
                            print(error ?? "")
                        }else if doHaveFailedManager == false{
                            AudioCacheManager.shared.saveInFileCache(tempFileURL: audioDirURL, firebaseFileURL: audioDirURL)
                        }
                        AudioCacheManager.shared.removeTmpFile(dirURL: audioDirURL)
                        callback(error)
                    }
                    
                    if doHaveFailedManager{
                        AudioCacheManager.shared.saveInFileCache(tempFileURL: audioDirURL, firebaseFileURL: audioDirURL)
                    }
                }else{
                    callback(NSError.getWith(description: "Was not able to upload audio"))
                }
            }
        }
        
        func sendMediaMessage(newMedia : NewMedia, eventID: String, messageID: String, informationDict: [String: Any], callback : @escaping ( _  error : Error?) -> Void) {
            
            if let VideoFirebaseUrl = newMedia.videoUrl {
                sendVideoMessage(thumbnailImage: newMedia.image, videoDirURL: VideoFirebaseUrl, eventID: eventID, messageID: messageID, informationDict: informationDict, callback: callback)
                return
            }
            let messagePhoto = newMedia.image
            guard let imageData = messagePhoto.highestQualityJPEGNSData else {
                    callback(NSError.getWith(description: "Image highestQualityJPEGNSData Failed"))
                    return
            }
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            var storage = Storage.storage().reference()
            storage = storage
                .child(eventID)
                .child(messageID)
                .child("newPhoto.jpeg")
            
            storage.putData(imageData, metadata: metadata) { (meta, error) in
                    if let error = error {
                        callback(error)
                        return
                    } else {
                        storage.downloadURL { url, error in
                            if let downloadedURL = url {
                                var informationDict = informationDict
                                SDImageCache.shared.add(image: messagePhoto, url: downloadedURL)
                                informationDict["photoLink"] = downloadedURL.absoluteString
                                Functions.functions().httpsCallable("sendEventMessage-sendEventMessage").call(informationDict) { (result, error) in
                                    if let _ = error  {
                                        SDImageCache.shared.removeImage(forKey: downloadedURL.absoluteString)
                                    }
                                    callback(error)
                                    print("123 \(String(describing: result?.data))")
                                }
                            }
                           
                        }
                    }
                }
            
            
            func sendVideoMessage(thumbnailImage : UIImage, videoDirURL : URL, eventID: String, messageID: String, informationDict: [String: Any], callback : @escaping (  _  error : Error?) -> Void = {  _ in}) {

                var informationDict = informationDict
                var thumbnailFirebaseUrl : URL! = nil
                var VideoFirebaseUrl : URL! = nil
                let dispatchGroup = DispatchGroup()
                
                let uploadImage = {
                    let messagePhoto = thumbnailImage
                    var storageRef = Storage.storage().reference()
                    guard let imageData = messagePhoto.highestQualityJPEGNSData else {
                            callback(NSError.getWith(description: "Image highestQualityJPEGNSData Failed"))
                            return
                    }
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    dispatchGroup.enter()
                    
                    storageRef = storageRef
                        .child(eventID)
                        .child(messageID)
                        .child("thumbnail.jpeg")
                    storageRef.putData(imageData, metadata: metadata) { (meta, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            dispatchGroup.leave()
                        } else {
                            storageRef.downloadURL { url, error in
                                if let url = url {
                                    thumbnailFirebaseUrl = url
                                }
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
                let uploadVideo = {
                    var storageRef = Storage.storage().reference()
                    let metadata = StorageMetadata()
                    metadata.contentType = "video/quicktime"
                    dispatchGroup.enter()

                    storageRef = storageRef
                        .child(eventID)
                        .child(messageID)
                        .child("video.mov")
                    storageRef.putFile(from: videoDirURL, metadata: metadata ) { (meta, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            dispatchGroup.leave()
                        } else {
                            storageRef.downloadURL { url, error in
                                if let url = url {
                                    VideoFirebaseUrl = url
                                }
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
                uploadImage()
                uploadVideo()
                
                dispatchGroup.notify(queue: .main) {
                    if let videoUrl = VideoFirebaseUrl ,
                       let thumbnailUrl = thumbnailFirebaseUrl  {
                        informationDict["thumbnailUrl"] = thumbnailUrl.absoluteString
                        informationDict["videoUrl"] = videoUrl.absoluteString
                        Functions.functions().httpsCallable("sendEventMessage-sendEventMessage").call(informationDict) { (result, error) in
                            if let error = error {
                                print(error.localizedDescription)
                                VideoCacheManager.shared.removeFromTempCacheIfExist(fileFirebaseURL: videoUrl)
                                SDImageCache.shared.removeImage(forKey: thumbnailUrl.absoluteString)
                            }
                            callback(error)
                        }
                        
                        SDImageCache.shared.add(image: thumbnailImage, url: thumbnailUrl)
                        VideoCacheManager.shared.saveInFileCache(tempFileURL: videoDirURL, firebaseFileURL: videoUrl)
                        
                    }else{
                        let error = NSError.getWith(description: "Sending Message Failed")
                        callback(error)
                    }
                }
            }
        }
        
    }
    func likeEventMessage(eventID: String, nameOfCurrentUser: String, conversationID: String, messageID: String) {
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        var likeInfo = [String: Any]()
        likeInfo = [
            "sentBy": userId,
            "eventID": eventID,
            "messageID": messageID,
            "conversationID": conversationID,
            "nameOfCurrentUser": nameOfCurrentUser,
        ]
        Functions.functions().httpsCallable("likeEventMessage-likeEventMessage").call(likeInfo) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    print("\(error)")
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            print("123 \(String(describing: result?.data))")
        }
    }
//    func checkIfEventIsOver() {
//
//        Functions.functions().httpsCallable("checkIfEventIsOver-checkIfEventIsOver").call() { (result, error) in
//            if let error = error as NSError? {
//                if error.domain == FunctionsErrorDomain {
//                    print("\(error)")
//                    _ = FunctionsErrorCode(rawValue: error.code)
//                    _ = error.localizedDescription
//                    _ = error.userInfo[FunctionsErrorDetailsKey]
//                }
//                // ...
//            }
//            print("123 \(String(describing: result?.data))")
//        }
//
//    }
    func updateEventDetails(oldStartTime: Date, newStartTime: Date, eventName: String, eventDescription: String, location: String, eventID: String, allAttendingTokens: [String]) {
        guard let userId = Auth.auth().currentUser?.uid else{ return }

        var eventInfo = [String: Any]()
        var newEventTime = false
        if oldStartTime != newStartTime {
            newEventTime = true
        }
        let format = DateFormatter()
        format.dateFormat =  "YYYY/MM/d HH:mm:ssZ"
        let newStartTime2 = format.string(from: newStartTime)
        
        let format2 = DateFormatter()
   
        format2.dateFormat = "MMMM d, h:mma"
        let newEventTimeString = format2.string(from: newStartTime)
        eventInfo = [
            "createdBy": userId,
            "eventID": eventID,
            "eventName": eventName,
            "eventDescription": eventDescription,
            "eventTimeStart": newStartTime2,
            "location": location,
            "newEventTime": newEventTime,
            "allAttendingTokens": allAttendingTokens,
            "newEventTimeString": newEventTimeString,
        ]
        Functions.functions().httpsCallable("updateEventDetails-updateEventDetails").call(eventInfo) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    print("\(error)")
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            print("123 \(String(describing: result?.data))")
        }
        
    }
    func requestToJoinEvent(eventID: String, sentByToken: String, nameOfSendingUser: String, eventName: String, message: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else{ return }
 
            var eventInfo = [String: Any]()
        eventInfo = [
                "eventID": eventID,
                "eventName": eventName,
                "userID": currentUserId,
                "sentByUserToken": sentByToken,
                "nameOfSendingUser": nameOfSendingUser,
                "message": message
            ]
        
        Functions.functions().httpsCallable("requestToJoinEvent-requestToJoinEvent").call(eventInfo) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    print("\(error)")
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            print("123 \(String(describing: result?.data))")
        }
        
    }
    func acceptEventRequest(eventID: String, token: String, eventName: String, userID: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else{ return }
 
            var eventInfo = [String: Any]()
        eventInfo = [
                "currentUser": currentUserId,
                "eventID": eventID,
                "eventName": eventName,
                "userID": userID,
                "token": token,
            ]
        Functions.functions().httpsCallable("acceptEventRequest-acceptEventRequest").call(eventInfo) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    print("\(error)")
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            print("123 \(String(describing: result?.data))")
        }
        
    }
    func declineEventRequest(eventID: String, userID: String) {
 
            var eventInfo = [String: Any]()
        eventInfo = [
                "eventID": eventID,
                "userID": userID,
            ]
        Functions.functions().httpsCallable("declineEventRequest-declineEventRequest").call(eventInfo) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    print("\(error)")
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            print("123 \(String(describing: result?.data))")
        }
        
    }
    func removeFromEvent(eventID: String, userID: String) {
 
            var eventInfo = [String: Any]()
        eventInfo = [
                "eventID": eventID,
                "userID": userID,
            ]
        Functions.functions().httpsCallable("removeFromEvent-removeFromEvent").call(eventInfo) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    print("\(error)")
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            print("123 \(String(describing: result?.data))")
        }
        
    }
    func cancelEventInvitation(eventID: String, userID: String) {
 
            var eventInfo = [String: Any]()
        eventInfo = [
                "eventID": eventID,
                "userID": userID,
            ]
        Functions.functions().httpsCallable("cancelEventInvitation-cancelEventInvitation").call(eventInfo) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    print("\(error)")
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            print("123 \(String(describing: result?.data))")
        }
        
    }
    func deleteEvent(eventID: String, eventName: String) {
 
            var eventInfo = [String: Any]()
        eventInfo = [
                "eventID": eventID,
                "eventName": eventName,
            ]
        Functions.functions().httpsCallable("deleteEvent-deleteEvent").call(eventInfo) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    print("\(error)")
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            print("123 \(String(describing: result?.data))")
        }
        
    }
}
