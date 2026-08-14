//
//  GroupChatInfo.swift
//  speakEZ
//
//  Created by Ahmad naeem on 4/14/22.
//

import SwiftUI

struct GroupChatInfo: View {
    let columns = [GridItem(GridItem.Size.fixed(17)),GridItem(.fixed(17))]
    @ObservedObject var allMessages : OpenedGroupConversationOO
    @State var isShowingGroupChatPopUp = false
    @State var leaveGroupAlert = false
    @State var AddMembersMatchedGeometry = ""
    @State var isEditingGroupName: Bool = false
    @Binding var GroupChatInfoMatchedGeometry: String
    @StateObject var functions = LeaveGroupChatFunction()
    @Binding var selectedGroupChat : ChatModel?
    @Environment(\.colorScheme) var colorScheme
    @State var OpenProfileMatchedGeometry = ""
    @State var OpenedProfileSelectedPerson = Person(id: "")
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            themeController.theme.primary
                .edgesIgnoringSafeArea(.all)
            VStack {
                ZStack  {
                    HStack  {
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                GroupChatInfoMatchedGeometry = ""
                            }
                        }){
                            Image(systemName: "chevron.left")
                                .font(.title3.weight(.bold))
//                                .bold()
//                                .padding(.bottom, 10)
//                                .padding(.leading)
                                .foregroundColor(Color.black)
 
                        } // BUTTON
                        Spacer()
                        Menu {
                            Button("Add Members", action: {
                                withAnimation {
                                    AddMembersMatchedGeometry = "0"
                                }
                            })
                            Button("Rename Group", action: {
                                withAnimation {
                                    isEditingGroupName = true
                                }
                            })
                            Button("Leave Group", action: {
                                withAnimation {
                                    leaveGroupAlert = true
                                }
                            })
                        } label: {
                            ZStack {
                                Text(".")
                                    .font(.largeTitle)
                                    .offset(y: -7)
                                Text(".")
                                    .font(.largeTitle)
                                Text(".")
                                    .font(.largeTitle)
                                    .offset(y: 7)
                            }
                        }
                        .padding(.top, -20)
                        .foregroundColor(Color.black)

                    } // HSTACK
                    .padding(.horizontal, 16)
                    VStack {
                        Text(allMessages.chatModel.groupName)
                            .fontWeight(.bold)
                        Text("\(allMessages.chatModel.otherMembers.count) members")
                            .font(.caption)
                            .fontWeight(.light)
                    } // VSTACK
                    .foregroundColor(Color.black)
                }
                GroupChatMembers(allMessages : allMessages, OpenedProfileSelectedPerson: $OpenedProfileSelectedPerson, OpenedProfileMatchedGeometry: $OpenProfileMatchedGeometry, themeController: themeController)
                
                Spacer()
            }
            .padding(.top, iOS15 ? 10 : 60)
            .disabled(isShowingGroupChatPopUp ? true : false)
            .blur(radius: isShowingGroupChatPopUp || isEditingGroupName ? 20 : 0)
          
            .alert(isPresented: $leaveGroupAlert) {
   Alert(
       title: Text("Are you sure you want to leave this group?"),
                  primaryButton: .destructive(Text("Yes")) {
                      print("Deleting...")
//                      InviteToEventMatchedGeometry = ""
//                      CreateEventMatchedGeometry = ""
                      functions.leaveGroupChat(groupChatUsers: allMessages.chatModel.otherMembers, chatUID: allMessages.chatUID, usersWhoLeftGroupChat: allMessages.chatModel.usersWhoLeft ?? [""])
                      GroupChatInfoMatchedGeometry = ""
                      selectedGroupChat = nil
                  },
                  secondaryButton: .cancel()
              )
}

            if OpenProfileMatchedGeometry != "" {
                if friendsDictionary.friendsDictionary[OpenProfileMatchedGeometry] != nil {
                    FriendProfileHomeTabView(FriendProfileMatchedGeometry: $OpenProfileMatchedGeometry, id: OpenProfileMatchedGeometry, isFromOpenedPost: true, themeController: themeController)
                    //                    .padding(.horizontal, 20)
                        .padding(.top, iOS15 ? 10 : (screenHeight > 800 ? 10 : 10) )

                } else {
                    StrangerProfileTabView(ProfileMatchedGeometry: $OpenProfileMatchedGeometry, person: OpenedProfileSelectedPerson , id: OpenProfileMatchedGeometry)

                }
                
            }
            if isEditingGroupName != false {
                ChangeGroupNameChatAlert(name: allMessages.chatModel.groupName, isGroupChatAlertShowing: $isEditingGroupName, chatUID: allMessages.chatModel.chatUID, groupChatUsers: allMessages.chatModel.otherMembers, GroupChatInfoMatchedGeometry: $GroupChatInfoMatchedGeometry, themeController: themeController)
            }
            if AddMembersMatchedGeometry != "" {
                InviteToGroupChatTabView(NewGroupChatMatchedGeometry: $AddMembersMatchedGeometry, titleName: allMessages.chatModel.groupName, currentGroupChatUsers: allMessages.chatModel.otherMembers, chatUID: allMessages.chatModel.chatUID, allCurrentGroupChatUsers: allMessages.chatModel.allMembersDict, themeController: themeController)
            }
        }
        .padding(.top, -60)
    }
}

struct GroupChatInfoTabView: View {
    @Binding var GroupChatInfoMatchedGeometry: String
    @State var selectedTab = "NewConversation"
    @State var emptyStringBinding = ""
    @State var titleName = ""
    @Binding var selectedGroupChat : ChatModel?
    @ObservedObject var allMessages : OpenedGroupConversationOO
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var themeController: ThemeController
    var body: some View {
        if selectedTab == "NewConversation" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("none")
                    GroupChatInfo(allMessages: allMessages, GroupChatInfoMatchedGeometry: $GroupChatInfoMatchedGeometry, selectedGroupChat: $selectedGroupChat, friendsDictionary: friendsDictionary, themeController: themeController)
                        .tag("NewConversation")
                        .padding(.top, 60)
                }
                .edgesIgnoringSafeArea(.bottom)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    GroupChatInfoMatchedGeometry = ""
                }
        }
        
    }
}
