//
//  PostModel.swift
//  Clix(No Firebase)
//
//  Created by Carson O'Sullivan on 11/15/20.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFunctions
import FirebaseStorage 
import SDWebImage
import RealmSwift

struct PostModel: Identifiable, Hashable {
    
    ///post creator user id
    let id: String
    let time: Timestamp
    let updatedAt: Timestamp
    
    var content: String
    var photoLink: URL? = nil
    let postID: String
    private (set) var timeString: String
    private (set) var accurateTimeString = ""
    private (set) var commentTime = Timestamp()
    private (set) var commentSentBy = ""
    private (set) var isAComment = false
    ///only used when current user send post, so we can just add this in the postInfo dict
    var tags : [String] = []
    var tempImage : UIImage?
    var status : Status = .successfull
    var thumbnailUrl : URL? = nil
    var videoUrl : URL? = nil
    var audioUrl : URL? = nil
    var timeDate : Date {
        time.dateValue()
    }  
    var nameOfCurrentUser: String = ""
    var hasBeenRead: Bool
    var hasSubscribed: Bool? 
    var mediaKind : NewMedia.Kind?{
        if let _ = audioUrl {
            return .audio
        }else if let _ = photoLink{
            return .image
        }else if let _ = videoUrl,
                 let _ = thumbnailUrl {
            return .video
        }
        return nil
    }
    var firebaseFolderName : String? {
        (audioUrl ?? photoLink  ?? videoUrl)?.secondLastComponent
    }
    
    let isDummy: Bool
    internal init(id: String,
                  time: Timestamp,
                  content: String,
                  photoLink: URL? = nil,
                  postID: String,
                  timeString: String,
                  accurateTimeString: String = "",
                  commentTime: Timestamp = Timestamp(),
                  commentSentBy: String = "",
                  isAComment: Bool = false,
                  tempImage : UIImage? = nil,
                  tags: [String] = [ ],
                  status : Status = .successfull,
                  thumbnailUrl : URL? = nil,
                  videoUrl : URL? = nil,
                  audioUrl: URL? = nil,
                  nameOfCurrentUser: String = "",
                  hasBeenRead: Bool = false,
                  updatedAt : Timestamp) {
        //FIXME: - check do we need to add updatedAt as an nil or we can just use the time
        self.id = id
        self.time = time
        self.content = content
        self.photoLink = photoLink
        self.postID = postID
        self.timeString = timeString
        self.accurateTimeString = accurateTimeString
        self.commentTime = commentTime
        self.commentSentBy = commentSentBy
        self.isAComment = isAComment
        self.tempImage = tempImage
        self.tags = tags
        self.status = status 
        self.thumbnailUrl = thumbnailUrl
        self.videoUrl = videoUrl
        self.audioUrl = audioUrl
        self.nameOfCurrentUser = nameOfCurrentUser
        self.hasBeenRead = hasBeenRead
        self.updatedAt = updatedAt
        self.isDummy = status == .sending
    }
    
    // make DateFormatter a static var and test it out
   
    init(postDoc: QueryDocumentSnapshot, tags: [String], hasBeenRead: Bool = false) {
        self.init(postDict: postDoc.data(), postID: postDoc.documentID, tags: tags, hasBeenRead: hasBeenRead)
    }
    //will only return postModel if user is has permission to see the post
    init?(postDoc: QueryDocumentSnapshot, currentAccesssTagIds tagIds: [String], hasBeenRead: Bool = false) {
        let postTags = postDoc.data()["tags"] as? [String] ?? []
        var allowedTags = [String]()
        if postTags.isNotEmpty {
            allowedTags = tagIds.getSet().intersection(postTags).getArray()
        }
        
        if postTags.isEmpty || allowedTags.isNotEmpty {
            self.init(postDoc: postDoc, tags: allowedTags, hasBeenRead: hasBeenRead)
        }else{
            return nil
        }
    }
    
    private init(postDict: [String : Any],postID : String, tags: [String], hasBeenRead: Bool = false) {
       let dict = postDict
       let sentBy = dict["sentBy"] as? String ?? ""
       let content = dict["content"] as? String ?? ""
       let time = dict["time"] as? Timestamp ?? Timestamp()
       let thumbnailUrl = (dict["thumbnailUrl"] as? String)?.possibleURL
       let videoUrl = (dict["videoUrl"] as?  String)?.possibleURL
       let audioUrl = (dict["audioUrl"] as?  String)?.possibleURL
       let photoLink = (dict["photoLink"] as?  String)?.possibleURL
       let updatedAt =  dict["updatedAt"] as?  Timestamp ?? Timestamp()
      let format = Self.accurateTimeStringFormatter//DateFormatter()
//        format.dateFormat = "MMM d, h:mm:ss a"
       let accurateTimeString = format.string(from: time.dateValue())
       self.init(id: sentBy,
                 time: time,
                 content: content,
                 photoLink : photoLink,
                 postID: postID,
                 timeString: time.getTimeString(),
                 accurateTimeString: accurateTimeString,
                 tags: tags,
                 thumbnailUrl: thumbnailUrl,
                 videoUrl: videoUrl,
                 audioUrl: audioUrl,
                 hasBeenRead: hasBeenRead,
                 updatedAt: updatedAt)
   }
    enum Constant : String {
    case updatedAt
    }
}

