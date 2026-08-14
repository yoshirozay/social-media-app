//
//  EventModel.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 7/29/22.
//

import Foundation
import SwiftUI
import Firebase


struct EventModel: Identifiable, Hashable {
    let id: String
    var eventName: String = ""
    var eventDescription: String = ""
    var month: String = ""
    var dateNumber: String = ""
    var time: Timestamp = Timestamp()
    var startTime: String = ""
    var location = ""
    var isLoading = false
}

struct EventMessageModel: Identifiable, Hashable {
    let id: String
    let time: Timestamp
    let message: String
    var timeString: String
    var messageID: String
    var status : Status = .successfull
    var isGIF: Bool?
    var photoLink: URL? = nil
    var thumbnailUrl : URL? = nil
    var videoUrl : URL? = nil
    var audioUrl: URL? = nil
    var tempImage : UIImage?
    var kind : NewMedia.Kind?
    
    
    internal init(
        id: String,
        time: Timestamp,
        message: String,
        timeString: String,
        messageID: String,
        status: Status = .successfull,
        isGIF: Bool,
        photoLink: URL? = nil,
        tempImage : UIImage? = nil,
        thumbnailUrl : URL? = nil,
        videoUrl : URL? = nil,
        audioUrl: URL? = nil) {
            self.id = id
            self.time = time
            self.message = message
            self.messageID = messageID
            self.status = status
            self.timeString = timeString
            self.isGIF = isGIF
            self.photoLink = photoLink
            self.tempImage = tempImage
            self.thumbnailUrl = thumbnailUrl
            self.videoUrl = videoUrl
            self.audioUrl = audioUrl
        }

    init(messageDict dict: [String : Any], messageID : String)  {
        let sentBy = dict["sentBy"] as? String ?? ""
        let message = dict["message"] as? String ?? ""
        let time = dict["time"] as? Timestamp ?? Timestamp()
        let timeString = time.getTimeString()
        let photoLink = dict["photoLink"].possibleURL
        let thumbnailUrl = dict["thumbnailUrl"].possibleURL
        let videoUrl = dict["videoUrl"].possibleURL
        let audioUrl = dict["audioUrl"].possibleURL
        let isGIF = dict["isGIF"] as?  Bool ?? false
        self.init(
            id: sentBy,
            time: time,
            message: message,
            timeString: timeString,
            messageID: messageID,
            isGIF: isGIF,
            photoLink: photoLink,
            thumbnailUrl: thumbnailUrl,
            videoUrl: videoUrl,
            audioUrl: audioUrl
        )
    }
    static func getEventConversationCollRef(eventID: String, conversationID: String) -> CollectionReference {
          Firestore.firestore().collection("AllEvents")
            .document(eventID.nonEmpty).collection("EventConversation")
            .document(conversationID.nonEmpty).collection("Messages")
    }
    static func getEventConversationMessageLikeRef(eventID: String, conversationID: String, messageID: String) -> CollectionReference {
        getEventConversationCollRef(eventID: eventID, conversationID: conversationID)
            .document(messageID.nonEmpty).collection("Likes")
    }

}

extension EventMessageModel{

    static let dateFormatter : DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "MMM d, h:mm:ss a"
        return format
    }()
}

struct EventRequest: Identifiable, Hashable {
    let id: String
    let person: Person
    let message: String
    let token: String
}
