//
//  OpenedGroupConversation.swift
//  speakEZ
//
//  Created by Ahmad naeem on 12/14/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Introspect 
import Firebase
import Combine

struct OpenedGroupConversation: View {
    @Binding var selectedGroupChat : ChatModel?
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @StateObject var allMessages : OpenedGroupConversationOO
    //    @StateObject var userChats = AllMessagesOO()
    @EnvironmentObject var allChats : AllMessagesOO
    
    @State var message = ""
    @State var textHeight: CGFloat = 0
    @StateObject var keyboard = KeyboardViewModel()
    @StateObject var functions = SendMessageFunctions()
    @State var OpenedPhotoSelectedItem: URL?
    @State var OpenedPhotoMatchedGeometry: String = ""
    @State var OpenedGIFMatchedGeometry: String = ""
    @State var selectedMedia: SelectedMedia?
    @State var ShowPhotoImagePicker = false
    //    @State var GroupProfileMatchedGeometry = ""
    @Environment(\.colorScheme) var colorScheme
    @State var list: UITableView?
    @State var textViewMaxHeight: CGFloat = 200
    @State var isOpenFromProfile = false
    @State var emptyStringBinding = ""
    @State var GroupChatInfoMatchedGeometry: String = ""
    @State var isNewGroupChat: Bool
    @Binding var NewGroupChatMatchedGeometry: String
    @Binding var NewConversationMatchedGeometry: String
    @State var isTyping = false
    @State var isShowingGIFkeyboard = false
    @State var gifURL: String = ""
    @StateObject var soundManager = SoundManager()
    @State var playRecording = false
    @State var canShowListProgresser = false
    @Binding var show: Bool
    @ObservedObject var themeController: ThemeController
    var mainBody : some View{
        ZStack{
            
            VStack {
                ZStack {
                    HStack  {
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                selectedGroupChat = nil
                                show.toggle()
                                if isNewGroupChat {
                                    NewConversationMatchedGeometry = ""
                                    NewGroupChatMatchedGeometry = ""
                                }
                            }
                        }){
                            Image(systemName: "chevron.left")
                                .font(.title3.weight(.bold))
                                .padding(.bottom, 10)
                        } // BUTTON
                        .buttonStyle(.borderless)
                        Spacer()
                        ZStack {
                            if isLargeScreen {
                                Circle()
                                    .frame(width: 43, height: 43)
                                //                                    .foregroundColor( friendsDictionary.friendsDictionary[id 2]?.profileCircle)
                                //                                .foregroundColor(Color.mainColor)
//                                    .background(Color.softWhite)
                                    .foregroundColor(themeController.theme.secondary.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            Button(action: {
                                GroupChatInfoMatchedGeometry = "0"
                                hideKeyboard()
                            }){
                                ChatGroupProfileImage(chatModel: allMessages.chatModel)
                            }  .buttonStyle(.borderless)
                        } // BUTTON
                    } // HSTACK
                    .padding(.bottom, 10)
                    VStack {
                        Text(allMessages.chatModel.groupName  )
                            .fontWeight(.bold)
                        Text("\(allMessages.chatModel.otherMembers.count) members")
                            .font(.caption)
                            .fontWeight(.light)
                    } // VSTACK
                } // ZSTACK
                .foregroundColor(Color.black)
                .padding(.horizontal)
                // Displaying Message
                messageList
                Spacer()
                ZStack (alignment: .bottom) {
                    VStack() {
                        selectedMediaView
                        expandingTextView
                    }
                    
                    HStack {
                        if allMessages.chatUID.isNotEmpty{
                            TypingIndicatorController(people: TypingIndicatorOO(type: .OpenedConversation, resourceID: allMessages.chatUID, authorID: ""), currentView: .OpenedConversation, themeController: themeController)
                                .padding(.leading, 20)
                                .animation(.easeInOut(duration: 0.3))
                        }
                        Spacer()
                        if selectedMedia?.newMedia == nil {
                            RecordNewAudioView(soundManager: soundManager, selectedMedia: $selectedMedia, isFromMessages: true, audioCommentAlert: .constant(false), buttonAlertType: .constant(.none), themeController: themeController)
                                .offset(x: message != "" || selectedMedia != nil ? 11 : 0)
                            
                        }
                        if selectedMedia?.audioUrl == nil && !soundManager.isRecording {
                            sendGifButton
                                .offset(x: message != "" || selectedMedia?.image != nil ? 11 : 0)
                            sendPhotoButton
                                .offset(x: message != "" || selectedMedia?.image != nil ? 11 : 0)
                        }
                    }
                    .offset(x: -16, y: -82 + keyboard.value)
                    .offset(y: iOS15 ? 0 : -screenHeight/45)
                    .offset(y: keyboard.value > 0 ? -keyboard.value : 0)
                    .offset(y: iOS15 ? 0 : 26)
                    
                }
                .padding(.bottom, isOpenFromProfile && iOS15 ? 30 : 0)
                .padding(.bottom, keyboard.bottomPadding > 0 ? iOS15 ? (keyboard.bottomPadding - 66) : keyboard.bottomPadding : keyboard.bottomPadding)
                .animation(.linear(duration: 0.2), value: keyboard.value)
            } // VStack, main container
            //#if os(iOS)
            //                .padding(.top, 60)
            //#endif
            if GroupChatInfoMatchedGeometry != "" {
                GroupChatInfoTabView(GroupChatInfoMatchedGeometry: $GroupChatInfoMatchedGeometry, selectedGroupChat: $selectedGroupChat, allMessages: allMessages, friendsDictionary: friendsDictionary, themeController: themeController)
                    .onAppear(perform: allMessages.removeViewInfo)
                    .onDisappear(perform: allMessages.setViewInfo)
                
            }
            if OpenedPhotoMatchedGeometry != "" {
                OpenPhotoTabView(OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, photo: OpenedPhotoSelectedItem, isFromTimeline: false)
            }
            if OpenedGIFMatchedGeometry != "" {
                OpenedGIFTabView(OpenedGIFMatchedGeometry: $OpenedGIFMatchedGeometry)
                
            }
        } // ZStack
        .padding(.top, iOS15 == true && iOS16 != true ? screenHeight < 870 ? 48 : 44 : 0)
        .padding(.top, iOS16 ? screenHeight < 930 ? 48 : 59 : 0)
        .padding(.top, iOS15 ? 0 : 48)
        .padding(.top, screenHeight < 740 ? -28 : 0)
        .edgesIgnoringSafeArea(.all)
        .onChange(of: isCurrentViewVisible, perform: stopAndDeleteRecordingIfAny)
        .background(themeController.theme.primary.ignoresSafeArea(.all))
        .animation(.linear(duration: 0.2), value: keyboard.value)
        .transition(.move(edge: .trailing))
        
    }
    var body: some View {
         mainBody
            .onChange(of: selectedMedia?.image, perform: onImageChange)
//            .padding(.top, isLargeScreen ? 0 : -10)
            .onReceive(allMessages.$dismissChat ) { dismissChat in
                if dismissChat {
                    selectedGroupChat = nil
                }
            }
    }
    
    var sendPhotoButton : some View {
        
        Circle()
            .foregroundColor(themeController.theme.messageList)
//            .foregroundColor(colorScheme == .light ? .softWhite : .backgroundColor)
            .frame(width: 46, height: 46)
            .shadow(color: .black.opacity(0.16), radius: 6, x: 0, y: 3)
            .overlay(
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundColor(.black)
            )
            .onTapGesture {
                ShowPhotoImagePicker = true
            }
            .presentMediaPicker(isPresented: $ShowPhotoImagePicker, selectedMedia: $selectedMedia,text: $message, parentView: .message)
        
    }
    
    var sendGifButton : some View {
        
        Circle()
            .foregroundColor(themeController.theme.messageList)
//            .foregroundColor(colorScheme == .light ? .softWhite : .backgroundColor)
            .frame(width: 46, height: 46)
            .shadow(color: .black.opacity(0.16), radius: 6, x: 0, y: 3)
            .overlay(
                Image("gifSticker")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            )
            .onTapGesture {
                isShowingGIFkeyboard = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if isShowingGIFkeyboard {
                        TypingIndicatorOO.isTypingInOCCloudFunc(
                            otherUsers: allMessages.allMemberIDs, chatUID: allMessages.chatUID)
                    } else {
                        if message.isEmpty && selectedMedia?.image == nil {
                            TypingIndicatorOO.isNotTypingInOCCloudFunc(
                                otherUsers: allMessages.allMemberIDs, chatUID: allMessages.chatUID)
                        }
                    }
                }
            }
            .popover(isPresented: $isShowingGIFkeyboard, content: {
                GIFController(url: $gifURL, present: $isShowingGIFkeyboard)
                    .offset(y: 35)
            })
    }
    
    var listFetchingProgresserView : some View {
        ZStack{
            if allMessages.canShowProgresser , canShowListProgresser  {
                HStack {
                    Spacer()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: themeController.theme.accent))
                        .padding(.trailing,10)
                    Spacer()
                }
                .animation( .spring())
            }
        }
    }
    
    var messageList : some View{
        ZStack {
            if #available(iOS 16.0, *) {
                VStack {
//                    if !allMessages.messages.isEmpty  {
                        List() {
                            
                            ForEach(allMessages.sortedMessages, id: \.id) { item in
                                
                                ChatBubble(message: item,
                                           myMessage: item.sentBy,
                                           OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, OpenedGIFMatchedGeometry: $OpenedGIFMatchedGeometry,
                                           person: allMessages.allMembers[item.sentBy] ?? Person(id: item.sentBy),
                                           chatUID: allMessages.chatUID,
                                           senderWeblink : item.sentBy == currentUserID ? nil : allMessages.allMembers[item.sentBy]?.profilePicLink,
                                           isAGroupMessage: true, themeController: themeController)
                                .id(item.id)
                                .onAppear {
                                    allMessages.getNextPageIfNeeded(message: item)
                                }
                                .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
                                .scaleEffect(x: 1, y: -1, anchor: .center)
                                .environmentObject(allMessages)
                                .listRowBackground(Color.clear)
                            }
                            
//                            listFetchingProgresserView
                        }
                        .background(themeController.theme.messageList.cornerRadius(25, corners: [.bottomLeft, .bottomRight]))
                        .padding(.top, -8)
                        .scrollContentBackground(.hidden)
                        .scrollDismissesKeyboard(.interactively)
//                        .padding(.leading,-15)
                        .scaleEffect(x: 1, y: -1, anchor: .center)
                        .onAppear() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                if   allMessages.messages.isNotEmpty == true {
                                    self.list?.scrollToBottom()
                                    //                                    self.list?.scrollToRow(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
                                }
                            }
                        }
                        .onChange(of: allMessages.goToBottom) { (value) in
                            DispatchQueue.main.async {
                                if   allMessages.messages.isNotEmpty == true {
                                    self.list?.scrollToBottom()
                                    //                                    self.list?.scrollToRow(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
                                }
                            }
                        }
                    }
