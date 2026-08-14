//
//  RealmViewOnceMsg.swift
//  speakEZ
//
//  Created by Ahmad naeem on 9/17/21.
//
 
import Realm
import Combine
import RealmSwift
extension MessageModel {
    static func userDidView(message : MessageModel,chatUID : String) {
        let realmViewOnce = RealmViewOnceMsg(message : message)
         realmViewOnce.saveInRealm { print($0?.localizedDescription ?? "") }
 
        SendMessageFunctions.didViewMessage(messageUID: message.id, chatUID: chatUID){error in
            if error == nil {
//                realmViewOnce.deleteFromRealm{   print($0?.localizedDescription ?? "") }
            }else{
                print("nope")
            }
        } 
    }
    
    mutating func userDidView(chatUID : String) {
        self.alreadyViewOnce = true
        Self.userDidView(message : self,chatUID : chatUID)
    }
    
    func saveViewOnceInRealm(){
       let realmViewOnce = RealmViewOnceMsg(message : self)
        realmViewOnce.saveInRealm { error in
            print(error?.localizedDescription ?? "")
        }
    }
 
}
  
class RealmViewOnceMsg : Object {
   @Persisted(primaryKey: true) var messageUID : String
    @Persisted var otherUserID: String
    @Persisted var chatUID: String
   @Persisted var timeDate : Date
    convenience init(message : MessageModel) {
        self.init()
        messageUID = message.id
        otherUserID = message.otherUserID
        timeDate = message.time.dateValue()
        chatUID = message.chatID
    }
   var unmanaged : RealmViewOnceMsg {
       return RealmViewOnceMsg(value: self)
   }
   
   class func doesExist(messageUID : String) -> Bool {
       return getResultFor(messageUID : messageUID)?.first != nil
   }
   
   class func getResultFor(otherUserID : String) -> Results<RealmViewOnceMsg>? {
       guard let realm = try? Realm() else { return nil }
       let results = realm.objects(RealmViewOnceMsg.self).filter("\(RealmRawMessage.Constant.otherUserID() ) == %@",otherUserID)
       return results
   }
   
   class func getResultFor(messageUID : String) -> Results<RealmViewOnceMsg>? {
       guard let realm = try? Realm() else { return nil }
       let results = realm.objects(RealmViewOnceMsg.self).filter("\(RealmRawMessage.Constant.messageUID() ) == %@",messageUID)
       return results
   }
    
    class func deleteFromCache(message : MessageModel, callback : @escaping ( _ error : Error?) -> Void = {_ in}) {
        Self.deleteFromRealm(messageUID: message.id, callback: callback)
        message.deleteMediaFromCache()
    }
   ///if message exist it will remove it
   class func deleteFromRealm(messageUID : String, callback : @escaping ( _ error : Error?) -> Void = {_ in}) {
       if let realmViewOnceMsg = getResultFor(messageUID : messageUID)?.first{
           deleteFromRealm(realmObject: realmViewOnceMsg, callback: callback)
       }
   }
   
   class func getRealmViewOnceCountPublisher(otherUserID : String, callback : @escaping (_ isEmpty : Bool) -> Void) -> AnyCancellable?  {
     
       guard let results = getResultFor(otherUserID: otherUserID) else { return nil }
       let realmSubscriber = results.collectionPublisher
           . map { $0.isNotEmpty}
           .sink(receiveCompletion: { _ in
           }, receiveValue: callback)
       return realmSubscriber
   }
}
//MARK: - for chatId
extension RealmViewOnceMsg{
    
    class func getRealmViewOnceCountPublisher(chatUID : String, callback : @escaping (_ isEmpty : Bool) -> Void) -> AnyCancellable?  {
        guard let results = getResultFor(chatUID: chatUID) else { return nil }
        let realmSubscriber = results.collectionPublisher
            . map { $0.isNotEmpty}
            .sink(receiveCompletion: { _ in
            }, receiveValue: callback)
        return realmSubscriber
    }
    class func getResultFor(chatUID : String) -> Results<RealmViewOnceMsg>? {
        guard let realm = try? Realm() else { return nil }
        let results = realm.objects(RealmViewOnceMsg.self).filter("\(RealmRawMessage.Constant.chatUID() ) == %@",chatUID)
        return results
    }
    
}
