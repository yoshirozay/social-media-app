//
//  ArcMenu.swift
//  speakEZ crossplatform (iOS)
//
//  Created by Carson O'Sullivan on 7/14/21.
//

import SwiftUI
import Firebase

struct ArcMenu: View {
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    @Binding var isNavigationMenuShowing: Bool
    @State var iconPosition = false
    @Binding var NotificationstMatchedGeometry: String
    @Binding var AllFriendsMatchedGeometry: String
    @Binding var AllMessagesMatchedGeometry: String
    @Binding var NewPostMatchedGeometry: String
    @Binding var newRequest: Bool
    var backgroundColor: Color = .supportingColor
    var backgroundColor2: Color = .speakerPink
    var backgroundColor3: Color = Color.blue
    var isOnlyMessagesShowing: Bool = false
    var isOnlyFriendRequestShowing: Bool = false  
    @EnvironmentObject var notifications: NotificationsOO
    @EnvironmentObject var allMessages: AllMessagesOO
    
#if os(macOS)
    @Binding var selectedTab: String
#endif

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .stroke()
                    .frame(width: 150, height: 150)
                    .opacity(0)
                
                ArcMenuButton(imageName: "notification",  backgroundColor: notifications.newNotifications.count != 0
                              ? Color.supportingColor.opacity(0.00) : Color.supportingColor.opacity(0.00)){
                    
//                    if notifications.notifications.count != 0 {
//                        functions.readNotification(notificationInformation: notifications.cloudNotifications)
//                    }
                    notifications.readNotification()
#if os(iOS)
                    NotificationstMatchedGeometry = "0"
#elseif os(macOS)
                    selectedTab = MacOSHome.Constant.notifications.selectionKey
#endif 
                }
                    .offset(x: -75)
                    .rotationEffect(.degrees(iconPosition ? 0 : -90))
                .animation(Animation.easeInOut(duration: 0.5).delay(0.2))
                .animation(Animation.easeOut(duration: 1))
                .disabled(tutorialNumber == 2 || tutorialNumber == 5)
                
                ArcMenuButton(imageName: "chat-bubble", backgroundColor2: allMessages.doesUserHaveAMessage == true ? Color.speakerPink : Color.speakerPink.opacity(0.00) ){
                    allMessages.readMessage()
#if os(iOS)
                    AllMessagesMatchedGeometry = "0"
#elseif os(macOS)
                    selectedTab = MacOSHome.Constant.allMessages.selectionKey
#endif
                }
                .offset(x: -75)
                .rotationEffect(.degrees(iconPosition ? 30 : -90))
                .animation(Animation.easeIn(duration: 0.5).delay(0.1))
                .animation(Animation.easeOut(duration: 1))
                .disabled(tutorialNumber == 2 || tutorialNumber == 5)
#if os(iOS)
                let userImageName = "user"
#elseif os(macOS)
                let userImageName =  MacOSHome.Constant.friends.imageName
#endif
                ArcMenuButton(imageName: userImageName, backgroundColor3: newRequest == true ? Color.blue : Color.blue.opacity(0.00)){
                    if tutorialNumber == 2 {
                        tutorialNumber = 3
                    }
#if os(iOS)
                    AllFriendsMatchedGeometry = "0"
#elseif os(macOS)
                    selectedTab = MacOSHome.Constant.friends.selectionKey
#endif
                }
                    .offset(x: -75)
                    .rotationEffect(.degrees(iconPosition ? 60 : -90))
                .animation(Animation.easeIn(duration: 0.5).delay(0.05))
                .animation(Animation.easeOut(duration: 1))
                .disabled(tutorialNumber == 5)
              
                ArcMenuButton(imageName: "speak"){
#if os(iOS)
                    NewPostMatchedGeometry = "0"
#elseif os(macOS)
                    selectedTab = MacOSHome.Constant.newPost.selectionKey
#endif
                    if tutorialNumber == 5 {
                        tutorialNumber = 6
                    }
                }
                    .offset(x: -75)
                    .rotationEffect(.degrees(iconPosition ? 90 : -90))
                .animation(Animation.easeIn(duration: 0.5))
                .animation(Animation.easeOut(duration: 1))
                .disabled(tutorialNumber == 2)
                  
            }
            .clipShape(Rectangle().offset(x: -20, y: -50))
