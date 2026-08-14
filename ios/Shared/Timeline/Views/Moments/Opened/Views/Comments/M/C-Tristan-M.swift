//
//  C-Tristan-M.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//

import Foundation
import FirebaseFirestore

extension CommentModel  {
   
    struct Preloaded {
        private init(){}
        static let shared = Preloaded()
         
        static func getCommentsForPost(postID : String) -> [CommentModel] {
             shared.getCommentsForPost(postID: postID)
         }
    }
    
}
//for now just make dummy comment for one post only
extension CommentModel.Preloaded  {
  
          func getCommentsForPost(postID : String) -> [CommentModel] {
            guard let postID = PostModel.Preloaded.PostIDs.init(rawValue: postID) else { return [] }
            switch postID {
            case .post1 :
                return  post1Comments
            case .post2:
                return  post2Comments
            case .post3:
                return  post3Comments
            case .post4:
                return  post4Comments
            case .post5:
                return post5Comments
            case .post6:
                return  post6Comments
            case .post7:
                return post7Comments
            case .post8:
                return post8Comments
            case .post9:
                return post9Comments
            case .post10:
                return post10Comments
            }
        }
          var post1Comments : [CommentModel] {
            let commentsByOrder = [
                "Add friends by typing their username in the search bar, then press \"GO\"",
                "To share your profile with others, either send them your username or navigate to your profile, then press the share icon in the top right corner"]
            return getAllCommentOFPost(number: 1, comments: commentsByOrder)
        }
        
          var post2Comments : [CommentModel] {
            let commentsByOrder = [
                "There are no \"Followers\" or \"Following\" in speakEZ. To be in someone's 150, they must also be in your 150.",
                "This is to ensure your speakEZ stays like a speakeasy, genuine, intimate, and a place where anything goes.",
                "Moments can be seen by all people in your speakEZ, unless you use \"Keys\"",
            ]
            return getAllCommentOFPost(number: 2, comments: commentsByOrder)
        }
        
          var post3Comments : [CommentModel] {
            let commentsByOrder = [
                "Not all moments are for all eyes. Press the lock icon and attach a key(s) to it for additional privacy",
                "Your community wants to hear from you. Let's do better at keeping them in the loop",
                "Timelines are made entirely of moments"]
            return getAllCommentOFPost(number: 3, comments: commentsByOrder)
        }
        
          var post4Comments : [CommentModel] {
            let commentsByOrder = [
                "Keys are flexible and unlimited. You can create a fantasy football key, a mental health key, a fitness key, etc.",
                "Only friends who have access to your Key can see the contents of your locked moment. Additionally, they cannot see who else has access to your Key, nor can they see that your moment is locked.",
                "Moments are unlocked by default" ]
            return getAllCommentOFPost(number: 4, comments: commentsByOrder)
        }
        
          var post5Comments : [CommentModel] {
            let commentsByOrder = [
                "Messages are private conversations. Only the person you are talking to can see these messages",
                "Start a new conversation by pressing \"+\" in \"Messages\" or create a group chat by pressing \"+\" a second time",
                "Press the Camera button at the bottom of \"Messages\" to send a photo/video in multiple conversations at once",
            ]
            return getAllCommentOFPost(number: 5, comments: commentsByOrder)
        }
         
