//
//  ReadPostSyncManager.swift
//  speakEZ
//
//  Created by Ahmad naeem on 4/6/22.
//
  
import Firebase
import FirebaseFirestore
import Combine
 

protocol ReadPostSyncAccessAble { }
extension ReadPostSyncAccessAble {
    var areReadPostIDsSynced :  CurrentValueSubject<Bool?,Never> {
        ReadPostSyncManager.isSyncedPublisher
    }
}

class ReadPostSyncManager {
    ///now that is just amzing. i think it would be a very good idea that if we use a listener instead to fetch ReadPostIDs from the server. when we will get them we will removed the listener after a 30 seconds.
    /// so for the commentLikeVM, we will first try to get ReadPost from firebase cache, then if we did not get anything we will start listening to the listener
    static func syncReadPost() {
        guard let userId = currentUserID else{ return }
        let docRef = ReadPost.getCollRef(userId: userId)
            .order(by: ReadPost.Constant.readTime(), descending: true)
//            .limit(to: 1)
        docRef.getDocuments(source : .cache) {(snap, error) in
//            guard let doc = snap?.documents.first else {
//                sendSyncedStatus(error == nil)
//                return
//            }
            do {
                let lastPostReadTime: Timestamp? = try snap?.documents.first?.data(as: ReadPost.self)?.readTime
                //so if we do not get anything from the cache then we will still search in the server db
//                if let lastReadTime = try snap?.documents.first?.data(as: ReadPost.self) {
//                    print(" lastReadTime \(lastReadTime)")
//                }
                var docRef = ReadPost.getCollRef(userId: userId)
                    .order(by: ReadPost.Constant.readTime(), descending: true)
                if let lastPostReadTime = lastPostReadTime {
                    docRef = docRef.whereField(ReadPost.Constant.readTime(), isGreaterThanOrEqualTo: lastPostReadTime)
                }
                docRef.getDocuments(source : .server) {(snap, error) in
                    if error == nil{
                        print("ReadPostIDs are synced")
                    }
                    sendSyncedStatus(error == nil)
                }
            }catch let error{
                print(" \(error.localizedDescription)")
                  assert(false, " what happend  syncWithServer failed  ")
            }
        }
    }
    static func sendSyncedStatus(_ isSynced : Bool){
        isSyncedPublisher.send(isSynced)
    }
    static let isSyncedPublisher =  CurrentValueSubject<Bool?,Never>(false)
    
}

struct ReadPost : Decodable {
    var documentId : String
    var readTime : Timestamp
    
    enum CodingKeys: String, CodingKey {
        case documentId
        case readTime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        documentId = try FirestoreDocumentID(from: decoder).documentId
        readTime = try container.decode(Timestamp.self, forKey: .readTime)
    }
}

extension ReadPost {
      enum Constant : String{
        case documentId
        case readTime
        case ReadPost
        case ReadPostIDs
    }
    static func getCollRef(userId : String) -> CollectionReference {
        Firestore.firestore().collection(Constant.ReadPost()).document(userId.nonEmpty).collection(Constant.ReadPostIDs())
    }
}

/*
 first we will query cache to get most last readPost, and save its time in a var
 then we will query server to get all readPosts after the last readpost of cahce.
 now that way we will be able to sync the readPost with server.
 so now we can just get readpost info of a post in the CommentLikeVM and update the post.
 */

/*
 now we will add readPost functionality, so for that we will for now just get all the posts and like
 i think the best way would be to,
 first we call firestore query in the cache to get the last readTime of a post. then we will query to server to get all readPost which readTime is greater then the readTimeo of last cache readPost. by doing this we make sure that readPost is synced .
 now we will need to post a notificion after we sync the readPost. now we will add listener to the notification from CommentLikeVM. when we will get response from the CommentLikeVM we will query in the cache for the current postData and check if it has been read.
 now the question is should we add a listener of the latest readPostIDs or not? because we also want to know and update cache when a readPost is updated.

 otherwise we will have to controll and wait until we get the readPost
 
 */