//                .background(themeController.theme.messageList.cornerRadius(25, corners: [.topLeft, .bottomRight]))
////                .background((colorScheme == .light ? Color.softWhite : Color.accent).cornerRadius(25, corners: [.topLeft, .topRight]))
//                .padding(.top, -8)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.canShowListProgresser = true
                    }
                }
            } else {
                VStack {
//                    if !allMessages.messages.isEmpty  {
                        List() {
                            
                            ForEach(allMessages.sortedMessages, id: \.id) { item in
                                
                                ChatBubble(message: item,
                                           myMessage: item.sentBy,
                                           OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, OpenedGIFMatchedGeometry: $OpenedGIFMatchedGeometry,
                                           person: allMessages.allMembers[item.sentBy] ?? Person(id: item.sentBy),
                                           chatUID: allMessages.chatUID,
                                           senderWeblink : item.sentBy == currentUserID ? nil : allMessages.allMembers[item.sentBy]?.profilePicLink,
                                           isAGroupMessage: true, themeController: themeController)
                                .id(item.id)
                                .onAppear {
                                    allMessages.getNextPageIfNeeded(message: item)
                                }
                                .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
                                .scaleEffect(x: 1, y: -1, anchor: .center)
                                .environmentObject(allMessages)
                            }
                            
                            listFetchingProgresserView
                        }
//                        .background((colorScheme == .light ? Color.softWhite : Color.accent).cornerRadius(25, corners: [.bottomLeft, .bottomRight]))
                        .background(themeController.theme.messageList.cornerRadius(25, corners: [.bottomLeft, .bottomRight]))
                            .padding(.top, -8)
                        .scaleEffect(x: 1, y: -1, anchor: .center)
                        .listStyle(SidebarListStyle())
                        
                        .introspectTableView(customize: { list in
                            if self.list == nil {
                                self.list = list
        #if os(iOS)
                                list.allowsSelection = false
                                list.selectionFollowsFocus = false
                                list.keyboardDismissMode = .interactive
        #endif
                            }
                        })
                        .onAppear() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                if   allMessages.messages.isNotEmpty == true {
                                    self.list?.scrollToBottom()
                                    //                                    self.list?.scrollToRow(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
                                }
                            }
                        }
                        .onChange(of: allMessages.goToBottom) { (value) in
                            DispatchQueue.main.async {
                                if   allMessages.messages.isNotEmpty == true {
                                    self.list?.scrollToBottom()
                                    //                                    self.list?.scrollToRow(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
                                }
                            }
                        }
                    }

                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.canShowListProgresser = true
                    }
                }
            }
    }
}
       
    func unselectMedia(){
        withAnimation {
        selectedMedia?.deleteCacheOfSelectedMediaIfAny()
        selectedMedia = nil
        }
    }
    var selectedMediaView: some View{
        ZStack{
        if let _ = selectedMedia?.audioUrl {
            RecordedAudioView(newMedia: $selectedMedia,soundManager: soundManager, isFromMessages: true, themeController: themeController)
//                .background(colorScheme == .light ? Color.softWhite : Color.accent)
                .background(themeController.theme.messageList)
        }else{
                    (selectedMedia?.image).map  { image in
                    HStack {
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 105, height: 120)
                                .shadow(radius: 5, x: 0, y: -1)
                                .shadow(radius: 5, x: 0, y: 1)
                                .clipShape(Rectangle())
                                .cornerRadius(10)
                                .padding(.leading, 8)
                            Button(action: unselectMedia) {
                                Image(systemName: "clear")
                                    .foregroundColor(Color.speakerPink.opacity(1))
                            }  .buttonStyle(.borderless)
                                .padding(.leading, 95)
                                .padding(.bottom, 95)
                        }
                        Spacer()
                    }
                .frame(height: 125)
//                .background(colorScheme == .light ? Color.softWhite : Color.accent)
                .background(themeController.theme.messageList)
            }
        }
        }
    }
    
    func sendMessage(isGIF: Bool = false) {
         
        guard let userId = currentUserID else{
            return
        }
        let nameOfSendingUser = friendsDictionary.friendsDictionary[userId]?.name ?? ""
        let chatID =  allMessages.chatUID
         
        let messageModelRaw = MessageModel.Raw(sentBy: userId,
                                               message: isGIF ? gifURL : message.trimWhitespacesAndNewlines(),
                                               chatUID: chatID,
                                               otherUserID: "",
                                               token: "",
                                               nameOfSendingUser: nameOfSendingUser,
                                               newMedia: isGIF ? nil : selectedMedia?.newMedia,
                                               isGIF: isGIF,
                                               groupName: allMessages.chatModel.groupName,
                                               audioDirURL: isGIF ? nil : selectedMedia?.audioUrl)
        allMessages.sendNewMessage(messageRaw: messageModelRaw)
        if isGIF{
            TypingIndicatorOO.isNotTypingInOCCloudFunc(otherUsers: allMessages.allMemberIDs, chatUID: allMessages.chatUID)
        }else{
            message = ""
            selectedMedia = nil
        }
    }
    var expandingTextView : some View {
        VStack (spacing: 16) {
//            if newMedia?.image == nil {
//            if selectedMedia == nil{
                Rectangle()
                    .frame(width: screenWidth, height: 5)
                    .foregroundColor(Color.mainColorInverse)
//            }
            ZStack {
             
                HStack(alignment: .bottom, spacing: 0) {
                HStack(spacing: 15) {
                    ZStack {
                    HStack  {
    //                          TextField("Message", text: $message)
                        ZStack {
                            if message.isEmpty {

                                TextField("Message",text :  $message)
                                    .foregroundColor(Color.gray)
                                    .padding(.leading,12)
                                    .animation(.none)
                                    .opacity(soundManager.isRecording ? 0 : 1)
                            }
                            ExpandingTextView(text: $message, maxHeight: $textViewMaxHeight, isFirstResponder: false)
                            .background(Color.clear)
                        .padding(.leading, 8)
                        .padding(.vertical, 10)
                        .opacity(soundManager.isRecording ? 0 : 1)
                        .onChange(of: gifURL, perform: { value in
                            sendMessage(isGIF: true)
//                            var friendsDict : [String : Person]  {
//                               return friendsDictionary.friendsDictionary
//                            }
//
//                            guard let userId = Auth.auth().currentUser?.uid else{
//                                return
//                            }
//                            let nameOfSendingUser = friendsDictionary.friendsDictionary[userId]?.name ?? ""
//                            let chatID =   allMessages.chatUID
//                            let messageModelRaw = MessageModel. Raw(sentBy: userId,
//                                                                   message: gifURL,
//                                                                   chatUID: chatID,
//                                                                   otherUserID: "",
//                                                                   token: "",
//                                                                   nameOfSendingUser: nameOfSendingUser,
//                                                                   newMedia: newMedia?.newMedia,
//                                                                   isGIF: true, groupName: allMessages.chatModel.groupName)
//                            allMessages.sendNewMessage(messageRaw: messageModelRaw)
//                            TypingIndicatorOO.isNotTypingInOCCloudFunc(
//                                otherUsers: allMessages.allMemberIDs, chatUID: allMessages.chatUID)
                          
                        })

                        .onReceive(Just(message)) { content in
                            if content.isNotEmpty {
                                if isTyping == false {
                                    TypingIndicatorOO.isTypingInOCCloudFunc(
                                        otherUsers: allMessages.allMemberIDs, chatUID: allMessages.chatUID)
                                }
                                isTyping = true
                            } else {
                                if isTyping == true {
                                    TypingIndicatorOO.isNotTypingInOCCloudFunc(
                                        otherUsers: allMessages.allMemberIDs, chatUID: allMessages.chatUID)
                                    isTyping.toggle()
                                } else {
                                    isTyping = false
                                }
                            }
                        }
    //                        .background(Color.speakerPurple.opacity(0.2))

                    }
    //                    .padding(.vertical, 10)
//                        .background(soundManager.isRecording ? Color.mainColorInverse.opacity(0.001) : colorScheme == .light ? Color.mainColorInverse.opacity(0.6) : Color.backgroundColor)
                        .background(soundManager.isRecording ? Color.mainColorInverse.opacity(0.001) : themeController.theme.primary)
                    }
                        if soundManager.isRecording {
                                Audio(soundManager: soundManager)
                                    .frame(width: screenWidth - 21, height: 54)
//                                    .background(Color.softWhite)
                                    .background(themeController.theme.messageList)
                        }
                }
                } // HSTACK
                .clipShape(ChatBubbleShape(direction: .right))
                .padding(.trailing, 16)
                .padding(.leading, 5)
                    if  soundManager.isRecording == false, message.isNotEmpty || selectedMedia != nil  {

                    Button(action: {
                        if message != "" || selectedMedia != nil {
                            sendMessage()
                    }
                    }){
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color.mainColor)
                            // Rotating paperplane
                            .rotationEffect(.init(degrees: 45))
                            // Padding Shape
                            .padding(.vertical, 10)
                            .padding(.leading, 12)
                            .padding(.trailing, 17)
//                            .background(colorScheme == .light ? Color.mainColorInverse.opacity(0.6) : Color.backgroundColor)
                            .background(themeController.theme.messageList)
                            .clipShape(Circle())
                    } // BUTTON
                    .padding(.leading, -18)
                }
            } // HSTACK

            }
            .offset(y: -8)
        }
