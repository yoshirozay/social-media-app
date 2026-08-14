//
//  CommentRepliesOO.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 4/23/21.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import Combine


class CommentRepliesOO: ObservableObject {
    @Published var comments = [CommentModel]()
    @Published var personDict = [String : Person]()
    @Published var friendsWhoCommented = [String]()
    @Published var friendsDictionary = FriendsDictionary(addFriendsListener : false)
    ///userId
    let id: String
    let postID: String
    let commentID: String
    
    init(id: String, postID: String, commentID: String) {
        self.id = id
        self.postID = postID
        self.commentID = commentID
        getAllRepliyedCommentsOfPost(id: id, postID: postID, commentID: commentID,source : .cache)
    }
    
    private func getAllRepliyedCommentsOfPost(id: String, postID: String, commentID: String, source: FirestoreSource = .default) {
        friendsDictionary.getFriendsDictionary(source: .default) { [weak self] (_, error) in
//            print("get CommentRepliesOO :-   got callback")
            if let errorCode = (error as NSError?)?.code,
               //will get unavailable error, if we did not find anything in the cache or server. in this case it is cache
               FirestoreErrorCode.unavailable.rawValue != errorCode {
                print(error?.localizedDescription ?? "")
            }else{
                self?.getAllRepliyedComments(id: id, postID: postID,commentID : commentID, source: source) { lastTime in
                    self?.addCommentListener(id: id, postID: postID, commentID : commentID,  lastTimestamp: lastTime)
                    self?.checkAndRemovedDeletedRepliedComment(id: id, postID: postID, commentID: commentID)
                }
                self?.startListenersForNewFriends(id: id)
            }
        }
    }
    
    func checkAndRemovedDeletedRepliedComment(id: String, postID: String,commentID: String) {
        fetchRepliedCommentsDocs(id: id, postID: postID, commentID: commentID, source: .server) { docs, error in
            let allCommentIds = self.comments.map({$0.commentID})
            DispatchQueue.global(qos: .background).async { [weak self] in
                let serverCommentIds = (docs.map({$0.documentID}).getSet())
                let allDeletedCommentIDs = allCommentIds.getSet().subtracting(serverCommentIds)
                DispatchQueue.main.async {
                    allDeletedCommentIDs.forEach {commentID in
                        self?.removeFromCommentsIfExist(commentID: commentID)
                    }
                }
            }
        }
    }
    
    private func fetchRepliedCommentsDocs(id: String, postID: String,commentID: String, source: FirestoreSource, callback : @escaping (_ docs : [QueryDocumentSnapshot],  _  error : Error?) -> Void){
        let docRef = CommentModel
            .getPostCommentCollRef(authorId: id, postID: postID,commentID : commentID)
        
        docRef.getDocuments(source: source) { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents,error == nil else {
                print("Error fetching documents: ",error?.localizedDescription ?? "")
                callback([], error)
                return
            }
            callback(documents, nil)
        }
    }
    
    private  func getAllRepliyedComments(id: String, postID: String, commentID: String, source: FirestoreSource, callback : @escaping ( _  lastTime : Timestamp?) -> Void ) {
        fetchRepliedCommentsDocs(id: id, postID: postID, commentID: commentID, source: source) {[weak self]  documents, _ in 
            for document in documents {
                self?.buildCommentDictionaries(document, id: id,source : source)
            }
            
            let allTimeStamp = documents.compactMap({$0.get("time") as? Timestamp})
            let lastTime = allTimeStamp.max(by: {$0.dateValue() < $1.dateValue() })
            callback(lastTime)
        }
    }
    
    private var commentListenerReg : ListenerRegistration?
    ///will start listener to the new comment added so we can also update our oo
    
    private func addCommentListener(id: String, postID: String, commentID: String, lastTimestamp : Timestamp? = nil) { 
        let docRef = CommentModel.getPostCommentCollRef(authorId: id, postID: postID,commentID : commentID)

        
        let listenerClouser : ( QuerySnapshot?,Error?) -> () = {
            [weak self] (querySnapshot, error) in
            if error != nil {
                print("there's an error CommentLikesOO.swift")
                return
            }
            
            guard let documentChanges = querySnapshot?.documentChanges else {
                print("Error fetching documents: \(error?.localizedDescription ?? "" )")
                return
            }
            for documentChange in documentChanges {
                if documentChange.type == .added {
                    self?.buildCommentDictionaries(documentChange.document, id: id)
                }else if  documentChange.type == .removed {
                    print("comment removed  ",documentChange.document)
                    self?.removeFromCommentsIfExist(commentID: documentChange.document.documentID)
                }
            }
        }
        
        commentListenerReg?.remove()
        if let lastTimestamp = lastTimestamp {
            commentListenerReg = docRef
                .whereField("time", isGreaterThan: lastTimestamp)
                .addSnapshotListener {listenerClouser($0,$1)}
        }else{
            commentListenerReg = docRef
                .addSnapshotListener {listenerClouser($0,$1)}
        }
    }
    
