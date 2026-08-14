//
//  OSExpandingTextView.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/6/21.
//

import SwiftUI
import AppKit
import UserNotifications

 
typealias ExpandingTextView = OSExpandingTextView
struct OSExpandingTextView: View {
    @Binding var text: String
    @Binding var maxHeight: CGFloat 
    @State var height: CGFloat = Self.font.pointSize

    var body: some View {
        MacOSEditorTextView(text: $text,
                            dynamicHeight: $height,
                            font: Self.font,
                            maxHeight : maxHeight)
            .frame(height: height )
            .onChange(of: text) { newVal in
                if newVal.isEmpty{
                    height = NSFont.systemFont(ofSize: 15, weight: .regular).pointSize
                }
            }
    }
    static private var font : NSFont { NSFont.systemFont(ofSize: 14, weight: .regular) }
}
 
