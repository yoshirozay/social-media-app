//
//  NotificationsModel.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 2/22/21.
//

import SwiftUI
import Firebase
import FirebaseFirestore


struct Notification: Identifiable, Hashable {
    var id: String
    var resourceType: String
    var resourceID: String
    var sentFromUser: String
    var createdAt: Timestamp
    var timeString = ""
    var accurateTimeString = ""
    var currentUser = Auth.auth().currentUser?.uid ?? ""
    var newNotification: Bool
    var nameOfSendingUser = ""
    var webLink: URL?
    var nameOfSharedFriend = ""
    var notificationType :  Notification.Kind? {
        return Notification.Kind(rawValue: resourceType)
    }
    var originalAuthor : String?
    
    enum Kind : String {
        //first 7 cases are post related
        case like,
             comment,
             postMention,
             commentMention,
             likedComment,
             commentReply,
             alsoC,
             /// these are friends related
             acceptedRequest,
             friendRequest,
             sharedF
        
        var isItPostRelatedNotification : Bool {
            Self.isItPostRelatedNotification(resourceType: self.rawValue)
        }
        
        func getIfPostRelatedNotification() -> Notification.Kind? {
            Self.getIfPostRelatedNotification(resourceType: self.rawValue)
        }
        
      static func isItPostRelatedNotification(resourceType : String) -> Bool{
            if let notifType = Notification.Kind(rawValue: resourceType ){
                switch notifType {
                case .like,
                     .comment,
                     .likedComment,
                     .commentReply,
                     .postMention,
                     .commentMention,
                     .alsoC:
                    return true
                default:
                    return false
                }
            }
            return false
        }
        
        static func getIfPostRelatedNotification(resourceType : String) -> Notification.Kind? {
            if  isItPostRelatedNotification(resourceType: resourceType),
                let notifType = Notification.Kind(rawValue: resourceType )  {
                return notifType
            }
            return nil
        }
        
    }
}

struct MentionNotification: Identifiable, Hashable {
    var id: String
    var resourceID: String
    var sentBy = Auth.auth().currentUser?.uid ?? ""
    var sentTo: String
    var token = ""
    var nameOfSendingUser = ""
    var originalAuthor: String
}
