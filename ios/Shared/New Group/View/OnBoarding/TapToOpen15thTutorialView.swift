//
//  TapToOpen15thTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/4/21.
//

import SwiftUI
//import UIKit

//MARK:- tutorial number 15
struct TapToOpen15thTutorialView : View {
    
     let firstPost : PostModel
    @Binding var OpenedPostSelectedItem : PostModel
    @Binding var OpenedPostMatchedGeometry : String
    
    var body : some View {
        ZStack {
           
            Color.black.opacity(0.0001)
                 
            VStack{
                Color.green.opacity(0.0001)
                    .frame( height: 131).onTapGesture {
                        OpenedPostSelectedItem = firstPost
                        OpenedPostMatchedGeometry = "0"
                        tutorialNumber = 16
                    }
                 
                    Image(systemName: "arrow.up")
                        .font(.system(size: 50 , weight: .bold, design: .monospaced))
                        .foregroundColor(Color.speakerPink)
//                        .rotationEffect(Angle(degrees: 20))
                        .padding(.bottom , 50)
//                        .padding(.top , 55)
               
                
                WalkInText(txt: "Tap to open",fontSize : 17)
                    .frame(width: 270)
                    .padding(.bottom , screenHeight/2)
                
                Spacer()
            }
          
            
        }.highPriorityGesture(DragGesture())
       // .padding(.top , 150)
    }
    
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    
}
