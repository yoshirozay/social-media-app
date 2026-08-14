//
//  P-Realm-M.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//


import RealmSwift
import Realm
import Combine

class RealmPost : Object {
  
  @Persisted  (primaryKey: true)  var postID : String
  @Persisted  var id: String
  @Persisted  var content: String
  @Persisted  var tags: List<String>
  @Persisted  var kind : NewMedia.Kind?
  @Persisted  var sendTime : Date
  @Persisted  var isPostTagged : Bool = false
  @Persisted  var isFailed : Bool = false
  @Persisted  var mentions: List<RealmPostMention>
  @Persisted  var nameOfCurrentUser: String
  @Persisted  var friendTokens: List<String>
   
  convenience init(rawPostModel : PostModel.Raw) {
      self.init()
      self.id = rawPostModel.id
      self.content = rawPostModel.content
      self.tags.append(objectsIn: rawPostModel.tags)
      self.postID = rawPostModel.postID
      self.kind = rawPostModel.selectedMediaKind
      self.sendTime = rawPostModel.time.dateValue()
      self.isPostTagged = rawPostModel.isPostTagged
      self.mentions.append(objectsIn: rawPostModel.mentions)
      self.isFailed = false
      self.friendTokens.append(objectsIn: [])
      self.nameOfCurrentUser = rawPostModel.nameOfCurrentUser
  }
  /// all unmanaged Mentions
  var allMentions : [RealmPostMention] {
      mentions.map({$0.unmanaged})
  }
}

extension RealmPost : RealmFailAble {
  class func getAllPosts() -> [PostModel] {
      guard let realm = try? Realm() else { return [] }
      let failedPosts = realm.objects(RealmPost.self).getPostModels()
      return failedPosts
  }
  class func updateAllPostsIsFailedProperty(to isFailed : Bool){
      guard let realm = try? Realm(),
            let realmPosts = getAllFailedObjectsResult() else { return  }
      
      DispatchQueue.main.async {
          do {
              try realm.write {
                  realmPosts.forEach({$0.isFailed = isFailed})
              }
          } catch {
              assert(false, " what happend   saveInRealm \(error.localizedDescription)")
          }
      }
  }
  
  class func save(rawPost : PostModel.Raw) {
      rawPost.realmPost.saveInRealm()
  }
  
  class func getFromRealm(postID : String) -> RealmPost? {
      guard let realm = try? Realm() else { return nil }
      let realmPost = realm.objects(RealmPost.self).filter("\(Constant.postID() ) == %@",postID).first
      return realmPost
  }
  
  class func getOldest() -> RealmPost? {
      guard let realm = try? Realm() else { return nil }
      let realmPost = realm.objects(RealmPost.self)
          .sorted(byKeyPath: Constant.sendTime() , ascending: true)
          .first
      return realmPost
  }
  
  class func deleteFromRealm(postID : String, callback : @escaping ( _ error : Error?) -> Void = {_ in}) {
      if let realmRawMessage = getFromRealm(postID: postID) {
          deleteFromRealm(realmObject: realmRawMessage) { callback($0) }
      }
  }
  
  class func markAs(failed : Bool,postID : String){
      if let realmRawMsg = getFromRealm(postID: postID){
          realmRawMsg.markAs(failed: failed)
      }
  }
  
  func markAs(failed : Bool, callback : @escaping (_ error : Error?) -> Void = {_ in}) {
      if  let realm = try? Realm() {
          DispatchQueue.main.async {
              do {
                  try realm.write {
                      self.isFailed = failed
                  }
              } catch   {
                  callback(error)
                  assert(false, " what happend   saveInRealm \(error.localizedDescription)")
              }
          }
      }else{
          let error = NSError.getWith(description: " let realm = try? Realm()  failed")
          callback(error)
          assert(false, " what happend   saveInRealm ")
      }
  }
  
  func getPostModel() -> PostModel? {
      if let rawPost = getRawPostModel() {
          return PostModel(rawPost : rawPost)
      }
      return nil
  }
  
  func getRawPostModel() -> PostModel.Raw? {
      return PostModel.Raw(realmPost: self)
  }
  
  class func getRealmLatestFailedPostListener(callback : @escaping ( _ allUpdatedPosts : [PostModel]) -> Void) -> AnyCancellable? {
      
      guard let results = getAllFailedObjectsResult() else { return nil }
      
      let realmSubscriber = results.changesetPublisher.sink {  changes in
          
          var newPostResults : Results<RealmPost>?
          switch changes {
          case let .initial(initialResults):
              newPostResults = initialResults
          case let .update(updatedResults, _, _, _):
              newPostResults = updatedResults
          case let .error(error):
              assert(false, " results.changesetPublisher = \(error.localizedDescription) ")
          }
          if let postModels = newPostResults?.getPostModels() {
              DispatchQueue.main.async {
                  callback(postModels)
              }
          }
      }
      return realmSubscriber
  }
  
  enum Constant : String {
      case postID
      case sendTime
      case isFailed
      case otherUserID
  }
}
/*
PostModel
- id : "DUTQCiU4pgWTedkzwMc53VIebkP2"
- time : <FIRTimestamp: seconds=1631634789 nanoseconds=910200119>
- content : "D"
- photoLink : nil
- postID : "C396EDE7-0A50-4009-876E-6C12E07E8D3A"
- timeString : "8:53 PM"
- accurateTimeString : "Sep 14, 8:53:09 PM"
- commentTime : <FIRTimestamp: seconds=1631634789 nanoseconds=910602092>
- commentSentBy : ""
- isAComment : false
- tags : 0 elements
- tempImage : nil
- status : speakEZ.Status.sending
- thumbnailUrl : nil
- videoUrl : nil



so we will do the same as the messages but with we will also need to check for the deleting as well.
we will also create a failedPostManager
*/
extension Results where Element == RealmPost{
   //will only return message which were able to be converted into it
  func getPostModels() -> [PostModel] {
      let failedPosts = self.toArray().compactMap({ $0.getPostModel()})
      return failedPosts
  }

}
/*
we also need to remov the logic where we remove the failed post. and also need to add all failed post in the time line as well
*/



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