extension PostModel {
    init (sentBy : String, postID : String = UUID().uuidString, content: String,
          tags: [String], status : Status = .sending, newMedia: NewMedia? = nil, audioUrl: URL? = nil, timestamp: Timestamp? = nil, nameOfCurrentUser: String = "", hasBeenRead: Bool = false, updatedAt : Timestamp = Timestamp() ) {
        var newTimestamp =  Timestamp()
        if let timestamp = timestamp {
            newTimestamp = timestamp
        }
        let format = DateFormatter()
        format.dateFormat = "MMM d, h:mm:ss a"
        let accurateTimeString = format.string(from: newTimestamp.dateValue())
        
        self.init(id: sentBy,
                  time: newTimestamp,
                  content: content,
                  photoLink: nil,
                  postID: postID,
                  timeString: newTimestamp.getTimeString(),
                  accurateTimeString: accurateTimeString,
                  tempImage : newMedia?.image,
                  tags: tags,
                  status: status ,
                  videoUrl : newMedia?.videoUrl,
                  audioUrl : audioUrl,
                  nameOfCurrentUser: nameOfCurrentUser,
                  hasBeenRead: hasBeenRead,
                  updatedAt: updatedAt)
         //FIXME: - check do we need to add updatedAt as an argument or we can just use the time
    }
    
    init(rawPost : PostModel.Raw){
        self.init(sentBy: rawPost.id,
                  postID: rawPost.postID,
                  content: rawPost.content,
                  tags: rawPost.tags, 
                  newMedia: rawPost.newMedia,
                  timestamp: rawPost.time,
                  nameOfCurrentUser: rawPost.nameOfCurrentUser,
                  hasBeenRead: rawPost.hasBeenRead
        )
    }
    static var empty : PostModel{
        PostModel(id: "", time: Timestamp(), content: "", postID: "", timeString: "", updatedAt: Timestamp())
    }
}

extension PostModel {
    static func getPostCollectionReference(friendId : String) -> CollectionReference {
        let collectionRef = Firestore.firestore()
            .collection("Posts")
            .document(friendId.nonEmpty)
            .collection("UserPosts")
        return collectionRef
    }
    
     //will also update that when a user adds a new friend
    ///
   
