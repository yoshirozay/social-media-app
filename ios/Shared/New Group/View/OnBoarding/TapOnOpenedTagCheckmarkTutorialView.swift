//
//  TapOnOpenedTagCheckmarkTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/4/21.
//

import SwiftUI
//MARK:- tutorial number  12
struct TapOnOpenedTagCheckmarkTutorialView  : View {
    
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0

    var body : some View { 
        ZStack{
            Color.black.opacity(0.001)
                .padding(.trailing,50)
            Color.red.opacity(0.001)
                .padding(.top,200)
            VStack{
                HStack{
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 50 , weight: .bold, design: .monospaced))
                        .foregroundColor(Color.speakerPink)
                        .rotationEffect(Angle(degrees: -20))
                }
                Spacer()
            }
            .padding(.trailing,30)
            .padding(.top,170) 
        } .highPriorityGesture(DragGesture())
        .onDisappear{ 
            if tutorialNumber == 12 {
              tutorialNumber = 13
           }
        }
    }
     
}
