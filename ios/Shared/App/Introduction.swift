//
//  Introduction.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 5/4/22.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import Contacts

struct IntroductionController: View {
    @State var currentView = "Introduction1"
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var allChats: AllMessagesOO
    @ObservedObject var timelinePosts: TimelinePostsOO
    @Binding var signOut: Bool
    @Binding var newMedia: SelectedMedia?
    var persistenceController = PersistenceController.shared
    @ObservedObject var intro: IntroVideoOO
    @ObservedObject var notifications: NotificationsOO
    @State var emptyStringBinding = ""
    @State var isAFirstTimeUser = false
    @Binding var permissionAccess: [String]
    var body: some View {
        ZStack {
            switch currentView {
            case "Introduction1":
                IntroductionSelection1(currentView: $currentView, isAFirstTimeUser: isAFirstTimeUser)
                    .transition(AnyTransition.asymmetric(
                        insertion:.move(edge: .trailing),
                        removal: .move(edge: .leading)))
            case "Introduction2":
                IntroductionSelection2(currentView: $currentView, friendsDictionary: friendsDictionary, isAFirstTimeUser: isAFirstTimeUser)
                    .transition(AnyTransition.asymmetric(
                        insertion:.move(edge: .trailing),
                        removal: .move(edge: .leading)))
            case "CreateProfile":
                IntroductionCreateProfile(currentView: $currentView)
                    .transition(AnyTransition.asymmetric(
                        insertion:.move(edge: .trailing),
                        removal: .move(edge: .leading)))
            case "Introduction3":
                IntroductionSelection3(currentView: $currentView)
                    .transition(AnyTransition.asymmetric(
                        insertion:.move(edge: .trailing),
                        removal: .move(edge: .leading)))
                
            case "Two-Factor":
                IntroductionPhoneNumber(currentView: $currentView, permissionAccess: permissionAccess, isAFirstTimeUser: isAFirstTimeUser)
                    .transition(AnyTransition.asymmetric(
                        insertion:.move(edge: .trailing),
                        removal: .move(edge: .leading)))
            case "Permission":
                IntroductionPermissions(currentView: $currentView, permissionAccess: $permissionAccess, isAFirstTimeUser: isAFirstTimeUser)
                    .transition(AnyTransition.asymmetric(
                        insertion:.move(edge: .trailing),
                        removal: .move(edge: .leading)))
            case "Contacts":
                IntroductionContacts(currentView: $currentView, suggestedFriends: SuggestedFriendsOO(friendsDictionary: friendsDictionary), friendsDictionary: friendsDictionary)
                    .transition(AnyTransition.asymmetric(
                        insertion:.move(edge: .trailing),
                        removal: .move(edge: .leading)))
                
                
            case "Home":
                HomeTabView(newMedia: $newMedia,
                            pushNotificationVM: PushNotificationVM(timelinePosts: timelinePosts, allMessagesOO: allChats), signOut: $signOut, NewPostMatchedGeometry: $emptyStringBinding, timelinePosts: timelinePosts)
                                  .environment(\.managedObjectContext, persistenceController.container.viewContext)
                                  .environmentObject(allChats)
                                  .environmentObject(notifications)
                                  .onAppear(perform: intro.checkIntroForCurrentUser)
 
            default:
                IntroductionSelection1(currentView: $currentView, isAFirstTimeUser: isAFirstTimeUser)
                    .transition(AnyTransition.asymmetric(
                        insertion:.move(edge: .trailing),
                        removal: .move(edge: .leading)))
            }
        }
    }
}

