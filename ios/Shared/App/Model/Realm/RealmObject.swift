//
//  RealmObject.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 8/31/21.
//


import Foundation
import RealmSwift
import Realm
 

struct RealmObject {
   
   static func setDefaultRealmForUser( ) {
       
       let config = Realm.Configuration(
           // Set the new schema version. This must be greater than the previously used
           // version (if you've never set a schema version before, the version is 0).
           schemaVersion: 10,
           // Set the block which will be called automatically when opening a Realm with
           // a schema version lower than the one set above
           migrationBlock: { _, _ in
               // We haven’t migrated anything yet, so oldSchemaVersion == 0
               //                           if (oldSchemaVersion < 1) {
               //                               // Nothing to do!
               //                               // Realm will automatically detect new properties and removed properties
               //                               // And will update the schema on disk automatically
               //                           }
           }
       )
       // Set this as the configuration used for the default Realm
       Realm.Configuration.defaultConfiguration = config
       if let fileURL = config.fileURL{
           print("Realm is located at:", fileURL)
       }
       RealmRawMessage.updateAllMsgsIsFailedProperty(to: false)
   }
    
    static func deleteAll() {
        if  let realm = try? Realm() {
            DispatchQueue.main.async {
                do {
                    try realm.write {
                        realm.deleteAll()
                    }
                } catch   {
                    assert(false, " what happend   saveInRealm \(error.localizedDescription)")
                }
            }
        }else{
            let error = NSError.getWith(description: " let realm = try? Realm()  failed")
            
            assert(false, " what happend   saveInRealm ")
        }
    }
    
}
extension Results {
    func toArray<T>(ofType _: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        return array
    }
    
    func toArray() -> [Element] {
        var array = [Element]() 
        for i in 0 ..< count {
            array.append(self[i])
        }
        return array
    }
}


extension Realm {
   static func safeInit() -> Realm? {
       do {
           let realm = try Realm()
           return realm
       }
       catch {
            assert(false, " safeInit \(error.localizedDescription)")
       }
       return nil
   }

   func safeWrite(_ block: @escaping () -> ()) {
       DispatchQueue.main.async {
           do {
               try write(block)
           } catch {
               assert(false, "   safeWrite \(error.localizedDescription)")
           }
       }
   }
}

extension Object {
    
   func saveInRealm(callback : @escaping (_ error : Error?) -> Void = {_ in}){
       Self.updateInRealm(realmObject: self, updateStatus: .add,callback: callback)
   }
   
   func deleteFromRealm(callback : @escaping (_ error : Error?) -> Void = {_ in}){
       Self.deleteFromRealm(realmObject: self, callback: callback)
   }
   
   class func deleteFromRealm(realmObject : Object, callback : @escaping (_ error : Error?) -> Void = {_ in}) {
       Self.updateInRealm(realmObject: realmObject, updateStatus: .delete, callback: callback)
   }
   
    private class func updateInRealm(realmObject: Object, updateStatus: RealmObjectUpdateStatus, callback: @escaping (_ error : Error?) -> Void = {_ in}) {
        do {
            let realm = try Realm()
            DispatchQueue.main.async {
                do {
                    try realm.write {
                        if updateStatus == .add {
                            realm.add(realmObject)
                        } else if updateStatus == .delete {
                            realm.delete(realmObject)
                        }
                        callback(nil)
                    }
                } catch   {
                    callback(error)
                    assert(false, " what happend   saveInRealm \(error.localizedDescription)")
                }
                
            }
        }catch{
            callback(error)
            assert(false, " what happend saveInRealm \((error).localizedDescription) ")
        }
    }
    
    class func deleteAll<T>(realmObjects : Results<T>, callback : @escaping (_ error : Error?) -> Void = {_ in}) where T : Object {
        if  let realm = try? Realm() {
            DispatchQueue.main.async {
                do {
                    try realm.write {
                            realm.delete(realmObjects)
                        callback(nil)
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
   enum RealmObjectUpdateStatus {
       case delete
       case add
   }
   
}
