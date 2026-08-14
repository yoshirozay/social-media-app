//
//  AllMessages.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/19/21.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI
import Firebase
import FirebaseAuth

import Combine
 

struct AllMessages: View {
    @Namespace var namespace
    @State var OpenedConversationMatchedGeometry = ""
    @State var OpenedConversationMatchedGeometry2 = ""
    @State var NewConversationMatchedGeometry = ""
    
    @State var selectedGroupChat : ChatModel?
    @Binding var AllMessagesMatchedGeometry: String
//    @StateObject var messages = AllMessagesOO()
    @ObservedObject var allChats : AllMessagesOO
    @StateObject var readMessageFunction = ReadMessageFunctions()
    @Binding var selectedTab: String
    @State var ShowPhotoImagePicker = false
    @State var newMedia: NewMedia? 
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @State var isFromArcMenu = false
    @State var emptyStringBinding = ""
    @Environment(\.colorScheme) var colorScheme
    @State var NewGroupChatMatchedGeometry: String = ""
    @State var show = false
    @ObservedObject var currentTab: CurrentTab
    @ObservedObject var pushNotificationVM : PushNotificationVM
    @AppStorage("messagesCameraAlert") var messagesCameraAlert : Bool = false
    @State var buttonAlertType: ButtonAlertType = .none
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {

        mainBody
//            (pushNotificationVM.didSet ? Color.red : Color.blue)
//                .onDisappear {
//                    NewConversationMatchedGeometry = ""
//                    NewGroupChatMatchedGeometry = ""
//                    selectedGroupChat = nil
//                }
                .fullSwipePop(show: $currentTab.showConversation) {
                    ZStack {
                        OpenedConversation(OpenedConversationMatchedGeometry: $currentTab.friendID, allMessages: OpenedConversationOO(otherUserID: currentTab.friendID) , allChats: allChats, id2: currentTab.friendID, isFromOpenedMoment: false, isFirstResponder: false, show: $currentTab.showConversation, themeController: themeController)
                    }
                }
                .fullSwipePop(show: $show) {
                    ZStack {
                        if NewConversationMatchedGeometry != "" {
                            //                            || pushNotificationVM.otherUserID.isNotEmpty {
                            //                            let NewConversationMatchedGeometry = pushNotificationVM.otherUserID
                            //                            if let id = pushNotificationVM.otherUserID {
                            //                                otherID = id
                            //                            }
                            NewConversation(NewConversationMatchedGeometry: $NewConversationMatchedGeometry, messages: allChats, show: $show, themeController: themeController)
                                .onDisappear() {
                                    if currentTab.currentTab == "message" {
                                        NewConversationMatchedGeometry = ""
                                    }
                                }
                        }  else if NewGroupChatMatchedGeometry != "" {
                            NewGroupChat(NewGroupChatMatchedGeometry: $NewGroupChatMatchedGeometry, NewConversationMatchedGeometry: $NewConversationMatchedGeometry, show: $show, allChats: allChats, selectedGroupChat: $selectedGroupChat, themeController: themeController)
                                .onDisappear() {
                                    if currentTab.currentTab == "message" {
                                        NewGroupChatMatchedGeometry = ""
                                        //                                        selectedGroupChat = nil
                                    }
                                }
                        } else if selectedGroupChat != nil {
                            OpenedGroupConversation(selectedGroupChat : $selectedGroupChat,
                                                    allMessages: OpenedGroupConversationOO(groupDetail: allChats.groupDetailOf(selectedGroupChat ?? ChatModel(chatUID: "", isAGroup: true, members: [Person(id: "")], lastMessage: MessageModel(id: "", sentBy: "", time: Timestamp(), message: "", timeString: "", chatID: "", isDummy: false), time: Date())),
                                                                        
                                                                                           addPNListener: true),
                                                    isNewGroupChat: false,
                                                    NewGroupChatMatchedGeometry: $NewGroupChatMatchedGeometry,
                                                    NewConversationMatchedGeometry: $NewConversationMatchedGeometry, show: $show, themeController: themeController)
                            .onDisappear() {
                                if currentTab.currentTab == "message" {
                                    selectedGroupChat = nil
                                }
                            }
                        } else if pushNotificationVM.selectedGroupChat != nil {
                            OpenedGroupConversation(selectedGroupChat : $pushNotificationVM.selectedGroupChat,
                                                    allMessages: OpenedGroupConversationOO(groupDetail: allChats.groupDetailOf(pushNotificationVM.selectedGroupChat ?? ChatModel(chatUID: "", isAGroup: true, members: [Person(id: "")], lastMessage: MessageModel(id: "", sentBy: "", time: Timestamp(), message: "", timeString: "", chatID: "", isDummy: false), time: Date())),
                                                                                           addPNListener: true),
                                                    isNewGroupChat: false,
                                                    NewGroupChatMatchedGeometry: $NewGroupChatMatchedGeometry,
                                                    NewConversationMatchedGeometry: $NewConversationMatchedGeometry, show: $show, themeController: themeController)
                            .onDisappear() {
                                if currentTab.currentTab == "message" {
                                    pushNotificationVM.clearConversations()
                                    
                                    print("HELLO 2")
                                }
                            }
                        } else if OpenedConversationMatchedGeometry != "" {
                            OpenedConversation(OpenedConversationMatchedGeometry: $OpenedConversationMatchedGeometry, allMessages: OpenedConversationOO(otherUserID: OpenedConversationMatchedGeometry) , allChats: allChats, id2: OpenedConversationMatchedGeometry, isFromOpenedMoment: false, isFirstResponder: false, show: $show, themeController: themeController)
                        } else if pushNotificationVM.otherUserID.isNotEmpty {
                            OpenedConversation(OpenedConversationMatchedGeometry: $pushNotificationVM.otherUserID, allMessages: OpenedConversationOO(otherUserID: pushNotificationVM.otherUserID) , allChats: allChats, id2: pushNotificationVM.otherUserID, isFromOpenedMoment: false, isFirstResponder: false, show: $show, themeController: themeController)
                                .id(pushNotificationVM.otherUserID)
                                .zIndex(pushNotificationVM.zIndex(.newPrivateMessage))
                                .onDisappear() {
                                    if currentTab.currentTab == "message" {
                                        pushNotificationVM.clearConversations()
                                        print("OTHER USER2 = \(pushNotificationVM.otherUserID)")
                                        print("HELLO 3")
                                    }
                                }
                        }
//                        pushNotificationVM.selectedGroupChat.map { chatModel in
//                            OpenedGroupConversation(selectedGroupChat : $pushNotificationVM.selectedGroupChat,
//                                                    allMessages: OpenedGroupConversationOO(groupDetail: allChats.groupDetailOf(pushNotificationVM.selectedGroupChat ?? ChatModel(chatUID: "", isAGroup: true, members: [Person(id: "")], lastMessage: MessageModel(id: "", sentBy: "", time: Timestamp(), message: "", timeString: "", chatID: "", isDummy: false), time: Date())),
//                                                                                           addPNListener: true),
//                                                    isNewGroupChat: false,
//                                                    NewGroupChatMatchedGeometry: $NewGroupChatMatchedGeometry,
//                                                    NewConversationMatchedGeometry: $NewConversationMatchedGeometry, show: $show)
//                            .onDisappear() {
//                                if currentTab.currentTab == "message" {
//                                    pushNotificationVM.otherUserID = ""
//                                    pushNotificationVM.selectedGroupChat = nil
//                                    pushNotificationVM.notificationTrigger = nil
//                                }
//                            }
//
//                        }

                    }
                }

    }
//#if os(iOS)
//        .padding(.top, -60)
//#endif
        .frame(width: screenWidth, height: screenHeight-66, alignment: .top)
        .onReceive(pushNotificationVM.$notificationTrigger) { trigger in
            if let trigger: NotificationViewTrigger = trigger {
                    switch pushNotificationVM.isFromBannerNotification {
                    case true:
                        if trigger.type == .message || trigger.type == .groupMessage {
                            if pushNotificationVM.selectedGroupChat != nil || pushNotificationVM.otherUserID != "" {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    if currentTab.currentTab == "message" {
                                        withAnimation {
                                            show = true
                                        }
                                    } else {
                                        show = true
                                    }
                                }
                            }
                        }
                    case false :
                        if trigger.type == .message || trigger.type == .groupMessage {
                            if pushNotificationVM.selectedGroupChat != nil || pushNotificationVM.otherUserID != "" {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                                    if currentTab.currentTab == "message" {
                                        withAnimation {
                                            show = true
                                            pushNotificationVM.tapFromBannerNotification()
                                        }
                                    } else {
                                        show = true
                                        pushNotificationVM.tapFromBannerNotification()
                                    }
                                }
                            }
                        }
                    }

            }
        }
        
    }
    var chatScrollView: some View{
        
        ScrollView() {
            if allChats.sortedChats.isNotEmpty {
            LazyVStack(spacing: 16) {
                ForEach(allChats.sortedChats , id: \.self) { chatModel in
                    let item = chatModel.lastMessage
                    if chatModel.isAGroup == false, let item = item {
                        //                    ForEach(allChats.allMessages , id: \.self) { item in
                        if let friend = friendsDictionary.friendsDictionary[item.otherUserID] {
                            IndividualMessage(message: item, userChatInfo: $allChats.userChatInfo, friend: friend, isFromAllMessages: true, people: TypingIndicatorOO(type: .OpenedConversation, resourceID: item.chatID, authorID: ""), themeController: themeController)
                                .matchedGeometryEffect(id: UUID(), in: namespace, isSource: false)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    readMessageFunction.readMessage(chatUID: item.id)
                                    withAnimation {
                                        OpenedConversationMatchedGeometry = item.otherUserID
                                        show.toggle()
                                    }
                                }
                                .padding(.horizontal)
                            //                            Divider()
//                            Rectangle()
//                                .frame(width: screenWidth - 40, height: 2)
////                                .foregroundColor(themeController.theme.primary.opacity(0.6))
//                                .foregroundColor(Color.black.opacity(0.2))
                            Divider()
                        }
                        
                    }else{
                        GroupMessage(chatModel: chatModel, groupChatInfo: $allChats.groupChatInfo, isFromAllMessages: true, people: TypingIndicatorOO(type: .OpenedConversation, resourceID: chatModel.chatUID, authorID: ""), themeController: themeController)
                            .overlay(Color.green.opacity(0.0000001))
                            .onTapGesture {
                                withAnimation {
                                    selectedGroupChat = chatModel
                                    show.toggle()
                                }
                            }
                        Divider()
                        //                        Divider()
//                        Rectangle()
//                            .frame(width: screenWidth - 40, height: 2)
////                            .foregroundColor(themeController.theme.primary.opacity(0.6))
//                            .foregroundColor(Color.black.opacity(0.2))
                    }
                }
            }
            .background(themeController.theme.secondary
                .clipShape(RoundedRectangle(cornerRadius: 25))
                        //                            .padding(.horizontal, 10)
                .padding(.vertical, -18)
            )
            .padding(.top, 34)
        }
        }
    }
    var mainBody: some View {
        ZStack {

        VStack {

            HStack (spacing: 0) {
                TitleHeader(title: "Messages") {
//                  AllMessagesMatchedGeometry  = "house.fill"
                    currentTab.changeTab(tab: "house.fill")
                }
         
                Button(action: {
                    if messagesCameraAlert != false {
                        ShowPhotoImagePicker.toggle()
                    } else {
                        withAnimation {
                            hideKeyboard()
                            buttonAlertType = .messagesCamera
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                messagesCameraAlert = true
                            }
                        }
                    }
                }) {
                    Image("camera")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .offset(y: 2)
                }     .padding(.leading, 10)
                Spacer()
                Menu {
                    Button("Message", action: {
                        withAnimation() {
                            NewConversationMatchedGeometry = "0"
                            show.toggle()
                        }
                    })
                    Button("Group Chat", action: {
                        withAnimation() {
                            NewGroupChatMatchedGeometry = "0"
                            show.toggle()
                        }
                    })
                } label: {
                    ZStack {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
                            .font(.title2.weight(.bold))
                    }
                    .frame(width: 40)
                    .contentShape(Rectangle())
            }

                .padding(.trailing, 16)
            } // HStack, Navigation Menu
            .padding(.bottom, 14)
            Rectangle()
                .frame(width: screenWidth, height: 5)
                .foregroundColor(Color.mainColorInverse)
                .padding(.top, 8)
            ZStack {
                if allChats.sortedChats.isEmpty {
                    MessageGirlImage(NewConversationMatchedGeometry: $NewConversationMatchedGeometry, show: $show)
                        .offset(y: -80)
                }
                chatScrollView
            }
//#if os(iOS)
////            .padding(.bottom, screenHeight < 800 && iOS15 == false ? -0 : 0)
//////            .padding(.bottom, phoneHeight / 20.83) // 43
////            .padding(.bottom, iOS15 && screenHeight > 800 ? -35 : 0)
////            .padding(.bottom, isFromArcMenu && iOS15 == false ? 35 : 0)
//#endif
            .mutualFullScreenCover(isPresented: $ShowPhotoImagePicker, content: {
                InstagramImagePickerView(newMedia: $newMedia, text: .constant(""), themeController: themeController)
                    .environmentObject(friendsDictionary)
                    .environmentObject(allChats)
            })
            Spacer()
        } // VStack, main container
#if os(iOS)
        .padding(.top, iOS15 == true && iOS16 != true ? screenHeight < 870 ? 48 : 44 : 0)
        .padding(.top, iOS16 ? screenHeight < 930 ? 48 : 59 : 0)
        .padding(.top, iOS15 ? 0 : 48)
        .padding(.top, screenHeight < 740 ? -28 : 0)
#elseif os(macOS)
        .padding(.top, 20)
#endif
        .clipped()
  
            if newMedia != nil {
                SharePhoto( media: $newMedia, presentationMode: presentationMode, isFromSharedFriend: false, themeController: themeController)
            }
            if buttonAlertType != .none {
                ButtonTapAlertController(buttonAlertType: $buttonAlertType, themeController: themeController) 
            }
            
        } // ZStack
        .onAppear {
            print("screenHeight = \(screenHeight)")
        }
        .background(themeController.theme.primary)
        .onTapGesture {
            
        }
    }
 
     

    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    @Environment(\.presentationMode) var presentationMode

}

