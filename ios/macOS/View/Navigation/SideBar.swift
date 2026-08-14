//
//  NavigationButtons.swift
//  speakEZ crossplatform (iOS)
//
//  Created by Carson O'Sullivan on 1/31/21.
//

import SwiftUI
 
struct SideBar: View {
    @StateObject var navigation = OSNavigationOO()
    
    var body: some View {
            VStack{
                // tab Buttons....
                OSNavigationButton(image: "notification", title: "Notifications", selectedTab: $navigation.selectedTab)
                
                OSNavigationButton(image: "chat-bubble", title: "Messages", selectedTab: $navigation.selectedTab)

                OSNavigationButton(image: "hexagon", title: "Friends", selectedTab: $navigation.selectedTab)

                OSNavigationButton(image: "user", title: "Profile", selectedTab: $navigation.selectedTab)

                OSNavigationButton(image: "speak2", title: "New Post", selectedTab: $navigation.selectedTab)
                
                Spacer()
                
                OSNavigationButton(image: "user", title: "Settings", selectedTab: $navigation.selectedTab)
            }
            .padding()
            .padding(.top,35)
        
    }
}
 
struct BlurView: NSViewRepresentable {

    func makeNSView(context: Context) -> NSVisualEffectView {

        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow

        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {

    }
}

