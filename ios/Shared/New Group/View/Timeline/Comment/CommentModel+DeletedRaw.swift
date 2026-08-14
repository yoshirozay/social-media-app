//
//  CommentModel+DeletedRaw.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 12/12/21.
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
