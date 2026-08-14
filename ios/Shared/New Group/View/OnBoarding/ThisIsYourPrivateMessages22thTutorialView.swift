//
//  ThisIsYourPrivateMessages22thTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/8/21.
//

import SwiftUI
 
//MARK:- tutorial number  21 (22 on slide)
struct ThisIsYourPrivateMessages21thTutorialView  : View {
     
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    let detail = "This is your private messages"
    var body : some View {
        ZStack{
            CenteredTextWithNexButtonView(detail: detail, width : 270)
        }
        .highPriorityGesture(DragGesture())
    }
}