//        .background((colorScheme == .light ? Color.softWhite : Color.accent)
        .background((themeController.theme.messageList)
            .ignoresSafeArea(.all))
        .padding(.top, -8)
    }
    
    ///this one is the  large

     
    var isCurrentViewVisible: Bool {
        GroupChatInfoMatchedGeometry.isEmpty &&
        OpenedPhotoMatchedGeometry.isEmpty &&
        OpenedGIFMatchedGeometry.isEmpty &&
        !ShowPhotoImagePicker &&
        !isShowingGIFkeyboard 
    }
    
    func stopAndDeleteRecordingIfAny(isCurrentViewVisible: Bool){
        if isCurrentViewVisible == false {
            if soundManager.isRecording {
                soundManager.stopAndDelete()
            }
        }
    }
    

    func onImageChange( _ image : UIImage?){
        var newHeight = (image == nil) ? (expandableTextViewMaxHeight) : (expandableTextViewMaxHeight - 150)
        newHeight = newHeight < 50 ? 50 : newHeight
        self.textViewMaxHeight = newHeight
        ///so we can reload the ExpandableTextView
        if message.isNotEmpty {
            message = " " + message
            self.message.removeFirst()
        }
    }
    
    let expandableTextViewMaxHeight : CGFloat = screenHeight*0.2 + 150
    let isLargeScreen = screenHeight > 800
}
   
