//
//   TapToComment17thTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/7/21.
//
 
import SwiftUI
//import UIKit
//MARK:- tutorial number 17
struct TapToComment17thTutorialView : View {
    
    var action : (() -> Void)
    var body : some View {
        ZStack(alignment: .topLeading) {
            Color.green.opacity(0.0001)
            mainBody
        }.highPriorityGesture(DragGesture())
    }
    
    
    var mainBody : some View { 
        let haveScreenBottomCurve = UIApplication.getSafeAreaBottomInsets() != 0
         
       return ZStack(alignment: .topLeading) {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { 
                        action()
                        tutorialNumber = 18 
                    },  label : {
                        Color.yellow.opacity(0.0001)
                            .frame(width: 60, height: 60)
                    })
                }
            }.padding(.horizontal, 10)
            .padding(.bottom,  CGFloat(haveScreenBottomCurve ? 0 : 10))
            //            .padding(.bottom, 0  )
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    WalkInText(txt: "Send a comment",fontSize : 17)
                }
                
                HStack {
                    Spacer()
                    Image(systemName: "arrow.down.right")
                        .font(.system(size: 50 , weight: .bold, design: .monospaced))
                        //                    .rotationEffect(Angle(degrees: 20))
                        .foregroundColor(Color.speakerPink)
                }
                
            }.padding(.trailing ,50)
            .padding(.bottom , 50 +  CGFloat(haveScreenBottomCurve ? 0 : 10))
         
        }
        .frame(width: screenWidth, height: screenHeight + CGFloat(haveScreenBottomCurve ? 0 : 35)  )
        
    }
    
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    
}
 
