//
//  HeaderButton.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 10/5/21.
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
            .onTapGesture {
                withAnimation(.easeIn(duration: 0.1)) {
                    action()
                }
            }
    }
}
