//
//  NewGroupChat.swift
//  speakEZ
//
//  Created by Ahmad naeem on 12/19/21.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI
import Firebase

struct NewGroupChatTabView: View {
    @Binding var NewGroupChatMatchedGeometry: String
    @Binding var NewConversationMatchedGeometry: String
    @State var selectedTab = "NewConversation"
    @State var emptyStringBinding = ""
    var body: some View {
        if selectedTab == "NewConversation" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("none")
                    NewGroupChat(NewGroupChatMatchedGeometry: $NewGroupChatMatchedGeometry, NewConversationMatchedGeometry: $NewConversationMatchedGeometry, show: .constant(false), allChats: AllMessagesOO(friendsDictionary: FriendsDictionary()), selectedGroupChat: .constant(nil), themeController: ThemeController())
                        .tag("NewConversation")
                        .padding(.top, iOS15 ? 10 : 60)
                }
                .edgesIgnoringSafeArea(.bottom)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .ignoresSafeArea(edges: .top)
        } else {
           EmptyView()
                .onAppear() {
                    NewGroupChatMatchedGeometry = ""
                }
        }

    }
}

struct NewGroupChat: View {
    @Namespace var namespace
    @State var OpenedConversationMatchedGeometry = ""
    @State var OpenedConversationMatchedGeometry2 = ""
    @Binding var NewGroupChatMatchedGeometry: String
    @Binding var NewConversationMatchedGeometry: String
    @StateObject var keyboard = KeyboardOO()
    @State var text = ""
    @State var selectedUser: [String] = []//[Auth.auth().currentUser!.uid]
    @State var trueBinding = true
    @State var falseBinding = false
    @State var isGroupChatAlertShowing = false
    @State var isEditingGroupName = false
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @Environment(\.colorScheme) var colorScheme
    @State var hasSetKeyboardDismissMode: Bool = false
    @Binding var show: Bool
    @ObservedObject var allChats : AllMessagesOO
    @Binding var selectedGroupChat : ChatModel?
    @StateObject var textBindingManager = TextBindingManager(limit: 21)
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            themeController.theme.primary
            VStack {
                VStack {
                    HStack (spacing: 16) {
                        if isEditingGroupName == true && text.count > 0{
                            Button(action: {
                                text = ""
                            }) {
                                Image(systemName: "xmark")
                                    .font(.title3.weight(.bold))
                                    .padding(.leading)
                            }
                        } else {
                            Button(action: {
                                withAnimation {
                                    NewGroupChatMatchedGeometry = ""
                                    show.toggle()
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.title3.weight(.bold))
                                    .padding(.leading)
                                
                            }

                        }
                        HStack {
                            if isEditingGroupName != true {
                                Text("Group Name")
                                    .fontWeight(.bold)
                                    .font(.title)
                                
                                Button(action: {
                                    isEditingGroupName = true
                                }){
                                    Image(systemName: "pencil")
                                }
                            } else {
                                
                                FirstResponder(text: $textBindingManager.text, placeHolderText: "Group Name", isFromMessages: true)
                                    .frame(width: screenWidth / 1.5 , height: 40)
                            }
                        }
                   
                        Spacer()
                        Button(action: {
//                            NewGroupChatMatchedGeometry = ""
                            doneTap()
                        }) {
                            
                            Text("Done")
                                .fontWeight(.bold)
                                .font(.caption)
                                .foregroundColor(themeController.theme.accent)
                                .padding(.top, 3)
                            
                        }
                        .frame(width: 40)
                        .padding(.trailing, 5)
                        .disabled(selectedUser.count < 1 ? true : false)
                        .opacity(selectedUser.count < 1 ? 0.0 : 1.0)

                    }
//                    .frame(height: 40)
                    .foregroundColor(Color.black)
//                    .animation(.easeInOut(duration: 0.3))

//                    Spacer()
                }
                ZStack {
                    VStack {

                        HStack {
                            VStack (alignment: .leading, spacing: 3) {
                        Text("MEMBERS")
                            .font(.headline)
                            .foregroundColor(Color.black)
                          
                        Rectangle()
                            .frame(width: 90, height: 2)
                            .foregroundColor(themeController.theme.accent.opacity(0.2))
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 20)
                            Spacer()
                        }
                        ScrollView(showsIndicators: false) {
                            LazyVStack (spacing: 15) {
                               
                               let userId = { currentUserID }()
                               
                               ForEach(Array(friendsDictionary.allFriendsExcludingCurrentUser), id: \.self){ item in
//                                   HStack {
//                                       Text(item.id)
//                                           Spacer()
//                                   }
//                                   .padding(.vertical)
                            SelectIndividuals(id: item.id, selectedUser: $selectedUser, selected: selectedUser.contains(item.id) ? $trueBinding : $falseBinding, themeController: themeController)
                                .disabled(isGroupChatAlertShowing ? true : false)
                                .disabled(item.id == userId  )
//                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        hideKeyboard()

                                    }
                                 
                            }
                               .padding(.horizontal, 16)
                           }
                            .background(themeController.theme.secondary
                               .clipShape(RoundedRectangle(cornerRadius: 25))
   //                            .padding(.horizontal, 10)
                               .padding(.vertical, -10)
                               )
                           .padding(.top, 20)
                        }.introspectScrollView {  scrollView in
                            if hasSetKeyboardDismissMode == false{
#if os(iOS)
                                scrollView.keyboardDismissMode = .interactive
#endif
                                hasSetKeyboardDismissMode = true
                            }
                        }
                        .padding(.top, -20)
                        
                    }
                    .padding(.top, 5)
                    
                    Spacer()
                }
                .padding(.top)
                
                Spacer()
            } // VStack, Main Container
            .ignoresSafeArea(.keyboard)
            .padding(.top, iOS15 == true && iOS16 != true ? screenHeight < 870 ? 48 : 44 : 0)
            .padding(.top, iOS16 ? screenHeight < 930 ? 48 : 59 : 0)
            .padding(.top, iOS15 ? 0 : 48)
            .padding(.top, screenHeight < 740 ? -28 : 0)
        } // ZStack

//        .edgesIgnoringSafeArea(.bottom)
//        .padding(.top, -60)
        
    }

    func doneTap() {
        
        guard let userId = currentUserID,
        let currentUser = friendsDictionary.friendsDictionary[userId] else { return }
        var name = text
        if name.trimWhitespacesAndNewlines() == "" {
            name = "Group Chat"
        }
        var members = selectedUser.compactMap({friendsDictionary.friendsDictionary[$0]})
        members.append(currentUser)
        let dummyModel = ChatModel(chatUID: UUID().uuidString,
                                   isAGroup: true,
                                   members: members,
                                   lastMessage: nil,
                                   time: Date(),
                                   
                                   groupName: name,
                                   status: .sending,
                                   usersWhoLeft: nil)
        withAnimation {
            selectedGroupChat = dummyModel
            NewGroupChatMatchedGeometry = ""
        }
//        isGroupChatAlertShowing = false
        
    }
}
