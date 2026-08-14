//
//  OpenedGroupConversationOO.swift
//  speakEZ
//
//  Created by Ahmad naeem on 12/14/21.
//
 

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine
 

class OpenedGroupConversationOO: ObservableObject {
    
    @Published private (set) var dismissChat: Bool = false
    @Published private (set) var messages: [MessageModel] = []
    @Published private (set) var goToBottom : Bool = false
    @Published private (set) var canFetchPage = false
    @Published private (set) var didfetchAllMessages = false
    @Published private (set) var chatModel : ChatModel
    @Published var allMembers : [String : Person]
    @Published var allMemberIDs = [String]()
      var chatUID: String {  chatModel.chatUID  }
      var isDummy : Bool {  chatModel.status == .sending }
    private var dummyMessageInArray = 0
    private var messageListener : ListenerRegistration? = nil
    private var lastMsgDoc : QueryDocumentSnapshot? = nil
    private var isFirstPage = true
    private var canStillFetchFromCache = true
    private var pageFlagMsg : MessageModel!
    private var viewOnceSub : AnyCancellable?
    private var doHaveViewOnceInRealm = false
    var newChatListener : ListenerRegistration?
    var canShowProgresser : Bool {
         canFetchPage == false && didfetchAllMessages == false
    }
    var sortedMessages : [MessageModel] {
        messages.sorted(by: {$0.time.dateValue().timeIntervalSinceNow > $1.time.dateValue().timeIntervalSinceNow})
    }
    var sub = Set<AnyCancellable>()
    var chatModelPublisher: ChatModelPublisher
    // groupDetailOf(_ chatModel : ChatModel) -> ChatGroupVMDetail?
    init(groupDetail : ChatGroupDetail,addPNListener : Bool = true) {
//        print("123# OpenedGroupConversationOO ")
       
        self.chatModel = groupDetail.chatModel
        self.chatModelPublisher = groupDetail.publisher 
        self.allMembers = groupDetail.allMembersDict
        self.fetchNonFriendPastMembers()
        guard let _ = Auth.auth().currentUser?.uid else{ return }
        getPage()
          
      let allFailedMessages = MessageModel.getFailedRealmMessagesOf(chatID: chatUID)
        if allFailedMessages.isNotEmpty{
            messages.append(contentsOf: allFailedMessages)
            dummyMessageInArray = allFailedMessages.count
        }
         
        viewOnceSub = RealmViewOnceMsg.getRealmViewOnceCountPublisher(chatUID: chatUID) { [weak self] doHaveViewOnceInRealm in
            self?.doHaveViewOnceInRealm = doHaveViewOnceInRealm
        }
        
        chatModelPublisher.sink {[weak self] chatModel in
            self?.updateWithLatest(chatModel : chatModel)
        }.store(in: &sub)
        setViewInfo()
        
        startPNListener(addPNListener: addPNListener) 
    }
    
    func updateWithLatest(chatModel : ChatModel) {
        self.chatModel = chatModel
        self.updateAllMembers(chatModel.allMembersDict)
    }
    
    func updateAllMembers(_ latestMembers : [String : Person]) {
        DispatchQueue.main.async {[weak self] in
            if let updateMembers = self?.allMembers.merging(latestMembers, uniquingKeysWith: { (_, new) in new }){
                self?.allMembers = updateMembers
                DispatchQueue.main.async {
                self?.allMemberIDs = self?.allMembers.keys.sorted() ?? [""]
                }
            }
        }
    }
 
