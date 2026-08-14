//
//  OpenedConversationViewModel.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/19/21.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine
/*
 so the issue is we use otherUserID to get chatID in the OpenedConversationOO. so in groups who we will do it? will we will share chatID or somthing else. 
 */
class OpenedConversationOO: ObservableObject {
    @Published private (set) var dismissChat: Bool = false
    @Published private (set) var messages: [MessageModel] = []
    @Published private (set) var goToBottom : Bool = false
    @Published private (set) var canFetchPage = false
    @Published private (set) var didfetchAllMessages = false
    private (set) var chatUID: String = ""
    private var otherUserID : String
    private var dummyMessageInArray = 0
    private var messageListener : ListenerRegistration? = nil
    private var lastMsgDoc : QueryDocumentSnapshot? = nil
    private var isFirstPage = true
    private var canStillFetchFromCache = true
    private var pageFlagMsg : MessageModel!
    private var viewOnceSub : AnyCancellable?
    private var pnSub : AnyCancellable?
    private var doHaveViewOnceInRealm = false
    var newChatListener : ListenerRegistration?
    
    var canShowProgresser : Bool {
         canFetchPage == false && didfetchAllMessages == false
    }
    var sortedMessages : [MessageModel] {
        messages.sorted(by: {$0.time.dateValue().timeIntervalSinceNow > $1.time.dateValue().timeIntervalSinceNow})
    }
    
    init(otherUserID: String, addPNListener : Bool = true ) {
          print("123#  OpenedConversationOO init")
        self.otherUserID = otherUserID
        
        guard currentUserID != nil else{ return }
        
        getUserChatID(source: .cache, otherUserID: otherUserID) { [weak self] chatID, error in
            if let chatID = chatID, error == nil{
                self?.chatUID = chatID
                self?.getPage()
                self?.setViewInfo()
            }else{
                self?.addListenerForNewUserChat(otherUserID: otherUserID){ [weak self] chatID, error in
                    if let chatID = chatID, error == nil{
                        self?.chatUID = chatID
                        self?.getPage()
                        self?.setViewInfo()
                    }
                }
            }
        }
        
      
        
        
      let allFailedMessages = MessageModel.getFailedRealmMessagesOf(otherUserID: otherUserID) + OpenedConversationNewUserChatssManager.shared.getAllDummyMessagesOf(otherUserID: otherUserID)
        if allFailedMessages.isNotEmpty {
            self.messages.append(contentsOf: allFailedMessages)
            dummyMessageInArray = allFailedMessages.count
        }
 
        viewOnceSub = RealmViewOnceMsg.getRealmViewOnceCountPublisher(otherUserID: otherUserID) { [weak self] doHaveViewOnceInRealm in
            self?.doHaveViewOnceInRealm = doHaveViewOnceInRealm
        }
        startPNListener(addPNListener: addPNListener) 
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
        messageListener?.remove()
        newChatListener?.remove()
        viewOnceSub?.cancel()
        pnSub?.cancel()
    }
   
}

//MARK: - View once related
extension OpenedConversationOO {
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
extension OpenedConversationOO {
    
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
extension OpenedConversationOO {
    
    
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
        
        guard self.chatUID.isNotEmpty, self.otherUserID.isNotEmpty  else {
            return
        }
        
        let otherUserID = self.otherUserID
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
            guard let chatUID = self?.chatUID else { return  }
            let allMsgs = documents
                .map({MessageModel(messageID: $0.documentID , otherUserID : otherUserID, dict: $0.data(), chatID: chatUID)})
//                .filter({$0.alreadyViewOnce == false})
            self?.addOrUpdateMessages(newMessages: allMsgs)
            callback(nil)
        }
    }
    
