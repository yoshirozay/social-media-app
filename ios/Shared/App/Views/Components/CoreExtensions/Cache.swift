//
//  Cache.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 2/9/21.
//

import SwiftUI
import Firebase

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) { self.key = key }
        
        override var hash: Int { return key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            
            return value.key == key
        }
    }
}

private extension Cache {
    final class Entry {
        let key: Key
        let value: Value
        let expirationDate: Date
        
        init(key: Key, value: Value, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}

private extension Cache {
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()
        
        func cache(_ cache: NSCache<AnyObject, AnyObject>,
                   willEvictObject object: Any) {
            guard let entry = object as? Entry else {
                return
            }
            
            keys.remove(entry.key)
        }
    }
}
private extension Cache {
    func entry(forKey key: Key) -> Entry? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }
        
        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }
        
        return entry
    }
    
    func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        keyTracker.keys.insert(entry.key)
    }
}

extension Cache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }
            
            insert(value, forKey: key)
        }
    }
}
extension Cache.Entry: Codable where Key: Codable, Value: Codable {}

extension Cache: Codable where Key: Codable, Value: Codable {
    convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach(insert)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap(entry))
    }
}

extension Cache where Key: Codable, Value: Codable {
    func saveToDisk(
        withName name: String,
        using fileManager: FileManager = .default
    ) throws {
        let folderURLs = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        
        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        let data = try JSONEncoder().encode(self)
        try data.write(to: fileURL)
    }
}
class PostLoader: ObservableObject {
    @Published var post = PostModel(id: "", time: Timestamp(), content: "", postID: "", timeString: "", updatedAt: Timestamp())
    typealias Handler = (Result<PostModel, Error>) -> Void
    
    private let cache = Cache<String, PostModel>()
    
    func getPost(withID id: String) {
        //        if let cached = cache[id] {
        print("id = \(id)")
        loadImageFromCache(key: id)
        //            return handler(.success(cached))
        //        }
        //        performLoading { [weak self] result in
        //                    let article = try? result.get()
        //                    article.map { self?.cache[id] = $0 }
        //                    handler(result)
        //                }
        
    }
    func loadImageFromCache(key: String) {
        let cachePost = cache.value(forKey: NSString(string: key) as String)
        post = cachePost ?? PostModel(id: "", time: Timestamp(), content: "", postID: "lame", timeString: "", updatedAt: Timestamp())
        print("KEY = \(key)")
        print ("cachePost = \(cachePost)")
    }
    
}


final class Cache<Key: Hashable, Value>: ObservableObject {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval
    private let keyTracker = KeyTracker()
    
    init(dateProvider: @escaping () -> Date = Date.init,
         entryLifetime: TimeInterval = 12 * 60 * 60,
         maximumEntryCount: Int = 1000) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
    }
    
    func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        keyTracker.keys.insert(key)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        print("value = \(value)")
        print("key = \(key)")
    }
    func value(forKey key: Key) -> Value? { // retrieving values
        let entry = wrapped.object(forKey: WrappedKey(key))
        guard dateProvider() < entry?.expirationDate ?? Date() else {
            // Discard values that have expired
            removeValue(forKey: key)
            return nil
        }
        return entry?.value
    }
    
    func removeValue(forKey key: Key) { // removing an existing value:
        wrapped.removeObject(forKey: WrappedKey(key))
    }
}