    func fetchNonFriendPastMembers( ) {
        
        var members : [String: Person] = [:]
        let nonFriendIds : [String] =  chatModel.usersWhoLeft?.filter{allMembers[$0] == nil} ?? []
 
            if nonFriendIds.isNotEmpty{
                let dispatchGroup = DispatchGroup()
                var nsError : Error?

                nonFriendIds.forEach { id in
                    if id.isNotEmpty{
                    dispatchGroup.enter()
                        Person.fetchUserUsingCTN(id: id) { user, error in
                                if let user = user {
                                    members[user.id] = user
                                }else {
                                    nsError = error ?? "did not get user".asError
                                }
                                dispatchGroup.leave()  
                        }
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    withAnimation(.easeIn) {
                        self.updateAllMembers(members)
                    }
                    if let error = nsError{
                        print("fetchNonFriendPastMembers( ) { \(error.localizedDescription)")
                    }
                }
            }
      
    }
   
    func setCanFetchPage(_ val : Bool) {
        canFetchPage = val
    }
    
    func getNextPageIfNeeded(message : MessageModel) {
        if  canFetchPage,
            !didfetchAllMessages,
            (pageFlagMsg?.id == message.id) || message.id == messages.last?.id {
            getPage()
            //            print("\(message.id) getNextPageIfNeeded =")
        }
    }
    
    //we should add and inLast argument as well so we can add the new one in the last, and the old messages fetched in the first places
   
    func pageFetchComplete() {
        
        let halfPageSize : Int = Self.pageSize/2
        pageFlagMsg = messages.first
        if messages.count > halfPageSize {
            pageFlagMsg = messages[halfPageSize]
        }
        setCanFetchPage(true)
        //        print("getNextPageIfNeeded pageFetchComplete =" )
    }
    
    static var dateFormatter : DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "MMM d, h:mm a"
        return format
    }()
    
    static let pageSize = 50
    deinit {
        removeViewInfo()
        sub.cancelAll()
        messageListener?.remove()
        newChatListener?.remove()
        viewOnceSub?.cancel()
          print("OpenedGroupConversationOO deinit ")
    }
 
}

//MARK: - View once related
extension OpenedGroupConversationOO {
    func userDidViewMesssage(id: String){
        if let index = messages.firstIndex(where: {$0.id == id}){
            messages[index].userDidView(chatUID : chatUID)
        }
    }
     func checkDoesAlreadyViewOnceExist(messages : [MessageModel]) {
         messages.forEach { message in
             guard let alreadyViewOnce = message.alreadyViewOnce else{ return }
             if alreadyViewOnce {
                 if doHaveViewOnceInRealm{
                     RealmViewOnceMsg.deleteFromCache(message: message)
                     //now we now there are some message which viewonce was updated but not deleted from realm
                 }   //now here we will check only and only if there are any records in the realm otherwise we will not
             }else{
                 checkAlreadyViewOnce(messageUID: message.id)
             }
         }
     }
     
      
     ///this func will check for the message which were viewd but not updated on firestore db.
     func checkAlreadyViewOnce(messageUID : String) {
         DispatchQueue.global(qos: .userInitiated).async  {[weak self] in
             let doesExist = RealmViewOnceMsg.doesExist(messageUID: messageUID)
             if  doesExist {
                 guard let self = self else { return  }
                 if let index = self.messages.firstIndex(where: {$0.id == messageUID}){
                     DispatchQueue.main.async {
                         self.messages[index].alreadyViewOnce = true 
                     }
                 }else{
                    print("like what?")
                 }
                 SendMessageFunctions.didViewMessage(messageUID: messageUID, chatUID: self.chatUID){ error in
                     if error == nil {
//                         RealmViewOnceMsg.deleteFromRealm(messageUID: messageUID)
                     }
                 }
             }
         }
         //     SendMessageFunctions.updateAlreadyViewOnce(messageUID: id)
     }
}

//MARK: - updating message array
extension OpenedGroupConversationOO {
    
    func addMessageIfDoesNotExist(message : MessageModel) {
        if !messages.contains(where: {$0.id == message.id}){
            insertMessage(message)
        }
    }
    
    func addMessagesIfDoesNotExist(newMessages : [MessageModel]) {
        let newAllMessages : [MessageModel] = newMessages.compactMap { msg in
            if !messages.contains(where: {$0.id == msg.id}) {
                return msg
            }
            return nil
        }
        insertMessages(newAllMessages)
    }
      