struct IntroductionSelection1: View {
    @Binding var currentView: String
    @State var titleText = "speakEZ"
    @State var isAFirstTimeUser: Bool
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            
            Image(colorScheme == .light ? "coolBackground" : "Planes")
                .resizable()
                .scaledToFill()
            //                .edgesIgnoringSafeArea(.all)
                .blur(radius: 15)
                .frame(width: screenWidth, height: screenHeight)
            
            
            ZStack {
                VStack {
                    ZStack {
                        Image("friends")
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth/1.4267, height: screenHeight/3.087) // 300, 300
                        
                    }
                    .frame(width: screenWidth/1.05, height: screenHeight/3.087) // 300
                    .padding(screenWidth/10.7) // 40
                    .background(Color.mainColorInverse.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    ZStack {
                        VStack (alignment: .leading, spacing: 23) {
                            HStack {
                                ZStack {
                                    Text(titleText)
                                        .font(.largeTitle)
                                    Rectangle()
                                        .frame(width: CGFloat(titleText.count * 18), height: 2)
                                        .foregroundColor(Color.speakerPurple)
                                        .offset(y: 20)
                                }
                                Spacer()
                            }
                            Text("Keep your circle connected by turning everyday thoughts into group conversations")
                                .font(.title3)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            Rectangle()
                                .frame(width: 30, height: 2)
                                .foregroundColor(Color.speakerPurple)
                            Text("You can add up to 150 people, send friend requests to see what's up!")
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.title3)
                            Rectangle()
                                .frame(width: CGFloat(titleText.count * 18 - 30), height: 2)
                                .foregroundColor(Color.speakerPurple)
                            
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 5)
                        
                        
                        VStack {
                            Button(action: {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    if isAFirstTimeUser != true {
                                        currentView = "Permission"
                                    } else {
                                    currentView = "CreateProfile"
                                    }
                                }
                            }) {
                                Text("Next")
                                    .font(.headline)
                                    .padding()
                                    .padding(.horizontal, 30)
                                    .foregroundColor(Color.white)
                                    .background(Color.speakerPurple.opacity(1))
                                    .clipShape(Capsule())
                            }
                            .padding(.top, 30)
                            
                        }
                        .offset(y: screenHeight/4.5)
                    }
                    
                    Spacer()
                    
                }
            }
            .frame(width: screenWidth/1.05, height: screenHeight / 1.1)
            .background(Color.mainColorInverse.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .animation(.easeIn(duration: 0.3))
        }
    }
}

