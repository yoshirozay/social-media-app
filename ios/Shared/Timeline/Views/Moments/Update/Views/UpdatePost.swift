//
//  HomeU.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//


import SwiftUI

struct UpdatePost : View {
    @Binding var showUpdatePost : PostModel?
    @StateObject var updatePostVM : UpdatePostVM
    var body: some View {
        ZStack{
            Color.gray
            VStack{
                Spacer()
                TextEditor(text: $updatePostVM.text)
                    .foregroundColor(.black)
                    .frame( height: screenHeight*0.5, alignment: .center)
                    .padding(.horizontal,5)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
                Spacer()
                HStack{
                    Spacer()
                    
                    Button(action: {
                        updatePostVM.updatePost()
                    }) {
                        Text("Edit").font(.title).foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showUpdatePost = nil
                    }) {
                        Text("Cancel").font(.title).foregroundColor(.black)
                    }
                    
                    Spacer()
                }.padding(.bottom)
                Spacer()
            }
        }.frame(width: screenWidth*0.9, height: screenHeight*0.6, alignment: .center)
         .cornerRadius(20)
    }
}