struct MessageGirlImage: View {
    @Binding var NewConversationMatchedGeometry: String
    @Binding var show: Bool
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Button(action: {
            withAnimation {
                NewConversationMatchedGeometry = "0"
                show = true
            }
        }) {
            Image(colorScheme == .light ? "messageGirlLight" : "messageGirlDark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: screenWidth/1.055, height: screenHeight/2)
                .opacity(1)
        }
    }
}
struct AllMessagesTabView: View {
    @Binding var AllMessagesMatchedGeometry: String
    @State var selectedTab = "AllMessages"
    @State var emptyBoolBinding = false
    @State var emptyStringBinding = ""
    @ObservedObject var pushNotificationVM : PushNotificationVM
    var body: some View {
        if selectedTab == "AllMessages" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("none")
                    AllMessages(AllMessagesMatchedGeometry: $AllMessagesMatchedGeometry, allChats: AllMessagesOO(friendsDictionary: FriendsDictionary()), selectedTab: $emptyStringBinding, isFromArcMenu: true ,currentTab: CurrentTab(), pushNotificationVM: pushNotificationVM, themeController: ThemeController())
                        .tag("AllMessages")
                    
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
            }
            .ignoresSafeArea(edges: .top)
        } else { 
            EmptyView()
                .onAppear() {
                    AllMessagesMatchedGeometry = ""
                }
        }
        
    }
}  

