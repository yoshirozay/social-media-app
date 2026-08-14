//
//  AlertView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/22/21.
//

import SwiftUI

struct AlertView: View {
    @State var color = Color.black.opacity(0.7)
    @Binding var errorString: String
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .transition(.opacity)
            
            VStack {
                Text( "Error:" )
                    .multilineTextAlignment(.center)
                    .foregroundColor( color)
                    .font(Font.system(size: 22, weight: .medium, design: .monospaced))
                    .padding(.top, 20)
                
                Text(errorString)
                    .font(Font.system(size: 18))
                    .foregroundColor( color)
                    .padding(.top)
                    .padding(.horizontal, 25)
                
                Button(action: {
                    self.errorString.removeAll()
                }) {
                    Text("Ok")
                        .bold()
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .frame(width: screenWidth - 120)
                }.buttonStyle(.borderless)
#if os(macOS)
                .frame( height: 40)
#endif
                .background(Color.speakerPurple)
                .cornerRadius(10)
                .padding(.top, 25)
            }
            .padding(.vertical, 30)
            .frame(width: screenWidth - 80)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                VStack{
                Image(systemName: "questionmark.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color.speakerPink)
                    .background(Color.speakerPurple.cornerRadius(40))
                    .offset(x: 0, y: -40)
                    Spacer()
                }
            )
            
        }
        .transition(.opacity)
//        .onTapGesture {
//            errorString.removeAll()
//        }
    }
}
