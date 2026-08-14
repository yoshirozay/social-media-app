//
//  CreateMmomentIntroTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/3/21.
//

import SwiftUI
//MARK:- tutorial number 5
struct CreateMmomentIntroTutorialView : View { 
    var body : some View {
        
        ZStack{
            VStack(spacing : 10){
                Spacer()
                WalkInText(txt: "Create moments",fontSize : 17)
                    .foregroundColor(Color.white)
                    //                    .frame(width: 100, alignment: .center)
                    .padding(.leading , 70 + 20)
                    .padding(.trailing , 70 - 20)
                HStack{
                    Spacer()
                    Image(systemName: "arrow.down.right")
                        .font(.system(size: 50 , weight: .bold, design: .monospaced))
                        .foregroundColor(Color.speakerPink)
                        .rotationEffect(Angle(degrees: 20))
                        .padding(.trailing,50)
                        .padding(.bottom, 150 + 38 + 18)
                        .padding(.bottom, screenHeight < 800 ? -30 : 0)
                }
            }
        }.background(Color.black.opacity(0.00001))
    }
}