    func addOrUpdateMessages(newMessages : [MessageModel]) {
        let newAllMessages : [MessageModel] = newMessages.compactMap { msg in
            if let index = messages.firstIndex(where: {$0.id == msg.id}) {
                let msg = messages[index]
                
                if msg.hasBeenLiked != msg.hasBeenLiked {
                    messages[index].hasBeenLiked = msg.hasBeenLiked
                }
                if msg.didTakeScreenShot != msg.didTakeScreenShot {
                    messages[index].didTakeScreenShot = msg.didTakeScreenShot
                }
                if msg.alreadyViewOnce != msg.alreadyViewOnce {
                    messages[index].alreadyViewOnce = msg.alreadyViewOnce
                    if msg.alreadyViewOnce == true {
                        RealmViewOnceMsg.deleteFromCache(message: msg)
                    }
                }
                return nil
            }else{
                return msg
            }
        }
        insertMessages(newAllMessages)
    }
    ///this func is wrong for now. we need to add hasBeenLiked logic for func which first check to add new messages. alos need to make sure that we dummy messages are working
//    func addMessageIfNeeded(message : MessageModel) {
//        if let index = messages.firstIndex(where: {$0.id == message.id}) {
//            let oldMsg = messages[index]
//            if message.hasBeenLiked == oldMsg.hasBeenLiked{
//                insertMessage(message)
//            }else{
//                messages[index].hasBeenLiked = message.hasBeenLiked
//            }
//        }
//    }
    
    private func insertMessage(_ message : MessageModel){
        messages.insert(message, at: 0)
        checkDoesAlreadyViewOnceExist(messages: [message])
    }
    
    private func insertMessages(_ newMessages : [MessageModel]) {
        guard newMessages.isNotEmpty else {  return  }
        messages.insert(contentsOf: newMessages, at: 0)
        checkDoesAlreadyViewOnceExist(messages: newMessages)
    }
    
//    private func removeMessage( messageId: String) {
//        if let index =  messages.firstIndex(where: {$0.id == messageId}) {
//            //we found the dummy so we will just replace it with the real message (that we get from the listener)
//            messages.remove(at: index)
//        }
//    }
}

//MARK: - fetching message pages
extension OpenedGroupConversationOO {
    
    
    private func getMessagePageQuery(chatUID : String) -> Query {
        let messageQuery = Firestore.firestore()
            .collection("ChatMessages")
            .document(chatUID.nonEmpty)
            .collection("ChatMessagess")
            .order(by: "time", descending: true)
        return messageQuery
    }
    
    
    ///so this will only be called from the cache results. and we will get all msg between last and first doc including last and first as well. so we can update the the whole page hasBeenLike and any possible missing messages
    func syncCacheWithServer(lastMsgDocument: QueryDocumentSnapshot,
                             firstMsgDocument: QueryDocumentSnapshot,
                             callback: @escaping (Error?) -> Void = {_ in}) {
       
        let chatUID = self.chatUID
        var messageQuery = getMessagePageQuery(chatUID: chatUID)
        
        messageQuery = messageQuery
            .start(atDocument: firstMsgDocument)
            .end(atDocument: lastMsgDocument)
//            .whereField(MessageModel.Constant.alreadyViewOnce(), isEqualTo: false)
        
        messageQuery.getDocuments(source: .server) {[weak self]  (snap, error) in
            guard let documents = snap?.documents, error == nil else {
                let error : Error = error ?? NSError.getWith(description: "getUserChats querySnapshot was nil")
                callback( error)
                return
            }
            let allMsgs = documents
                .map({MessageModel(messageID: $0.documentID, dict: $0.data(), chatID: chatUID)})
//                .filter({$0.alreadyViewOnce == false})
            self?.addOrUpdateMessages(newMessages: allMsgs)
            callback(nil)
        }
    }
    
