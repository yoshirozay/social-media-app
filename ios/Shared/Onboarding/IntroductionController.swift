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
    @State var currentView : CurrentIntroView = .IntroSpeakEZ
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var allChats: AllMessagesOO
    @ObservedObject var timelinePosts: TimelinePostsOO
    @Binding var signOut: Bool
    @Binding var newMedia: SelectedMedia?
    var persistenceController = PersistenceController.shared
    @ObservedObject var intro: IntroVideoOO
    @ObservedObject var notifications: NotificationsOO
    @ObservedObject var firstLogin: FirstLoginOO
    @State var emptyStringBinding = ""
    @StateObject var permissonVM = PermissionVM()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL

    //Flow is: IntroSpeakEZ -> Permissions -> CreateProfile -> TwoFactor -> SuggestedFriends/Contacts
    var body: some View {
        ZStack {
            switch currentView {
            case .IntroSpeakEZ:
                IntroSpeakEZ(currentView: $currentView, firstLogin: firstLogin)
                    .transition(AnyTransition.asymmetric(
                        insertion:.move(edge: .trailing),
                        removal: .move(edge: .leading)))
            case .CreateProfile:
                IntroductionCreateProfile(currentView: $currentView,intro: intro,firstLogin: firstLogin)
                    .transition(AnyTransition.asymmetric(
                        insertion:.move(edge: .trailing),
                        removal: .move(edge: .leading)))
            case .Permission:
                IntroductionPermissions(currentView: $currentView, firstLogin: firstLogin, permissonVM: permissonVM)
                    .transition(AnyTransition.asymmetric(
                        insertion:.move(edge: .trailing),
                        removal: .move(edge: .leading)))
            case .Two_Factor:
                IntroductionPhoneNumber(currentView: $currentView,firstLogin: firstLogin)
                    .transition(AnyTransition.asymmetric(
                        insertion:.move(edge: .trailing),
                        removal: .move(edge: .leading)))
            case .Contacts:
                IntroductionContacts(currentView: $currentView, suggestedFriends: SuggestedFriendsOO(friendsDictionary: friendsDictionary), friendsDictionary: friendsDictionary)
                    .transition(AnyTransition.asymmetric(
                        insertion:.move(edge: .trailing),
                        removal: .move(edge: .leading)))
                 
                
            case .Home:
                Image(colorScheme == .light ? "coolBackground" : "Planes")
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 15)
                    .frame(width: screenWidth, height: screenHeight)
                    .opacity(showHomeFromUndernathe ? 0 : 0.8)
                    .onAppear{
                        withAnimation(.easeIn(duration: 1)) {
                            showHomeFromUndernathe = true
                        }
                }
            }
        }.onChange(of: currentView) { view in
            if view == .Home{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        intro.showIntroController = false
                }
            }
        }.onReceive(permissonVM.openDeviceSetting) { openSetting in 
                openURL(openSetting)
        }
    }
    
    @State var showHomeFromUndernathe = false
    
   
}
 
enum CurrentIntroView: String {
    case IntroSpeakEZ
    case CreateProfile
    case Two_Factor = "Two-Factor"
    case Permission
    case Contacts
    case Home
}
 
enum PermissonType : String{
    case contacts = "Contacts"
    case pushNotifications = "Notifications"
}

/*
 so what is happening is that when user gets done with creating a profile we want to mark it at
 intro.showIntroController = false
 but when that happens
 */
