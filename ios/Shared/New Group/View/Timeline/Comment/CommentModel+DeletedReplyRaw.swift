//
//  CommentModel+DeletedReplyRaw.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 12/12/21.
//

import Foundation

extension CommentModel { 
    struct DeletedReplyRaw {
        var sentBy: String
        var ogCommentID: String
        var commentReplyID: String
        var postID: String
        var otherUserID: String
         
        var dictionary : [String : Any] {
            [
                Constant.sentBy() : sentBy,
                Constant.ogCommentID() : ogCommentID,
                Constant.commentReplyID() : commentReplyID,
                Constant.postID() : postID,
                Constant.otherUserID() : otherUserID
            ]
        }
        enum Constant : String {
            case sentBy
            case ogCommentID
            case commentReplyID
            case postID
            case otherUserID
        }
    }
}
