//
//  Comment-M.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//


import Firebase
import FirebaseFirestore
import FirebaseFunctions
import FirebaseStorage
import Foundation
import LinkPresentation

struct CommentModel: Identifiable, Hashable {
   
   let id: String
   let time: Timestamp
   let comment: String
   var timeString: String
   var accurateTimeString: String
   var commentID: String
   var status : Status = .successfull
   var isGIF : Bool?
   var photoLink: URL? = nil
   var thumbnailUrl : URL? = nil
   var videoUrl : URL? = nil
   var audioUrl: URL? = nil
   var tempImage : UIImage?
   var kind : NewMedia.Kind?
   var isDummy: Bool
   let hasMention: Bool
    var linkMetaData: LPLinkMetadata? = nil
   internal init(id: String,
                 time: Timestamp,
                 comment: String,
                 timeString: String,
                 accurateTimeString: String,
                 commentID: String,
                 status: Status = .successfull,
                 photoLink: URL? = nil,
                 tempImage : UIImage? = nil,
                 thumbnailUrl : URL? = nil,
                 videoUrl : URL? = nil,
                 isGIF : Bool = false,
                 audioUrl: URL? = nil,
                 linkMetaData: LPLinkMetadata? = nil
   ) {
       self.id = id
       self.time = time
       self.comment = comment
       self.timeString = timeString
       self.accurateTimeString = accurateTimeString
       self.commentID = commentID
       self.status = status
       self.isDummy = status == .sending
       self.photoLink = photoLink
       self.tempImage = tempImage
       self.thumbnailUrl = thumbnailUrl
       self.videoUrl = videoUrl
       self.isGIF = isGIF
       self.audioUrl = audioUrl
       self.kind = audioUrl == nil ? (videoUrl == nil ? ((photoLink == nil && tempImage == nil) ? nil : .image) : .video) : .audio
       self.hasMention = comment.indicesOf(string: "@").isNotEmpty
       self.linkMetaData = linkMetaData
   }
   
    
   init(commentDict dict: [String : Any],commentID : String)  {
       let sentBy = dict["sentBy"] as? String ?? ""
       let content : String = ((dict["comment"] ?? dict["content"]) as? String) ?? ""
       // cloud function uses "comment" but old function uses "content"
       let time = dict["time"] as? Timestamp ?? Timestamp()
       let accurateTimeString = Self.dateFormatter.string(from: time.dateValue())
       let photoLink = dict["photoLink"].possibleURL
       let thumbnailUrl = dict["thumbnailUrl"].possibleURL
       let videoUrl = dict["videoUrl"].possibleURL
       let audioUrl = dict["audioUrl"].possibleURL
       let isGIF = dict["isGIF"] as?  Bool ?? false
       self.init(id: sentBy,
                 time: time,
                 comment: content,
                 timeString: time.getTimeString(),
                 accurateTimeString: accurateTimeString,
                 commentID: commentID,
                 photoLink: photoLink,
                 thumbnailUrl : thumbnailUrl,
                 videoUrl : videoUrl,
                 isGIF : isGIF,
                 audioUrl: audioUrl
           )
   }
  
   static func getPostCommentCollRef(authorId : String,postID : String) -> CollectionReference {
         Firestore.firestore().collection("Posts")
           .document(authorId.nonEmpty).collection("UserPosts")
           .document(postID.nonEmpty).collection("Comments")
   }
   
   static func getPostCommentCollRef(authorId : String,postID : String,commentID : String) -> CollectionReference {
       getPostCommentCollRef(authorId: authorId, postID: postID)
           .document(commentID.nonEmpty).collection("Comments")
   }
   
   static func getPostCommentLikeRef(authorId: String, postID: String, commentID: String) -> CollectionReference {
       getPostCommentCollRef(authorId: authorId, postID: postID)
           .document(commentID.nonEmpty).collection("Likes")
   }
   
   init(rawComment : CommentModel.Raw) {
       let time = Timestamp()
       let accurateTimeString = Self.dateFormat.string(from: time.dateValue())
       self.init(id: rawComment.sentBy,
                 time: time,
                 comment: rawComment.comment,
                 timeString: time.getTimeString(),
                 accurateTimeString: accurateTimeString,
                 commentID: rawComment.commentID,
                 status: .sending,
                 tempImage: rawComment.newMedia?.image,
                 videoUrl : rawComment.newMedia?.videoUrl,
                 isGIF: rawComment.isGIF,
                 audioUrl: rawComment.selectedMedia?.audioUrl)
   }
   
   static let dateFormat : DateFormatter = {
       let format = DateFormatter()
       format.dateFormat = "MMM d, h:mm:ss a"
       return format
   }()
}

extension CommentModel {
   internal init(id: String, commentID: String, comment: String, time: Timestamp) {
       let accurateTimeString = Self.dateFormatter.string(from: time.dateValue())
       self.init(id: id,
                 time: time,
                 comment: comment,
                 timeString: time.getTimeString(),
                 accurateTimeString: accurateTimeString,
                 commentID: commentID  )
   }
   
}
