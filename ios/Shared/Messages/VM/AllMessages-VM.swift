//
//  AllMessagesOO.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 1/26/21.
//

import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift
 //so what is happening is i think is that some chat are not getting thei
class AllMessagesOO: ObservableObject {
    @Published var doesUserHaveAMessage = false
    @Published var unreadMessageChatIDs = [String]()
    ///for now the key will be user id and value will be the user chat having chat id and ongoingM essageIds
    @Published var userChatInfo = [String : UserChat]()
    @Published var groupChatInfo = [String : UserChat]()
    //so when we will get this from posttimeline. the timeline init has been called mean the app has already tried fetching from cache. so we can check in the init , if we have firends then it means we do have frinds.
    @Published var friendsDictionary : FriendsDictionary
    @Published var allChats : [ChatModel] = []
    
    var sortedChats : [ChatModel] {
        return allChats.sorted{
            ($0.lastMessage?.time.dateValue() ?? .distantPast) > ($1.lastMessage?.time.dateValue() ?? .distantPast)
        }
    }
    
    var groupChatsSortedByName : [ChatModel] {
        allChats.filter{$0.isAGroup}.sorted{ $0.groupName < $1.groupName }
    }
    /// we use this as a pointer and check in case friendDictionary publisher publishe anything. so in case use adds new friend or remove friends. allChats can be update accordingly
    var currentFriendIds : Set<String>
    /**  it is only used for single chats with zero messages. so we can add a dummy chatModel when current user sends a messages. but we use this set to make sure that chatUID is correct just to be safe */
    var unStartedChatIDs = Set<String>()
    
    init(friendsDictionary: FriendsDictionary) {
        self.friendsDictionary = friendsDictionary
        self.currentFriendIds = Set(friendsDictionary.friendsDictionary.keys)
//        print("123#  (friendsDictionary.friendsDictionary.keys) \(friendsDictionary.friendsDictionary.count)")
        addFriendListener()
        fetchAllChats(source: .cache) { [weak self] error in
            self?.startAllChatListeners()
        }
        startDummyMessageListener()
        startDummyMessageListenerForChatGroup()
    }
    
    func addFriendListener() {
        friendsDictionary.$friendsDictionary.didSet.sink { [weak self] newDict in
            guard let self = self else { return }
            let newSet = Set(newDict.keys)
//            print("123# newDict.count \(newDict.count)")
            //for now this check is for only new added/removed friends.
            if self.currentFriendIds != newSet {
                self.fetchAllChats(source: .cache)
//                print("123# self.currentFriendIds != newSet")
            }
            self.currentFriendIds = newSet
        }.store(in: &subs)
    }
    
    func queryForUserChatss() -> Query?{
        guard let userId = currentUserID else {  return nil  }
        return UserChatss.getUserChatsQuery(currentUserId: userId)
    }
    
