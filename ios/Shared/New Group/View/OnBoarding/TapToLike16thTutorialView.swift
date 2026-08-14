//
//  TapToLike16thTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/4/21.
//
 
import SwiftUI
//import UIKit
 
//MARK:- tutorial number 16
struct TapToLike16thTutorialView : View {
     
    var action : (() -> Void)
    var body : some View {
        ZStack {
            Color.black.opacity(0.0001)
            VStack {
                HStack {
                    Button(action: action,
                           label : {
                            Color.yellow.opacity(0.0001)
                                .frame(width: 40, height: 40)
                    })
                        .padding(.leading,10)
                    Spacer()
                }
                Spacer()
            }   .padding(.top , 170)
            
            VStack {
                
                HStack {
                Image(systemName: "arrow.up.left")
                    .font(.system(size: 50 , weight: .bold, design: .monospaced))
                    .rotationEffect(Angle(degrees: 20))
                    .foregroundColor(Color.speakerPink)
                    Spacer()
                }
                .padding(.bottom , 5)
                
                HStack {
                    WalkInText(txt: "You can like moments",fontSize : 17)
                    Spacer()
                }
               
                
                Spacer()
            }
            .padding(.top , 220-10)
            .padding(.leading , 23  )
            
            
        }.highPriorityGesture(DragGesture())
    }
    
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    
}