    private func getMessagesPage(source : FirestoreSource ,
                                 lastMsgDocument : QueryDocumentSnapshot? = nil,
                                 limit : Int = OpenedGroupConversationOO.pageSize,
                                 callback : @escaping (_ allMsgs : [MessageModel],
                                                       _ lastMsgDoc : QueryDocumentSnapshot?,
                                                       _ firstMsgDoc : QueryDocumentSnapshot?,
                                                       _ error : Error?) -> Void) {
        let chatUID = self.chatUID
        var messageQuery = getMessagePageQuery(chatUID: chatUID)
            .limit(to: limit)
        
        if let lastMsgDocument = lastMsgDocument {
            messageQuery = messageQuery.start(afterDocument: lastMsgDocument)
        }
        
        messageQuery.getDocuments(source: source) { (snap, error) in
            guard let documents = snap?.documents, error == nil else {
                let error : Error = error ?? NSError.getWith(description: "getUserChats querySnapshot was nil")
                callback([],nil,nil,error)
                return
            }
            
            let allMsgs = documents.map({MessageModel(messageID: $0.documentID , dict: $0.data(),   chatID: chatUID )})
            callback(allMsgs,documents.last,documents.first,error)
        }
    }
    //WARNINING we always have one message that the AllChats fetch
    func getPage() {
        
        setCanFetchPage(false)
        let isFirstPage = isFirstPage
        
        if canStillFetchFromCache {
            let lastMsgDoc = self.lastMsgDoc
            getMessagesPage(source: .cache, lastMsgDocument: lastMsgDoc) { [weak self]
                (cacheMessages, cacheLastMsgDoc, cacheFirstMsgDoc, cacheError) in
                
                guard let self = self else { return  }
                
                self.canStillFetchFromCache = (cacheMessages.count == Self.pageSize)
                self.insertMessages(cacheMessages)
                if let cacheLastMsgDoc = cacheLastMsgDoc{
                    self.lastMsgDoc = cacheLastMsgDoc
                }
                if self.canStillFetchFromCache == false {
                    self.getPageFromServer(shouldCheck: true)
                }else{
                    self.pageFetchComplete()
                }
                /// we need to check do we need to plus one more even if we got and error or not
                
                if isFirstPage {
                    self.addListenerForLatestMessages(lastMsgDocument: cacheFirstMsgDoc)
                }
                
                if let cacheLastMsgDoc = cacheLastMsgDoc,
                    let cacheFirstMsgDoc = cacheFirstMsgDoc {
                   self.syncCacheWithServer(lastMsgDocument: cacheLastMsgDoc, firstMsgDocument: cacheFirstMsgDoc)
               }
                 
            }
        }else{
            getPageFromServer()
        }
        self.isFirstPage = false
    }
    
    func getPageFromServer(shouldCheck : Bool = false) {
        getMessagesPage(source: .server, lastMsgDocument: lastMsgDoc) { [weak self] (newMessages,lastMsgDoc,_,error) in
            if let error = error  {
                self?.setCanFetchPage(true)
                print(error.localizedDescription)
            }else{
                
                guard let self = self else { return  }
                
                if shouldCheck {
                    self.addMessagesIfDoesNotExist(newMessages: newMessages)
                }else{
                    self.insertMessages(newMessages)
                }
                self.lastMsgDoc = lastMsgDoc
                self.pageFetchComplete()
                if lastMsgDoc == nil{
                    self.didfetchAllMessages = true
                }
            }
        }
    }
    
}

//MARK: - listenesrs
extension OpenedGroupConversationOO {
    
    private func addListenerForLatestMessages( lastMsgDocument : QueryDocumentSnapshot? = nil) {
        
        let chatUID = chatUID
        var messageQuery = getMessagePageQuery(chatUID: chatUID)
         
        if let lastMsgDocument = lastMsgDocument {
            messageQuery = messageQuery.end(atDocument: lastMsgDocument)
        }
        
        messageListener?.remove()
        messageListener = messageQuery.addSnapshotListener() { [weak self] (snap, error) in
            
            guard let docChanges = snap?.documentChanges, error == nil else {
                print(error?.localizedDescription ?? "Latest Messages querySnapshot was nil")
                return
            }
            
            var allMessages = [MessageModel]()
            var lastMsgDoc: QueryDocumentSnapshot?
            for documentChange in docChanges {
                if documentChange.type == .added {
                    let doc = documentChange.document
                    let newMessage = MessageModel(messageID: doc.documentID, dict: doc.data(), chatID: chatUID)
                    allMessages.append(newMessage)
                    lastMsgDoc = doc
                }else if documentChange.type == .modified {
                    let doc = documentChange.document
                    
                    if let index = self?.messages.firstIndex(where: {$0.id == doc.documentID}) {
                        let newMessage = MessageModel(messageID: doc.documentID, dict: doc.data(), chatID: chatUID )
                        self?.messages[index] = newMessage
//                        if let alreadyViewOnce = newMessage.alreadyViewOnce {
//                            self?.messages[index].alreadyViewOnce = alreadyViewOnce
//                            if alreadyViewOnce{
//                                RealmViewOnceMsg.deleteFromRealm(messageUID: doc.documentID)
//                            }
//                        }
//                        if let didTakeScreenShot = newMessage.didTakeScreenShot {
//                            self?.messages[index].alreadyViewOnce = didTakeScreenShot
//                        }
                    }
                }
            }
            
            guard let self = self ,
                  let lastMsgDoc = lastMsgDoc else { return  }
               self.addListenerMessages(newMessages: allMessages)
               self.goToBottom.toggle()
            
            if self.lastMsgDoc == nil{
                self.lastMsgDoc = lastMsgDoc
                self.pageFetchComplete()
            }
            
        }
    }
    