struct OpenedGroupConversationTabView: View {
    @Binding var selectedGroupChat : ChatModel?
    @State private var selectedTab = "NewConversation"
    @EnvironmentObject var allChats : AllMessagesOO
    @State var isNewGroupChat = false
    @Binding var NewGroupChatMatchedGeometry: String
    @Binding var NewConversationMatchedGeometry: String
    var addPNListener : Bool = true
    var body: some View {
        if selectedTab == "NewConversation" , let chatModel = selectedGroupChat {
            ZStack {
                let openedConversation =
                OpenedGroupConversation(selectedGroupChat : $selectedGroupChat,
                                        allMessages: OpenedGroupConversationOO(groupDetail: allChats.groupDetailOf(chatModel),
                                                                               addPNListener: addPNListener),
                                        isNewGroupChat: isNewGroupChat,
                                        NewGroupChatMatchedGeometry: $NewGroupChatMatchedGeometry,
                                        NewConversationMatchedGeometry: $NewConversationMatchedGeometry, show: .constant(false), themeController: ThemeController())
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("none")
                    openedConversation
                        .tag("NewConversation")
                        .padding(.top, iOS15 ? (screenHeight > 800 ? 10 : 30) :  60)
                       

                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
#elseif os(macOS)
              openedConversation
                .padding(.top,10)
#endif
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear {
                selectedGroupChat = nil
                    if isNewGroupChat {
                        NewConversationMatchedGeometry = ""
                        NewGroupChatMatchedGeometry = ""
                    }
            }
        }
        
    }
}
 
