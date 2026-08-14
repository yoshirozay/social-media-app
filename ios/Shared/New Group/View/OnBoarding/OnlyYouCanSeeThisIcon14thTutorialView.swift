//
//  OnlyYouCanSeeThisIcon14thTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/4/21.
//
 
import SwiftUI


//MARK:- tutorial number  14
struct OnlyYouCanSeeThisIcon14thTutorialView  : View {  
    var body : some View {
        ZStack {
            
            Color.black.opacity(0.0001)
            
            VStack{
                HStack{
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 50 , weight: .bold, design: .monospaced))
                        .foregroundColor(Color.speakerPink)
//                        .rotationEffect(Angle(degrees: 20))
                        .padding(.bottom , 50)
                        .padding(.trailing,55)
                        .padding(.top , 55)
                }
                
                WalkInText(txt: "Only you can see this key, your private community cannot",fontSize : 17)
                    .frame(width: 270)
                    .padding(.bottom , 100)
                    .onTapGesture {
                        tutorialNumber += 1
                    }

            }
           
        }.highPriorityGesture(DragGesture())
        .padding(.bottom, screenHeight/1.9)
     }
    
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    
}
