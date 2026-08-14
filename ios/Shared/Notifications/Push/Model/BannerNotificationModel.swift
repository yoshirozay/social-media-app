//
//  BannerNotificationModel.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 5/20/22.
//

import Foundation

struct NotificationBanner: Identifiable, Hashable {
    var id: String
    var notificationType: PNType
    var resourceID: String
    var authorID: String = ""
    var userID: String = ""
    var title: String = ""
    var body: String = ""
    var userImage: URL?
}

struct PushNotificationModel: Decodable {
    let aps: APS
    var type: PNType?
    var chatId: String?
    var postId: String?
    var authorId: String?
    var userID: String?
    var commentAuthorId: String?
    var comment: String?
    var userImage: URL?
    var eventID: String?
    
    enum CodingKeys: String, CodingKey {
        case aps
        case chatId
        case type
        case postId
        case authorId
        case userID
        case commentAuthorId
        case comment
        case userImage
        case eventID
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        aps = try container.decode(APS.self, forKey: .aps)
        type = try container.decodeIfPresent(PNType.self, forKey: .type)
        chatId = try container.decodeIfPresent(String.self, forKey: .chatId)
        postId = try container.decodeIfPresent(String.self, forKey: .postId)
        authorId = try container.decodeIfPresent(String.self, forKey: .authorId)
        userID = try container.decodeIfPresent(String.self, forKey: .userID)
        commentAuthorId = try container.decodeIfPresent(String.self, forKey: .commentAuthorId)
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        userImage = try container.decodeIfPresent(URL.self, forKey: .userImage)
        eventID = try container.decodeIfPresent(String.self, forKey: .eventID)

    }
    
    struct APS: Decodable {
        let alert: Alert
        
        struct Alert: Decodable {
            let title: String
            let body: String
        }
    }
    
    init(decoding userInfo: [AnyHashable : Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
        self = try JSONDecoder().decode(PushNotificationModel.self, from: data)
    }
}
