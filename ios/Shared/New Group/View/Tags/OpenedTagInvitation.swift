//
//  OpenedTagInvitation.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 8/27/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import Combine 

struct OpenedTagInvitation: View {
    @State var classification: String
    @State var description: String
    @Binding var OpenedTagInvitationMatchedGeometry: String
    @State var tagID: String
    @StateObject var functions = CreateTagFunction()
    @ObservedObject var tagFriends: TagFriendsOO
    @State var tagSentBy: String
    @State var FriendProfileMatchedGeometry: String = ""
    var body: some View {
        ZStack {
            Color.mainColorInverse
                .ignoresSafeArea(.all)
            VStack {
                HStack {
                    Button(action: {
                        OpenedTagInvitationMatchedGeometry = ""
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.mainColor)
                    }
                    .offset(y: 4)
                    Text("#\(classification)")
                        .foregroundColor(.speakerPurple)
                        .font(.largeTitle)
                    
                    Spacer()
                    HStack (spacing: 10){
                        Button(action: {
                            
                            OpenedTagInvitationMatchedGeometry = ""
                        }){
                            Text("Reject")
                                .font(.headline)
                                .foregroundColor(.speakerPink)
                                .padding(.top, 4)
                        }
                        Button(action: {
                            
                            guard let userId = Auth.auth().currentUser?.uid else{ return }  
                            functions.acceptTagInvite(tagID: tagID, acceptingUser: userId)
                            OpenedTagInvitationMatchedGeometry = ""
                        }){
                            Text("Accept")
                                .font(.headline)
                                .padding(.trailing)
                                .foregroundColor(.speakerPurple)
                                .padding(.top, 4)
                        }
                    }
                }
                HStack {
                    Text(description)
                        .font(.caption)
                        .padding(.vertical, 5)
                    Spacer()
                }
                
                .padding(.bottom, 10)
                ScrollView(showsIndicators: false) {
                    LazyVStack() {
                        HStack {
                            Text("INVITED BY")
                                .font(.headline)
                              .foregroundColor(Color.mainColor)
                            Spacer()
                        }
                        SearchBarResults(id: tagSentBy, size: 40)
                            .onTapGesture {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    FriendProfileMatchedGeometry = tagSentBy
                                }
                            }
                            .padding(.bottom, 10)
                    HStack {
                        Text("FRIENDS")
                            .font(.headline)
                          .foregroundColor(Color.mainColor)
                        Spacer()
                    }
                    ForEach(tagFriends.friendIDs, id: \.self) { item in
                        SearchBarResults(id: item, size: 40)
                            .onTapGesture {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    FriendProfileMatchedGeometry = item
                                }
                            }

                    }
                }
                    }
                    .padding(.top, 10)

                Spacer()
                HStack (alignment: .bottom) {
                    LinearGradient(gradient: .init(colors: [Color.speakerPurple.opacity(0.8), Color.speakerPink.opacity(0.8)]), startPoint: .bottomLeading, endPoint: .bottomTrailing)
                        .shadow(radius: 2)
                }
                .frame(width: screenWidth, height: 50)
                .padding(.bottom, screenHeight / 20.83) // 43
                .padding(.leading, -16)
            }
            .padding(.leading) 
            if FriendProfileMatchedGeometry != "" {
                FriendProfileAllFriendsTabView(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: FriendProfileMatchedGeometry)
                    .padding(.top, -60)
            }
        }
    }
}

struct OpenedTagInvitationTabView: View {
    @Binding var OpenedTagInvitationMatchedGeometry: String
    @State var selectedTab = "tag"
    @State var description: String
    @State var tagID: String
    @StateObject var tagFriends = TagFriendsOO(tagID: "")
    @State var tagSentBy: String
    var body: some View {
        if selectedTab == "tag" {
            ZStack {
                
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    OpenedTagInvitation(classification: OpenedTagInvitationMatchedGeometry, description: description, OpenedTagInvitationMatchedGeometry: $OpenedTagInvitationMatchedGeometry, tagID: tagID, tagFriends: tagFriends, tagSentBy: tagSentBy)
                        .tag("tag")
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    OpenedTagInvitationMatchedGeometry = ""
                }
        }
    }
}