    static func getMostOldestPostTime(  friendIds : [String],
        callback : (@escaping (_ postTime : Timestamp? , _  error : Error?) -> Void)) {
        
     let dispatchGroup = DispatchGroup()
        
        var allPostTimes : [Timestamp] = [ ]
        var postError : Error!
        
        for friendId in friendIds {
            dispatchGroup.enter()
            fetchOldestPost(friendId: friendId) { postTime, error in
                if let postTime = postTime {
                    allPostTimes.append(postTime)
                }else if let error = error{
                    postError = error
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .global(qos: .background)) {
            var oldestPostTime : Timestamp!
            if allPostTimes.isNotEmpty {
                oldestPostTime = allPostTimes.removeFirst()
                for time in allPostTimes {
                    if time < oldestPostTime!{
                        oldestPostTime = time
                    }
                }
            }
             callback(oldestPostTime,postError)
        }
        
    }
    
    static func fetchOldestPost ( friendId : String,
        callback : (@escaping (_ postTime : Timestamp? , _ error : Error?) -> Void) ) {
        
        let collectionRef = getPostCollectionReference(friendId: friendId)
        collectionRef
            .order(by: "time", descending: false)
            .limit(to: 1)
            .getDocuments(source: .server) { (querySnapshot, error) in
                guard let documents  = querySnapshot?.documents,
                       error == nil else {
                    let error : Error = error ?? NSError.getWith(description: "fetchOldestPost Post document was nil")
                    callback(nil , error)
                    return
                }
                let postTime = documents.last?.get("time") as? Timestamp
//                print("postTime = ",postTime?.dateValue())
                callback(postTime, nil)
            }
    }
    
    static func fetchPost(postID : String,
                          friendId : String,
                          source: FirestoreSource ,
                       callback : (@escaping (_ post : PostModel? , _  error : Error?) -> Void) ) {
        
            let collectionRef = getPostCollectionReference(friendId: friendId)
           collectionRef
            .document(postID.nonEmpty)
            .getDocument(source: source)  { (document, error) in
                
                guard let document : DocumentSnapshot = document, let postDict = document.data() , error == nil else {
                    callback(nil , error)
                    return
                }
                
                let tags = postDict["tags"] as? [String] ?? []
                let post = PostModel(postDict: postDict, postID: document.documentID, tags: tags)
                callback(post,  nil)
            }
    }
    
    static func fetchPostFromCacheOrNetwork(postID : String,
                                        friendId : String,
                                        callback : (@escaping (_ post : PostModel? , _  error : Error?) -> Void)) {
        self.fetchPost(postID: postID, friendId: friendId, source: .cache) { post, error in
            if let post = post {
                callback(post,error)
            }else{
                self.fetchPost(postID: postID, friendId: friendId, source: .server) { post, error in
                        callback(post,error)
                }
            }
        }
    }
    static var accurateTimeStringFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm:ss a"
        return formatter
    }()
    
    var  doesHaveAVideo : Bool{
        return  (thumbnailUrl != nil && videoUrl != nil)
    }
    
    var  doesHaveAPhoto : Bool{
        return  (photoLink != nil  )
    }
    var  doesHaveAudio : Bool{
        return  (audioUrl != nil  )
    }
    
    func deleteMediaFromCacheIfExist() {
        if let thumbnailUrlString = thumbnailUrl?.absoluteString ,
           let videoUrl = videoUrl {
            SDImageCache.shared.removeImage(forKey: thumbnailUrlString)
         
            VideoCacheManager.shared.removeFromTempCacheIfExist(fileFirebaseURL: videoUrl)
 
        }else if let photoURLString = photoLink?.absoluteString {
            SDImageCache.shared.removeImage(forKey: photoURLString) 
        } else if let audioUrl = audioUrl {
            AudioCacheManager.shared.removeFromTempCacheIfExist (fileFirebaseURL: audioUrl)
        }
    }
    
//    struct Raw: Identifiable, Hashable {
//        
//    }
}

//enum Status : Int, Codable,PersistableEnum {
//    case sending
//    case successfull
////    case error
//}


 
///preloadedPosts 
extension PostModel {
   
    struct Preloaded {
        
       private init(){}
        static let shared = Preloaded()
        
        static var allPosts : [PostModel] = {
            shared.allTristanPosts
        }()
         
          var allTristanPosts : [PostModel]  {
//            let allPosts = [post1,post2 ,post3 ,post4 ,post5, post6]
              let allPosts = [post7, post8, post9, post10]
            // will use this but when we make sure that we only use timeline only ones in the whole object
//            Self.dateFormatter = nil
//            Self.accurateTimeStringFormatter = nil
            return allPosts
        }
      
       
       static func getDateOfPost(number: Int) -> Date {
            let dateStr = "July 1, 2022"
            let date = (dateFormatter.date(from: dateStr) ?? Date()) + TimeInterval(number)
           return date
        }
        //need to check will it work
          private func getPreloadedPost(content: String, postID: String, ofNumber number: Int, photoLink: URL? = nil ) -> PostModel {
             
            let id = TristanUserID
              let date = Self.getDateOfPost(number: number)
            let time = Timestamp(date: date)
            let accurateTimeString = accurateTimeStringFormatter.string(from: date)
            
            return PostModel(id: id,
                             time: time,
                             content: content ,
                             photoLink : photoLink,
                             postID: postID,
                             timeString: "X days ago",
                             accurateTimeString: accurateTimeString,
                             commentTime: time,
                             tags: [],
                             updatedAt: time)
        }
        private var post10 : PostModel {
            let content = "Notifications :)"
            let postID = PostIDs.post10()
            
            let post = getPreloadedPost(content: content, postID: postID, ofNumber: 10)
            return post
        }
        private var post9 : PostModel {
          let content = "Communication is key"
          let postID = PostIDs.post9()

          let post = getPreloadedPost(content: content, postID: postID, ofNumber: 9)
          return post
      }
        private var post8 : PostModel {
            let content = "Moments!!!"
            let postID = PostIDs.post8()
            
            let post = getPreloadedPost(content: content, postID: postID, ofNumber: 8)
            return post
        }
        private var post7 : PostModel {
          let content = "Friends are important <3 (tap here)"
          let postID = PostIDs.post7()

          let post = getPreloadedPost(content: content, postID: postID, ofNumber: 7)
          return post
      }
          private var post6 : PostModel {
            let content = "Open the \"Moments\" above for more information"
            let postID = PostIDs.post6()

            let post = getPreloadedPost(content: content, postID: postID, ofNumber: 6)
            return post
        }
        
