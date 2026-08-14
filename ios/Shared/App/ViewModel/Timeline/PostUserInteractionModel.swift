//
//  PostUserInteractionModel.swift
//  speakEZ
//
//  Created by Ahmad naeem on 2/12/22.
//


import Foundation 
import FirebaseFirestoreSwift
import FirebaseFirestore
  
///coments and likes which we use in the CommentLikeVM
struct PostUserInteractionModel : Decodable {
    var documentId : String
    var sentBy : String
    /** as we do not time for now we will not decode it from the like*/
    var time : Timestamp
    
    enum CodingKeys: String, CodingKey {
        case documentId
        case sentBy
        case time
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        documentId = try FirestoreDocumentID(from: decoder).documentId
        sentBy = try container.decode(String.self, forKey: .sentBy)
        time = try container.decode(Timestamp.self, forKey: .time)
    }
    static func getCollRef(authorId : String,postID : String) -> CollectionReference {
        Firestore.firestore().collection("Posts").document(authorId.nonEmpty).collection("UserPosts").document(postID.nonEmpty).collection("Likes")
    }
}
extension PostUserInteractionModel : Identifiable,Hashable,Equatable {
    var id : String { documentId }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(documentId)
    }
    static func == (lhs: PostUserInteractionModel, rhs: PostUserInteractionModel) -> Bool {
        return lhs.documentId == rhs.documentId
    }
}
