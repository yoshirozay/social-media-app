//
//  RealmPostMention.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/15/21.
//

import Foundation

import RealmSwift
import Realm
import Combine


class RealmPostMention : Object {
  @Persisted  var id: String
  @Persisted  var token: String
  @Persisted  var sentTo: String
  @Persisted  var nameOfSendingUser : String
  
  convenience init(id: String,
                   token: String,
                   sentTo: String,
                   nameOfSendingUser : String) {
      self.init()
      self.id = id
      self.token = token
      self.sentTo = sentTo
      self.nameOfSendingUser = nameOfSendingUser
  }
  ///now we use this when we get RealmPost from realm and convert it to PostModel.Raw. because when we try to get any data from mentions, the app crashes because we are trying to access realm object in other thread in which it was created. as we only want the dict so we just make a copy instead
//  func getCopy() -> RealmPostMention {
//    RealmPostMention(value: self)
//    let d = self.unmanaged
////      RealmPostMention(id: id, token: token, sentTo: sentTo, nameOfSendingUser: nameOfSendingUser)
//  }
  func getInfoDict(currentUserId : String , postID: String) -> [String: String]{
      return  [Constant.id(): id,
               Constant.resourceID(): postID,
               Constant.sentBy(): currentUserId,
               Constant.sentTo(): sentTo,
               Constant.token(): token,
               Constant.nameOfSendingUser(): nameOfSendingUser,
               currentUserId: currentUserId]
  }
 
  enum Constant : String {
      case id
      case resourceID
      case sentBy
      case sentTo
      case token
      case nameOfSendingUser
  } 
}
extension RealmPostMention{
    var unmanaged : RealmPostMention{
        return RealmPostMention(value: self)
    }
}
