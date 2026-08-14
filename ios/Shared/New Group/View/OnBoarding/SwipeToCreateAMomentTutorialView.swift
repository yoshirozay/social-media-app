//
//  SwipeToCreateAMomentTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/3/21.
//
 

import SwiftUI
//MARK:- tutorial number  8
 
struct SwipeToCreateAMomentTutorialView  : View {
    
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
     
    var body : some View {
        ZStack{
            Color.black.opacity(0.00001)
            VStack(alignment : .center, spacing : 20){
                SwipeArrowView(direction: .right)
//                HStack{
                    WalkInText(txt: "Swipe",fontSize : 17)
                        .frame(width: 220)
//                        .padding(.bottom,90)
//                    Spacer()
//                }
                
            }
        }
    }
     
}
