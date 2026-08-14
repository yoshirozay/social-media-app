//
//  C-VM.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//


import SwiftUI
import Firebase
import Combine
import FirebaseFirestore
import Foundation
import LinkPresentation
/*
 we need to make comments fast and for that we will first just use the cache then network technique here because a non-friend user might have commented and has changed its webLink , then if we only get them from the cache then we will not get the latest one
 */
typealias RawReplyCommentPublisher = Publishers.Filter<Published<CommentModel.Raw.Reply?>.Publisher>

class CommentsOO: ObservableObject {
    @Published var comments = [CommentModel]()
    @Published private (set) var goToBottom : Bool = false
    @Published var personDict = [String : Person]()
    @Published var friendsWhoCommented = Set<String>()
    @Published var friendsDictionary = FriendsDictionary(addFriendsListener : false)
    @Published var rawReplyComment: CommentModel.Raw.Reply?
    var sortedComments : [CommentModel]{
      comments.sorted(by: {$0.time  < $1.time }) + preloadedComments
    }
   var preloadedComments : [CommentModel] = []
    ///user id
    private let id : String
    private let postID : String
    //will try to change the return type to a simpler one, i think for that we will need map instead of filter
    func getRawReplyCommentPublisher(commentID : String)
    -> RawReplyCommentPublisher {
        let newPublisher = self.$rawReplyComment.filter {[weak self] in
            $0?.postID == self?.postID &&
                $0?.sentBy == currentUserID &&
                $0?.commentID == commentID
        }
        return newPublisher
    }
    
    init(id: String, postID: String) {
//          print("123# CommentsOO")
        self.id = id
        self.postID = postID
        getAllCommentsOfPost(id: id, postID: postID, source: .cache)
    }
    
    func addPreloadedCommentsIfNeeded(){
        if id == TristanUserID,
           let person = friendsDictionary.friendsDictionary[id] {
            buildUserDictionary(person.id, person: person)
            preloadedComments = CommentModel.Preloaded.getCommentsForPost(postID: postID)
            friendsWhoCommented.insert(id)
        }
    }
    
    private func getAllCommentsOfPost(id: String, postID: String, source: FirestoreSource = .default) {
        friendsDictionary.getFriendsDictionary(source: source) { [weak self] (_, error) in
//            print("get CommentsOO :-   got callback")
            self?.addPreloadedCommentsIfNeeded()
            if let errorCode = (error as NSError?)?.code,
               //will get unavailable error, if we did not find anything in the cache or server. in this case it is cache
               FirestoreErrorCode.unavailable.rawValue != errorCode {
                print(error?.localizedDescription ?? "")
            }else{
         
                self?.getAllComments(id: id, postID: postID, source: source) { lastTime in
                    self?.addCommentListener(id: id, postID: postID,  lastTimestamp: lastTime)
                    self?.checkAndRemovedDeletedComment(id: id, postID: postID)
//                    self?.getAllCommentsLinks()
                    self?.goToBottom.toggle()
                  
                }
                self?.startListenersForNewFriends(id: id)
            }
            
        }
    }
    
