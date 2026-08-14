//
//  SwipeArrowTutorialView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/3/21.
//

import SwiftUI
//MARK:- tutorial number 4,6,21
struct SwipeArrowTutorialView  : View {
    let direction : SwipeArrowView.Direction
    @State var text = "Swipe"
    var body: some View {
        ZStack{
             Color.black.opacity(0.00001)
            SwipeArrowView(direction: direction)
        }
        WalkInText(txt: text, fontSize : 17)
            .frame(width: 220)
            .offset(y: 125)
    }
}

struct SwipeArrowView  : View {
    let direction : Direction
    var body: some View {
        Image(systemName: "arrow."+direction())
            .font(.system(size: 120 , weight: .heavy, design: .rounded))
            .foregroundColor(Color.speakerPink)
    }
    
    enum Direction : String {
        case left
        case right
    }
}