    private func getMessagesPage(source : FirestoreSource ,
                                 lastMsgDocument : QueryDocumentSnapshot? = nil,
                                 limit : Int = OpenedConversationOO.pageSize,
                                 callback : @escaping (_ allMsgs : [MessageModel],
                                                       _ lastMsgDoc : QueryDocumentSnapshot?,
                                                       _ firstMsgDoc : QueryDocumentSnapshot?,
                                                       _ error : Error?) -> Void) {
        let otherUserID = self.otherUserID
        let chatUID = self.chatUID
        var messageQuery = getMessagePageQuery(chatUID: chatUID)
            .limit(to: limit)
        
        if let lastMsgDocument = lastMsgDocument {
            messageQuery = messageQuery.start(afterDocument: lastMsgDocument)
        }
        
        messageQuery.getDocuments(source: source) { [weak self] (snap, error) in
            guard let documents = snap?.documents, error == nil else {
                let error : Error = error ?? NSError.getWith(description: "getUserChats querySnapshot was nil")
                callback([],nil,nil,error)
                return
            }
            
            let allMsgs = documents.map({MessageModel(messageID: $0.documentID , otherUserID : otherUserID, dict: $0.data(),   chatID: chatUID )})
            callback(allMsgs,documents.last,documents.first,error)
        }
    }
    //WARNINING we always have one message that the AllChats fetch
    func getPage() {
        guard !chatUID.isEmpty  else {
            return
        }
        
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
extension OpenedConversationOO {
    
    private func addListenerForLatestMessages( lastMsgDocument : QueryDocumentSnapshot? = nil) {
        
        let chatUID = chatUID
        var messageQuery = getMessagePageQuery(chatUID: chatUID)
        let otherUserID = self.otherUserID
        
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
                    let newMessage = MessageModel(messageID: doc.documentID, otherUserID: otherUserID, dict: doc.data(), chatID: chatUID)
                    allMessages.append(newMessage)
                    lastMsgDoc = doc
                }else if documentChange.type == .modified {
                    let doc = documentChange.document
                    
                    if let index = self?.messages.firstIndex(where: {$0.id == doc.documentID}) {
                        let newMessage = MessageModel(messageID: doc.documentID, otherUserID: otherUserID, dict: doc.data(), chatID: chatUID )
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
//MARK: - Chat related
extension OpenedConversationOO {
    
    
    
    private func getChatQuery(otherUserId : String) ->  Query?{
        guard let userId = Auth.auth().currentUser?.uid else { return nil }
    
        let chatQuery = UserChatss.getUserChatsQuery(currentUserId: userId)
            .whereField("user", in: [otherUserId])
            .limit(to: 1)
        return chatQuery
    }
    
    private func getUserChatID(source: FirestoreSource = .default,otherUserID: String,callback : @escaping ( _ chatUID : String? ,_  error : Error?) -> Void) {
        guard let chatQuery = getChatQuery(otherUserId : otherUserID) else {
            return
        }
        
        chatQuery.getDocuments(source: source) {  (querySnapshot, error) in
            guard let document = querySnapshot?.documents.first, error == nil else {
                let error : Error = error ?? NSError.getWith(description: "getUserChats querySnapshot was nil")
                callback(nil,error)
                return
            }
            callback(document.documentID ,nil)
            
        }
    }
    

    private func addListenerForNewUserChat(otherUserID: String,callback : @escaping ( _ chatUID : String? ,_  error : Error?) -> Void) {
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        let chatQuery = UserChatss.getUserChatsRef(currentUserId: userId)
            .whereField("user", in: [otherUserID])
    
        newChatListener?.remove()
        newChatListener = chatQuery.addSnapshotListener() {[weak self] (querySnapshot, error) in
            guard var documentChanges = querySnapshot?.documentChanges, error == nil else {
                let error = error ?? "getUserChats querySnapshot was nil".asError
                callback(nil,error)
                return
            }
            documentChanges =  documentChanges.filter({$0.type == .added})
            var userChats: [UserChatss] = documentChanges.compactMap({try? $0.document.data(as: UserChatss.self)})
            userChats = userChats.uniqueSorted
            if let chatUID = userChats.first?.documentId,
               self?.chatUID.isEmpty == true {
                callback(chatUID ,nil)
                self?.newChatListener?.remove()
            }
        }
    }
}
//MARK: - sending new messages
extension OpenedConversationOO {
    
    ///so we are using this so we do not need to check the messages array all the time , we will only check the array before appending message if the value is greater then 0 of dummyMessageInArray
    
    func sendNewMessage(messageRaw: MessageModel.Raw) {
        
        DispatchQueue.main.async {
            let messageModel = messageRaw.getMessageModel()
            self.insertMessage(messageModel)
            self.dummyMessageInArray += 1
            self.goToBottom.toggle()
            if messageRaw.chatUID.isNotEmpty {
                SendMessageFunctions.sendNewMessage(messageRaw: messageRaw) {
                    print($0?.localizedDescription ?? "sendNewMessage successfully")
                }
            }else{
                OpenedConversationNewUserChatssManager.shared.sendMessageOfDummy(otherUserID: self.otherUserID, messageRaw: messageRaw)
            }
        }
    }
}

extension OpenedConversationOO: PNViewManagerSetAble{
    var docId : String {  chatUID }
    var type: PNViewManager.OnScreenView { .privateChat }
    func startPNListener(addPNListener: Bool){
        if addPNListener {
            publisherForNewPN.assign(to: &$dismissChat)
        }else{
            pnSub = addPushNotificationViewListener()
        }
    }
}


/*
 now we also want to sycn message with cache as we do for posts. because now message can be updated. for that we can just check only one property that was changed. for that we can just get messages with alreadyViewOnce false and then check them up with the server. and if the are marked false we just update the message simple.
 */
