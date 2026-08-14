//
//  IntroductionContacts.swift
//  speakEZ
//
//  Created by Ahmad naeem on 6/1/22.
//
import Contacts
import SwiftUI
import SDWebImageSwiftUI

struct IntroductionContacts: View {
    @Binding var currentView: CurrentIntroView
    @State var titleText = "Adding Friends"
    @State var isLoading = true
    @State var areContactsAvailable = false
    @State var contactsCount = 10
    @StateObject var suggestedFriends: SuggestedFriendsOO
    @ObservedObject var friendsDictionary: FriendsDictionary
    @Environment(\.colorScheme) var colorScheme
    @State var StrangerProfileMatchedGeometry: String = ""
    @State var StrangerProfileSelectedItem = Person(id: "")
    var body: some View {
        ZStack {
            
//            IntroBackground()
            LinearGradient(gradient: Gradient(colors: [.backgroundColor, .accent]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ZStack {
                VStack {
                    HStack {
                        Text("Add Friends")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.leading, 3)
                        Spacer()
                        Button(action: {
                            currentView = .Home 
                        }) {
                            Image(systemName: "arrow.right")
                                .font(.title)
                                .foregroundColor(Color.mainColor.opacity(0.6))
                                .padding(5)
                                .background(Color.mainColorInverse.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        .padding(.trailing, 16)
                    }
                    .frame(width: screenWidth/1.05, height: screenHeight/16.24) // 300, 50
                    .padding(.leading, 16)
                    .background(Color.mainColorInverse.opacity(0.2))
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    if isLoading != true {
                        if suggestedFriends.allSuggestedFriends.isNotEmpty {
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack {
                                        ForEach(Array(suggestedFriends.allSuggestedFriends.sorted(by: ({$0.user.username < $1.user.username }))), id: \.self){ suggestedFriend in
                                            IntroductionContact(person: suggestedFriend.user, friendshipStatus: StrangerProfileOO(id: suggestedFriend.user.id), friendsDictionary: friendsDictionary)
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    withAnimation(.spring()) {
                                                        StrangerProfileMatchedGeometry = "0"
                                                        StrangerProfileSelectedItem = suggestedFriend.user
                                                    }
                                                }
                                            Rectangle()
                                                .foregroundColor(Color.speakerPurple.opacity(0.2))
                                                .frame(width:screenWidth/1.05, height: 1)
                                        }
                                }
                            } .frame(width: screenWidth/1.05)
                        } else {
                            Spacer()
                            VStack {
                                Text("No contacts available, start the trend by verifying your number.")
                                    .multilineTextAlignment(.center)
                                if suggestedFriends.areContactsAvailable != true {
                                    Button(action: {
                                        suggestedFriends.askForPermissionAndFetchContacts()
//                                        let store = CNContactStore()
//                                        store.requestAccess(for: .contacts) {  (granted, error) in
//
//                                            if let error = error {
//                                                print("failed to request access", error)
//                                                return
//                                            }
//                                        }
                                    }) {
                                        Text("Access Contacts")
                                            .padding(10)
                                            .background(Color.mainColorInverse.opacity(0.4))
                                            .foregroundColor(Color.speakerPurple.opacity(0.6))
                                            .clipShape(RoundedRectangle(cornerRadius: 7))
                                    } .offset(y: 20)
                                }
                            }
                            
                            
                        }
                        
                    } else {
                        Spacer()
                        ProgressView()
                    }
                    Spacer()
                    HStack {
                        Button(action: {
                            currentView = currentUser?.phoneNumber == nil ? .Two_Factor : .Home  
                         }) {
                            Image(systemName: "arrow.left")
                                .font(.title3)
                                .foregroundColor(Color.mainColor.opacity(0.6))
                                .padding(5)
                                .background(Color.mainColorInverse.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        .padding(.leading, 10)
                        Spacer()
                    }
                    .padding(.bottom, 10)
                }
            }
            .frame(width: screenWidth/1.05, height: screenHeight / 1.1)
            .background(Color.mainColorInverse.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .animation(.easeIn(duration: 0.3))
            if StrangerProfileMatchedGeometry != "" {
                StrangerProfileTabView(ProfileMatchedGeometry: $StrangerProfileMatchedGeometry, person: StrangerProfileSelectedItem, id: StrangerProfileSelectedItem.id)
            }
        } .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isLoading = false
            }
            suggestedFriends.ifPermissionGrantedThenFetchContacts()
        }
    }
    
}

struct IntroductionContact: View {
    @State var person: Person
    @State var size: CGFloat = 55
    @State var hasRequestBeenSent = false
    @StateObject var friendshipStatus : StrangerProfileOO
    @ObservedObject var functions = FriendRequestsFunctions()
    @ObservedObject var friendsDictionary: FriendsDictionary
    @EnvironmentObject var alert: AlertOO
    @State private var showingFullFriendsListAlert = false
    var body: some View {
        HStack {
            WebImage(url: person.webLink)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 12) {
                Text(person.name)
                    .fontWeight(.bold)
                Text(person.username)
                    .font(.caption)
                    .padding(.top, -10)
            } // VSTACK
            Spacer()
            Button(action: {
                if hasRequestBeenSent {
                    functions.deleteFriendRequest(id: person.id)
                    friendshipStatus.cancelFriendRequest()
                    friendshipStatus.declineFriendRequest()
                } else {
                    guard let userId = currentUserID else { return }

                    if friendsDictionary.friendsDictionary.count < 152 {
                        functions.addFriend(id: person.id, nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "", token: person.token)
                        friendshipStatus.sendFriendRequest()
                    } else {
                        showingFullFriendsListAlert = true
                    }
                }
                hasRequestBeenSent.toggle()
            }) {
                Text(hasRequestBeenSent ? "SENT" : "SEND REQUEST")
                    .font(.caption2)
                    .foregroundColor(hasRequestBeenSent ? Color.speakerPink : Color.speakerPurple)
                    .padding(10)
                    .background(Color.mainColorInverse.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            .padding(.trailing, 10)

        } // HSTACK
        .padding(.leading, 10)
        .alert(isPresented: $showingFullFriendsListAlert) {
            Alert(
                title: Text("Your Friend list is full"),
                message: Text("150/150"))
        }

    }
}
