//
//  NewPost.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/20/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import Combine
import Introspect

struct EmptyView2: View {
    @State var ShowPhotoImagePicker = false
    @State var content = ""
    @Binding var selectedTab: String
    @Binding var newMedia: NewMedia?
    @Binding var NewPostMatchedGeometry: String
    var body: some View {
        ZStack {
            if newMedia != nil {
                EmptyView()
                    .onAppear {
                        selectedTab = "home"
                        NewPostMatchedGeometry = "0"
                        ShowPhotoImagePicker = false
                    }
            }
        }
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            ShowPhotoImagePicker = true
            }
        }
        .presentMediaPicker(isPresented: $ShowPhotoImagePicker, newMedia: $newMedia, text: $content, parentView: .post)
    }
}

struct NewMoment: View {
    @State var content = ""
    @State var keyboard = KeyboardOO()
    @Binding var NewPostMatchedGeometry: String

    var body: some View {
        ZStack (alignment: .top) {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: screenWidth - 10, height: screenHeight/2)
//                .offset(y: -phoneHeight/5)
                .foregroundColor(Color.speakerPink.opacity(0.2))
                .blur(radius: 10)
            RoundedRectangle(cornerRadius: 15)
                .frame(width: screenWidth - 30, height: screenHeight/2 - 15)
//                .offset(y: -phoneHeight/5 + 7.5)
                .foregroundColor(Color.mainColorInverse.opacity(0.9))
                .overlay(
                    ScrollView(showsIndicators: false) {
                        
                        TextField("hello", text: $content)
                            .introspectTextField { textField in
                                textField.becomeFirstResponder()
                                
                            }

                            .onReceive(Just(content)) { content in
                                if content.contains("@") {
                                    //                                    isShowingMentions = true
                                }
                            }
                            .onTapGesture {
                                if keyboard.value > 0 {
                                    hideKeyboard()
                                }
                            }
                        
                            .frame(width: screenWidth - 30, height: screenHeight/2 - 100)
                            .foregroundColor(Color.mainColor)
                        
                    }
                        .opacity(0.5)
                        .frame(width: screenWidth - 30, height: screenHeight/2 - 100)
                        .background(Color.clear)
                        .offset(y: -30)
//                        .offset(y: -phoneHeight/5 - 30)
                )
            HStack (spacing: 40) {
                HStack {
                    Button(action: {
                        NewPostMatchedGeometry = ""
                    }){
                        Image(systemName: "xmark.circle")
                        .resizable()
                        .foregroundColor(Color.mainColor)
                    }
                        .frame(width: 40, height: 40)
//                            .foregroundColor(.speakerPink)
//                            .padding(.horizontal)
                    
                }
                .frame(width: 70, height: 70)
                HStack {
                    
//                    Image("dantal-1")
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 70, height: 70)
//                        .scaledToFit()
//                        .clipShape(RoundedRectangle(cornerRadius: 5))
//                        .shadow(color: Color.mainColor, radius: 1, x: 0, y: 0)
    
                }
                .frame(width: 70, height: 70)
                HStack {
                    
//                    Image(systemName: "lock")
//                        .resizable()
//                        .frame(width: 40, height: 40)
//                        .foregroundColor(.main)
//                        .padding(.horizontal)
                }
                .frame(width: 70, height: 70)
                HStack {
                    
                    Image(systemName: "paperplane")
                        .resizable()
                        .frame(width: 40, height: 40)
//                        .foregroundColor(.speakerPink)
//                        .padding(.horizontal)
                }
                .frame(width: 70, height: 70)
                Spacer()
            }

            .frame(width: screenWidth - 30, height: screenHeight/10 - 5)
            .offset(x: screenWidth/20, y: screenHeight/2.5)
        }
    }
}
