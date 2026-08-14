//
//  DoubleCircle.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 10/17/22.
//

import SwiftUI


struct DoubleCircle: View {
    @State var size1: CGFloat
    @State var size2: CGFloat
    @ObservedObject var themeController: ThemeController
    @State var isFromComment = false
    var action: () -> ()
    var body: some View {
        Circle()
            .frame(width: size1, height: size1)
            .foregroundColor(isFromComment ? themeController.theme.primary : themeController.theme.secondary)
            .onTapGesture {
                action()
            }
            .overlay (
                Circle()
                    .frame(width: size2, height: size2)
                    .foregroundColor(isFromComment ? themeController.theme.secondary : themeController.theme.primary)
            )
            .onTapGesture {
                action()
            }
    }
}
