//
//  CommentModel+Raw.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 12/12/21.
//

import Foundation

extension CommentModel{
    struct Raw {
        var sentBy: String
        var comment: String
        var postID: String
        var otherUserID: String
        var friendIDs: [String]
        var token: String
        var nameOfSendingUser: String
         
        var selectedMedia: SelectedMedia?
        var isGIF : Bool = false
        var newMedia: NewMedia?{
            selectedMedia?.newMedia
        } 
        var kind: NewMedia.Kind? {
            selectedMedia?.newMedia?.kind
        }
        //FIXME: - need to change this
        var commentID: String = UUID().uuidString
 
        var commentInfo : [String: Any]  {
            [
                "sentBy": sentBy,
                "comment": comment.trimWhitespacesAndNewlines(),
                "commentID": commentID,
                "postID": postID,
                "otherUserID": otherUserID,
                 //FIXME: - need to test why we are having duplicate values here
                "friendsWhoCommented": friendIDs.getSet().getArray(),
                "token": token,
                "nameOfSendingUser": nameOfSendingUser,
                "isGIF": isGIF
            ]
        }
        var dummyCommentModel : CommentModel {
            CommentModel(rawComment: self)
        }
    }
    
    static let dateFormatter : DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "MMM d, h:mm:ss a"
        return format
    }()
}

extension CommentModel.Raw {
    struct Reply {
        var sentBy: String
        var comment: String
        var commentID: String
        var postID: String
        var webLink: URL
        var postOwnerID: String
        var otherUserID: String
        var token: String
        var postOwnerToken: String
        var nameOfSendingUser: String
        var friendIDs: [String]
        var friendIDs2: [String]
        var mentionIDs: [String]
        let dummyReplyCommentID: String = UUID().uuidString
    }
}