struct IntroductionSelection2: View {
    @Binding var currentView: String
    @State var titleText = "Moments"
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var friendsDictionary: FriendsDictionary
    @State var isAFirstTimeUser: Bool
    var body: some View {
        ZStack {
            
            Image(colorScheme == .light ? "coolBackground" : "Planes")
                .resizable()
                .scaledToFill()
            //                .edgesIgnoringSafeArea(.all)
                .blur(radius: 15)
                .frame(width: screenWidth, height: screenHeight)
            
            ZStack {
                
                VStack {
                    ZStack {
                        Image("moment")
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth/1.4267, height: screenHeight/3.087) // 300, 300
                        
                    }
                    .frame(width: screenWidth/1.05, height: screenHeight/3.087) // 300
                    .padding(screenWidth/10.7) // 40
                    .background(Color.mainColorInverse.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    ZStack {
                        VStack (alignment: .leading, spacing: 23) {
                            HStack {
                                ZStack {
                                    Text(titleText)
                                        .font(.largeTitle)
                                    Rectangle()
                                        .frame(width: CGFloat(titleText.count * 18 + 15), height: 2)
                                        .foregroundColor(Color.speakerPurple)
                                        .offset(y: 20)
                                }
                                Spacer()
                            }
                            Text("Are the materialization of thoughts, ideas, and appreciation for the small things in life.")
                                .font(.title3)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            Rectangle()
                                .frame(width: 30, height: 2)
                                .foregroundColor(Color.speakerPurple)
                            Text("Each Moment is home to it's own group conversation!")
                                .font(.title3)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            Rectangle()
                                .frame(width: CGFloat(titleText.count * 18 - 30 + 15), height: 2)
                                .foregroundColor(Color.speakerPurple)
                            
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 5)
                        
                        VStack {
                            Button(action: {
                                withAnimation(.easeIn(duration: 0.3)) {
//                                    if (friendsDictionary.friendsDictionary[currentUserID ?? ""]?.name ?? "") != "" {
                                    if isAFirstTimeUser != true {
                                        currentView = "Permission"
                                    } else {
                                    currentView = "CreateProfile"
                                    }
                                }
                            }) {
                                Text("Next")
                                    .font(.headline)
                                    .padding()
                                    .padding(.horizontal, 30)
                                    .foregroundColor(Color.white)
                                    .background(Color.speakerPurple.opacity(1))
                                    .clipShape(Capsule())
                            }
                            .padding(.top, 30)
                            
                        }
                        .offset(y: screenHeight/4.5)
                    }
                    Spacer()
                    HStack {
                        Button(action: {
                            currentView = "Introduction1"
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title3)
                                .foregroundColor(Color.mainColor.opacity(0.6))
                                .padding(5)
                                .background(Color.mainColorInverse.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        .padding(.leading, 10)
                        .padding(.bottom, 10)
                        Spacer()
                    }
                }
            }
            .frame(width: screenWidth/1.05, height: screenHeight / 1.1)
            .background(Color.mainColorInverse.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .animation(.easeIn(duration: 0.3))
        }
    }
}

struct IntroductionSelection3: View {
    @Binding var currentView: String
    @State var titleText = "Adding Friends"
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            
            Image(colorScheme == .light ? "coolBackground" : "Planes")
                .resizable()
                .scaledToFill()
            //                .edgesIgnoringSafeArea(.all)
                .blur(radius: 15)
                .frame(width: screenWidth, height: screenHeight)
            
            
            ZStack {
                VStack {
                    ZStack {
                        Image("friends")
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth/1.4267, height: screenHeight/3.087) // 300, 300
                        
                    }
                    .frame(width: screenWidth/1.05, height: screenHeight/3.087) // 300
                    .padding(screenWidth/10.7) // 40
                    .background(Color.mainColorInverse.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    ZStack {
                        VStack (alignment: .leading, spacing: 23) {
                            HStack {
                                ZStack {
                                    Text(titleText)
                                        .font(.largeTitle)
                                    Rectangle()
                                        .frame(width: CGFloat(titleText.count * 16), height: 2)
                                        .foregroundColor(Color.speakerPurple)
                                        .offset(y: 20)
                                }
                                Spacer()
                            }
                            Text("Is the most important step to getting started with speakEZ")
                                .font(.title3)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            Rectangle()
                                .frame(width: 30, height: 2)
                                .foregroundColor(Color.speakerPurple)
                            Text("Verify your phone number to find your friends!")
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.title3)
                            Rectangle()
                                .frame(width: CGFloat(titleText.count * 16 - 30), height: 2)
                                .foregroundColor(Color.speakerPurple)
                            
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 5)
                        
                        
                        VStack {
                            
                            Button(action: {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    currentView = "Two-Factor"
                                }
                            }) {
                                Text("Next")
                                    .font(.headline)
                                    .padding()
                                    .padding(.horizontal, 15)
                                    .foregroundColor(Color.white)
                                    .background(Color.speakerPurple.opacity(1))
                                    .clipShape(Capsule())
                            }
                            .padding(.top, 30)
                            
                        }
                        .offset(y: screenHeight/4.5)
                    }
                    Spacer()
                    HStack {
                        Button(action: {
                            currentView = "Permission"
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title3)
                                .foregroundColor(Color.mainColor.opacity(0.6))
                                .padding(5)
                                .background(Color.mainColorInverse.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        .padding(.leading, 10)
                        .padding(.bottom, 10)
                        Spacer()
                    }
                }
            }
            .frame(width: screenWidth/1.05, height: screenHeight / 1.1)
            .background(Color.mainColorInverse.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .animation(.easeIn(duration: 0.3))
        }
    }
}
struct IntroductionContacts: View {
    @Binding var currentView: String
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
            
            Image(colorScheme == .light ? "coolBackground" : "Planes")
                .resizable()
                .scaledToFill()
            //                .edgesIgnoringSafeArea(.all)
                .blur(radius: 15)
                .frame(width: screenWidth, height: screenHeight)
            
            
            ZStack {
                VStack {
                    HStack {
                        Text("Add Friends")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.leading, 3)
                        Spacer()
                        Button(action: {
                            currentView = "Home"
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
                                        let store = CNContactStore()
                                        store.requestAccess(for: .contacts) {  (granted, error) in
                                            
                                            if let error = error {
                                                print("failed to request access", error)
                                                return
                                            }
                                        }
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
                            currentView = "Introduction3"
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
                    guard let userId = Auth.auth().currentUser?.uid else { return }
                    
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
struct IntroductionPhoneNumber: View {
    @Binding var currentView: String
    @State var phoneNumber = ""
    @State var verificationCode = ""
    @State var y : CGFloat = 150
    @State var countryCode = ""
    @State var countryFlag = ""
    @State var keyboard = KeyboardOO()
    @State var contactsCount = 10
    @Environment(\.colorScheme) var colorScheme
    @State var showProgresser : Bool = false
    @State var isSkipButtonShowing = false
    @StateObject var phoneVM = PhoneVerificationVM()
    @EnvironmentObject var alert : AlertOO
    @State var isSkipAlertShowing = false
    @State var permissionAccess: [String]
    @State var isAFirstTimeUser: Bool
    var body: some View {
        GeometryReader { _ in
            ZStack {
                
                Image(colorScheme == .light ? "coolBackground" : "Planes")
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 15)
                    .frame(width: screenWidth, height: screenHeight)

                
                if showProgresser {
                    ProgressViewPurpleCircular().scaleEffect(3)
                }
                
                ZStack {
                    VStack {
                        VStack {
                            Text("Two-Factor Authentication")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.leading, 3)
                                .padding(.top, 5)
                                .padding(.leading, 16)
                            ZStack (alignment: .bottomLeading) {
                            Image("2FA")
                                .resizable()
                                .frame(width: screenWidth/1.2, height: screenHeight/3.087) // 300, 300
                                
                                if isSkipButtonShowing {
                                    if phoneVM.verificationID.isEmpty {
                                    Button(action: {
                                        isSkipAlertShowing = true
                                    
                                    }) {
                                        Text("Skip")
                                            .font(.footnote)
                                            .foregroundColor(Color.mainColor.opacity(0.6))
                                            .padding(7)
                                            .padding(.horizontal, 5)
                                            .background(Color.mainColorInverse.opacity(0.2))
                                            .clipShape(Capsule())
                                    }
                                    .padding(.trailing, 10)
                                    .offset(x: -20, y: 32)
                                    } else {
                                        Button(action: {
                                            phoneVM.verificationID = ""
                                        }) {
                                            Text("Back")
                                                .font(.footnote)
                                                .foregroundColor(Color.mainColor.opacity(0.6))
                                                .padding(7)
                                                .padding(.horizontal, 5)
                                                .background(Color.mainColorInverse.opacity(0.2))
                                                .clipShape(Capsule())
                                        }
                                        .padding(.trailing, 10)
                                        .offset(x: -20, y: 32)
                                    }
                                }
                            }
                            
                            
                        }
                        .frame(width: screenWidth/1.05)
                        .background(Color.mainColorInverse.opacity(0.2))
                        
                        ZStack {
                            if phoneVM.verificationID.isEmpty {

//
                                NumberPadFirstResponder(text: $phoneVM.phoneNumber, placeHolderText: "Phone Number", isPhoneNumber: true)
                                        .padding(32)
//                                        .padding(.leading, 20)
                                        .frame(width: 200, height: 50)
                                        .keyboardType(.phonePad)

                            } else {
                                
                                NumberPadFirstResponder(text: $phoneVM.verificationCode, placeHolderText: "Enter Verification Code")
                                    .padding(32)
//                                    .padding(.leading, 30)
                                    .frame(width: 200, height: 50)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .padding(.leading, 50)
                                
                            }

                            RoundedRectangle(cornerRadius: 10).stroke().background(Color.mainColorInverse.opacity(0.2))
                                .frame(width: 280, height: 50)
                                .opacity(self.y != 150 && keyboard.value > 0 ? 0 : 1)
                            
                            ZStack {
                                if phoneVM.verificationID.isEmpty {
                                    Button(action: {
 
                                        if showProgresser == false {
                                            showProgresser = true
                                            phoneVM.sendCode { error in
                                                showProgresser = false
                                                if let description = error?.localizedDescription{
                                                    alert.alertDetail = description
                                                }
                                            }
                                        }
                                    }) {
                                        ZStack {
                                            Text("Send Code")
                                                .font(.headline)
                                                .foregroundColor(Color.white)
                                        }
                                        .frame(width: 200, height: 50)
                                        .background(Color.speakerPurple)
                                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                                    }
                                    
                                    .opacity(phoneVM.phoneNumber.count < 10 || self.y != 150 ? 0.00 : 1.00)
                                    .disabled(phoneVM.phoneNumber.count < 10 || self.y != 150 ? true : false)
                                    .animation(.easeIn(duration: 0.3))
                                } else {
                                    Button(action: {

                                        if showProgresser == false {
                                            showProgresser = true
                                            phoneVM.signIn { error in
                                                showProgresser = false
                                                if let description = error?.localizedDescription{
                                                    alert.alertDetail = error.descriptionIfAny
                                                }else{
                                                    if permissionAccess.firstIndex(of: "Contacts") != nil || isAFirstTimeUser != true {
                                                                                      currentView = "Contacts"
                                                                                      } else {
                                                                                          currentView = "Home"
                                                                                      }
                                                }
                                            }
                                        }
                                       
                                    }) {
                                        ZStack {
                                            Text("Confirm")
                                                .font(.headline)
                                                .foregroundColor(Color.white)
                                        }
                                        .frame(width: 200, height: 50)
                                        .background(Color.speakerPurple)
                                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                                    }
                                    .animation(.easeIn(duration: 0.3))
                                }
                            }
                            .offset(y: 75)
                        }
//                        .offset(y: -150)
                        Spacer()
                        HStack {
                            Button(action: {
                                currentView = "Permission"
                                phoneVM.verificationID = ""
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
                        .opacity(y != 150 ? 0 : 1)
                        .disabled(y != 150 ? true : false)
                    }
                }
                .frame(width: screenWidth/1.05, height: screenHeight / 1.1)
                .background(Color.mainColorInverse.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .animation(.easeIn(duration: 0.3))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.easeIn(duration: 0.3)) {
                            isSkipButtonShowing = true
                        }
                    }
                }
                .alert(isPresented: $isSkipAlertShowing) {
       Alert(
           title: Text("Are you sure? Your friends will not be able to find you."),
                      primaryButton: .destructive(Text("Yes")) {
                          if permissionAccess.firstIndex(of: "Contacts") != nil || isAFirstTimeUser != true {
                                                            currentView = "Contacts"
                                                            } else {
                                                                currentView = "Home"
                                                            }
                          hideKeyboard()
//                          phoneVM.verificationID = ""
                          
                      },
                      secondaryButton: .cancel()
                  )
    }
                
                
            }
        }
        .ignoresSafeArea(.all)
    }
}

struct IntroductionCreateProfile: View {
    @Binding var currentView: String
    @Environment(\.colorScheme) var colorScheme
    @State var isShowingImagePicker = false
    @State var newMedia: NewMedia?
    @State var name: String = ""
    @State var username: String = ""
    @State var bio: String = ""
    @State var isUsernameTaken = false
    @State var school: String = ""
    @StateObject var functions = CreateProfileFunction()
    @StateObject var keyFunction = CreateTagFunction()
    @StateObject var editProfileFunction = EditProfileFunction()
    var allowedCharacters: [Character] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    let secretPassword = SecretPasswordFunction.savedSecretPassword
    @State var doesContainSpecialCharacter = false
    @State var showLoadingView = false
    @EnvironmentObject var alert : AlertOO
    @State var profileCreationError : ProfileCreationError?
    enum ProfileCreationError : String {
        case userNameTaken = "Username is already in use"
        case containSpecialCharacter = "Username contains an invalid character"
        case userNameAvailability = "something went wrong while checking Username availability"
        case profileCreate = "something went wrong while creating profile"
    }
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                let UserImage = newMedia?.image
                Image(colorScheme == .light ? "coolBackground" : "Planes")
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 15)
                    .frame(width: screenWidth, height: screenHeight)
                
                ZStack {
                    VStack {
                        HStack {
                            Image("speakEZLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: screenWidth/1.20, height: screenHeight/11)
                                .opacity(0.8)
                                .padding(.top, 15)
                        }
                        .presentMediaPicker(isPresented: $isShowingImagePicker, newMedia: $newMedia,parentView: .userProfile)

                        VStack  {
//                            ZStack  {
                            Rectangle()
                                .frame(width: screenWidth/1.05, height: 2)
                                .foregroundColor(Color.mainColorInverse)
//                                .offset(y: 5)
//                                Text("Create Profile")
//                                    .opacity(0.8)
////                                    .rotationEffect(.degrees(-3))
//                                    .offset(x: 10, y: -20)
//
//                            }
                            HStack(spacing: 0){
                                
                                Text("Name:")
                                    .font(.headline)
                                    .foregroundColor(Color.speakerPurple)
                                    .frame(width: screenWidth/3, alignment: .leading)
                                    .padding(.leading, 20)
                              
                                //
                                ZStack (alignment: .leading) {
//                                FirstResponder(text: $name, placeHolderText: "Tristan Winter")
                                    TextField("Tristan Winter", text: $name)
                                    .offset(x: 5)
                                    .frame(width: screenWidth/2, height: 35)
                                    .background(Color.mainColorInverse.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    Text("Create Profile")
                                        .opacity(0.8)
                                        .foregroundColor(Color.black)
                                        .offset(x: -0, y: -48)
                                }
                                Spacer()
                            }
                            Rectangle()
                                .frame(width: screenWidth/1.05, height: 2)
                                .foregroundColor(Color.mainColorInverse)
                            HStack(spacing: 0){
                                HStack (spacing: 0) {
                                    Text("Username:")
                                        .font(.headline)
                                        .foregroundColor(Color.speakerPurple)
                                    
                                    Text("*")
                                        .foregroundColor(Color.speakerPink)
                                        .offset(y: -3)
                                    
                                }
                                .frame(width: screenWidth/3, alignment: .leading)
                                .padding(.leading, 20)
                                TextField("tristan", text: $username)
                                    .offset(x: 5)
                                    .frame(width: screenWidth/2, height: 35)
                                    .background(Color.mainColorInverse.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                Spacer()
                            }
                            
                            Rectangle()
                                .frame(width: screenWidth/1.05, height: 2)
                                .foregroundColor(Color.mainColorInverse)
                            HStack(alignment: .center, spacing: 0){
                                Text("Profile Picture:")
                                    .font(.headline)
                                    .foregroundColor(Color.speakerPurple)
                                    .frame(width: screenWidth/3, alignment: .leading)
                                    .padding(.leading, 20)
                                Button(action: {
                                    showImagePicker()
                                }) {
                                    
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(Color.mainColorInverse.opacity(0.5))
                                        
                                            .frame(width: screenWidth/2, height: screenWidth/2)
                                        ZStack {
                                            if UserImage == nil {
                                                Image("tristan")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: screenWidth/2 - 20, height: screenWidth/2 - 20)
                                                Image(systemName: "plus.circle.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .foregroundColor(Color.mainColor)
                                                    .background(Circle().foregroundColor(.speakerPink))
                                                    .frame(width: 30, height: 30)
                                                    .offset(x: screenWidth/4, y: screenWidth/4 - 10)
                                                
                                            } else {
                                                if let UserImage = UserImage{ Image(uiImage: UserImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: screenWidth/2 - 10, height: screenWidth/2 - 10)
                                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                                }
                                            }
                                        }
                                    }
                                }
                                Spacer()
                            }
                            Rectangle()
                                .frame(width: screenWidth/1.05, height: 2)
                                .foregroundColor(Color.mainColorInverse)
                            
                        }
                        .padding(.top, 10)
                        if let profileCreationError = profileCreationError {
                            Text(profileCreationError())
                                .foregroundColor(.red)
                                .font(.subheadline)
                            
                        }

                        HStack {
                            Button(action: {
                                currentView = "Introduction2"
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.title3)
                                    .foregroundColor(Color.mainColor.opacity(0.6))
                                    .padding(5)
                                    .background(Color.mainColorInverse.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                            .offset(x: 5)
                            Spacer()
                        if username.count > 0 {
                            Button(action: {
                                hideKeyboard()
                                updateNameIfAvailabel()
    #if os(iOS)
                            let impactLight = UIImpactFeedbackGenerator(style: .soft)
                                            impactLight.impactOccurred()
    #endif

                            }) {
                                Text("Done")
                                    .font(.headline)
                                    .foregroundColor(Color.white)
                                    .padding(10)
                                    .padding(.horizontal, 10)
                                    .background(Color.speakerPurple.opacity(1).clipShape(Capsule()))
                            }
                        }
                            Spacer()
                        }
                        Spacer()
                        
                        
                    }
                    
                    
                }
                .frame(width: screenWidth/1.05, height: screenHeight / 1.1)
                .background(Color.mainColorInverse.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .animation(.easeIn(duration: 0.3))
                
            }
        }
        .ignoresSafeArea(.all)
    }
    func showImagePicker(){
//        hideStatusBar.wrappedValue = true
        isShowingImagePicker = true
    }
    func updateNameIfAvailabel() {
        guard showLoadingView == false else {
            //so user can not just call the updateNameIfAvailabel func over and over again
            return
        }
        guard username.lowercased().isAlphanumeric , let userId = Auth.auth().currentUser?.uid else {
            profileCreationError = .containSpecialCharacter
            return
        }
        
        if profileCreationError == .containSpecialCharacter {
            profileCreationError = nil
        }
       
        showLoadingView = true
        editProfileFunction.checkUsername(username) { isUsernameAvailable , error in
            
            if let error = error {
                showLoadingView = false
                profileCreationError = .userNameAvailability
                print(error.localizedDescription)
            }else if isUsernameAvailable {
                profileCreationError = nil
               
                let UserImage = newMedia?.image
                functions.createProfile(name: name == "" ? username : name,
                                        username: username,
                                        bio: bio,
                                        uid: userId,
                                        photo: UserImage,
                                        token: notificationToken,
                                        school: school,
                                        city: "",
                                        age: "",
                                        appPassword: secretPassword ?? "strawberry"){ error in
                    showLoadingView = false
                    if error == nil{
                        profileCreationError = nil
                        
                        currentView = "Permission"
//                        isFirstLogin = false
                    }else{
                        profileCreationError = .profileCreate
                    }
                }
                //                isFirstLogin = false
                keyFunction.createTag(name: "💜", description: "", friendIDs: [userId])
            }else{
                showLoadingView = false
                profileCreationError = .userNameTaken
            }
            
            
        }
    }
}

struct IntroductionPermissions: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var currentView: String
    @State var titleText = "Permissions"
    @Binding var permissionAccess: [String]
    @State var isSkipButtonShowing = false
    @State var isSkipAlertShowing = false
    @State var isAFirstTimeUser: Bool
    var body: some View {
        ZStack {
            
            Image(colorScheme == .light ? "coolBackground" : "Planes")
                .resizable()
                .scaledToFill()
                .blur(radius: 15)
                .frame(width: screenWidth, height: screenHeight)
            
            ZStack {
                VStack {
                ZStack {
                    
                    Image("permission")
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenWidth/1.6, height: screenHeight/3.4) // 300, 300
                    
                }
                .frame(width: screenWidth/1.05, height: screenHeight/3.087) // 300
                .padding(screenWidth/10.7) // 40
                .background(Color.mainColorInverse.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                    ZStack {
                        VStack (alignment: .leading, spacing: 23) {
                            HStack {
                                
                                ZStack {
                                    Text(titleText)
                                        .font(.largeTitle)
                                    Rectangle()
                                        .frame(width: CGFloat(titleText.count * 16), height: 2)
                                        .foregroundColor(Color.speakerPurple)
                                        .offset(y: 20)
                                }
                         
                                Spacer()
                            }
                            VStack (alignment: .leading, spacing: 23) {
                            IntroductionIndividualPermissions(title: "Notifications", description: "so you don't leave your friends on read", image: "bell", isImageInAssets: false, permissionAccess: $permissionAccess)
                            Rectangle()
                                .frame(width: 30, height: 2)
                                .foregroundColor(Color.speakerPurple)
                            IntroductionIndividualPermissions(title: "Contacts", description: "so you can find your friends... this app sucks without friends", image: "list.dash", isImageInAssets: false, permissionAccess: $permissionAccess)
                            Rectangle()
                                .frame(width: CGFloat(titleText.count * 16 - 30), height: 2)
                                .foregroundColor(Color.speakerPurple)
                            } .padding(.top, -5)
                            
                            
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 5)
                        
                        
                        VStack {
                            
                            Button(action: {
                                withAnimation(.easeIn(duration: 0.3)) {
//                                    if permissionAccess.firstIndex(of: "Contacts") != nil {
//                                    currentView = "Contacts"
//                                    } else {
//                                        currentView = "Home"
//                                    }
                                    currentView = "Two-Factor"
                                }
                            }) {
                                Text("Next")
                                    .font(.headline)
                                    .padding()
                                    .padding(.horizontal, 30)
                                    .foregroundColor(Color.white)
                                    .background(permissionAccess.count != 2 ? Color.speakerPurple.opacity(0.1) : Color.speakerPurple.opacity(1))
                                    .clipShape(Capsule())
                                
                            }
                            .disabled(permissionAccess.count == 2 ? false : true)
                            .padding(.top, 30)
                            
                        }
                        .offset(y: screenHeight/4.5)
                    }
                    Spacer()
                    HStack {
                        Button(action: {
                            currentView = "Introduction1"
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
                        if isSkipButtonShowing {
                        Button(action: {
                            isSkipAlertShowing = true
                        }) {
                            Text("Skip")
                                .font(.footnote)
                                .foregroundColor(Color.mainColor.opacity(0.6))
                                .padding(7)
                                .padding(.horizontal, 5)
                                .background(Color.mainColorInverse.opacity(0.2))
                                .clipShape(Capsule())
                        }
                        .padding(.trailing, 5)
                        }

                    }
                    .padding(.bottom, 10)
                }
            }
            .frame(width: screenWidth/1.05, height: screenHeight / 1.1)
            .background(Color.mainColorInverse.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .animation(.easeIn(duration: 0.3))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        isSkipButtonShowing = true
                    }
                }
            }
            .alert(isPresented: $isSkipAlertShowing) {
   Alert(
       title: Text("Are you sure? speakEZ won't work without Permissions."),
                  primaryButton: .destructive(Text("Yes")) {
//                      if isAFirstTimeUser {
//                          currentView = "Home"
//                      } else {
//                          currentView = "Contacts"
//                      }
                      currentView = "Two-Factor"
                 
                  },
                  secondaryButton: .cancel()
              )
}
        }
    }
}

struct IntroductionIndividualPermissions: View {
    @State var title: String = "Camera"
    @State var description: String = "to take pictures and videos"
    @State var image: String = "camera1"
    @State var isImageInAssets = true
    @Binding var permissionAccess: [String]
    var body: some View {
        HStack {
            if isImageInAssets {
            Image(image)
                .resizable()
                .frame(width: 40, height: 40)
            } else {
                Image(systemName: image)
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            VStack (alignment: .leading) {
              Text(title)
                    .font(.headline)
            Text(description)
                    .font(.caption)
            }
            Spacer()
            Button(action: {
                if permissionAccess.firstIndex(of: title) == nil {
                    if title == "Contacts" {
                        let store = CNContactStore()
                        store.requestAccess(for: .contacts) {  (granted, error) in
                            
                            if let error = error {
                                print("failed to request access", error)
                                return
                            }
                            if granted {
                                permissionAccess.append("Contacts")
                            }
                        }
                    
              
                    } else {
                        let center = UNUserNotificationCenter.current()
                        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                            
                            if let error = error {
                                print(error)
                            }
                            if granted {
                            permissionAccess.append("Notifications")
                            }
                          
                        }
                    }
                } else {
                    if let firstIndex = permissionAccess.firstIndex(of: title) {
                    permissionAccess.remove(at: firstIndex)
                    }
                }
            }) {
                Circle()
                    .fill(permissionAccess.firstIndex(of: title) != nil ? Color.speakerPurple : Color.speakerPurple.opacity(0.1))
                    .frame(width: 30, height: 30)
            }
        }
        .padding(.horizontal, 10)
        .frame(width: screenWidth/1.1, height: 70) // 300
//                            .padding(screenWidth/10.7) // 40
        .background(Color.mainColorInverse.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
