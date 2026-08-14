//
//  NewConversation.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 12/2/21.
//


import SwiftUI
import Combine
import SDWebImageSwiftUI 
import Firebase

struct NewConversation: View {
    @Namespace var namespace
    @State var OpenedConversationMatchedGeometry = ""
    @State var OpenedConversationMatchedGeometry2 = ""
    @Binding var NewConversationMatchedGeometry: String
    @State var NewGroupChatMatchedGeometry = ""
    @State var text = ""
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @StateObject var keyboard = KeyboardOO()
    @ObservedObject var messages: AllMessagesOO
    @Environment(\.colorScheme) var colorScheme
    @Binding var show: Bool
    @State var show2 = false
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            themeController.theme.primary.ignoresSafeArea(.all)
            VStack {
                HStack (spacing: 16) {
//                    Button(action: {
//                        NewConversationMatchedGeometry = ""
//                    }) {
//                        Image(systemName: "chevron.left")
//                            .font(.title3)
//                            .padding(.leading)
//                            .foregroundColor(Color.black)
//                    }
//                    Text("Message")
//                        .fontWeight(.bold)
//                        .font(.title)
                    TitleHeader(title: "New Conversation") {
                        withAnimation {
                            NewConversationMatchedGeometry = ""
                            show.toggle()
                        }
                        
                    }
                    Spacer()

                    
                }
              .foregroundColor(Color.black)
              .padding(.bottom, 10)
                ZStack {
                    VStack {
//                        HStack {
////                            VStack (alignment: .leading, spacing: 3) {
////                        Text("OPEN CONVERSATION")
////                            .font(.headline)
////
////
////                        Rectangle()
////                            .frame(width: 180, height: 2)
////                            .foregroundColor(Color.plumWeb.opacity(0.2))
////                        }
//                        .padding(.leading, 20)
//                        .padding(.bottom, 20)
//                            Spacer()
//                        }
                            ScrollView(showsIndicators: false) {
                               LazyVStack  (spacing: 10) {
                                    ForEach(Array(friendsDictionary.friendsDictionary.values.sorted(by: ({$0.name < $1.name }))), id: \.self){ item in
                                        if item.id != TristanUserID {
                                        SearchBarResults(id: item.id)
    
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                          if item.id != TristanUserID {
                                              withAnimation {
                                                  OpenedConversationMatchedGeometry = item.id
                                                  show2.toggle()
                                              }
                                            }
                                        }
                                    }
                                        Rectangle()
                                            .frame(width: screenWidth - 40, height: 2)
                                            .foregroundColor(themeController.theme.accent.opacity(0.2))
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
                            }
                            .padding(.top, -20)
//                            .animation(.easeIn)
                        
                    }
                    .padding(.top, -10)
                }
                .padding(.top)
                
                Spacer()
            } // VStack, Main Container
            .padding(.top, iOS15 == true && iOS16 != true ? screenHeight < 870 ? 48 : 44 : 0)
            .padding(.top, iOS16 ? screenHeight < 930 ? 48 : 59 : 0)
            .padding(.top, iOS15 ? 0 : 48)
            .padding(.top, screenHeight < 740 ? -28 : 0)
//            .edgesIgnoringSafeArea(.bottom)
#if os(macOS)
            .padding(.top, 20)
 #endif

//            if OpenedConversationMatchedGeometry != "" {
//                OpenedConversationTabView(OpenedConversationMatchedGeometry: $OpenedConversationMatchedGeometry, id: OpenedConversationMatchedGeometry)
//
//#if os(iOS)
////                    .padding(.top, -60)
//#endif
//            }
        } // ZStack
//        .padding(.top, -60)
        .fullSwipePop(show: $show2) {
            ZStack {
                OpenedConversation(OpenedConversationMatchedGeometry: $OpenedConversationMatchedGeometry, allMessages: OpenedConversationOO(otherUserID: OpenedConversationMatchedGeometry) , allChats: messages, id2: OpenedConversationMatchedGeometry, isFromOpenedMoment: false, isFirstResponder: false, show: $show2, themeController: themeController)
            }
        }
    }
}

struct NewConversationTabView: View {
    @Binding var NewConversationMatchedGeometry: String
    @State var emptyStringBinding = ""
    @State var selectedTab = "NewConversation"
    @ObservedObject var messages: AllMessagesOO
    var body: some View {
        if selectedTab == "NewConversation" {
            ZStack {
                let newConversation = NewConversation(NewConversationMatchedGeometry: $NewConversationMatchedGeometry, messages: messages, show: .constant(false), themeController: ThemeController())
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("none")
                    newConversation
                        .tag("NewConversation")
                        .padding(.top, iOS15 ? (screenHeight > 800 ? 10 : 40) : 60)
                        .background( Color.mainColorInverse.edgesIgnoringSafeArea(.all))
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
#elseif os(macOS)
                newConversation
#endif
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
//            AllMessages(AllMessagesMatchedGeometry: $emptyStringBinding, selectedTab: $emptyStringBinding, currentTab: CurrentTab())
                .onAppear() {
                    NewConversationMatchedGeometry = ""
                }
        }
        
    }
}
