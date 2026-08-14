//
//  SwipeToReturn18thTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/7/21.
//
 
import SwiftUI
//MARK:- tutorial number 18
struct SwipeToReturn18thTutorialView  : View {
   
   @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    
   var body : some View {
       ZStack{
           Color.black.opacity(0.00001)
           VStack(alignment : .center, spacing : 20){
               SwipeArrowView(direction: .right)
                   WalkInText(txt: "Swipe to return",fontSize : 17)
                       .frame(width: 220)
           }
       }
   }
    
}
