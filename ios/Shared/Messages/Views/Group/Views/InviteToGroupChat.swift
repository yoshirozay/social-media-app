//
//  InviteToGroupChat.swift
//  speakEZ
//
//  Created by Ahmad naeem on 4/14/22.
//

import SwiftUI

struct InviteToGroupChat: View {
    @Namespace var namespace
    @State var OpenedConversationMatchedGeometry = ""
    @State var OpenedConversationMatchedGeometry2 = ""
    @Binding var NewGroupChatMatchedGeometry: String
    @StateObject var keyboard = KeyboardOO()
    @State var text = ""
    @State var selectedUser = [String]()
    @State var trueBinding = true
    @State var falseBinding = false
    @State var titleName: String
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @State var currentGroupChatUsers: [Person]
    @State var allCurrentGroupChatUsers: [String : Person]
    @StateObject var functions = AddUsersToGroupChatFunction()
    @State var chatUID: String
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            themeController.theme.primary
                .edgesIgnoringSafeArea(.all)

            VStack {
                VStack {
                HStack (spacing: 16) {
                    Button(action: {
                        NewGroupChatMatchedGeometry = ""
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.bold))
                            .padding(.leading)
                            .foregroundColor(.black)
                    }
                    Text(titleName)
                        .fontWeight(.bold)
                        .font(.title)
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: {
                        functions.addUsersToGroupChat(newGroupChatUsers: selectedUser, groupChatName: titleName, currentGroupChatUsers: currentGroupChatUsers, chatUID: chatUID)
                        NewGroupChatMatchedGeometry = ""
                    }) {

                        Text("Done")
                            .fontWeight(.bold)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.top, 3)
                        
                    }
                    .padding(.trailing, 24)
                    .disabled(selectedUser.count < 1 ? true : false)
                    .opacity(selectedUser.count < 1 ? 0.0 : 1.0)

                }
              .foregroundColor(Color.mainColor)
                .padding(.top, keyboard.value == 0 ? 0 : 30)
                .animation(.easeInOut(duration: 0.3))
//                    Spacer()
                }
                ZStack {
                    VStack {

                        
//                        if self.text != "" {
                        ScrollView(showsIndicators: false) {
                            LazyVStack (spacing: 10) {
                        ForEach(Array(friendsDictionary.friendsDictionary.values.sorted(by: ({$0.name < $1.name }))), id: \.self){ item in
                            if allCurrentGroupChatUsers[item.id] == nil {
                            SelectIndividuals(id: item.id, selectedUser: $selectedUser, selected: selectedUser.contains(item.id) ? $trueBinding : $falseBinding, themeController: themeController)

                            }
                            }
                        .padding(.horizontal, 16)
//                        .padding(.trailing, 16)
                           }
                            .background(themeController.theme.secondary
                                        
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                //                            .padding(.horizontal, 10)
                                .padding(.vertical, -10)
                                )
                            .padding(.top, 20)
                        }
//                        }
                    }
                }
                .padding(.top, -5)
                
                Spacer()
            } // VStack, Main Containe
            .padding(.top, iOS15 ? 10 : 60)
        } // ZStack
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct InviteToGroupChatTabView: View {
    @Binding var NewGroupChatMatchedGeometry: String
    @State var selectedTab = "NewConversation"
    @State var emptyStringBinding = ""
    @State var titleName: String
    @State var currentGroupChatUsers: [Person]
    @State var chatUID: String
    @State var allCurrentGroupChatUsers: [String : Person]
    @ObservedObject var themeController: ThemeController
    var body: some View {
        if selectedTab == "NewConversation" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("none")
                    InviteToGroupChat(NewGroupChatMatchedGeometry: $NewGroupChatMatchedGeometry, titleName: titleName, currentGroupChatUsers: currentGroupChatUsers, allCurrentGroupChatUsers: allCurrentGroupChatUsers, chatUID: chatUID, themeController: themeController)
                        .tag("NewConversation")
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