    func checkAndRemovedDeletedComment(id: String, postID: String) {
        fetchCommentsDocs(id: id, postID: postID, source: .server) { docs, error in
             //FIXME: - we need to uncomment the below error check, otherwise all comments will be removed when user go offline.
//            guard error == nil else {return}
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
    
    private func fetchCommentsDocs(id: String, postID: String, source: FirestoreSource, callback : @escaping (_ docs : [QueryDocumentSnapshot],  _  error : Error?) -> Void){
        let docRef = CommentModel.getPostCommentCollRef(authorId: id, postID: postID)
        
        docRef.getDocuments(source: source) { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents,error == nil else {
                print("Error fetching documents: ",error?.localizedDescription ?? "")
                callback([], error)
                return
            }
            callback(documents, nil)
        }
    }
    ///will get all comments from firestore source and will start listener
    private func getAllComments(id: String, postID: String, source: FirestoreSource,callback : @escaping ( _  lastTime : Timestamp?) -> Void) {
        self.fetchCommentsDocs(id: id, postID: postID, source: source) {[weak self]  documents, _ in
            
            for document in documents {
                self?.buildCommentDictionaries(document, id: id,source : source)
            }
            
            let allTimeStamp = documents.compactMap({$0.get("time") as? Timestamp})
            let lastTime = allTimeStamp.max(by: {$0.dateValue() < $1.dateValue() })
            callback(lastTime)
        }
    }
    private func getAllCommentsLinks() {
        for item in sortedComments {
            print("URL ITEM = \(item.comment)")
            if checkIfLinkExists(commentModel: item) {
                fetchLinkMetaData(commentModel: item, link: getCommentLink(commentModel: item))
            } else {
                return
            }
        }
    }
    func checkIfLinkExists(commentModel: CommentModel) -> Bool {
        if commentModel.comment.contains("https://") && commentModel.isGIF != true {
            print("url TRUE")
            print("comment TRUE = \(commentModel.comment)")
            return true
        } else {
            print("comment FALSE = \(commentModel.comment)")
            print("url FALSE")
            return false
        }
            
    }
    private func getCommentLink(commentModel: CommentModel) -> URL {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
           else {
            return URL(string:"www.apple.com")!
           }
        let stringRange = NSRange(location: 0, length: commentModel.comment.count)
print("URL DOES THIS PRINT??")
        print("comment = \(commentModel.comment)")
           let matches = detector.matches(
            in: commentModel.comment,
               options: [],
               range: stringRange
           )
        let attributedString = NSMutableAttributedString(string: commentModel.comment)
        var url: URL = URL(string:"www.google.com")!
        attributedString.enumerateAttributes(in: stringRange, options: []) { attrs, range, _ in
                var urlString = attributedString.attributedSubstring(from: range).string
            url = URL(string: urlString) ?? URL(string:"www.facebook.com")!
            print("URL = \(url)")
            }
        print("URL2 = \(url)")
        return url
    }
    private func fetchLinkMetaData(commentModel: CommentModel, link: URL) {
        print("LINK = \(link)")
            let provider = LPMetadataProvider()
            provider.startFetchingMetadata(for: link) {[self] metaData, error in
                guard let data = metaData, error == nil else {
                    print("error adding link preview")
                    return
                }
                DispatchQueue.main.async {
                        self.updateCommentWithLinkMetaData(commentModel: commentModel, metadata: data)
                    print("URL DOES THIS PRINT?? 2")

                }
            }
    }
    private func updateCommentWithLinkMetaData(commentModel: CommentModel, metadata: LPLinkMetadata) {
        var updatedComment = commentModel
        updatedComment.linkMetaData = metadata
        if let firstIndex = comments.firstIndex(where: {$0.commentID == commentModel.commentID}) {
            comments.remove(at: firstIndex)
            withAnimation(.linear(duration: 0.1)) {
                comments.append(updatedComment)
            }
        }
    }
    private  var commentListenerReg : ListenerRegistration?
    ///will start listener to the new comment added so we can also update our oo
    //user can not change / delete a comment the only thing we need to refetch is the user it self not the comments
    private func addCommentListener(id: String, postID: String, lastTimestamp : Timestamp?) {
        let docRef = CommentModel.getPostCommentCollRef(authorId: id, postID: postID)
 
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
    ///this func will only ne called for comment only once not tiwce so there will be no duplication of comments
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
    //for this we will get half from cache and other from the listener so do not need to checkt that the comment is from cache ro from server
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
            self.goToBottom.toggle()
        }
        //        if tempComments.contains(where: { $0.commentID ==
        //        })
    }
    var tempComments : [CommentModel] = []
    
    lazy var dateFormat : DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "MMM d, h:mm:ss a"
        return format
    }()
    
