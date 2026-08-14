//
//  OpenedConversation.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/19/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Combine
import Introspect
 /*
 the progresser we add we will just add it in the chat bubble so we can use it for every kind of message.
 for the reset we can just follow the same logic as the post's
 */

struct OpenedConversation: View {
    @Binding var OpenedConversationMatchedGeometry: String
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @StateObject var allMessages : OpenedConversationOO
    //    @StateObject var userChats = AllMessagesOO()
    @ObservedObject var allChats : AllMessagesOO
    
    @State var id2: String
    @State var message = ""
    @State var textHeight: CGFloat = 0
    @StateObject var keyboard = KeyboardViewModel()
    @StateObject var functions = SendMessageFunctions()
    @State var OpenedPhotoSelectedItem: URL?
    @State var OpenedPhotoMatchedGeometry: String = ""
    @State var OpenedGIFMatchedGeometry: String = ""
    @State var selectedMedia: SelectedMedia?
    @State var ShowPhotoImagePicker = false
    @State var FriendProfileMatchedGeometry = ""
    @Environment(\.colorScheme) var colorScheme
    @State var list: UITableView?
    @State var textViewMaxHeight: CGFloat = 200
    @State var isOpenFromProfile = false
    @State var emptyStringBinding = ""
    @State var isFromOpenedMoment: Bool
    @State var isTyping = false
    @State var isShowingGIFkeyboard = false
    @State var gifURL: String = ""
    @StateObject var soundManager = SoundManager()
    @State var playRecording = false
    @State var canShowListProgresser = false
    @State var isFirstResponder = true
    @Binding var show: Bool
    @ObservedObject var themeController: ThemeController
    @EnvironmentObject var currentTab: CurrentTab
    var mainBody : some View {
        ZStack{
            VStack(spacing: 0) {
                ZStack {
                    HStack  {
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                OpenedConversationMatchedGeometry = ""
                                show.toggle()
                                currentTab.showConversation = false
                            }
                        }){
                            Image(systemName: "chevron.left")
                                .font(.title3.weight(.bold))
                                .padding(.bottom, 10)
                        } // BUTTON
                        .buttonStyle(.borderless)
                        Spacer()
                        ZStack {
                            Circle()
                                .frame(width: 43, height: 43)
                                .foregroundColor(friendsDictionary.friendsDictionary[id2]?.profileCircle)
                            //                                .foregroundColor(Color.mainColor)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                                .clipShape(Circle())
                            Button(action: {
                                FriendProfileMatchedGeometry = id2
                                hideKeyboard()
                            }){
                                
                                WebImage(url: friendsDictionary.friendsDictionary[id2]?.profilePicLink)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .background(Color.lightGray)
                                    .clipShape(Circle())
                            }  .buttonStyle(.borderless)
                        } // BUTTON
                    } // HSTACK
                    .padding(.bottom, 10)
                    VStack {
                        Text(friendsDictionary.friendsDictionary[id2]?.name ?? "")
                            .fontWeight(.bold)
                        Text(friendsDictionary.friendsDictionary[id2]?.username ?? "")
                            .font(.caption)
                            .fontWeight(.light)
                    } // VSTACK
                } // ZSTACK
                .foregroundColor(Color.black)
                .padding(.horizontal)
                //                .padding(.bottom, 10)
                //                .padding(.top, isLargeScreen ? 0 : 16)
                //                .animation(.spring())  // for keyboard
                // Displaying Message
//                ZStack (alignment: .topLeading) {
                messageList
//            }
                Spacer()
                ZStack (alignment: .bottom) {
                    VStack() {
                        selectedMediaView
                        expandingTextView
                    }
//                    .padding(.bottom, keyboard.bottomPadding)
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
//                .padding(.bottom, isOpenFromProfile && iOS15 ? 30 : 0)
                .padding(.bottom, keyboard.bottomPadding > 0 ? iOS15 ? (keyboard.bottomPadding - 66) : keyboard.bottomPadding : keyboard.bottomPadding)
                .animation(.linear(duration: 0.2), value: keyboard.value)
            } // VStack, main container
            //#if os(iOS)
            ////                .padding(.top, screenHeight > 800 ? 60 : 10)
            //
            //#endif
            
