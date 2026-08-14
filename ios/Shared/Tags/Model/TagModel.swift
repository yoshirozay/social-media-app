//
//  TagModel.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 6/3/21.
//
import Foundation
import SwiftUI
import Firebase


struct TagModel: Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String
}

struct TagModel2: Codable, Identifiable, Hashable {
    
    var id : String
    var name: String
    var description: String
    var sentBy: String = ""
    var status : Status = .successfull
    var isDummy : Bool{
        status == .sending
    }
    enum TagCodingKeys: String, CodingKey {
        case id
        case name
        case description
        case sentBy
    }
    
    init(id: String, name: String, description: String, sentBy: String, status : Status = .successfull) {
        self.id = id
        self.name = name
        self.description = description
        self.sentBy = sentBy
        self.status = status
    }
    
    init(id : String) {
        self.id = id
        self.name = ""
        self.description = ""
        self.sentBy = ""
    }
    
     init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: TagCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        description = try values.decode(String.self, forKey: .description)
        sentBy = try values.decode(String.self, forKey: .sentBy)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TagCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(sentBy, forKey: .sentBy)
    }
    

    static func getTagFromTagID(tagID: String? = nil, documentData: [String: Any], callback: @escaping (_ tag :  TagModel2?,  _ error : Error?) -> Void) {
        let dict = documentData
        let id = tagID
        let name = dict["name"] as? String ?? ""
        let description = dict["description"] as? String ?? ""

        func sendTagInCallback() {
            let tag : TagModel2
            tag = TagModel2(id: id ?? "", name: name, description: description, sentBy: "")
            callback(tag, nil)
        }
            sendTagInCallback()
    }
}
  
extension TagModel2   {
    static let tagNotification = Foundation.Notification.Name("TagNotificationSender")
    static let tagFailedNotification = Foundation.Notification.Name("tagFailedNotification")
}