    private func addListenerMessages( newMessages: [MessageModel]) {
        var messageToAdd :  [MessageModel] = []
        newMessages.forEach { newMsg in
            if dummyMessageInArray > 0,
               newMsg.status == .successfull,
               let index =  messages.firstIndex(where: {$0.id == newMsg.id}),
               messages[index].status == .sending{
               
                let _ = withAnimation(.default) {
                    messages[index] = newMsg
                }
                dummyMessageInArray -= 1
            }else{
                messageToAdd.insert(newMsg, at: 0)
            }
        }
        addMessagesIfDoesNotExist(newMessages: messageToAdd)
    }
    
}
 
//MARK: - sending new messages
extension OpenedGroupConversationOO {
    
      // we do need to update this func as well
    func sendNewMessage(messageRaw: MessageModel.Raw) {
//        return
        guard messageRaw.chatUID.isNotEmpty else {
//              assert(false, " what happend chatUID was empty   ")
              print(" messageRaw.chatUID isEmpty \(messageRaw.chatUID.isNotEmpty)")
             return
        }
        DispatchQueue.main.async { [weak self]  in
            
            guard let self = self else { return  }
            
            let messageModel = messageRaw.getMessageModel()
            self.insertMessage(messageModel)
            self.dummyMessageInArray += 1
//            self?.allChats.addOngoingMessage(messageModel)
//             var messageRaw = messageRaw
//            messageRaw.alreadyViewOnce = false
            self.goToBottom.toggle()
          
            if self.isDummy == false   {
                
                SendMessageFunctions.sendNewMessage(messageRaw: messageRaw) {   error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print(" SendMessageFunctions.sendNewMessage group chat",error.localizedDescription)
                        }else{
                            //           print("sendNewMessage successfully")
                        }
                    }
                }
            }else{
                CreateGroupUserChatFunction.sendMessageOfDummy(chatModel: self.chatModel, messageRaw: messageRaw)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
//                    CreateGroupUserChatFunction.create(chatModel: self.chatModel, callback: {_ in})
//                    CreateGroupUserChatFunction.shared
//                        .sendMessageOfDummy(chatModel: self.chatModel, messageRaw: messageRaw, publisher: self.chatModelPublisher)
//                }
            }
        }
    }
}

extension OpenedGroupConversationOO : PNViewManagerSetAble{
   var docId : String {  chatUID  }
   var type: PNViewManager.OnScreenView  { .groupChat }
    func startPNListener(addPNListener: Bool){
        if addPNListener {
            publisherForNewPN.assign(to: &$dismissChat)
        }else{
            addPushNotificationViewListener()
                .store(in: &sub)
        }
    }
}
 /*
so we do not want to create group when user will tap on done button after selecting users.  so we will only create group if the user send a message. so for that we will feed the OGC a dummy chatModel and also add a isDummy var as well so we know that this is a dummy chat.  and we will still add the publisher but it will not publish anything until user sends the first message and we can create a new group.
  so the issue is if user sends messages we want to save them in realm but we can not as there might not be a UserChatss exist.
  so for that we will need a var that will hold all the sent messages and will send them after we get confirmation of real UserChatss creates. for that we can have a static array in which we can add the sent messages. and on the chatModel creatino we will send the messages one by one like failed manager. i think we can use failed manager for that as well. we can save the messages with isFailed = true that way failed manager will start sending them auto matically
 */
/*
 now we will need alot of restrictions, so user can not interact with server on behafe of this UserChatss of chat group
 */
/*
 as he deint is not been called in the ios 14 i think we should first do the pn view not replaceing each other and then we can look into it. i think we mighe be able to resolve it using combine. if not then async might work. we will also going to have to check for all other OO to make sure they also deint.
 */