            friendProfileView
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
        ////                    .padding(.top, -60)
        //#endif
        
    }
    var body: some View {
        ZStack{
            
            mainBody
                .onAppear {
                    print("screenHeight = \(screenHeight)")
                }
//                .padding(.top, isLargeScreen ? 0 : -10)
        }.onChange(of: selectedMedia?.image) { image in
            var newHeight = (image == nil) ? (expandableTextViewMaxHeight) : (expandableTextViewMaxHeight - 150)
            newHeight = newHeight < 50 ? 50 : newHeight
            self.textViewMaxHeight = newHeight
            ///so we can reload the ExpandableTextView
            if message.isNotEmpty {
                message = " " + message
                self.message.removeFirst()
            }
        }
        .onChange(of: friendsDictionary.friendsDictionary[id2]?.id) { friendId in
            if friendId == nil {
                OpenedConversationMatchedGeometry = ""
            }
        }
        //        .padding(.top, iOS15 ? (screenHeight > 800 ? 0 : 30) : 0 )
        .onChange(of: allMessages.dismissChat) { dismissChat in
            if dismissChat {
                OpenedConversationMatchedGeometry.removeAll()
            }
        }
    }
    var sendPhotoButton : some View {
        
        Circle()
//            .foregroundColor(colorScheme == .light ? .softWhite : .backgroundColor)
            .foregroundColor(themeController.theme.messageList)
            .frame(width: 46, height: 46)
            .shadow(color: .black.opacity(0.16), radius: 6, x: 0, y: 3)
            .overlay(
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundColor(.black)
            )
            .onTapGesture {
                ShowPhotoImagePicker = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if ShowPhotoImagePicker {
                        TypingIndicatorOO.isTypingInOCCloudFunc(
                            otherUsers: [id2], chatUID: allMessages.chatUID)
                    } else {
                        if message == "" && selectedMedia?.image == nil {
                            TypingIndicatorOO.isNotTypingInOCCloudFunc(
                                otherUsers: [id2], chatUID: allMessages.chatUID)
                        }
                    }
                }
            }
            .presentMediaPicker(isPresented: $ShowPhotoImagePicker, selectedMedia: $selectedMedia,text: $message, parentView: .message)
    }
    
    var sendGifButton : some View {
        
        Circle()
//            .foregroundColor(colorScheme == .light ? .softWhite : .backgroundColor)
            .foregroundColor(themeController.theme.messageList)
            .shadow(color: .black.opacity(0.16), radius: 6, x: 0, y: 3)
            .frame(width: 46, height: 46)
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
                            otherUsers: [id2], chatUID: allMessages.chatUID)
                    } else {
                        if message.isEmpty && selectedMedia?.image == nil {
                            TypingIndicatorOO.isNotTypingInOCCloudFunc(
                                otherUsers: [id2], chatUID: allMessages.chatUID)
                        }
                    }
                }
            }
            .popover(isPresented: $isShowingGIFkeyboard, content: {
                GIFController(url: $gifURL, present: $isShowingGIFkeyboard)
                    .offset(y: 35)
            })
    }
    
    var selectedMediaView: some View{
        ZStack{
            if let _ = selectedMedia?.audioUrl {
                RecordedAudioView(newMedia: $selectedMedia,soundManager: soundManager, isFromMessages: true, themeController: themeController)
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
//                    .background(colorScheme == .light ? Color.softWhite : Color.accent)
                    .background(themeController.theme.messageList)
                }
            }
        }
    }
    
    var listFetchingProgresserView : some View {
        ZStack{
            if allMessages.canShowProgresser , canShowListProgresser  {
                HStack {
                    Spacer()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.speakerPurple))
                        .padding(.trailing,10)
                    Spacer()
                }
//                .animation( .spring())
            }
        }
    }
    
    var messageList : some View{
        ZStack {
            if #available(iOS 16.0, *) {
//        VStack {
//            if !allMessages.messages.isEmpty  {
                List() {
                    
                    ForEach(allMessages.sortedMessages, id: \.id) { item in
                        let person = friendsDictionary.friendsDictionary[id2] ?? Person(id: id2)
                        
                        ChatBubble(message: item,
                                   myMessage: item.sentBy,
                                   OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry,
                                   OpenedGIFMatchedGeometry: $OpenedGIFMatchedGeometry, person: person ,
                                   chatUID: allMessages.chatUID,
                                   senderWeblink : item.sentBy == currentUserID ? nil : person.profilePicLink, themeController: themeController)
                        .id(item.id)
                        .onAppear {
                            allMessages.getNextPageIfNeeded(message: item)
                        }
                        .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
                        .scaleEffect(x: 1, y: -1, anchor: .center)
                        .environmentObject(allMessages)
                        .listRowBackground(Color.clear)
                     
                    }
                }
                .background(themeController.theme.messageList.cornerRadius(25, corners: [.bottomLeft, .bottomRight]))
                    .padding(.top, -8)
                .scrollDismissesKeyboard(.interactively)
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
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.canShowListProgresser = true
                    }
                }
            } else {
                VStack (spacing: 0) {
//                    if !allMessages.messages.isEmpty  {
                        List() {
                            
                            ForEach(allMessages.sortedMessages, id: \.id) { item in
                                let person = friendsDictionary.friendsDictionary[id2] ?? Person(id: id2)
                                
                                ChatBubble(message: item,
                                           myMessage: item.sentBy,
                                           OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry,
                                           OpenedGIFMatchedGeometry: $OpenedGIFMatchedGeometry, person: person ,
                                           chatUID: allMessages.chatUID,
                                           senderWeblink : item.sentBy == currentUserID ? nil : person.profilePicLink, themeController: themeController)
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
                        .background(themeController.theme.messageList.cornerRadius(25, corners: [.bottomLeft, .bottomRight]))
//                        .background((colorScheme == .light ? Color.softWhite : Color.accent).cornerRadius(25, corners: [.bottomLeft, .bottomRight]))
                            .padding(.top, -8)
//                        .padding(.leading,-15)
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
//                    }
//                    else{
//                        Spacer()
//                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.canShowListProgresser = true
                    }
                }
            }
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
                        .onChange(of: gifURL){ _ in
                            sendMessage(isGIF: true)
                        }
                        .onReceive(Just(message)) { content in
                            if content.isNotEmpty {
                                if isTyping == false {
                                    TypingIndicatorOO.isTypingInOCCloudFunc(
                                        otherUsers: [id2], chatUID: allMessages.chatUID)
                                }
                                isTyping = true
                            } else {
                                if isTyping == true {
                                    TypingIndicatorOO.isNotTypingInOCCloudFunc(
                                        otherUsers: [id2], chatUID: allMessages.chatUID)
                                    isTyping.toggle()
                                } else {
                                    isTyping = false
                                }
                            }
                        }
                        

                    }

                        .background(soundManager.isRecording ? Color.mainColorInverse.opacity(0.001) : themeController.theme.primary)
                    }
                        if soundManager.isRecording {
                                Audio(soundManager: soundManager)
                                    .frame(width: screenWidth - 21, height: 54)
                                    .background(Color.mainColorInverse.opacity(0.6))
                        }
                }
                } // HSTACK
                .clipShape(ChatBubbleShape(direction: .right))
                .padding(.trailing, 16)
                .padding(.leading, 5)
                if  soundManager.isRecording == false, message.isNotEmpty || selectedMedia != nil  {
                    Button(action: {
                        sendMessage() 
                    }){
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color.black)
                            // Rotating paperplane
                            .rotationEffect(.init(degrees: 45))
                            // Padding Shape
                            .padding(.vertical, 10)
                            .padding(.leading, 12)
                            .padding(.trailing, 17)
                            .background(themeController.theme.messageList)
                            .clipShape(Circle())
                    } // BUTTON
                    .padding(.leading, -18)
                }
            } // HSTACK

            }

            .offset(y: -8)
