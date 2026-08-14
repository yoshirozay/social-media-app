//
//  Comment-DeletedRaw-M.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//

import Foundation

extension CommentModel {
    struct DeletedRaw {
        var sentBy: String
        var commentID: String
        var postID: String
        var otherUserID: String
        
        var dictionary : [String : Any] {
            [
                Constant.sentBy() : sentBy,
                Constant.commentID() : commentID,
                Constant.postID() : postID,
                Constant.otherUserID() : otherUserID
            ]
        }
        enum Constant : String {
            case sentBy
            case commentID
            case postID
            case otherUserID
        }
    }
}

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
