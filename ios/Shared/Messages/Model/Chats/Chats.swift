//
//  Chats.swift
//  speakEZ
//
//  Created by Ahmad naeem on 8/15/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
struct Chats: Decodable {
    //it can only be nil if we have a "documentID" field as well
    let documentId : String
    let lastMessageSentUUID : String
    let sentBy : String
    let members : [String]

    enum CodingKeys: String, CodingKey {
        case lastMessageSentUUID
        case sentBy
        case members
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        documentId = try FirestoreDocumentID(from: decoder).documentId 
        lastMessageSentUUID = try container.decode(String.self, forKey: .lastMessageSentUUID)
        sentBy = try container.decode(String.self, forKey: .sentBy)
        members = try container.decodeIfPresent([String].self, forKey: .members) ?? []
    }
    
    var otherUserID : String? {
        if let currentUserID = currentUserID {
            return members.filter({ $0 != currentUserID }).first
        }
        return nil
    }
    
}




struct FirestoreDocumentID : Decodable {
   var documentId : String
   enum CodingKeys: String, CodingKey {
       case ref
   }
   init(from decoder: Decoder) throws {
   
       let container = try decoder.container(keyedBy: CodingKeys.self)
       guard let documentID = try container.decode(DocumentID<DocumentReference>.self, forKey: .ref).wrappedValue?.documentID  else {
           throw  NSError.getWith(description: "was not able to get documentID")
       }
       self.documentId = documentID
   }
} 
