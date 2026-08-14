//
//  FriendProfileAllFriendsTabView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 10/5/21.
//

import SwiftUI

struct FriendProfileAllFriendsTabView: View {  // Used when an individual hexagon is selected
    @Binding var FriendProfileMatchedGeometry: String
    @State var selectedTab = "friendProfile"
    @State var id: String = ""
    @State var emptyStringBinding = ""
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    var body: some View {
        if selectedTab == "friendProfile" {
            ZStack {
                let friendProfile = FriendProfile(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,friendsDictionary:friendsDictionary, postData: FriendsPostsOO(id: id, friendsDictionary: timelinePosts.friendsDictionary), id: id, mentionedUserVM: MentionedUserVM(friendsDictionary: friendsDictionary), CloseOpenConversationFromProfile: $emptyStringBinding)
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    friendProfile
                        .tag("friendProfile")
                        .padding(.top, 60)
                }
             
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
#elseif os(macOS)
                friendProfile
#endif
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    FriendProfileMatchedGeometry = ""
                }
        }
    }
}
struct FriendProfileOpenedConversationTabView: View {  // Used when an individual hexagon is selected
    @Binding var FriendProfileMatchedGeometry: String
    @State var selectedTab = "friendProfile"
    @State var id: String = ""
    @State var emptyStringBinding = ""
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    @Binding var CloseOpenConversationFromProfile: String
    var body: some View {
        if selectedTab == "friendProfile" {
            ZStack {
                let friendProfile = FriendProfile(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,friendsDictionary:friendsDictionary, postData: FriendsPostsOO(id: id, friendsDictionary: timelinePosts.friendsDictionary), id: id, mentionedUserVM: MentionedUserVM(friendsDictionary: friendsDictionary), CloseOpenConversationFromProfile: $CloseOpenConversationFromProfile)
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    friendProfile
                        .tag("friendProfile")
                        .padding(.top, 60)
                }
             
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
#elseif os(macOS)
                friendProfile
#endif
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    FriendProfileMatchedGeometry = ""
                }
        }
    }
}
