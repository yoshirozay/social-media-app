//
//  ReplyToCommentFunction.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 4/29/21.
//

import Combine
import Firebase
import FirebaseFunctions


class ReplyToCommentFunction: ObservableObject ,CloudFunction {
    // NEEDS TESTING FOR FRIENDS WHO COMMENTED NOTIFICATIONS
//    func replyToComment(sentBy: String, comment: String, commentID: String, postID: String, webLink: URL, postOwnerID: String, otherUserID: String, token: String, postOwnerToken: String, nameOfSendingUser: String, friendIDs: [String], friendIDs2: [String]){
//        var friendsWhoCommented = [String]()
//        friendsWhoCommented.append(contentsOf: friendIDs)
//        friendsWhoCommented.append(contentsOf: friendIDs2)
//        // Combines friends who commented on the post + friends who only replied to a comment and not the original post
//
//        var newFriendIDs = friendsWhoCommented.unique()
//
//        if newFriendIDs.firstIndex(of: otherUserID) != nil {
//            let firstIndexMatching = newFriendIDs.firstIndex(of: otherUserID)
//            newFriendIDs.remove(at: firstIndexMatching!)
//        } // removes a double notification for the user who CurrentUser is replying to
//
//        var commentInformation = [String: Any]()
//        commentInformation = [
//            "sentBy": sentBy,
//            "comment": comment,
//            "commentID": commentID,
//            "postID": postID,
//            "webLink": "\(webLink)",
//            "postOwnerID": postOwnerID,
//            "otherUserID": otherUserID,
//            "token": token,
//            "nameOfSendingUser": nameOfSendingUser,
//            "friendsWhoCommented": newFriendIDs
//        ]
//        Functions.functions().httpsCallable("replyToComment-replyToComment").call(commentInformation) { (result, error) in
//            if let error = error as NSError? {
//                if error.domain == FunctionsErrorDomain {
//                    print("\(error)")
//                    _ = FunctionsErrorCode(rawValue: error.code)
//                    _ = error.localizedDescription
//                    _ = error.userInfo[FunctionsErrorDetailsKey]
//                }
//                // ...
//            }
//            print("123 \(String(describing: result?.data))")
//
//        }
//
//    }
    // NEEDS TESTING FOR FRIENDS WHO COMMENTED NOTIFICATIONS

    class func replyToComment( rawReplyComment: CommentModel.Raw.Reply,callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        
        var friendsWhoCommented = [String]()
        friendsWhoCommented.append(contentsOf: rawReplyComment.friendIDs)
        friendsWhoCommented.append(contentsOf: rawReplyComment.friendIDs2)
        // Combines friends who commented on the post + friends who only replied to a comment and not the original post
        
        var newFriendIDs = friendsWhoCommented.unique()
        if let firstIndexMatching = newFriendIDs.firstIndex(of: rawReplyComment.otherUserID) {
            newFriendIDs.remove(at: firstIndexMatching)
        } // removes a double notification for the user who CurrentUser is replying to
        
        let commentInformation : [String: Any] = [
            "sentBy": rawReplyComment.sentBy,
            "comment": rawReplyComment.comment.trimWhitespacesAndNewlines(),
            "commentID": rawReplyComment.commentID,
            "postID": rawReplyComment.postID,
            "webLink": "\(rawReplyComment.webLink)",
            "postOwnerID": rawReplyComment.postOwnerID,
            "otherUserID": rawReplyComment.otherUserID,
            "token": rawReplyComment.token,
            "nameOfSendingUser": rawReplyComment.nameOfSendingUser,
            "friendsWhoCommented": newFriendIDs
        ]
        
        sendReplyCommentCloudFunc(postInformation: commentInformation) {
            callback($0)
        }
         
    }
    
    class func sendReplyCommentCloudFunc(postInformation: [String : Any],callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        Self.call(funcName: "replyToComment-replyToComment", informationDict: postInformation){
            callback($0)
        }
    }
    
    class func deleteReplyComment(deletedReplyRawComment: CommentModel.DeletedReplyRaw,
                             callback : @escaping (_  error : Error?) -> Void = {_ in }){
         
        let commentInformation = deletedReplyRawComment.dictionary
        Self.call(funcName: Constant.deleteCommentReplyFuncName(), informationDict: commentInformation,callback: callback)
    }
    enum Constant : String{
        case deleteCommentReplyFuncName = "deleteCommentReply-deleteCommentReply"
    }
    //sentBy,ogCommentID,commentReplyID,postID,otherUserID
}
