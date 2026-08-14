//
//  EndOfOnboarding23thTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/8/21.
//
 
   
import SwiftUI
//MARK:- tutorial number = 23
struct EndOfOnboarding23thTutorialView  : View {
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    var body : some View {
        ZStack {
            Color.black.opacity(0.0001)
            LottieView().frame(width: screenWidth, height: screenHeight).opacity(0.6).offset( y: -100)
            WalkInText(txt: "Finish", fontSize : 50, allPadding : 50)
                .onTapGesture {
                    tutorialNumber = 23
            }
        }
         .highPriorityGesture(DragGesture())
    }
}
