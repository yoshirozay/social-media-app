//
//  IntroSpeakEZ.swift
//  speakEZ
//
//  Created by Ahmad naeem on 6/1/22.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import Contacts

struct IntroSpeakEZ: View {
    @Binding var currentView: CurrentIntroView
    @State var titleText = "speakEZ"
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var firstLogin: FirstLoginOO
    var body: some View {
        ZStack {
            
//            IntroBackground()
            LinearGradient(gradient: Gradient(colors: [.backgroundColor, .accent]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            ZStack {
                VStack {
                    ZStack {
                        Image(colorScheme == .light ? "permission55" : "permission44")
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth/1.4267, height: screenHeight/3.087) // 300, 300
                        
                    }
                    .frame(width: screenWidth/1.05, height: screenHeight/3.087) // 300
                    .padding(screenWidth/10.7) // 40
                    .background(Color.mainColorInverse.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    ZStack {
                        VStack (alignment: .leading, spacing: 23) {
                            HStack {
                                ZStack {
                                    Text(titleText)
                                        .font(.largeTitle)
                                    Rectangle()
                                        .frame(width: CGFloat(titleText.count * 18), height: 1)
                                        .foregroundColor(Color.speakerPurple)
                                        .offset(y: 20)
                                }
                                Spacer()
                            }
                            Text("Keep your circle connected by turning everyday thoughts into group conversations")
                                .font(.title3)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            Rectangle()
                                .frame(width: 30, height: 1)
                                .foregroundColor(Color.speakerPurple)
                            Text("You can add up to 150 people, send friend requests to see what's up!")
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.title3)
                            Rectangle()
                                .frame(width: CGFloat(titleText.count * 18 - 30), height: 1)
                                .foregroundColor(Color.speakerPurple)
                            
                        }
                        .foregroundColor(Color.black)
                        .padding(.horizontal, 14)
                        .padding(.top, 5)
                        
                        
                        VStack {
                            Button(action: {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    currentView = firstLogin.accountHasBeenCreated ? .Permission : .CreateProfile
                                }
                            }) {
                                Text("Next")
                                    .font(.headline)
                                    .padding()
                                    .padding(.horizontal, 30)
                                    .foregroundColor(Color.mainColor)
                                    .background(Color.mainColorInverse.opacity(0.6))
                                    .clipShape(Capsule())
                            }
                            .padding(.top, 30)
                            
                        }
                        .offset(y: screenHeight/4.5)
                    }
                    
                    Spacer()
                    
                }
            }
            .frame(width: screenWidth/1.05, height: screenHeight / 1.1)
            .background(Color.mainColorInverse.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .animation(.easeIn(duration: 0.3))
        }
    }
}
