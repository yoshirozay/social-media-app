//
//  HeaderButton.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//

import SwiftUI

struct HeaderButton: View {
    var image: String
    var action: () -> Void
    var body: some View {
        Image(systemName: image)
            .resizable()
            .frame(width: 23, height: 20)
            .padding(.horizontal, 14)
            .foregroundColor(Color.black)
            .onTapGesture {
                withAnimation(.easeIn(duration: 0.1)) {
                    action()
                }
            }
    }
}
