//
//  RealmChatModel.swift
//  speakEZ
//
//  Created by Ahmad naeem on 12/30/21.
//
  
import RealmSwift
import Realm
import Combine

class RealmChatModel : Object { 
    @Persisted  var chatUID : String
    @Persisted  var isAGroup : Bool = false
    ///for now we need to decide that will the members will also include the cu
    @Persisted  var otherMembersIds : List<String>
    @Persisted  var time : Date
    @Persisted  var groupName : String = ""
    @Persisted  var isFailed : Bool = false
    //    @Persisted  var status : Status = .successfull
   // @Persisted  var otherMembers : [Person]
//    @Persisted  var usersWhoLeft : [String]? 
//    @Persisted  var lastMessage : MessageModel?
    convenience init(chatModel : ChatModel) {
        self.init()
        self.chatUID = chatModel.chatUID
        self.isAGroup = chatModel.isAGroup
        self.otherMembersIds.append(objectsIn: chatModel.otherMembersIds)
        self.time = chatModel.time
        self.groupName = chatModel.groupName 
    }
    var dummyMembers : [Person] {
        otherMembersIds.map({Person(id: $0)})
    }
    var dummyChatModel : ChatModel?{
        ChatModel(realmChatModel: self)
    }
}

  
extension RealmChatModel : RealmFailAble {
//
    //done
    class func updateAllMsgsIsFailedProperty(to isFailed : Bool){
        guard let realm = try? Realm(),
              let realmObj = getAllFailedObjectsResult() else { return  }
        
        DispatchQueue.main.async {
            do {
                try realm.write {
                    realmObj.forEach({$0.isFailed = isFailed})
                }
            } catch {
                assert(false, " what happend   saveInRealm \(error.localizedDescription)")
            }
        }
    }
        ///done
    class func deleteAll(){
        guard let realm = try? Realm() else { return   }
        let results = realm.objects(RealmChatModel.self)
        Self.deleteAll(realmObjects: results) { error in
            print(error?.localizedDescription ?? "deleteAll RealmChatModel delete friend")
        }
    }
    //done
    class func save(chatModel : ChatModel) {
        let realmChatModel = RealmChatModel(chatModel : chatModel)
        realmChatModel.saveInRealm()
    }
    ///done
    class func getFromRealm(chatUID : String) -> RealmChatModel? {
        guard let realm = try? Realm() else { return nil }
        let realmChatModel = realm.objects(RealmChatModel.self).filter("\(Constant.chatUID()) == %@",chatUID).first
        return realmChatModel
    }
    
    class func doesExist(chatUID : String) -> Bool {
        return getFromRealm(chatUID: chatUID) != nil
    }
    ///done
    class func getOldest() -> RealmChatModel? {
        guard let realm = try? Realm() else { return nil }
        let realmChatModel = realm.objects(RealmChatModel.self)
            .sorted(byKeyPath: Constant.time() , ascending: true)
            .first
        return realmChatModel
    }
    //done
    class func deleteFromRealm(chatUID : String, callback : @escaping ( _ error : Error?) -> Void = {_ in}) {
        if let realmChatModel = getFromRealm(chatUID: chatUID) {
            deleteFromRealm(realmObject: realmChatModel,callback: callback)
        }
    }
    //done
    class func markAs(failed : Bool,chatUID : String){
        if let realmChatModel = getFromRealm(chatUID: chatUID){
            realmChatModel.markAs(failed: failed)
        }
    }
    //done
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
    
    enum Constant : String {
        case chatUID
        case time
        case isFailed
    }
}

extension RealmChatModel {
    
    class func getAllRealmChatModelResults() -> Results<RealmChatModel>? {
        guard let realm = try? Realm() else { return nil }
        let lastFailedRealmRawMessages = realm.objects(RealmChatModel.self)
        return lastFailedRealmRawMessages
    }
    
    class func getRealmChatModelListener(callback : @escaping (_ newLatestFailedMessages : ChatModel?,_ allUpdatedMessages : [ChatModel]) -> Void) -> AnyCancellable? {
        
//        var lastSentMessageInfo : MessageInfo?
        guard let results = getAllRealmChatModelResults() else { return nil }
        
        let realmSubscriber = results.changesetPublisher.sink {  changes in
            
            var newChatModelResults : Results<RealmChatModel>?
            
            switch changes {
            case let .initial(initialResults):
                newChatModelResults = initialResults
            case let .update(updatedResults, _, _, _):
                newChatModelResults = updatedResults
            case let .error(error):
                assert(false, " results.changesetPublisher = \(error.localizedDescription) ")
            }
            
            if let result = newChatModelResults { 
                var dummyChatModels : [ChatModel] = []
                for index in 0..<result.count {
                    if let dummyChatModel = result[index].dummyChatModel{
                        dummyChatModels.append(dummyChatModel)
                    }
                }
          
                DispatchQueue.main.async {
                    callback(nil,dummyChatModels)
                }
            }
        }
        return realmSubscriber
    }
}
