//////
//////  OSHome.swift
//////  speakEZ crossplatform (macOS)
//////
//////  Created by Carson O'Sullivan on 1/31/21.
////
//
import SwiftUI

//
struct OSHomeController: View {
    @StateObject var timelinePosts = TimelinePostsOO()
    @StateObject var friendsDictionary = FriendsDictionary()
    @StateObject var navigation = OSNavigationOO()
    var body: some View {
        ZStack{
            Color.red
            OSHome()
                .environmentObject(friendsDictionary)
                .environmentObject(timelinePosts)
                .environmentObject(navigation)
        }
        
    }
}
//
struct OSHome: View {
    @EnvironmentObject var navigation : OSNavigationOO
    @EnvironmentObject var timelinePosts : TimelinePostsOO
    @EnvironmentObject var friendsDictionary : FriendsDictionary
    
    var body: some View {
        ZStack {
          
        HStack {
            VStack{
                // tab Buttons....
                OSNavigationButton(image: "notification", title: "Notifications", selectedTab: $navigation.selectedTab)
                OSNavigationButton(image: "hexagon", title: "Friends", selectedTab: $navigation.selectedTab)
                OSNavigationButton(image: "chat-bubble", title: "Messages", selectedTab: $navigation.selectedTab)
                OSNavigationButton(image: "speak", title: "New Post", selectedTab: $navigation.selectedTab)
                OSNavigationButton(image: "home", title: "Home", selectedTab: $navigation.selectedTab)
                Spacer()
                
                OSNavigationButton(image: "user", title: "Profile", selectedTab: $navigation.selectedTab)
            }
            .offset(x: screenWidth/597.34)
            .padding()
            .padding(.top, screenWidth/51.2)
//
//        case "Messages": OSAllMessages(messages: AllMessagesOO(friendsDictionary: timelinePosts.friendsDictionary)
            
            ZStack {
                switch navigation.selectedTab {
                case "Notifications": Text("Notifications")
                   #if os(iOS)
                    //FIXME: - we need to init it like this with postTimeLine friendsDict  "AllMessagesOO(friendsDictionary: timelinePosts.friendsDictionary)"
                 #endif
                case "Messages": OSAllMessages(messages: AllMessagesOO(friendsDictionary: friendsDictionary))
                case "Friends": OSAllFriends()
                case "Profile": OSProfile()
                case "New Post": OSNewPosts()
                case "Home": OSTimelineMainView()
                default : OSTimelineMainView()
                }
                
             
            }
            .padding(.trailing, screenWidth/179.2) // 10
            .padding(.top,  screenWidth/179.2)
            .frame(maxWidth: screenWidth/2, maxHeight: .infinity)
            .animation(.none)
         
        }

    }

//        .background(BlurView())
        .ignoresSafeArea(.all)
    }
}
//
//struct OSNavigationButton: View {
//    
//    var image: String
//    var title: String
//    @Binding var selectedTab : String
//    
//    var body: some View {
//        
//        Button(action: {withAnimation{selectedTab = title}}, label: {
//            
//            VStack(spacing: 7){
//                
//                Image(image)
//                    .font(.system(size: 16, weight: .semibold))
//                    .foregroundColor(selectedTab == title ? .primary : .gray)
//                
//                Text(title)
//                    .fontWeight(.semibold)
//                    .font(.system(size: 11))
//                    .foregroundColor(selectedTab == title ? .primary : .gray)
//            }
//            .padding(.vertical,8)
//            .contentShape(Rectangle())
//            .frame(width: 75, height: 75)
//            .background(Color.purple.opacity(selectedTab == title ? 0.15 : 0))
//            .cornerRadius(10)
//        })
//        .buttonStyle(PlainButtonStyle())
//    }
//}
//
//
//struct BlurView: NSViewRepresentable {
//
//    func makeNSView(context: Context) -> NSVisualEffectView {
//
//        let view = NSVisualEffectView()
//        view.blendingMode = .behindWindow
//
//        return view
//    }
//
//    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
//
//    }
//}
//
struct OSHeaderButton: View {
    var image: String
    var action: () -> Void
    var body: some View {
        Image(systemName: image)
            .resizable()
            .padding(.horizontal, 14)
            .onTapGesture {
                withAnimation(.easeIn(duration: 0.3)) {
                    action()
                }
            }
    }
}
