//
//  CanLockMomentsTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/3/21.
//
   
import SwiftUI
//MARK:- tutorial number  = 8  
struct CanLockMomentsTutorialView  : View {
     
    var body : some View {
        ZStack{
            VStack(spacing : 0){
                HStack{
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 50 , weight: .bold, design: .monospaced))
                        .foregroundColor(Color.speakerPink)
                        .padding(.trailing,46)
                    
                }
                HStack{ 
                Spacer()
                    WalkInText(txt: "Lock your moments",fontSize : 17)
                        .frame(width: 220)
                        .padding(.trailing , 30)
                }
                //                75
                Spacer()
            }
            .padding(.top , 171)
            
        }
        .highPriorityGesture(DragGesture())
       
    }
     
}
