////
////  SuggestedFriends.swift
////  speakEZ
////
////  Created by Carson O'Sullivan on 12/7/21.
////
//
//import SwiftUI
//import SDWebImageSwiftUI
//
//struct SuggestedFriends: View {
//    @Namespace var namespace
//    @StateObject var suggestedFriends : SuggestedFriendsOO
//    @State var ProfileMatchedGeometry = ""
//    @State var ProfileMatchedGeometrySelectedItem: Person!
//    @StateObject var friendRequests = FriendRequestsOO()
//    @Binding var isSuggestedFriendsShowing: Bool
//    @EnvironmentObject var friendsDictionary: FriendsDictionary
//    var body: some View {
//        ZStack {
//            Color.mainColorInverse
//                .edgesIgnoringSafeArea(.all)
//
//            VStack {
//                HStack (spacing: 16) {
//                    Button(action: {
//                        isSuggestedFriendsShowing = false
//                    }) {
//                        Image(systemName: "chevron.left")
//                            .font(.title3)
//                            .padding(.leading)
//                    }
//                    Text("Suggested Friends")
//                        .fontWeight(.bold)
//                        .font(.title)
//                    Spacer()
//                }
//
//              .foregroundColor(Color.mainColor)
////                .offset(y: -keyboard.value*4)
//                ZStack {
//                SearchForSomeone(StrangerProfileMatchedGeometry: $ProfileMatchedGeometry, StrangerProfileSelectedItem: $ProfileMatchedGeometrySelectedItem)
//                    .padding(.top, 5)
//                    .padding(.bottom, 5)
//                    .padding(.bottom, iOS15 ? 15 : 0)
//                    
//                Text("\(friendsDictionary.friendsDictionary.count-2)/150")
//                    .fontWeight(.bold)
//                    .font(.footnote)
//                    .opacity(0.3)
//                    .offset(x: screenWidth/3 + 15, y: 40)
//
//                }
//                ZStack {
//                    VStack {
//                       
//                        List(){
//                            ForEach(Array(suggestedFriends.allSuggestedFriends), id: \.self) { suggFriend in
//                                let item = suggFriend.user 
//                                SuggestedFriendResults(person: item)
//                                    .matchedGeometryEffect(id: UUID(), in: namespace, isSource: false)
//                                    .contentShape(Rectangle())
//                                    .onTapGesture {
//                                        withAnimation(.easeIn(duration: 0.3)) {
//                                            ProfileMatchedGeometry = "0"
//                                            ProfileMatchedGeometrySelectedItem = item
//                                        }
//                                    }
//                            }
//                            
//                            if  suggestedFriends.isAllFetched == false{
//                                HStack {
//                                    Spacer()
//                                    ProgressViewPurpleCircular()
//                                    Spacer()
//                                } 
////                                .onAppear{
////                                    suggestedFriends.getNextPageIfNeeded()
////                                }
//                            }
//                        }
//                        .listStyle(InsetListStyle())
//                        .padding(.horizontal, iOS15 ? 10 : -8)
//                        .padding(.horizontal, iOS15 ? -20: 0)
//                        .padding(.top, iOS15 ? -20 : 0)
//                        .padding(.top, iOS15 ? 0 : 8)
//                        .padding(.bottom, iOS15 ? 0 : 60)
//                        .padding(.horizontal, iOS15 ? 0 : -4)
//
//                    }
//                }
//
//            }
//
//            .padding(.top, 60)
//            if ProfileMatchedGeometry != "" {
//                StrangerProfileTabView(ProfileMatchedGeometry: $ProfileMatchedGeometry,
//                                       person: ProfileMatchedGeometrySelectedItem,
//                                       id: ProfileMatchedGeometrySelectedItem.id,
//                                       friendRequest : friendRequests )
//            }
//        }
//    }
//}
//
//
//struct SuggestedFriendResults: View {
//    @EnvironmentObject var friendsDictionary: FriendsDictionary
//    @State var size: CGFloat = 55
//    @State var person: Person
//    @Environment(\.colorScheme) var colorScheme
//    var body: some View {
//        HStack {
//            ZStack {
//                Circle()
//                    .frame(width: size + 4, height: size + 4)
//                    .foregroundColor(person.profileCircle)
////                                .foregroundColor(Color.mainColor)
//                    .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
//                    .clipShape(Circle())
//                WebImage(url: person.webLink)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: size, height: size)
//                .background(Color.mainColor.opacity(0.1))
//                .clipShape(Circle())
//            }
//            VStack(alignment: .leading, spacing: 12) {
//                Text(person.name)
//                    .fontWeight(.bold)
//                Text(person.username)
//                    .font(.caption)
//                    .padding(.top, -10)
//            } // VSTACK
//           .foregroundColor(Color.mainColor)
//            Spacer()
//        } // HSTACK
//        .contentShape(Rectangle())
//        
//    }
//}
//
//struct SearchForSomeoneTabView: View {
//    @Binding var isSuggestedFriendsShowing: Bool
//    @State var selectedTab = "friendProfile"
//    @EnvironmentObject var friendsDictionary: FriendsDictionary
//    @EnvironmentObject var timelinePosts: TimelinePostsOO
//    var body: some View {
//        if selectedTab == "friendProfile" {
//            ZStack {
//                TabView(selection: $selectedTab) {
//                    EmptyView()
//                        .tag("home")
//                    SuggestedFriends(suggestedFriends: SuggestedFriendsOO(friendsDictionary: timelinePosts.friendsDictionary), isSuggestedFriendsShowing: $isSuggestedFriendsShowing)
//                        .tag("friendProfile")
//                }
//                .edgesIgnoringSafeArea(.bottom)
//                .mutualTabViewStyle()
//            }
//            .ignoresSafeArea(edges: .top)
//        } else {
//            EmptyView()
//                .onAppear() {
//                    isSuggestedFriendsShowing = false
//                }
//        }
//    }
//}
