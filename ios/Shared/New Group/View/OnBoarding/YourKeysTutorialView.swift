//
//  YourKeysTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/4/21.
//
 
import SwiftUI
//MARK:- tutorial number  9  
struct  YourKeysTutorialView  : View {
   @Binding var SelectedTagMatchedGeometry: String
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    var body: some View { 
            VStack(alignment: .center,spacing : 0){
                
                Color.black.opacity(0.0001)
                    .frame( height: 155)
                    .padding(.bottom,125 + 40)
                HStack{
                    Spacer()
                    Image(systemName: "arrow.up")
                        .font(.system(size: 50 , weight: .bold, design: .monospaced))
                        .foregroundColor(Color.speakerPink)
                    Spacer()
                }
                
                HStack(alignment: .center) {
//                    Spacer()
                WalkInText(txt: "Keys give you control to which friends see what moments",fontSize : 17)
                    .frame(width: 220)
//                    Spacer()
                }
                
                Spacer()
            }
            .onChange(of: SelectedTagMatchedGeometry) { tab in
                if tutorialNumber == 9  {
                    tutorialNumber = 10
                }
            }
      
    }
}
