//
//  TitleHeader.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 10/3/22.
//

import SwiftUI

struct TitleHeader: View {
    var title: String
    var action: () -> Void
    var body: some View {
        HStack (spacing: 16) {
            Button(action: {
                action()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.bold))
                    .padding(.leading)
                    .foregroundColor(Color.black)
            }
            Text(title)
                .fontWeight(.semibold)
                .font(.title)
                .foregroundColor(Color.black)
            
        }
    }
}