          var post6Comments : [CommentModel] {
            let commentsByOrder = [
                "When in doubt, swipe back",
]
            return getAllCommentOFPost(number: 6, comments: commentsByOrder)
        }
    var post7Comments : [CommentModel] {
        let commentsByOrder = [
            "With so much technology, it shouldn't be so difficult to stay connected with friends :( ",
            "That's why I made this app! speakEZ is where you can share the small and big Moments with the people you care about the most :)",
            "Your speakeasy has a capacity of 150 people- only add friends that you want to let see your full, authentic self!",
            "If you are wondering who you should add as a friend, imagine who you want at your wedding!",
        ]
        return getAllCommentOFPost(number: 7, comments: commentsByOrder)
    }
    var post8Comments : [CommentModel] {
      let commentsByOrder = [
        "This group conversation is what we call a Moment. The topic is your Moment's content!",
//          "Commenting on Moments sends a traditional text message, but you can spice it up by sending GIFs, photos, videos, and audio messages!",
        "You can communicate by writing a comment, or by pressing one of the icons below (to send a GIF, photo, video, or audio message!)",
          "You can only see Moments of people that belong to your friend list and vice versa (privacy is key)",
          "Swipe back and then press the top icon to share your first Moment!",
]
      return getAllCommentOFPost(number: 8, comments: commentsByOrder)
  }
    var post9Comments : [CommentModel] {
        let commentsByOrder = [
            "Everyone with access can see comments on a Moment, press the lock above to see who is included!",
            "Open Moments are symbolized by the \"unlock\" button, this means all the author's friends have access and can enjoy your comments",
            "If you see a locked symbol, congratulations! The author has created a friend sub-group and decided that you should be in it :)",
            "Locks can be attached when you create a Moment. They are incredibly flexible and can be used to create multiple friend sub-groups for all of your desires",
            "Using a lock is common courtesy for niche Moments, this helps to prevent uninteresting Moments on our Timelines (not everyone loves sports and not everyone loves shopping!)"
            
        ]
        return getAllCommentOFPost(number: 9, comments: commentsByOrder)
    }
    var post10Comments : [CommentModel] {
      let commentsByOrder = [
          "Notifications are essential to staying connected, I highly recommend you enable them!",
          "By default, you will receive silent notifications when your friends share Moments. You can always disable this feature in your profile settings if it gets overwhelming <3",
          "Commenting on a Moment subscribes you to its notifications",
          "You can simply hold down the author's photo and press pause notifications if you don't want them :)",
 
]
      return getAllCommentOFPost(number: 10, comments: commentsByOrder)
  }
          func getAllCommentOFPost(number : Int,comments : [String]) -> [CommentModel] {
            return comments.enumerated().map{ getCommentOf(number: $0.offset+1, ofPostNumber: number, commentText: $0.element) }
        }
          func getCommentOf(number :Int, ofPostNumber postNumber : Int,commentText : String ) -> CommentModel {
            let commentID = CommentIDs.getCommentIDOf(number : number)
            let time =  PostModel.Preloaded.getDateOfPost(number: postNumber).timestamp
            return CommentModel(id: TristanUserID, commentID: commentID, comment: commentText, time: time)
        }
        
      
       /*
        ///this is also a way to create a postComment var if needed and this works as well
          var post1Comments : [CommentModel] {
            [getCommentOf(number: 1, ofPostNumber: 1, commentText: "Post1Comment 1st comment here for preloaded comment people"),
             getCommentOf(number: 2, ofPostNumber: 1, commentText: "Post1Comment 2nd comment fluff-kun"),
             getCommentOf(number: 3, ofPostNumber: 1, commentText: "Post1Comment 3rd comment meo cats are cute")]
        }
        */
}

extension CommentModel.Preloaded  {
    enum CommentIDs : String {
        case commentID1 = "3EEC2035-259E-437E-9371-782E4D23D456"
        case commentID2 = "F3C4DE46-82F6-4818-9D76-02A062440250"
        case commentID3 = "0796C71A-A955-45F8-86E2-0307ACB2B9FE"
        case commentID4 = "A050E567-C916-445D-8CBD-C5C7C69097ED"
        case commentID5 = "5A33B0C1-4BBC-4C95-A809-ACF6CAB994B1"
        
     static func getCommentIDOf(number : Int) -> String{
            switch number {
            case 1:
               return CommentIDs.commentID1()
            case 2:
                return CommentIDs.commentID2()
            case 3:
                return CommentIDs.commentID3()
            case 4:
                return CommentIDs.commentID4()
            case 5:
                return CommentIDs.commentID5()
            default:
              return "6D2D9112-83AB-4224-AD81-132AB05FAF30"
            }
        }
    }
}