//            .offset(x: 150, y: 335)
            ArcMenuHomeButton(backgroundColor: notifications.newNotifications.count != 0 ? Color.supportingColor : Color.supportingColor.opacity(0.00), backgroundColor2: allMessages.doesUserHaveAMessage == true ? Color.speakerPink : Color.speakerPink.opacity(0.00), backgroundColor3: newRequest == true ? Color.blue : Color.blue.opacity(0.00), isOnlyMessagesShowing: notifications.newNotifications.count == 0 && allMessages.doesUserHaveAMessage == true ? true : false, isOnlyFriendRequestShowing: allMessages.doesUserHaveAMessage == false && notifications.newNotifications.count == 0 ? true : false) {
                if tutorialNumber == 1{
                    tutorialNumber = 2
                }
                isNavigationMenuShowing.toggle()
                self.iconPosition.toggle()
#if os(iOS)
                let impactLight = UIImpactFeedbackGenerator(style: .heavy)
                                impactLight.impactOccurred() 
#endif
                
            }.disabled(tutorialNumber == 2 || tutorialNumber == 5)
//             let _ = print("tutorialNumber ",tutorialNumber)
        }
    }
}

struct ArcMenuHomeButton: View {

    var backgroundColor: Color = .supportingColor
    var backgroundColor2: Color = .speakerPink
    var backgroundColor3: Color = Color.blue
    var isOnlyMessagesShowing: Bool = false
    var isOnlyFriendRequestShowing: Bool = false
    var action: () -> Void
    var body: some View {
        ZStack {
            
            // FAB Icon
            Button(action: {
               action()
            }) {
                Image("filter")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .padding(10)
            }.buttonStyle(.borderless)
            .background(LinearGradient(gradient: .init(colors: [Color.speakerPink.opacity(0.8), Color.speakerPurple.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
            .foregroundColor(.white)
            .clipShape(Circle())
            ZStack {
                    
                Circle()
                    .frame(width: 13, height: 13)
                    .offset(x: 19, y: 24)
                    .foregroundColor(isOnlyMessagesShowing == false ? backgroundColor2 : backgroundColor2.opacity(0.0))
                Circle()
                    .frame(width: 13, height: 13)
                    .offset(x: 12, y: 24)
                    .foregroundColor(isOnlyMessagesShowing == false ? backgroundColor : backgroundColor2)
                Circle()
                    .frame(width: 13, height: 13)
                    .offset(x: isOnlyFriendRequestShowing == false ? 5 : 12, y: 24)
                    .foregroundColor(backgroundColor3)
            }
        }
    }
}

struct ArcMenuButton: View {
    var imageName: String
    var backgroundColor: Color = .supportingColor
    var backgroundColor2: Color = .speakerPink
    var backgroundColor3: Color = Color.blue
    var action: () -> Void
    
#if os(macOS)
    @State var bugRotationDegree : Double = 0
#endif

    var body: some View {
        ZStack {
            Button(action: { action() }, label: {
                Image(imageName)
                    .resizable()
                    .frame(width: 18, height: 18)
                    .padding(10)
//
            }).buttonStyle(.borderless)
//            .rotationEffect(.degrees(imageName == "speak" ? -90 : 0))
//            .rotationEffect(.degrees(imageName == "user" ? -60 : 0))
//            .rotationEffect(.degrees(imageName == "chat-bubble" ? chatBubble : 0))
            .rotationEffect(.degrees(rotationDegree)) 
            .background(LinearGradient(gradient: .init(colors: [Color.speakerPurple.opacity(0.8), Color.speakerPink.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
            .foregroundColor(.white)
            .clipShape(Circle())
            ZStack {
                if imageName == Constant.notification() {
                Circle()
                    .foregroundColor(backgroundColor)
                    .frame(width: 11, height: 11)
                    .offset(x: 11, y: 11)
                }
                if imageName == Constant.chatBubble() {
                Circle()
                    .foregroundColor(backgroundColor2)
                    .frame(width: 11, height: 11)
                    .offset(x: 16, y: 4)
                  
                }
                
                if imageName == Constant.user() {
                Circle()
                    .foregroundColor(backgroundColor3)
                    .frame(width: 11, height: 11)
                    .offset(x: 15, y: -5)
                }
              
//                    .foregroundColor(imageName == "user" ? backgroundColor3: .clear)
////                : imageName == "chat-bubble" ? backgroundColor2 : imageName == "user" ? backgroundColor3 : Color.mainColorInverse.opacity(0.0))
//                    .frame(width: 11, height: 11)
//                    .offset(x: imageName == "notification" ? 11 : 0, y: imageName == "notification" ? 11 : 0)
//
//                    .offset(x: imageName == "chat-bubble" ? 15 : 0, y: imageName == "chat-bubble" ? -5 : 0)
//                    .offset(x: imageName == "user" ? 10 : 0, y: imageName == "user" ? -12 : 0)
//                    .foregroundColor(.speakerPink)
            }
        }
        
#if os(macOS)
        //we are doing this because there is a bug in macOS that it -30 rotation do not work as expected. but it does work if user taps or we set it after the int
        .onAppear{
            if  imageName == Constant.user(){
                bugRotationDegree = -60
            } else if  imageName == Constant.chatBubble(){
                bugRotationDegree = -30
            }
        }
    #endif
    
    }
  
    var rotationDegree :  Double {
        var degree = 0.0
        if imageName == Constant.speak() {
            degree =  -90
        } else if imageName == Constant.user(){
#if os(iOS)
            degree = -60
#elseif os(macOS)
            degree = bugRotationDegree
#endif
        } else if imageName == Constant.chatBubble(){
#if os(iOS)
            degree = -30
#elseif os(macOS)
            degree = bugRotationDegree
#endif
        }
        return degree
    }
    
    enum Constant : String{
        case notification
        case speak
        case chatBubble = "chat-bubble"
#if os(iOS)
        case user
#elseif os(macOS)
        case user = "hexagon"
#endif
 
    }

}


struct ArcMenu2: View {
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    @Binding var isNavigationMenuShowing: Bool
    @State var iconPosition = true
    @Binding var NotificationstMatchedGeometry: String
    @Binding var AllFriendsMatchedGeometry: String
    @Binding var AllMessagesMatchedGeometry: String
    @Binding var NewPostMatchedGeometry: String
    @Binding var newRequest: Bool
    var backgroundColor: Color = .supportingColor
    var backgroundColor2: Color = .speakerPink
    var backgroundColor3: Color = Color.blue
    var isOnlyMessagesShowing: Bool = false
    var isOnlyFriendRequestShowing: Bool = false
    @EnvironmentObject var notifications: NotificationsOO
    @EnvironmentObject var allMessages: AllMessagesOO
    @StateObject var friendFunctions = FriendRequestsFunctions()
#if os(macOS)
    @Binding var selectedTab: String
#endif

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .stroke()
                    .frame(width: 300, height: 300)
                    .opacity(0)
                
                ArcMenuButton2(imageName: "calendar",  backgroundColor: notifications.newNotifications.count != 0 && iconPosition
                               ? Color.supportingColor.opacity(0.00) : Color.supportingColor.opacity(0.00)){
                    
//                    if notifications.notifications.count != 0 {
//                        functions.readNotification(notificationInformation: notifications.cloudNotifications)
//                    }
//                    notifications.readNotification()
#if os(iOS)
                    NotificationstMatchedGeometry = "0"
#elseif os(macOS)
                    selectedTab = MacOSHome.Constant.notifications.selectionKey
#endif
                }
                    .offset(x: -135)
                    .rotationEffect(.degrees(iconPosition ? 0 : -90))
                .animation(Animation.easeInOut(duration: 0.5).delay(0.2))
                .animation(Animation.easeOut(duration: 1))
                .disabled(tutorialNumber == 2 || tutorialNumber == 5)
                
                ArcMenuButton2(imageName: "bubble.right", backgroundColor2: allMessages.doesUserHaveAMessage == true && iconPosition ? Color.speakerPink : Color.speakerPink.opacity(0.00) ){
                    allMessages.readMessage()
#if os(iOS)
                    AllMessagesMatchedGeometry = "0"
#elseif os(macOS)
                    selectedTab = MacOSHome.Constant.allMessages.selectionKey
#endif
                }
                .offset(x: -135)
                .rotationEffect(.degrees(iconPosition ? 30 : -90))
                .animation(Animation.easeIn(duration: 0.5).delay(0.1))
                .animation(Animation.easeOut(duration: 1))
                .disabled(tutorialNumber == 2 || tutorialNumber == 5)
#if os(iOS)
                let userImageName = "person"
#elseif os(macOS)
                let userImageName =  MacOSHome.Constant.friends.imageName
#endif
                ArcMenuButton2(imageName: userImageName, backgroundColor3: newRequest == true && iconPosition ? Color.blue : Color.blue.opacity(0.00)){
//                    if tutorialNumber == 2 {
//                        tutorialNumber = 3
//                    }
                    if newRequest == true {
                        friendFunctions.readFriendRequest()
                    }
#if os(iOS)
                    AllFriendsMatchedGeometry = "0"
#elseif os(macOS)
                    selectedTab = MacOSHome.Constant.friends.selectionKey
#endif
                }
                    .offset(x: -135)
                    .rotationEffect(.degrees(iconPosition ? 60 : -90))
                .animation(Animation.easeIn(duration: 0.5).delay(0.05))
                .animation(Animation.easeOut(duration: 1))
              
                ArcMenuButton2(imageName: "square.and.pencil"){
#if os(iOS)
                    NewPostMatchedGeometry = "0"
#elseif os(macOS)
                    selectedTab = MacOSHome.Constant.newPost.selectionKey
#endif
                    if tutorialNumber == 5 {
                        tutorialNumber = 6
                    }
                }
                    .offset(x: -135)
                    .rotationEffect(.degrees(iconPosition ? 90 : -90))
                .animation(Animation.easeIn(duration: 0.5))
                .animation(Animation.easeOut(duration: 1))
                .disabled(tutorialNumber == 2)
                  
            }
            .clipShape(Rectangle().offset(x: -20, y: -50))
//            .offset(x: 150, y: 335)
            ArcMenuHomeButton2(backgroundColor: notifications.newNotifications.count != 0 ? Color.supportingColor.opacity(0.00) : Color.supportingColor.opacity(0.00), backgroundColor2: allMessages.doesUserHaveAMessage == true ? Color.speakerPink : Color.speakerPink.opacity(0.00), backgroundColor3: newRequest == true ? Color.blue : Color.blue.opacity(0.00), isOnlyMessagesShowing: notifications.newNotifications.count == 0 && allMessages.doesUserHaveAMessage == true ? true : false, isOnlyFriendRequestShowing: allMessages.doesUserHaveAMessage == false && notifications.newNotifications.count == 0 ? true : false) {
                if tutorialNumber == 1{
                    tutorialNumber = 2
                }
                isNavigationMenuShowing.toggle()
                self.iconPosition.toggle()
#if os(iOS)
                let impactLight = UIImpactFeedbackGenerator(style: .heavy)
                                impactLight.impactOccurred()
#endif
                
            }.disabled(tutorialNumber == 2 || tutorialNumber == 5)
//             let _ = print("tutorialNumber ",tutorialNumber)
        }
    }
}

struct ArcMenuHomeButton2: View {

    var backgroundColor: Color = .supportingColor
    var backgroundColor2: Color = .speakerPink
    var backgroundColor3: Color = Color.blue
    var isOnlyMessagesShowing: Bool = false
    var isOnlyFriendRequestShowing: Bool = false
    var action: () -> Void
    var body: some View {
        ZStack {
            
            // FAB Icon
            Button(action: {
               action()
            }) {
                Image("filter")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .padding(10)
                    .offset(y: 3)
            }.buttonStyle(.borderless)
            .background(LinearGradient(gradient: .init(colors: [Color.speakerPink.opacity(0.8), Color.speakerPurple.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
            .foregroundColor(.white)
            .clipShape(Circle())
            ZStack {
                    
                Circle()
                    .frame(width: 22, height: 22)
                    .offset(x: 26, y: 33)
                    .foregroundColor(isOnlyMessagesShowing == false ? backgroundColor2 : backgroundColor2.opacity(0.0))
                Circle()
                    .frame(width: 22, height: 22)
                    .offset(x: 17.5, y: 33)
                    .foregroundColor(isOnlyMessagesShowing == false ? backgroundColor : backgroundColor2)
                Circle()
                    .frame(width: 22, height: 22)
                    .offset(x: isOnlyFriendRequestShowing == false ? 10 : 17.5, y: 33)
                    .foregroundColor(backgroundColor3)
            }
        }
    }
}

struct ArcMenuButton2: View {
    var imageName: String
    var backgroundColor: Color = .supportingColor
    var backgroundColor2: Color = .speakerPink
    var backgroundColor3: Color = Color.blue
    var action: () -> Void
    
#if os(macOS)
    @State var bugRotationDegree : Double = 0
#endif

    var body: some View {
        ZStack {
            Button(action: { action() }, label: {
                Image(systemName: imageName)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .padding(17)
                    .offset(x: (imageName == "square.and.pencil" ? 3 : 0), y: (imageName == "square.and.pencil" ? -2 : 0))
                    .offset(x: (imageName == "bubble.right" ? 0 : 0), y: (imageName == "bubble.right" ? 2 : 0))
//
            }).buttonStyle(.borderless)
//            .rotationEffect(.degrees(imageName == "speak" ? -90 : 0))
//            .rotationEffect(.degrees(imageName == "user" ? -60 : 0))
//            .rotationEffect(.degrees(imageName == "chat-bubble" ? chatBubble : 0))
            .rotationEffect(.degrees(rotationDegree))
            .background(LinearGradient(gradient: .init(colors: [Color.speakerPurple.opacity(0.8), Color.speakerPink.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
            .foregroundColor(.white)
            .clipShape(Circle())
            ZStack {
                if imageName == Constant.bell() {
                Circle()
                    .foregroundColor(backgroundColor)
                    .frame(width: 18, height: 18)
                    .offset(x: 20, y: 25)
                }
                if imageName == Constant.bubble() {
                Circle()
                    .foregroundColor(backgroundColor2)
                    .frame(width: 18, height: 18)
                    .offset(x: 30, y: 8)
                  
                }
                
                if imageName == Constant.person() {
                Circle()
                    .foregroundColor(backgroundColor3)
                    .frame(width: 18, height: 18)
                    .offset(x: 30, y: -12)
                }
              
//                    .foregroundColor(imageName == "user" ? backgroundColor3: .clear)
////                : imageName == "chat-bubble" ? backgroundColor2 : imageName == "user" ? backgroundColor3 : Color.mainColorInverse.opacity(0.0))
//                    .frame(width: 11, height: 11)
//                    .offset(x: imageName == "notification" ? 11 : 0, y: imageName == "notification" ? 11 : 0)
//
//                    .offset(x: imageName == "chat-bubble" ? 15 : 0, y: imageName == "chat-bubble" ? -5 : 0)
//                    .offset(x: imageName == "user" ? 10 : 0, y: imageName == "user" ? -12 : 0)
//                    .foregroundColor(.speakerPink)
            }
        }
        
#if os(macOS)
        //we are doing this because there is a bug in macOS that it -30 rotation do not work as expected. but it does work if user taps or we set it after the int
        .onAppear{
            if  imageName == Constant.person(){
                bugRotationDegree = -60
            } else if  imageName == Constant.bubble(){
                bugRotationDegree = -30
            }
        }
    #endif
    
    }
  
    var rotationDegree :  Double {
        var degree = 0.0
        if imageName == Constant.square() {
            degree =  -90
        } else if imageName == Constant.person(){
#if os(iOS)
            degree = -60
#elseif os(macOS)
            degree = bugRotationDegree
#endif
        } else if imageName == Constant.bubble(){
#if os(iOS)
            degree = -30
#elseif os(macOS)
            degree = bugRotationDegree
#endif
        }
        return degree
    }
    
    enum Constant : String{
        case bell
        case square = "square.and.pencil"
        case bubble = "bubble.right"
#if os(iOS)
        case person
#elseif os(macOS)
        case person = "person"
#endif
 
    }

}

