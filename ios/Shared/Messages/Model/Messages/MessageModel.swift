//
//  MessageModel.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/19/21.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import RealmSwift
struct MessageModel : Identifiable, Hashable {
    ///id is the message id
    private (set) var id: String
    private (set) var sentBy: String
    private (set) var time: Timestamp
    private (set) var message: String
    private (set) var timeString: String
    private (set) var accurateTimeString: String = ""
    private (set) var otherUserID: String = ""
    private (set) var thumbnailUrl : URL?
    private (set) var videoUrl: URL?
    private (set) var audioUrl: URL?
    private (set) var photoLink: URL?
    private (set) var chatID: String
                  var alreadyViewOnce: Bool?
    private (set) var isGIF: Bool?
                  var didTakeScreenShot: Bool?
    var status: Status = .successfull
    var tempImage: UIImage? = nil
    var hasBeenLiked: Bool = false
    var kind: NewMedia.Kind?{
        if let _ = audioUrl {
            return .audio
        }else if let _ = photoLink{
            return .image
        }else if let _ = videoUrl,
                 let _ = thumbnailUrl {
            return .video
        }
        return nil
    }
    let isDummy: Bool
    /*
     only used in OpenedConversationOO.sendNewMessage. for dummy all messages messageInfo. should not be used for any other reason
     **/
    mutating func addDummyLink(kind : NewMedia.Kind?){
        if let kind =  kind{
            if kind == .image{
                photoLink = URL(string: "https://www.google.com")
            }else if kind == .video{
                videoUrl =  URL(string: "https://www.google.com")
            }else if kind == .audio{
                audioUrl =  URL(string: "https://www.google.com")
            }
           
        }
    }

}


//MARK:-   init with dictionary as argument
extension MessageModel {
    init(messageID : String,
         otherUserID : String = "",
         dict : [String : Any],
         isTimeStringInDays : Bool = false,
         chatID : String) {
        self.id = messageID
        self.otherUserID = otherUserID
        self.sentBy = dict[Constant.sentBy()] as? String ?? ""
        self.time = dict[Constant.time()] as? Timestamp ?? Timestamp()
        self.message = dict[Constant.message()] as? String ?? ""
        self.hasBeenLiked = dict[Constant.hasBeenLiked()] as? Bool ?? false
        self.thumbnailUrl = dict[Constant.thumbnailUrl()].possibleURL
        self.videoUrl  = dict[Constant.videoUrl()].possibleURL
        self.audioUrl  = dict[Constant.audioUrl()].possibleURL
        self.photoLink = dict[Constant.photoLink()].possibleURL
        if isTimeStringInDays {
            self.timeString = time.getTimeString()
        }else{
            self.timeString = Self.dateFormatter.string(from: time.dateValue())
        }
        self.accurateTimeString = Self.accurateTimeFormatter.string(from: time.dateValue())
        self.alreadyViewOnce = dict[Constant.alreadyViewOnce()] as? Bool
        self.isGIF = dict[Constant.isGIF()] as? Bool
        self.didTakeScreenShot = dict[Constant.didTakeScreenShot()] as? Bool
        self.chatID = chatID
        self.isDummy = false
    }
    //we can also have a call func that will replace the whole message object it with the latest stuff. but for now we can do with this
 
    
    static func getFailedRealmMessagesOf(otherUserID : String) -> [MessageModel]{
        Self.Raw.getFailedRealmMessagesOf(otherUserID: otherUserID)
    }
    /// more of pending mesages instead of failed
    static func getFailedRealmMessagesOf(chatID : String) -> [MessageModel]{
          RealmRawMessage.getFromRealm(chatUID: chatID)
    }
}

//MARK:-  MessageModel.Raw init
extension MessageModel {
    ///dummpy message init
    init(messageRaw : MessageModel.Raw, isTimeStringInDays : Bool = false) {
        self.id = messageRaw.messageUID
        self.sentBy = messageRaw.sentBy
        self.time =  Timestamp()
        self.message = messageRaw.message.trimWhitespacesAndNewlines()
        self.tempImage = messageRaw.newMedia?.image
        //we will not use the dummy message videoURL. we will only use it for displaying the play button
        self.videoUrl = messageRaw.newMedia?.videoUrl
        self.timeString = isTimeStringInDays ? time.getTimeString() : Self.dateFormatter.string(from: time.dateValue())
        self.status = .sending
        self.isDummy = true
        self.otherUserID = messageRaw.otherUserID
        //will only be used when we get dummy messages from realm
        if let sendTime = messageRaw.sendTime{
            self.time = Timestamp(date: sendTime)
        }
        self.chatID = messageRaw.chatUID
        self.isGIF = messageRaw.isGIF
        self.audioUrl = messageRaw.audioDirURL
    }
    
    mutating func setMessage( _ message : String) {
        self.message = message
    }
    
    mutating func setTime( _ time: Timestamp) {
        self.timeString = time.getTimeString()
        self.time = time
    }
    func deleteMediaFromCache(){
        if let kind = kind{
            SelectedMedia.deleteRealmObjectMediaFromCache(objectKey: id, kind: kind)
        }
    }
}

//MARK:- Constant and static funcs
extension MessageModel {
    enum Constant : String {
        case sentBy
        case message
        case time
        case messageUID
        case chatUID
        case otherUserID
        case token
        case nameOfSendingUser
        case thumbnailUrl
        case videoUrl
        case audioUrl
        case hasBeenLiked
        case photoLink
        case alreadyViewOnce
        case isGIF
        case didTakeScreenShot
        case groupName
        
        case ChatMessages
        case ChatMessagess
    }
    
    static func getMessageQueryRef(chatUID : String) -> CollectionReference {
        return Firestore.firestore()
            .collection(Constant.ChatMessages())
            .document(chatUID.nonEmpty)
            .collection(Constant.ChatMessagess())
    }
    static var dateFormatter : DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "MMM d, h:mm a"
        return format
    }()
    
    static let accurateTimeFormatter : DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "MMM d, h:mm:ss a"
        return format
    }()
     
}

/*
view once feature
 we will add "alreadyOnlyViewOnce"  the field in the message document.
 Sending :-
            so when user will send a message and tap on view once button, we will add the alreadyOnlyViewOnce property in the dict. and the docuemnt will be created with alreadyOnlyViewOnce = false.
 Receiving:-
            so when user will receive the message with view once we will show it differently then other messages.
            when user will tap on the messaeg to view, we will add a RealmViewOnceMessage in the realm which will contain message id, time and didTakeScreenShot bool. then we will start the timer with 10 sec limit to dismiss the media view. will also call the DidViewedOnce cloud func to update the alreadyOnlyViewOnce property to true in the firestore db.
 
 now the issues we have.
 we did call cloud func to update the message but did not get the callback, but it was
      1.  updated
      2.  not updated
 
 updated
 so in case of it was not updated, when user will launch the app again, now for every message with alreadyViewOnce = false we will check with realm to make sure that it is not in the realm. if we did found message in the realm then it means that it is already viewed so we will call the cloud func and also mark message to true.
 
 in case it did get updated and now it is true. we will start a realm listener that will give us all the viewonce messages stored in the realm count. if the count is not zero then we will check each message with viewOnce = false and if we found a match we will delete it from the realm. we need to do this so app does get alot of unneeded realm view once messages.
 
 now the only issue we have is that user views the onlyView message while offline and then delete the app . in that case the next time user install the app the user will still again be able to see the view once message again
 */

enum Status : Int, Codable,PersistableEnum {
    case sending
    case successfull
//    case error
}