          private var post5 : PostModel {
            let content = "Swipe right for private and group conversations"
            let postID = PostIDs.post5()
            let url = Bundle.main.url(forResource: "tristanPost3", withExtension: "jpg")
            let post = getPreloadedPost(content: content, postID: postID, ofNumber: 5, photoLink : url)
            return post
        }
        
        
          private var post4 : PostModel {
            let content = "\"Keys\" allow for annonymous subgroups within your 150 friends"
            let postID = PostIDs.post4()
            let url = Bundle.main.url(forResource: "tristanPost4", withExtension: "jpg")
            let post = getPreloadedPost(content: content, postID: postID, ofNumber: 4, photoLink : url)
            return post
        }
        
        
          private var post3 : PostModel {
            let content = "\"Moments\" are flexible. They can be one-liners, essays, photos, videos, etc."
            let postID = PostIDs.post3()
            let url = Bundle.main.url(forResource: "tristanPost5", withExtension: "jpg")
            let post = getPreloadedPost(content: content, postID: postID, ofNumber: 3, photoLink : url)
            return post
        }
        
        
          private var post2 : PostModel {
            let content = "People in your speakeasy can see your \"Moments\" and vice versa. Swipe left to share a moment."
            let postID = PostIDs.post2()
            let url = Bundle.main.url(forResource: "tristanPost1", withExtension: "jpg")
            let post = getPreloadedPost(content: content, postID: postID, ofNumber: 2, photoLink : url)
            return post
        }
        
          private var post1 : PostModel {
            let content = "In speakEZ, your speakeasy is limited to 150 people. These are your special people."
              let postID = PostIDs.post1()
            
            let url = Bundle.main.url(forResource: "tristanPost2", withExtension: "jpg")
            let post = getPreloadedPost(content: content, postID: postID, ofNumber: 1, photoLink : url)
            return post
        }
         static var dateFormatter : DateFormatter! = {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            return dateFormatter
        }()
        
          var accurateTimeStringFormatter : DateFormatter! = {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, h:mm:ss a"
            return dateFormatter
        }()
        
        enum PostIDs : String {
            case post1 = "60C75D79-8DDB-4F23-8BE7-1587CC0B397A"
            case post2 = "F6EC1197-53D1-418E-8F30-618EB0E184DA"
            case post3 = "D70A36D8-92F1-4225-859A-C7E5763297BE"
            case post4 = "F933A975-2781-46ED-B5A3-2EA13CF045E7"
            case post5 = "DC8DC5BB-F102-4B40-AD9E-11FCDDD2F986"
            case post6 = "ABD28D34-8315-4BD0-871D-448C70BF9113"
            case post7 = "MFA3D322-524A-FSDD-F0AD-0FAM20RGMA23"
            case post8 = "MFA3D324-524A-FSDD-F0AD-0FAM20RGMA24"
            case post9 = "MFA3D325-524A-FSDD-F0AD-0FAM20RGMA25"
            case post10 = "MFA3D326-524A-FSDD-F0AD-0FAM20RGMA26"
        }
    }
}
protocol UpdateAbleMediaModel {
    var thumbnailUrl : URL? {get set}
    var videoUrl : URL?  {get set}
    var audioUrl : URL? {get set}
    var photoLink: URL?  {get set}
}

extension UpdateAbleMediaModel {
    private func getUpdatedCount(firebaseURL : URL,possibleExtraStringInName: String) -> Int?{
        if let storageFileName = firebaseURL.secondLastComponent,
           let firstRange = storageFileName.range(of:  possibleExtraStringInName){
            let key =  String(storageFileName[..<firstRange.lowerBound])
            let count = Int(key)
            return count
            
        }
        return nil
    }
    ///its the count that tell is how many times the object have been updated
    var mediaVersion : Int {
        var firebaseFileURL : URL?
        if let audioUrl = audioUrl {
            firebaseFileURL = audioUrl
        }else if let photoLink = photoLink{
            firebaseFileURL = photoLink
        }else if let videoUrl = videoUrl,
                 let _ = thumbnailUrl {
            firebaseFileURL = videoUrl
        }
        if let firebaseFileURL = firebaseFileURL,
           let count = getUpdatedCount(firebaseURL: firebaseFileURL,possibleExtraStringInName: "+") {
            return count
        }
        return 0
    }
    
    var mediaVersionStr : String {
        mediaVersion > 0 ?  String(mediaVersion) : ""
    }
}
extension PostModel : UpdateAbleMediaModel{
    
}
