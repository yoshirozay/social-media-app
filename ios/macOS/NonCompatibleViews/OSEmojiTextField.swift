//
//  OSEmojiTextField.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/6/21.
//


import SwiftUI
import Combine
import Cocoa

typealias EmojiTextField = OSEmojiTextField
struct OSEmojiTextField: View {
    
    @State var textField: NSTextField?
    @Binding var text: String
    let placeholder: String
    @Binding var isEmoji: Bool
    
    var body: some View {
        
        HStack{
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.body)
                .onReceive(Just(text), perform: { _ in
                    text = String(text.onlyEmoji().suffix(1))
                }).introspectTextField {textField = $0}
        }.overlay(Color.black.opacity(0.0000001)
         .onTapGesture(perform: openEmojiWindow))
    }
    
    func openEmojiWindow(){
        textField?.becomeFirstResponder()
        NSApp.orderFrontCharacterPalette(textField)
    }
}
