//
//  FirstWalkIn.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/2/21.
//

import SwiftUI


 //MARK:- tutorial number 1 

struct TutorialSkipButtonView : View   {
    
    @State var showAlert = false
    var body: some View {
        ZStack{
            SkipButton(txt: "Skip",fontSize : 17)
                .onTapGesture {
                    showAlert = true
                }
                .padding(.all,-20)
                .position(x: 50, y: screenHeight-100)
        }.alert(isPresented: $showAlert) {
              Alert (
                title: Text("Are you sure you want to skip tutorial?"),
                primaryButton: .destructive(Text("Skip")) {
                    TutorialManager.shared.skip()
                } ,
                secondaryButton: .cancel()
            )
        }
    }
    
}

struct FirstWalkIn : View   { 
    var body: some View {
        
        ZStack{
            Color.black.opacity(0.00001)
            VStack{
                Spacer()
                WalkInText(txt: "Navigation button",fontSize : 17)
                    .foregroundColor(Color.white)
//                    .frame(width: 100, alignment: .center)
                    .padding(.horizontal,80)
                HStack{
                    Spacer()
                    Image(systemName: "arrow.down.right")
                        .font(.system(size: 50 , weight: .bold, design: .monospaced))
                        .foregroundColor(Color.speakerPink)
                        .padding(.trailing,100 - 15)
                        .padding(.bottom, 150)
                        .padding(.bottom, screenHeight < 800 ? -30 : 0)
                    
                }
            }
            
        }  
    }
    
}

struct WalkInText: View {
    let txt : String
    var fontSize: CGFloat = 17
    var allPadding: CGFloat = 20
    var body: some View {
        ZStack { 
            Text(txt)
                .multilineTextAlignment(.center)
                .lineLimit(50)
                .font(.system(size: fontSize, weight: .bold))
                .padding(.all,allPadding)
                .background(
                    GeometryReader{ geometry in
                        let w =   max(geometry.size.height, geometry.size.width)
//                        Color.speakerPurple
                        LinearGradient(gradient: .init(colors:  [.speakerPurple.opacity(1), .speakerPink.opacity(1)]), startPoint: .leading, endPoint: .trailing)
                            
                            .cornerRadius(w/2)
                    }
                )
            
        }.padding(.all,20)
        .foregroundColor(Color.white)
    }
}

struct SkipButton: View {
    let txt : String
    var fontSize: CGFloat = 17
    var allPadding: CGFloat = 20
    var body: some View {
        ZStack {
            Text(txt)
                .foregroundColor(.mainColorInverse)
                .multilineTextAlignment(.center)
                .lineLimit(10)
                .font(.system(size: fontSize, weight: .bold))
                .padding(.all, 14)
                .padding(.horizontal, 10)
                .background(
                    GeometryReader{ geometry in
                        let w =   max(geometry.size.height, geometry.size.width)
//                        Color.speakerPurple
                        LinearGradient(gradient: .init(colors:  [.speakerPurple.opacity(1), .speakerPink.opacity(1)]), startPoint: .leading, endPoint: .trailing)
                            
                            .cornerRadius(w/2)
                    }
                )

            Text(txt)
                .foregroundColor(Color.mainColor.opacity(1))
                .multilineTextAlignment(.center)
                .lineLimit(10)
                .font(.system(size: fontSize, weight: .bold))
                .padding(.all, 10)
                .padding(.horizontal, 10)
                .background(
                    GeometryReader{ geometry in
                        let w =   max(geometry.size.height, geometry.size.width)
//                        Color.speakerPurple
                        LinearGradient(gradient: .init(colors:  [.mainColorInverse.opacity(0.7), .mainColorInverse.opacity(0.7)]), startPoint: .leading, endPoint: .trailing)
                            
                            .cornerRadius(w/2)
                    }
                )

            
        }.padding(.all,20)
        .foregroundColor(Color.white)
    }
}

/*
first we want to do walk throghy by a program .
need to test the positioning in swift ui
we will add test in the middle with a circle arround
we want the circle to remain outside the text

the best would be to create each screen programmitcally . instead of using a same func. that will take too long
we will create the custom so it will fit all screens
*/
/*
 to check that is the user new and we need to show tutorial. we will use a key and save it in user default. we will save it when the create user func is callled. and updated when user gets a call back. can also use realm if needed.
 then we will use a
 */