struct IndividualGroupMessage: View {
    @State var lastMessage = false
    @State var members: [Person]
    @State var chatInfo: ChatModel
    @Environment(\.colorScheme) var colorScheme
    let columns = [GridItem(GridItem.Size.fixed(20)),GridItem(.fixed(20))]
    var body: some View {
        HStack(spacing: 12) {
            ZStack {

                LazyVGrid(columns: columns) {
                    ForEach(members) { item in
//                        if item < 5 {
                        WebImage(url: item.webLink)
                                           .resizable()
                                           .aspectRatio(contentMode: .fill)
                                           .frame(width: 27, height: 27)
                                           .clipShape(Circle())
                                           .padding(.top, -5)
//                        }
                    }
                }
                .frame(width: 55, height: 50)
                .padding(.top, 5)
                Rectangle()
                    .frame(width: 2, height: 40)
//                    .foregroundColor(id == 1 || id == 3 || id == 4 || id == 7 || id == 10 ? Color.purple : Color.red.opacity(0.8))
                    .offset(x: -35, y: 0)
            }
            VStack(alignment: .leading, spacing: 12) {
                HStack {
//                ForEach(1 ..< 4) { item in
                    Text(chatInfo.groupName)
                    .font(.headline)

//                }
                }
                .lineLimit(1)
                Text(chatInfo.lastMessage?.message ?? "")
                    .font(.caption)
                    .padding(.top, -10)
            } // VTACK
           .foregroundColor(Color.mainColor)
            Spacer(minLength: 0)
            VStack {
                    Text(chatInfo.lastMessage?.timeString ?? "")
                    .font(.caption)
                    .padding(.top, 12)
                   .foregroundColor(Color.mainColor)
                Spacer()
            } // VSTACK
            
        }
    }
}

struct GroupProfileImage : View {
    var chatModel : ChatModel
    private let columns = [GridItem(GridItem.Size.fixed(20)),GridItem(.fixed(20))]
    @ObservedObject var themeController: ThemeController
    var body: some View {
        LazyVGrid(columns: columns, spacing: 3) {
                ForEach(chatModel.firstFourUsers, id: \.self) { user in
                    IndividualMessageCacheImageView(cacheImage: CacheImage(photoURL: user.profilePicLink, lightOrDark: Color.mainColorInverse),diameter : 27)
                }
            }
            .frame(width: 55, height: 50)
    }
}
