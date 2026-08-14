//
//  SharingMyFirstSpeakEZMoment13thTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/4/21.
//
 
import SwiftUI

//MARK:- tutorial number 13 
struct SharingMyFirstSpeakEZMoment13thTutorialView  : View {
    @Binding var content : String
    @State var allowTap = false
    var body : some View {
        ZStack {
            
            Color.black.opacity(0.0001)
                .padding(.trailing, allowTap ? 70 : 0)
            
            Color.black.opacity(0.0001)
                .padding(.top,130)
            

            
            VStack{
                HStack{
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 50 , weight: .bold, design: .monospaced))
                        .foregroundColor(Color.speakerPink)
                        .rotationEffect(Angle(degrees: 20))
                }
                Spacer()
            }
            .padding(.trailing,60)
            .padding(.top , 100)
             
        }.highPriorityGesture(DragGesture())
        .onAppear{
            let charInterval : Double = 0.05
            var str = "Sharing my first speakEZ moment!"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(str.count+2)*charInterval) {
                self.allowTap = true
            }
            
            func addChar(){
                guard str.isNotEmpty else { return  }
                withAnimation(.easeIn(duration: charInterval)) {
                    content.append(str.removeFirst())
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + charInterval) {
                    addChar()
                }
            }
            
            addChar()
            
        }
    }
     
}
