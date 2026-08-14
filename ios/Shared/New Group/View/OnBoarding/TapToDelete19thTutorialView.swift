//
//  TapToDelete19thTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/7/21.
//

import SwiftUI
//MARK:- tutorial number 19
struct TapToDelete19thTutorialView : View {
    
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
//    var action : (()->Void)
    
    var body : some View {
        ZStack {
            Color.black.opacity(0.0001)
            VStack {
               
                HStack{
                    Spacer()
                    Color.green.opacity(0.0001)
                        .onTapGesture {
//                            action()
//                            tutorialNumber = 20
                        }
                        .frame(width: 35, height: 30)
                        .padding(.trailing , 25)
                }
           
                HStack{
                    Spacer()
                    Image(systemName: "arrow.up")
                        .font(.system(size: 50 , weight: .bold, design: .monospaced))
                        .foregroundColor(Color.speakerPink)
//                        .rotationEffect(Angle(degrees: 20))
                        .padding(.bottom , 50)
//                        .padding(.trailing,55)
                    Spacer()
//                        .padding(.top , 55)
                }
                
                WalkInText(txt: "Delete moments",fontSize : 17)
                    .frame(width: 270)
                    .padding(.bottom , 100)
               
                Spacer()
            }.padding(.top,130-25)
            
        }.highPriorityGesture(DragGesture())
     }
    
    
}
