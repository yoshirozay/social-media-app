//
//  MacOsDismissButton.swift
//  speakEZ (macOS)
//
//  Created by Ahmad naeem on 11/20/21.
//

import SwiftUI

struct  MacOsDismissButton : View {
    @Binding var matchedGeometry : String
    var body: some View {
        Button {
            matchedGeometry = ""
        } label: {
            HStack {
                Image(systemName: "xmark")
//                    .padding(.trailing, 7)
                    .font(.title2)
                    .foregroundColor(.speakerPurple)
                Spacer()
            }
            
        }.buttonStyle(.borderless)
    }
}
