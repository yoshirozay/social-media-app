//
//  FriendRequests.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/6/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct FriendRequests: View {
    @Namespace var namespace
    @Binding var searchFriendRequestMatchedGeometry: String
    @State var text = ""
    @State var ProfileMatchedGeometry = ""
    @State var ProfileMatchedGeometrySelectedItem: Person!
    @StateObject var friendRequests = FriendRequestsOO()
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            Color.mainColorInverse
                .edgesIgnoringSafeArea(.all)
            (colorScheme == .light ?
            Color.plumWeb.opacity(0.2) : Color.speakerPurple.opacity(0.2))
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack (spacing: 16) {
                    Button(action: {
                        searchFriendRequestMatchedGeometry = ""
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .padding(.leading)
                    }.buttonStyle(.borderless)
                    Text("Friend Requests")
                        .fontWeight(.bold)
                        .font(.title)
                    Spacer()
                    
                }
              .foregroundColor(Color.mainColor)
                if friendRequests.requests.values.isEmpty {
                    Text("EMPTY")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.mainColor.opacity(0.2))
                        .offset(y: screenHeight/2 - 75)

                }
                List(Array(friendRequests.requests.values), id: \.self){ item in
                    FriendRequestResults(person: item)
                        .matchedGeometryEffect(id: UUID(), in: namespace, isSource: false)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.3)) {
                                ProfileMatchedGeometry = "0"
                                ProfileMatchedGeometrySelectedItem = item
                            }
                        }
                }
                .padding(.horizontal, iOS15 ? 10 : -8)
//                        .listRowInsets(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: 0))
//                        .padding(.bottom, 0)
                .padding(.horizontal, iOS15 ? -26: 0)
                .padding(.top, iOS15 ? -20 : 0)
                .padding(.top, iOS15 ? 0 : 8)
//                .padding(.bottom, shouldApplyPadding ? 0 : 60)
                .padding(.horizontal, iOS15 ? 0 : -4)
               
                Spacer()
            }
            .padding(.top, 60) 
#if os(macOS)
            .padding(.top, 20)
#endif

            if ProfileMatchedGeometry != "" {
                StrangerProfileTabView(ProfileMatchedGeometry: $ProfileMatchedGeometry,
                                       person: ProfileMatchedGeometrySelectedItem,
                                       id: ProfileMatchedGeometrySelectedItem.id,
                                       friendRequest : friendRequests )
                    .padding(.top, -60)
            }
        }
        .padding(.top, iOS15 ? -50 : 0)
    }
}

struct FriendRequestsTabView: View {
    @Binding var searchFriendRequestMatchedGeometry: String
    @State var selectedTab = "FriendRequest"
    @State var emptyStringBinding = ""
    var body: some View {
        if selectedTab == "FriendRequest" {
            ZStack {
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    FriendRequests(searchFriendRequestMatchedGeometry: $searchFriendRequestMatchedGeometry)
                        .tag("FriendRequest")
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
#elseif os(macOS)
                FriendRequests(searchFriendRequestMatchedGeometry: $searchFriendRequestMatchedGeometry)
#endif
            } 
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    searchFriendRequestMatchedGeometry = ""
                }
        }
    }
}

struct FriendRequestResults: View {
//    @StateObject var friendRequest = FriendRequestsOO()
    @StateObject var functions = FriendRequestsFunctions()
    @State var person: Person
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        HStack {
            WebImage(url: person.profilePicLink)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 55, height: 55)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 12) {
                Text(person.name)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                Text(person.username)
                    .font(.caption)
                    .foregroundColor(Color.black)
                    .padding(.top, -10)
            } // VSTACK
           .foregroundColor(Color.mainColor)
            Spacer()

            
            
        } // HSTACK
        
    }
}


struct SuggestedFriendRow: View {
//    @StateObject var friendRequest = FriendRequestsOO()
    @StateObject var functions = FriendRequestsFunctions()
    let suggestedFriend: SuggestedFriend
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        HStack {
            WebImage(url: suggestedFriend.user.profilePicLink)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 55, height: 55)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 12) {
                Text(suggestedFriend.name)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                Text(suggestedFriend.user.username)
                    .font(.caption)
                    .foregroundColor(Color.black)
                    .padding(.top, -10)
            } // VSTACK
           .foregroundColor(Color.mainColor)
            Spacer()
//            if suggestedFriend.isFromContacts{
//                Image(systemName: "person.text.rectangle.fill").font(.title).padding(.trailing)
//            }
        } // HSTACK
        
    }
}
