//
//  IntroVideoView.swift
//  speakEZ
//
//  Created by Ahmad naeem on 11/24/21.
//

import Foundation
import SwiftUI
import AVFoundation
import AVKit

struct IntroVideoView : View {
    @ObservedObject var intro : IntroVideoOO 
    
    var body : some View {
        ZStack {
            if intro.bringToFront{
                playerView
            }else{
                EmptyView()
            }
           
        }
    }
    
    var playerView : some View {
        ZStack{
            VideoPlayer(player: intro.avPlayer)
                .background(Color.black)
                    .edgesIgnoringSafeArea(.all)
 //               VideoPlayerView()
 //               .frame(width: screenWidth, height: screenWidth)
            VStack{
                HStack{
                    Button {
                        intro.closePlayer()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.speakerPurple)
                    }
                    .padding(.leading ,10)
                    .padding(.top , 10)
                    Spacer()
                }
                Spacer()
            }
        }
    }
    
    
    
}