    deinit {
        commentListenerReg?.remove()
    }
}
extension CommentsOO {
    ///now in this func we can add .cache condition to first get user from the cache then from the server
    private func buildUserInfoDictionary(source: FirestoreSource = .default,sentBy: String,callback : @escaping (_ error : Error?) -> Void = {_ in}) -> Void {
        let docRef = Firestore.firestore().collection("UserInfo").document(sentBy.nonEmpty)
        docRef.getDocument(source : source) {[weak self] (document, error) in
            
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
    
    private func buildUserDictionary(_ dictionaryKey: String, person: Person) {
        self.personDict[dictionaryKey] = person
    }
    
    private func buildFriendsWhoCommented(_ sentBy: String, id: String) -> Void {
        if friendsDictionary.friendsDictionary[sentBy] != nil && sentBy != Auth.auth().currentUser?.uid && sentBy != id { // Don't send yourself, or the original post owner an "also commented" comment
            DispatchQueue.main.async { [weak self] in
                self?.friendsWhoCommented.insert(sentBy)
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
    
   
}
extension CommentsOO {
    func sendNewComment(rawComment : CommentModel.Raw, mentionedIDs: [String], postID: String, originalAuthor: String) {
        let time = Timestamp()
        
        let accurateTimeString = dateFormat.string(from: time.dateValue())
        
        let commentObject = CommentModel(id: rawComment.sentBy,
                                         time: time,
                                         comment: rawComment.comment,
                                         timeString: time.getTimeString(),
                                         accurateTimeString: accurateTimeString,
                                         commentID: UUID().uuidString,
                                         status: .sending )
        
        DispatchQueue.main.async { [weak self] in
            self?.tempComments.append(commentObject)
            self?.buildComment(commentObject)
            self?.goToBottom.toggle()
            // we will always have the currentUser in the friendsDictionary
            if let person = self?.friendsDictionary.friendsDictionary[commentObject.id] {
                self?.buildUserDictionary(person.id, person: person)
            }
            
            
            let commentID = commentObject.commentID
            let userId = commentObject.id
              
            
            SendCommentFunction.send(rawComment: rawComment) { [weak self] error in
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
                        self?.commentMentionFunction(mentionedIDs: mentionedIDs, postID: postID, originalAuthor: originalAuthor)
                    }
                }
            }
        }
    }
    func getMentionedFriendsInfo (mentionedIDs: [String], postID: String, originalAuthor: String) -> [[String: String]]{
        var mentionedInformation = [[String: String]]()
        
        guard let userId = Auth.auth().currentUser?.uid else{ return mentionedInformation}
        
            for item in mentionedIDs {
                if item != originalAuthor {
                    mentionedInformation.append(["id": "\(UUID())", "resourceID": postID, "sentBy": userId, "sentTo": item, "token": self.friendsDictionary.friendsDictionary[item]?.token ?? "", "nameOfSendingUser": self.friendsDictionary.friendsDictionary[userId]?.name ?? "", "originalAuthor": originalAuthor])
                    print("MENTIONED INFO = \(mentionedInformation)")
            }
            }
        return mentionedInformation
    }
    
    func commentMentionFunction(mentionedIDs: [String], postID: String, originalAuthor: String){

        Functions.functions().httpsCallable("commentMention-commentMention").call(getMentionedFriendsInfo(mentionedIDs: mentionedIDs, postID: postID, originalAuthor: originalAuthor)) { (result, error) in
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
    
    /*
     so if the comment is not send and we have added currrent user in the arrya of the firendsWhoCommented, we will need to remove the current user as well. if it already exist then no problem, but if we added it then we need to remove it as well. becuase we use it when we send comments.
     and we will also need to consider the senario
     , if user open post , user do not have net connection, we get comments from the cachec, now user send a comment at the exact time device  get connection, now the post acutlly have more comments which were not loaded so, in this case we will just send comment and will left the other commentrs, i think we use it for the notificaton.
     i think to resolve this we can just make a var and name it didListenerStarted and will mark it correct when we get response from the listener. but the problem can occur if user is chating and then user goes offline , now the listener has started, so now when we send comment and at the same time we get connection, the new commeners will be leftout
     */
  
}
extension CommentsOO{
    func deleleComment(comment : CommentModel){
       
    let deletedRawComment = CommentModel.DeletedRaw(sentBy: comment.id, commentID: comment.commentID, postID: postID, otherUserID: id)
        SendCommentFunction.deleteComment(deletedRawComment : deletedRawComment) {  error in
            print(error?.localizedDescription ?? "")
        }
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
  

extension CommentsOO {
    func sendCommentTest(rawComment : CommentModel.Raw, mentionedIDs: [String]) {
         
        let commentObject = rawComment.dummyCommentModel
        guard commentObject.kind != nil || commentObject.comment.isNotEmpty else {  return  }

        DispatchQueue.main.async { [weak self] in
            self?.tempComments.append(commentObject)
            self?.buildComment(commentObject)
            self?.goToBottom.toggle()
            // we will always have the currentUser in the friendsDictionary
            if let person = self?.friendsDictionary.friendsDictionary[commentObject.id] {
                self?.buildUserDictionary(person.id, person: person)
            }
             
            let commentID = commentObject.commentID
            let userId = commentObject.id
            let otherUserID = rawComment.otherUserID
            let postID = rawComment.postID
            SendCommentFunction.send(rawComment: rawComment) { [weak self] error in
//            SendCommentFunction.sendComment(rawComment: rawComment) { [weak self] error in
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
                        self?.commentMentionFunction(mentionedIDs: mentionedIDs, postID: postID, originalAuthor: otherUserID)
                    }
                }
            }
        }
    }
//    func subscribeToPost(postID: String, originalAuthor: String) {
//        guard let userId = Auth.auth().currentUser?.uid else{ return }
//        let docRef = Firestore.firestore().collection("CommentSubscription").document(userId.nonEmpty)
//        docRef.getDocument {(document, error) in
//    let dataDescription = document?.data() as? [String: String]
//            if dataDescription?[postID] == nil {
//                    SubscribeToPost.subscribeToPostCloudFunction(postID: postID, originalAuthor: originalAuthor)
//                    print("subscribe")
//                } else {
//                    print("already subscribed")
//                    return
//                }
//
//        }
//    }
//    func unsubscribeToPost(postID: String, originalAuthor: String) {
//        guard let userId = Auth.auth().currentUser?.uid else{ return }
//        let docRef = Firestore.firestore().collection("CommentSubscription").document(userId.nonEmpty)
//        docRef.getDocument {(document, error) in
//    let dataDescription = document?.data() as? [String: String]
//            if dataDescription?[postID] != nil {
//                    SubscribeToPost.unsubscribeToPostCloudFunction(postID: postID, originalAuthor: originalAuthor)
//                    print("unsubscribe")
//                } else {
//                    print("not subscribed")
//                    return
//                }
//
//        }
//    }
}

extension CommentsOO {
    func send(comment: String, selectedMedia: SelectedMedia?, token: String, nameOfSendingUser: String, mentionedIDs: [String]){
        guard let userId = currentUserID else { return }
        let rawComment = CommentModel.Raw(sentBy: userId,
                                          comment: comment,
                                          postID:   postID,
                                          otherUserID: id,
                                          friendIDs: friendsWhoCommented.getArray(),
                                          token: token,
                                          nameOfSendingUser: nameOfSendingUser,
                                          selectedMedia : selectedMedia)
        sendCommentTest(rawComment : rawComment, mentionedIDs: mentionedIDs)
    }

}




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
