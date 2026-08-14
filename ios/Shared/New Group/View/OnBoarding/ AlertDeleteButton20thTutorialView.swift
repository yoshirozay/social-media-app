//
//   AlertDeleteButton20thTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/7/21.
//
 

import SwiftUI
//MARK:- tutorial number 20
struct AlertDeleteButton20thTutorialView : View {
    
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    
    var body : some View {
        return ZStack {
            Color.black.opacity(0.00001)
           
            VStack{
              
                Image(systemName: "arrow.up")
                    .font(.system(size: 50 , weight: .bold, design: .monospaced))
                    .foregroundColor(Color.speakerPink)//Color.speakerPurple)
                       .rotationEffect(Angle(degrees: 20))
                    .padding(.leading, 75)
                    .padding(.top ,  screenHeight/2)
                    .padding(.top , 65 - UIApplication.getSafeAreaTopInsets())
                Spacer()
            } .frame(width: screenWidth, height: screenHeight, alignment: .center)
                
        }.highPriorityGesture(DragGesture())
    }
    
    
}