    private func buildCommentDictionaries(_ userComment: DocumentSnapshot?, id: String,source: FirestoreSource = .default ) {
   
        guard let commentDict = userComment?.data(),
              let commentID = userComment?.documentID   else {
            return
        }
        let commentModel = CommentModel(commentDict: commentDict, commentID: commentID)
        let sentBy = commentModel.id
        buildComment(commentModel)
        if let person = friendsDictionary.friendsDictionary[sentBy] {
            self.buildUserDictionary(person.id, person: person)
        }else{
            //only fetch for non friends
            buildUserInfoDictionary(source :source ,sentBy: sentBy)
        }
        buildFriendsWhoCommented(sentBy, id: id)
    }
    
    private func buildComment(_ comment: CommentModel) {
        //we have tempComments and the given comment is also from the current user. then we will check the message text,if it is also same then we will replace the matching tempComment with  given comment in the comments array.
        if !tempComments.isEmpty,
           comment.status == .successfull,
           comment.id == Auth.auth().currentUser?.uid ,
           let index = tempComments.firstIndex(where: {$0.comment == comment.comment}){
            let tempCommentID = tempComments[index].commentID
            if let indexTempComment = self.comments.firstIndex(where: {$0.commentID == tempCommentID}){
                self.comments[indexTempComment] = comment
                self.tempComments.remove(at: index)
            }
        }else{
            self.comments.append(comment)
        }
        //        if tempComments.contains(where: { $0.commentID ==
        //        })
    }
    
    private func buildUserDictionary(_ dictionaryKey: String, person: Person) {
        self.personDict[dictionaryKey] = person
    }
    
