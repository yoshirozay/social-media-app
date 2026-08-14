//
//  Post.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/15/21.
//

import SwiftUI

struct CurrentUserPosts: View {
    @State var id: Int = 3
    let currentUserPosts: [PostModel] = Bundle.main.decode("currentUserPosts.json")
    var body: some View {
        VStack {
            HStack (spacing: 10) {
                
                Image(currentUserPosts[id].photo)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                    .onTapGesture {
                    }
                
                HStack(alignment: .top) { // necessary to align timestamp with name
                    VStack(alignment: .leading, spacing: 2) {
                        Text("D'antal Sampson")
                            .fontWeight(.bold)
                        Text("@dantal")
                            .font(.caption)
                    } // VSTACK
                    Spacer()
                    Text(currentUserPosts[id].time)
                        .font(.caption)
                        .padding(.horizontal)
                } // HSTACK
                .foregroundColor(.mainColor)
                
            } // HSTACK
            .padding(.horizontal)
            .padding(.vertical, 6)
                HStack {
                    Text(currentUserPosts[id].post)
                        .font(.title3)
                        .padding(.horizontal, 16)
                    Spacer()
                } // HSTACK
            Spacer()
        }
        .foregroundColor(.mainColor)
        .padding(.top, -45)
    }
}

struct Post_Previews: PreviewProvider {
    static var previews: some View {
        CurrentUserPosts()
    }
}
