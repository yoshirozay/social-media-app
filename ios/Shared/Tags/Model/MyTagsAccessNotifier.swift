//
//  MyTagsAccessNotifier.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 8/26/21.
//
 
import Combine
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
protocol MyTagsAccessNotifierAccessAble { }
extension MyTagsAccessNotifierAccessAble{
    var myTagsAccessNotifier : MyTagsAccessNotifier {
        MyTagsAccessNotifier.shared
    }
}

class MyTagsAccessNotifier {
   private init( ) {  }
    typealias AccessTagPublisher = Publishers.Map<Published<MyTagsAccessNotifier.TagAccessCallback>.Publisher, Bool>
    @Published var accessTagsInfoUpdate : TagAccessCallback = TagAccessCallback()
    public let myTagsAccessPublisher = PassthroughSubject<MyTagsAccessNotifier.TagAccessCallback,Never>()
    //    CurrentValueSubject
    var tagsListener: ListenerRegistration?
    var myTagIDs : [String]{
        accessTagsInfoUpdate.allTags.map({$0.id})
    }
    private init(userId : String? = nil) {
        if let userId  = userId {
            getMyTagsAccessID(userId: userId)
        }
    }
    
    //return bool haveLostAcessed
    func getAccessTagPublisher(postTags : [String]) -> AccessTagPublisher  {
        return $accessTagsInfoUpdate.map {
            (postTags.isNotEmpty && $0.allTags.map({$0.id}).getSet().intersection(postTags).isEmpty)
        }
    }
    
    //return bool haveLostAcessed
    typealias PostsAccessTagPublisher = Publishers.Map<PassthroughSubject<MyTagsAccessNotifier.TagAccessCallback, Never>, Bool>
    func getPostsAccessTagPublisher(postTags : [String]) ->  PostsAccessTagPublisher {
        return myTagsAccessPublisher.map{
            (postTags.isNotEmpty && $0.allTags.map({$0.id}).getSet().intersection(postTags).isEmpty)
        }
    }
    
    func getMyTagsAccessID(userId : String) {
        
        let docRef = Firestore.firestore()
            .collection(Constant.MyTagsAccess())
            .document(userId.nonEmpty)
        tagsListener?.remove()
        tagsListener = docRef.addSnapshotListener { [weak self] (document, error)  in
            guard let dict = document?.data(), error == nil else {
                print("there's an error getMyTagIDs = ",error?.localizedDescription ?? "")
                return
            }
            
            guard let self = self else { return }
            
            let accessTags : [AccessTag] = dict.compactMap { key,val  in
                if let creatorID = val as? String {
                    return AccessTag(id: key, creatorID: creatorID)
                }
                return nil
            }
            let allTags = accessTags
            let removedTags = self.accessTagsInfoUpdate.allTags.getSet().subtracting(allTags).getArray()
            let addedTags = allTags.getSet().subtracting(self.accessTagsInfoUpdate.allTags.getSet()).getArray()
            let accessTagsInfoUpdate = TagAccessCallback(allTags: allTags,
                                                         addedTags: addedTags ,
                                                         deletedTags: removedTags )
            self.accessTagsInfoUpdate = accessTagsInfoUpdate
            
            DispatchQueue.main.async {
                self.myTagsAccessPublisher.send(accessTagsInfoUpdate)
            }
        }
    }
    
    
    struct AccessTag : Hashable,Equatable {
        var id : String
        var creatorID : String
        
        static func == (lhs: AccessTag, rhs: AccessTag) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    struct TagAccessCallback {
        var allTags : [AccessTag] = []
        var addedTags : [AccessTag] = []
        var deletedTags : [AccessTag] = []
        
        func getDeletedPostsIds(currentPosts : [PostModel]) -> [String] {
            let allTagIds = allTags.ids
            let deletedPostIds : [String] = deletedTags.ids.reduce([]) { result, deletedTag in
                result + currentPosts.compactMap { post in
                    let postTags = post.tags 
                    //so first we check that the removed tag is included in posts tags. then we check does post tags are more then one. if no then return post id.
                    //if yes then check does we have access to post by someother tag that we have in our updatedTags
                    if  postTags.contains(deletedTag),
                        ( postTags.count == 1 ||
                            postTags.getSet().intersection(allTagIds).isEmpty ) {
                        return post.postID
                    }else{
                        return nil
                    }
                }
            }
            return deletedPostIds
        }
        
    }
    
    enum Constant : String {
        case MyTagsAccess
    }
    
    static fileprivate var shared = MyTagsAccessNotifier()
    class func configure(userId : String) {
        Self.shared = MyTagsAccessNotifier(userId: userId)
    }
    class func cancel() {
        shared = MyTagsAccessNotifier()
    }
    
    deinit {
        tagsListener?.remove()
    }
    
}

extension Array where Element ==  MyTagsAccessNotifier.AccessTag{
    var ids : [String] {
        self.map({$0.id})
    }
}
 


/*
so this class will be used only to get update about the tags listener as it has been used almost every where in the app.
so one suggestion is that we create a  array of AccessTags instead of only ids.
and then user can subs to two publisher. one which will give ids and other the whole object.
so we will return three things. updatedTags, newTags,deletedTags

*/
