//
//  UpdatePost.swift
//  speakEZ
//
//  Created by Ahmad naeem on 2/15/22.
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

class UpdatePostVM : ObservableObject {
    let post : PostModel
    init(post : PostModel) {
        self.post = post
    }
    @Published var text : String = ""
    func updatePost(){
        
        guard let userId = currentUserID,userId == post.id else { return }
        
        if text.trimWhitespacesAndNewlines().isNotEmpty{
            NewPostFunctions.edit(postID: post.postID, author: userId, content: text) { error in
                print("123^ UpdatePostVM \(error?.localizedDescription ?? "successfull")")
            }
        }
    }
    
}

