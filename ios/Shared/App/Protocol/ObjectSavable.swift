////
////  ObjectSavable.swift
////  speakEZ (iOS)
////
////  Created by Ahmad naeem on 8/15/21.
////
//
//import Foundation
//
//protocol ObjectSavable : UserDefaults {
//    func setObjectValue<Object>(_ object: Object, forKey: String) throws where Object: Encodable
//    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
//}
//
//extension ObjectSavable  {
//    func setObjectValue<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
//        let encoder = JSONEncoder()
//        do {
//            let data = try encoder.encode(object)
//            set(data, forKey: forKey)
//        } catch {
//            throw ObjectSavableError.unableToEncode
//        }
//    }
//    
//    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
//        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
//        let decoder = JSONDecoder()
//        do {
//            let object = try decoder.decode(type, from: data)
//            return object
//        } catch {
//            throw ObjectSavableError.unableToDecode
//        }
//    }
//}
//
//enum ObjectSavableError: String, LocalizedError {
//    case unableToEncode = "Unable to encode object into data"
//    case noValue = "No data object found for the given key"
//    case unableToDecode = "Unable to decode object into given type"
//    
//    var errorDescription: String? {
//        rawValue
//    }
//}
//
//extension UserDefaults: ObjectSavable {
//    
//}
