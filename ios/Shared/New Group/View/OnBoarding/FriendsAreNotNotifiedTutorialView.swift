//
//  FriendsAreNotNotifiedTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/4/21.
//
 
import SwiftUI
//MARK:- tutorial number  10
struct FriendsAreNotNotifiedTutorialView  : View {
     
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    let detail = "Friends can't see that your moment is locked, only you can"
    var body : some View {
        ZStack{
            CenteredTextWithNexButtonView(detail: detail, width : 270)
        }
        .highPriorityGesture( DragGesture()  )
    }
}

struct CenteredTextWithNexButtonView  : View {
    
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    let detail : String
    var width : CGFloat = 220
    var body : some View {
        ZStack{
            Color.black.opacity(0.00001)
            
             VStack(spacing : 10){
//                Spacer()
                
                HStack{
                    WalkInText(txt: detail,fontSize : 17)
                        .frame(width: width)
                        .padding(.bottom,90)
                        .onTapGesture {
                                tutorialNumber += 1
                        }
                }
                

                
//                Spacer()
             }
            .padding(.top , (63 + 10 + 60  ) + 30)
        }
    }
}
