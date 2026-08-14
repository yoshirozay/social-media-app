//
//  MyPeopleIntroTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/3/21.
//

import SwiftUI

//MARK:- tutorial number 3
struct MyPeopleIntroTutorialView  : View {
     
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
     
    var body : some View {
        ZStack{
            Color.black.opacity(0.00001)
            VStack(spacing : 10){
                HStack{
                    Image(systemName: "arrow.up")
                        .font(.system(size: 50 , weight: .bold, design: .monospaced))
                        .foregroundColor(Color.speakerPink)
                        .padding(.leading,70)
                        .onTapGesture {
                            tutorialNumber += 1
                        }
                    Spacer()
                }
                HStack{
                WalkInText(txt: "Add friends",fontSize : 17)
                    .frame(width: 220)
                    .padding(.leading , 30)
                    
                   
                    .onTapGesture {
                        tutorialNumber += 1
                    }
                    Spacer()
                }

            }
            .padding(.bottom, screenHeight/1.7)
//            .padding(.top , (63 + 10 + 60  ) + 30)
        }
    }
}