    func startAllChatListeners() {
        guard let query = queryForUserChatss() else {  return  }
        chatListener?.remove()
        chatListener = query.addSnapshotListener {[weak self] (querySnapshot, error) in
        
            guard let documentChanges = querySnapshot?.documentChanges, error == nil else {
                print("Error fetching documents: \(error?.localizedDescription ?? "there's an error AllMessagesOO5.swift") ")
                return
            }
           
            var (userChats,userChatGroups) = UserChatss.decodeChatsFrom(chatsDocChange: documentChanges)
            userChats = userChats.filter({ self?.friendsDictionary.friendsDictionary[$0.user] != nil}) + userChatGroups
            userChats.forEach { self?.updateDoc(userChat: $0,docType: $0.type) }
        }
    }
    
    
    func fetchAllChats(source: FirestoreSource , callback: @escaping (Error?) -> Void = { _ in }) {
        guard let query = queryForUserChatss() else {  return  }
        query.getDocuments(source: source) {[weak self] (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents, error == nil else {
                print("Error fetching documents: \(error?.localizedDescription ?? "there's an error AllMessagesOO4.swift") ")
                callback(error ?? "there's an error AllMessagesOO4.swift".asError)
                return
            }
            
            let dispathGroup = DispatchGroup()
            var someError : Error?
            
            var (userChats,userChatGroups) = UserChatss.decodeChatsFrom(chatsDoc: documents)
            userChats = userChats.filter({ self?.friendsDictionary.friendsDictionary[$0.user] != nil})  + userChatGroups
            
            userChats.forEach { userChat in
                dispathGroup.enter()
                self?.updateDoc(userChat: userChat, source : source){ error in
                    if let error = error {
                        someError = error
                    }
                    dispathGroup.leave()
                }
            }
            dispathGroup.notify(queue: .main){
                if userChats.count != documents.count{
                    print("userChats.count  \(userChats.count)  = documents.count \(documents.count)")
                }
                callback(someError)
            }
        }
    }
    
    func updateDoc( userChat : UserChatss,docType : DocumentChangeType ) {
        updateIfHaveNewMessage(userChat : userChat)
        if docType == .added {
            updateUserChatInfoIfNeeded(userChat: userChat)
            addListenerToChat(userChat: userChat)
        }else if  docType == .modified {
            addListenerToChat(userChat: userChat) 
        }else if docType == .removed {
//              print(" updateDoc  docType == .removed")
            removeDeletedChat(Id : userChat.documentId)
            //            assert(false, "what happend check")
         }
    }
    
    func removeDeletedChat(Id : String){
        if let index = allChats.firstIndex(where: {$0.id == Id}){
            allChats.remove(at: index)
        }
    }
    
    func updateDoc(userChat : UserChatss, source: FirestoreSource, callback : @escaping ( _  error : Error?) -> Void){
        updateIfHaveNewMessage(userChat: userChat)
        updateUserChatInfoIfNeeded(userChat: userChat)
        fetchChat(userChat: userChat, source : source, callback: callback)
    }
    
    //this works with allChats
    func updateIfHaveNewMessage( userChat : UserChatss){
    
         if userChat.newMessage {
             self.doesUserHaveAMessage = true
             self.unreadMessageChatIDs.append(userChat.documentId)
         }
    }
    
    //this does not work with allChats need to check for possible fix. as group chat user is just empty string
    ///so if this func is called for same message twice. it will only run for the first one so we
    func updateUserChatInfoIfNeeded(userChat : UserChatss){
        let userId = userChat.user
        if self.userChatInfo[userId] == nil {
           self.userChatInfo[userId] = UserChat(chatId: userChat.documentId)
        }
        //chat group
        let chatId = userChat.documentId
        if self.groupChatInfo[chatId] == nil {
           self.groupChatInfo[chatId] = UserChat(chatId: userChat.documentId)
        }
    }
    //i think we should add a check. so before calling to fetch Chats we should check does this chat was updated? so we only fetch the UserChatss which were update. for now we can do this only for group chat
    func addListenerToChat(userChat : UserChatss) {
        let chatID = userChat.documentId
        let listener = Firestore.firestore()
            .collection(Constant.Chats())
            .document(chatID.nonEmpty)
            .addSnapshotListener{ [weak self] (document, error) in
                let chat = try? document?.data(as: Chats.self)
                self?.chatFetchResponse(userChat: userChat, chat: chat, source: .server)
                print(error?.localizedDescription ?? "")
            }
        chatListeners[chatID]?.remove()
        chatListeners[chatID] = listener
    }
    
    func fetchChat(userChat : UserChatss, source : FirestoreSource = .cache, callback : @escaping ( _  error : Error?) -> Void) {
        let chatID = userChat.documentId
        Firestore.firestore()
            .collection(Constant.Chats())
            .document(chatID.nonEmpty)
            .getDocument(source: source) { [weak self] (document, error) in
                if let error = error,
                   source == .cache,
                   FirestoreErrorCode.unavailable.rawValue == error.errorCode {
                    self?.fetchChat(userChat: userChat,source: .default, callback: {_ in})
                }else{
                    let chat = try? document?.data(as: Chats.self)
                    self?.chatFetchResponse(userChat: userChat, chat: chat, source: source)
                }
                callback(error)
            }
    }
 
    func chatFetchResponse(userChat: UserChatss, chat: Chats?, source : FirestoreSource){
        if chat != nil || userChat.isGroupChat {
            if chat?.otherUserID != TristanUserID {
                handleChatModified(userChat: userChat, chat: chat, source: source)
            }
            //the reasom we commented unStartedChatIDs.remove is quite simple. unStartedChatIDs will only be needed for single chat with zero id. so it can never be bigger then 150 count. and so i do not think it is a good idea to update it every time UserChatss get updated. we can just add stuff. and on next launch it will not add the started chats which were started on previous session
//             unStartedChatIDs.remove(userChat.documentId)
        }else {
            if chat?.otherUserID != TristanUserID {
                unStartedChatIDs.insert(userChat.documentId)
            }
        }
    }
    
    /*
     so should i make the chat model a class and add listener in it self so it can update it self
     we will need listener to every non friend group members. or we can update them when the user will tap and open the openConversations.
     as we do want the user to let tap on chat group and open users profiles. we will
     */
   
    
    func getChatOtherMembers(chatGroup: ChatGroup?, chat: Chats?, callback : @escaping (_ members : [Person],  _  error : Error?) -> Void) {
    
        if let chatGroup = chatGroup,
            chatGroup.groupChat == true {
            var members : [Person] = []
            var nonFriendIds : [String] = []
            
            chatGroup.users.forEach { id in
                if let friend = self.friendsDictionary.friendsDictionary[id]{
                    members.append(friend)
                }else{
                    nonFriendIds.append(id)
                }
            }
            
            if nonFriendIds.isEmpty{
                callback(members,nil)
            }else{
                let dispatchQueue = DispatchQueue(label:"FetchUserUsingCTNQueue", qos: .default)
                let dispatchGroup = DispatchGroup()
                var nsError : Error?
                
                nonFriendIds.forEach { id in
                    dispatchGroup.enter()
                    DispatchQueue.global(qos: .default).async  {
                        Person.fetchUserUsingCTN(id: id) { user, error in
//                            DispatchQueue.global(qos: .userInitiated).async  {
                            dispatchQueue.sync{
                                if let user = user {
                                    members.append(user)
                                }else {
                                    nsError = error ?? "did not get user".asError
                                }
                                dispatchGroup.leave()
                                
                            }
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    if let error = nsError{
                        callback([], error)
                    }else{
                        callback(members,nil)
                    }
                }
            }
            
        }else{
          if  let otherUserID = chat?.otherUserID ,
              let otherUser = self.friendsDictionary.friendsDictionary[otherUserID]  {
              callback([otherUser],nil)
            }else {
                callback([], "Chats member was not a friend for signle chat".asError)
            }
        }
    }
    
    /*here we will like to have UserChatss and Chats
    here we will fetch the latest message and the user at the same time using dispatch group and then add them in the allChats
     so the reason is that we have a listener on chat not for lastMessage directly. so if the Chats changed we fetch the latest message again,thus we will also need to update the chatmodels
     so this func will be called in case UserChats or Chats updates.
     
     so we will call two funcs here
     1. get all members (but in case of )
     2. get the lastMessage Object
     */
    func handleChatModified(userChat : UserChatss, chat: Chats?, source : FirestoreSource) {
        
        var chatUserID = ""
        if  userChat.isGroupChat == true {
//              print("  userChat.isGroupChat ")
        } else if let chatUserId = chat?.otherUserID  {
            chatUserID = chatUserId
        }else{
//              assert(false, " what happend incorrect chat flow. chat is not group chat nither do we have otherUSerID for signle chat   ")
            return
        }
        
        let dispatchGroup = DispatchGroup()
        var nsError : Error?
        
        var allMembers = [Person]()
        var lastMessage : MessageModel?
        dispatchGroup.enter()
        getChatOtherMembers(chatGroup: userChat.chatGroup, chat: chat) { members,error in
            if error != nil || members.isEmpty {
                nsError = (error ?? "members.isEmpty".asError)
                print(" error == nil || members.isEmpty {  \(error?.localizedDescription ?? "nope not working")")
            }else{
                allMembers = members
            }
            dispatchGroup.leave()
        }
        if let chat = chat {
            dispatchGroup.enter()
            MessageModel.getMessageQueryRef(chatUID: chat.documentId)
                .document(chat.lastMessageSentUUID.nonEmpty)
                .getDocument(source: source) { (doc, err) in
                    if let msgDoc = doc,
                       let msgDict = msgDoc.data() {
                        let message = MessageModel(messageID: msgDoc.documentID,
                                                   otherUserID : chatUserID,
                                                   dict: msgDict,
                                                   isTimeStringInDays: true,
                                                   chatID: userChat.documentId)
                        lastMessage = message
                    }else{
                        nsError = (err ?? " lastMessageSent msgDoc.data() is nil".asError)
                    }
                    dispatchGroup.leave()
                }
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            if  allMembers.isNotEmpty {
            
                let chatModel = ChatModel(userChat: userChat, members: allMembers, lastMessage: lastMessage)
                DispatchQueue.main.async {
                    self?.updateChats(chatModel: chatModel)
                }
            }else {
                print(" handleChatModified error \(nsError?.localizedDescription ?? "")")
            }
        }
    }
    //this func will only be called for fetched ChatModel not dummy one
    func updateChats(chatModel: ChatModel) {
        
        if let chatIndex = allChats.firstIndex(where: { $0.id == chatModel.id }) {
            
            if let newLastMessage = chatModel.lastMessage {
                if let currentLastMessage = allChats[chatIndex].lastMessage{
                    var chatModel = chatModel
                    
                    if newLastMessage.message.isEmpty , currentLastMessage.message == Constant.delivered() {
                        chatModel.lastMessage?.setMessage(Constant.delivered())
                    }
                    
//                    if currentLastMessage.time < newLastMessage.time  {
//                        allChats[chatIndex] = chatModel
//                    }else{
//                        allChats[chatIndex] = chatModel
//                    }
                    allChats[chatIndex] = chatModel
                }else{
                    allChats[chatIndex] = chatModel
                }
            }else{
                if allChats[chatIndex].lastMessage != nil, chatModel.lastMessage == nil{
                    //it means that chatModel was fetched from server and the current user is offline
                    return
                }
                allChats[chatIndex] = chatModel
//                print("for now leave it be. in future chatModel will be updated when user will leave/add other users and such   ")
            }
        } else {
            allChats.append(chatModel)
        }
        
    }
    
    var subs = Set<AnyCancellable>()
    var chatListeners : [String:ListenerRegistration] = [:]
    var chatListener : ListenerRegistration?
     
    deinit {
        subs.cancelAll()
        chatListener?.remove()
        chatListeners.forEach({$0.value.remove()})
//          print("AllMessagesOO deinit called")
    }
}
//MARK: - sendTo and marking message read cloud funcs
extension AllMessagesOO {
    
    func sendMessagesTo(selectedUser : [String],
                        selectedChatGroup : [SelectedChat],
                        friendsDict : [String : Person],
                        media : NewMedia,
                        isViewOnce : Bool){
 
        guard let currentUserID = currentUserID else {
            return
        }
          
        var selectedChats : [SelectedChat] = selectedChatGroup
        selectedUser.forEach { userId in
            
            let chatId = userChatInfo[userId]?.chatId ?? UUID().uuidString
            selectedChats.append(SelectedChat(otherUserID: userId, chatId: chatId))
        }
        
        let alreadyViewOnce = isViewOnce ? false : nil
        selectedChats.forEach { chat in
            let chatID = chat.chatId
            let otherUserID = chat.otherUserID
            let messageRaw = MessageModel.Raw(sentBy: currentUserID,
                                              message: media.description.trimWhitespacesAndNewlines(),
                                              chatUID: chatID,
                                              otherUserID: otherUserID,
                                              token: friendsDict[otherUserID]?.token ?? "",
                                              nameOfSendingUser: friendsDict[currentUserID]?.name ?? "",
                                              newMedia: media, 
                                              alreadyViewOnce : alreadyViewOnce,
                                              msgKind: .sendTo,
                                              groupName: chat.groupName)
            
            if userChatInfo[otherUserID] == nil , otherUserID.isNotEmpty {
               userChatInfo[otherUserID] = UserChat(chatId: messageRaw.chatUID)
            }

            

            if let index = allChats.firstIndex(where: {$0.id == chatID}) {
                if  allChats[index].lastMessage == nil {
                    allChats[index].lastMessage = messageRaw.getMessageModel()
                }
                allChats[index].lastMessage?.setTime(Timestamp())
            }else if unStartedChatIDs.contains(chatID) {
                var dummyMessage = messageRaw.getMessageModel()
                dummyMessage.setTime(Timestamp())
                let dummyChatModel = ChatModel(chatUID: dummyMessage.chatID,
                                               isAGroup: false,
                                               members: [],
                                               lastMessage: dummyMessage,
                                               time: dummyMessage.time.dateValue(),
                                               groupName: "",
                                               status: .sending)
                allChats.append(dummyChatModel)
                unStartedChatIDs.remove(dummyMessage.chatID)
            }
            
            SendMessageFunctions.sendNewMessage(messageRaw: messageRaw) { [weak self]  error in
  
                if let error = error {
                    print(error.localizedDescription)
                }else{
                     //i think the lastMessage was replace or somthing
                    if let index = self?.allChats.firstIndex(where: {$0.chatUID == chatID}){
                        self?.allChats[index].lastMessage?.setMessage(Constant.delivered())
                    }
                }
            } 
        }
       
        
    }
    
    func readMessage() {
        ReadMessageFunctions.markAllMessagesReadOf(chatUIDs: unreadMessageChatIDs)
        doesUserHaveAMessage = false
    }
    
    func markAllUnreadMessagesRead(){
//        print("marked All Unread Messages as Read")
        unreadMessageChatIDs.forEach {
            ReadMessageFunctions.readMessage(chatUID: $0)
        }
        doesUserHaveAMessage = false
    }
    
}
//MARK: - dummy msgs funcs
extension AllMessagesOO {
    
     /*
      so for the first launch we will need to use all the allUpdatedMessages and call the handleChat
      */
     func startDummyMessageListener() {
         /*
          so we do not need any messages here what w
          */
        var doHaveFailedMsgs = RealmRawMessage.getOldest() != nil
           RealmRawMessage.getRealmLatestFailedMessageListener { [weak self] newLatestFailedMessages , allUpdatedMessages in
             var haveFailedMessagesOfotherUserID : [String]
             
             if doHaveFailedMsgs{
                 haveFailedMessagesOfotherUserID = allUpdatedMessages.map { $0.message.otherUserID }
             }else{
                 haveFailedMessagesOfotherUserID = allUpdatedMessages.compactMap {
                     $0.msgKind == .sendTo ? $0.message.otherUserID : nil
                 }
             }
             //if the message says dilevered the new message does not go into the sending one
             guard let self = self else { return  }
             
             DispatchQueue.main.async {
                 for key in self.userChatInfo.keys {
                     
                     let doHaveSendingMessages = haveFailedMessagesOfotherUserID.removeFisrIfExist(key)?.isNotEmpty ?? false
                     if self.userChatInfo[key]?.haveFailedMessages == !doHaveSendingMessages {
                         self.userChatInfo[key]?.haveFailedMessages = doHaveSendingMessages
                     }
                     if doHaveFailedMsgs{
                         continue
                     }
                     if let latestSentMsgInfo = newLatestFailedMessages,
                        latestSentMsgInfo.msgKind == .openConversation,
                        key == latestSentMsgInfo.message.otherUserID {
                         //we can not user here the func that update allChats as we do not have chatID here
//                         self.handleChatModified(message: latestSentMsgInfo.message)
                         self.updateAllChatsWithDummyMessage(message: latestSentMsgInfo.message)
                         self.userChatInfo[key]?.haveFailedMessages = false
                     }
                 }
                 if doHaveFailedMsgs{
                     doHaveFailedMsgs = false
                 }
             }
           }?.store(in: &subs)
         
     }
    
    private func updateAllChatsWithDummyMessage(message: MessageModel) -> Void {
        let chatIndex = allChats.firstIndex(where: {  $0.chatUID == message.chatID })
        if let chatIndex = chatIndex {
            if !allChats[chatIndex].isAGroup,
               let oldMessage = allChats[chatIndex].lastMessage,
               oldMessage.time < message.time {
                var chat = allChats[chatIndex]
                //we do this becuase otherWise the allChats will update its subscriber two times. one for status and one time for lastMessage update
                chat.status = .sending
                chat.lastMessage = message
                allChats[chatIndex] = chat
            }
        }else if unStartedChatIDs.contains(message.chatID) {
                let dummyChatModel = ChatModel(chatUID: message.chatID, isAGroup: false, members: [], lastMessage: message, time: message.time.dateValue(), groupName: "", status: .sending)
                allChats.append(dummyChatModel)
                unStartedChatIDs.remove(message.chatID)
        }
    }
   
    func startDummyChatModelListener(){
        RealmChatModel.getRealmChatModelListener { [weak self]  _, dummyChatModels in 
            guard let self = self else { return  }
            
            for chatModel in dummyChatModels{
                if  self.groupChatInfo[chatModel.id] == nil{
                    self.addDummyChatModel(chatModel: chatModel)
//                    let chatId = chatModel.id
//                    self.groupChatInfo[chatId] = UserChat(chatId: chatId,haveFailedMessages : true)
//                    self.allChats.insert(chatModel, at: 0)
                }else{
                    
                }
            }
        }?.store(in: &subs)
    }
    
    func addDummyChatModel(chatModel: ChatModel) {
        let chatId = chatModel.id
        let chatGroup = ChatGroup(groupChat: true, users: chatModel.otherMembersIds, name: chatModel.groupName)
        getChatOtherMembers(chatGroup: chatGroup, chat: nil) { [weak self]  allMembers, error in
            if self?.groupChatInfo[chatModel.id] == nil {
                self?.groupChatInfo[chatId] = UserChat(chatId: chatId,haveFailedMessages : true)
                var chatModel = chatModel
                chatModel.otherMembers = allMembers
                self?.allChats.insert(chatModel, at: 0)
            }
        }
    }
    
   func startDummyMessageListenerForChatGroup() {
       startDummyChatModelListener()
       /*groupChatInfo
        so we do not need any messages here what w
        */
      var doHaveFailedMsgs = RealmRawMessage.getOldest() != nil
          RealmRawMessage.getRealmLatestFailedMessageListener { [weak self] newLatestFailedMessages , allUpdatedMessages in
           var haveFailedMessagesOfchatId : [String]
   
           if doHaveFailedMsgs{
               haveFailedMessagesOfchatId = allUpdatedMessages.map { $0.message.chatID }
           }else{
               haveFailedMessagesOfchatId = allUpdatedMessages.compactMap {
                   $0.msgKind == .sendTo ? $0.message.chatID : nil
               }
           }
           //if the message says dilevered the new message does not go into the sending one
           guard let self = self else { return }

           DispatchQueue.main.async {
               for key in self.groupChatInfo.keys {

                   let doHaveSendingMessages = haveFailedMessagesOfchatId.removeFisrIfExist(key)?.isNotEmpty ?? false
                   if self.groupChatInfo[key]?.haveFailedMessages == !doHaveSendingMessages {
                       self.groupChatInfo[key]?.haveFailedMessages = doHaveSendingMessages
                   }
                   if doHaveFailedMsgs{
                       continue
                   }
                   if let latestSentMsgInfo = newLatestFailedMessages,
                      latestSentMsgInfo.msgKind == .openConversation,
                      key == latestSentMsgInfo.message.chatID {
                       //we can not user here the func that update allChats as we do not have chatID here
//                         self.handleChatModified(message: latestSentMsgInfo.message)
                       self.updateAllGroupChatsWithDummyMessage(message: latestSentMsgInfo.message)
                       self.groupChatInfo[key]?.haveFailedMessages = false
                   }
               }
               if doHaveFailedMsgs{
                   doHaveFailedMsgs = false
               }
           }
       }?.store(in: &subs)

   }
    
    ///its just a temporyri use func until we fix otherUserID issue in messageModel
    private func updateAllGroupChatsWithDummyMessage( message: MessageModel) -> Void {
        if let chatIndex = allChats.firstIndex(where: { $0.chatUID == message.chatID }) {
            var chat = allChats[chatIndex]
  /* we do this becuase otherWise the allChats will update its subscriber two times.
   one for status and one time for lastMessage update */
            chat.status = .sending
            chat.lastMessage = message
            if let oldMessage = allChats[chatIndex].lastMessage {
                if oldMessage.time < message.time {
                    allChats[chatIndex] = chat
                }
            }else{
                allChats[chatIndex] = chat
            }
        }
    }
    //MARK:- will need to check does cahce then listener is affecting the functionlaity
//    private func handleChatModified( message: MessageModel) -> Void {
//       /* if let currentChatIndex = messageInfo.firstIndex(where: { $0.otherUserID == message.otherUserID }) {
//            let oldMessageText = messageInfo[currentChatIndex].message
//            messageInfo[currentChatIndex] = message
//            if message.message == "", oldMessageText == Constant.delivered() {
//                messageInfo[currentChatIndex].setMessage(Constant.delivered())
//            }
//        */
//       if let chatIndex = messageInfo.firstIndex(where: { $0.otherUserID == message.otherUserID }) {
//
//           let oldMessageText = messageInfo[chatIndex].message
//
//           var message = message
//
//           if message.message.isEmpty , oldMessageText == Constant.delivered() {
//               message.setMessage(Constant.delivered())
//           }
//
//           if messageInfo[chatIndex].time < message.time {
//               messageInfo[chatIndex] = message
//           }else{
//
//           }
//
//       } else {
//             messageInfo.append(message)
//        }
//    }
     
    func getPublisherFor(chatId : String) -> ChatModelPublisher {
         $allChats.compactMap { chats in
           chats.first(where:{$0.id == chatId && $0.status == .successfull})
        }
    }
    
    func groupDetailOf(_ chatModel : ChatModel) -> ChatGroupDetail{
        let friendsWhoLeft = friendsDictionary.getFriendsOf(ids: chatModel.usersWhoLeft ?? [])
        let publisher = getPublisherFor(chatId : chatModel.id)
        let groupDetails =  ChatGroupDetail(chatModel: chatModel, publisher: publisher, friendsWhoLeft: friendsWhoLeft)
        return groupDetails
    }
}
struct ChatGroupDetail {
    let chatModel: ChatModel
    let publisher: ChatModelPublisher
    let friendsWhoLeft: [Person]
    /**this includes the current members. plus past group members which are currently friends*/
    var allMembersDict : [String : Person] {
        let friendsWhoLeftDict = friendsWhoLeft.reduce(into: [String: Person]()) { $0[$1.id] = $1  }
        return chatModel.allMembersDict.merging(friendsWhoLeftDict){current,_ in current}
    }
}

typealias ChatModelPublisher = Publishers.CompactMap<Published<[ChatModel]>.Publisher, ChatModel>
extension AllMessagesOO {
     
    enum Constant : String {
        case delivered = "Delivered"
        case sending = "Sending..."
        case UserChats
        case UserChatss
        case newMessage
        case user
        case Chats
        case lastMessageSentUUID
        case members
        case ChatMessages
        case ChatMessagess
        case time
    }
}
//yes we can but UserChatss and Chats both does not have time, so we will just compare the message date i think
/*
 now we want to
 for group chats, in all messages
 we will get weblink of chat, for single chat from the friendDict and for group chat we will fetch first four users using NTC and add there weblink in the chat. when user will tap on a group chat we will  pass the weblinks in the chat object and will fetcch all messages of chat. and we will try to fetch all users from the cache. so in cahse user taps on the group pic we will only open group profile if we have fetched all other users of that chat group.
 */
 