//            .padding(.bottom, -5)
//            .padding(.top, 15)
//            .padding(.bottom, iOS15 ? 0 : 60)
//            .padding(.bottom, iOS15 && screenHeight > 800 ? -30: 0)
//            .ignoresSafeArea(.keyboard)
        }
//        .background((colorScheme == .light ? Color.softWhite : Color.accent)
//            .ignoresSafeArea(.all))
        .background(themeController.theme.messageList
                  .ignoresSafeArea(.all))
        .padding(.top, -8)
    }
    
    func sendMessage(isGIF: Bool = false) {
        var friendsDict : [String : Person]  {
            return friendsDictionary.friendsDictionary
        }
        
        guard let userId = currentUserID else{
            return
        }
        let chatID =   allMessages.chatUID
        let messageModelRaw = MessageModel.Raw(sentBy: userId,
                                               message:  isGIF ? gifURL : message.trimWhitespacesAndNewlines(),
                                               chatUID: chatID,
                                               otherUserID: id2,
                                               token: friendsDict[id2]?.token ?? "",
                                               nameOfSendingUser: friendsDict[userId]?.name ?? "",
                                               newMedia: isGIF ? nil : selectedMedia?.newMedia,
                                               isGIF: isGIF,
                                               audioDirURL: isGIF ? nil : selectedMedia?.audioUrl)
        allMessages.sendNewMessage(messageRaw: messageModelRaw)
        if isGIF{
            TypingIndicatorOO.isNotTypingInOCCloudFunc(otherUsers: [id2], chatUID: allMessages.chatUID)
        }else{
            message = ""
            selectedMedia = nil
        }
    }
    

    
    func unselectMedia(){
        withAnimation {
        selectedMedia?.deleteCacheOfSelectedMediaIfAny()
        selectedMedia = nil
        }
    }
    
    var friendProfileView : some View {
       (FriendProfileMatchedGeometry.isNotEmpty ? FriendProfileMatchedGeometry : nil)
            .map {
                FriendProfileOpenedConversationTabView(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: $0, CloseOpenConversationFromProfile: $OpenedConversationMatchedGeometry, themeController: themeController)
                .onAppear(perform: allMessages.removeViewInfo)
                .onDisappear(perform: allMessages.setViewInfo)
            }
    }
    

    var isCurrentViewVisible: Bool {
        FriendProfileMatchedGeometry.isEmpty &&
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
    

   let isLargeScreen = screenHeight > 800
    let expandableTextViewMaxHeight : CGFloat = screenHeight*0.2 + 150
}
   
struct OpenedConversationTabView: View {
    @Binding var OpenedConversationMatchedGeometry: String
    @State var selectedTab = "NewConversation"
    @State var id: String
    @State var emptyStringBinding = ""
    @EnvironmentObject var allChats : AllMessagesOO
 
    var addPNListener : Bool = true
     
    @State var isFromOpenedMoment = false
    @State var isFirstResponder = true
    var body: some View {
        if selectedTab == "NewConversation" {
            ZStack {
                let openedConversation = OpenedConversation(OpenedConversationMatchedGeometry: $OpenedConversationMatchedGeometry, allMessages: OpenedConversationOO(otherUserID: id) , allChats: allChats, id2: id, isFromOpenedMoment: isFromOpenedMoment, isFirstResponder: isFirstResponder, show: .constant(false), themeController: ThemeController())
 
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("none")
                    openedConversation
                        .tag("NewConversation")
                        .padding(.top, iOS15 ? 10 : 60)
                    
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
                    .onAppear() {
                        OpenedConversationMatchedGeometry = ""
                    } 
        }
        
    }
}

 
 
