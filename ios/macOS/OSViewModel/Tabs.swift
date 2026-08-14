//
//  Tabs.swift
//  speakEZ crossplatform (iOS)
//
//  Created by Carson O'Sullivan on 1/31/21.
//

import SwiftUI

class OSNavigationOO: ObservableObject {
    @Published var selectedTab = "Home"
    
    enum MainView : String {
        case  Notifications
        case  Messages
        case  Friends
        case  Profile
        case  NewPost = "New Post"
        case  Home
    }
    
    func changeTo(_ mainView : MainView){
        selectedTab = mainView()
    }
}
 