    private func buildUserInfoDictionary(source: FirestoreSource = .default,sentBy: String,callback : @escaping (_ error : Error?) -> Void = {_ in}) -> Void {
        let docRef = Firestore.firestore().collection("UserInfo").document(sentBy.nonEmpty)
        docRef.getDocument {[weak self] (document, error) in
            
            guard let user = document else { return }
            let uid = user.documentID
            guard let userDocumentData = document?.data() else { return }
            Person.getPersonFromUserInfo(userId : uid , documentData: userDocumentData) {[weak self] (person, error) in
                if let person = person {
                    self?.buildUserDictionary(uid, person: person)
                    if source == .cache {
                        //we are doing this because this user is not a friends so he might have changed his user info so we need the freshe data so thats way first we get data from cahce to update the view, and then we update the data from the server to show latest data in the view.
                        self?.buildUserInfoDictionary(sentBy: sentBy)
                    }
                }else{
                    print(error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    private func buildFriendsWhoCommented(_ sentBy: String, id: String) -> Void {
        if friendsDictionary.friendsDictionary[sentBy] != nil && sentBy != Auth.auth().currentUser?.uid && sentBy != id { // Don't send yourself, or the original post owner an "also commented" comment
            DispatchQueue.main.async { [weak self] in
                self?.friendsWhoCommented.append(sentBy)
            }
        }
    }
    
    private func startListenersForNewFriends( id: String) {
        self.friendsDictionary.startListeningToNewFriends { [weak self] (friends, error) in
            let newFriendsIds = friends.ids
            if !newFriendsIds.isEmpty {
                
                if let commenterIds = self?.comments.map({$0.id}) {
                    //by doing intersection we will get user ids who are
                    //1. new friends
                    //2. also the have commented on this posts
                    //== so in the newCommenterFriends we will have commented friends which are new so it means they are not added in the friendsWhoCommented array, (most of the time)) .
                    let newCommenterFriends = Set(newFriendsIds).intersection(commenterIds)
                    for newFriendId in newCommenterFriends {
                        if let strongSelf = self,
                           !strongSelf.friendsWhoCommented.contains(newFriendId) {
                            self?.buildFriendsWhoCommented(newFriendId, id : id)
                        }
                    }
                    /*
                     newCommenterFriends are newFriends who as commented. now we just need to get new friends
                     */
                }
            }else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    //    let safeQueue = DispatchQueue(label: "thread-safe-obj", qos: .userInteractive, attributes: .concurrent)
    
    var tempComments : [CommentModel] = []
    
    lazy var dateFormat : DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "MMM d, h:mm:ss a"
        return format
    }()
    
    var subscription: AnyCancellable?
    func setSubscription(publisher : RawReplyCommentPublisher) {
        if    subscription == nil {
            subscription = publisher.sink {[weak self] rawCommentReply in
//                print(rawCommentReply)
                if let rawCommentReply = rawCommentReply {
                    self?.sendNewReplyComment(rawReplyComment: rawCommentReply)
                }
            }
        }
    }
    
    deinit {
        subscription?.cancel()
        commentListenerReg?.remove()
//        print("CommentRepliesOO deinit called")
    }
    static var dummyCommentIds : Set<String> = []
}
extension CommentRepliesOO {
    func getMentionedFriendsInfo (mentionedIDs: [String], postID: String, originalAuthor: String, personReplyingTo: String) -> [[String: String]]{
        
        guard let userId = Auth.auth().currentUser?.uid else{ return []}
        
        var mentionedInformation = [[String: String]]()
            for item in mentionedIDs {
                if item != originalAuthor || item != personReplyingTo {
                    mentionedInformation.append(["id": "\(UUID())", "resourceID": postID, "sentBy": userId, "sentTo": item, "token": self.friendsDictionary.friendsDictionary[item]?.token ?? "", "nameOfSendingUser": self.friendsDictionary.friendsDictionary[userId]?.name ?? "", "originalAuthor": originalAuthor])
            }
            }
        return mentionedInformation
    }
    
    func commentReplyMentionFunction(mentionedIDs: [String], postID: String, originalAuthor: String, personReplyingTo: String){

        Functions.functions().httpsCallable("commentMention-commentMention").call(getMentionedFriendsInfo(mentionedIDs: mentionedIDs, postID: postID, originalAuthor: originalAuthor, personReplyingTo: personReplyingTo)) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    print("\(error)")
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            print("123 \(String(describing: result?.data))")

        }
    
    }
    func sendNewReplyComment(rawReplyComment : CommentModel.Raw.Reply) {
        DispatchQueue.main.async { [weak self] in
            guard !Self.dummyCommentIds.contains(rawReplyComment.dummyReplyCommentID) else {
                print("duplicate reply comment")
                return
            }
            Self.dummyCommentIds.insert(rawReplyComment.dummyReplyCommentID)
//            print("sending reply comment")
            let time = Timestamp()
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMM d, h:mm:ss a"
            let accurateTimeString = dateFormat.string(from: time.dateValue())
            
            let commentObject = CommentModel(id: rawReplyComment.sentBy,
                                             time: time,
                                             comment: rawReplyComment.comment,
                                             timeString: time.getTimeString(),
                                             accurateTimeString: accurateTimeString,
                                             commentID: rawReplyComment.dummyReplyCommentID,
                                             status: .sending )
            
            
            self?.tempComments.append(commentObject)
            self?.buildComment(commentObject)
            // we will always have the currentUser in the friendsDictionary
            if let person = self?.friendsDictionary.friendsDictionary[commentObject.id] {
                self?.buildUserDictionary(person.id, person: person)
            }
            
            
            let commentID = commentObject.commentID
            let userId = commentObject.id
            
 
            ReplyToCommentFunction.replyToComment(rawReplyComment: rawReplyComment)  { [weak self] error in
                
                DispatchQueue.main.async { [weak self] in
                    if let error = error {
                        let _ = withAnimation(.linear) { [weak self] in
                            self?.removeTempComment(userId: userId, commentID: commentID)
                        }
                        print(error.localizedDescription)
                    }else{
                        /// for imitating listener response
                        //                        Timer .scheduledTimer(withTimeInterval: 2, repeats: false) {[weak self] (_) in
                        //                            commentObject.status = .successfull
                        //                            self?.buildComment(commentObject)
                        //                        }
//                        print("sendComment successfully done")
                        self?.commentReplyMentionFunction(mentionedIDs: rawReplyComment.mentionIDs, postID: rawReplyComment.postID, originalAuthor: rawReplyComment.postOwnerID, personReplyingTo: rawReplyComment.otherUserID)
                    }
                    Self.dummyCommentIds.remove(commentID)
                }
            }
        }
     
    }
    
    private func removeTempComment(userId : String,commentID : String) {
        if let index = comments.firstIndex(where: {$0.commentID == commentID}){
            comments.remove(at: index)
            if  comments.firstIndex(where: {$0.id == userId}) == nil {
                personDict.removeValue(forKey: userId)
            }
        }
        if let index =  tempComments.firstIndex(where: {$0.commentID == commentID}){
            tempComments.remove(at: index)
        }
    }
}

extension CommentRepliesOO{
    func deleleReplyComment(comment : CommentModel){
        let  deletedReplyRawComment = CommentModel.DeletedReplyRaw(sentBy: comment.id,
                                                                   ogCommentID: commentID,
                                                                   commentReplyID: comment.commentID,
                                                                   postID: postID,
                                                                   otherUserID: id)
         
        ReplyToCommentFunction.deleteReplyComment(deletedReplyRawComment : deletedReplyRawComment)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.removeFromCommentsIfExist(commentID: comment.commentID)
        }
    }
    
    func removeFromCommentsIfExist(commentID : String) {
        if let index = comments.firstIndex(where: {$0.commentID == commentID}){
            
         let _ =  withAnimation {
                comments.remove(at: index)
            }
        }
    }
}
