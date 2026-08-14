//
//  EmojiKeyboard.swift
//  speakEZ crossplatform (iOS)
//
//  Created by Carson O'Sullivan on 6/22/21.
//

import SwiftUI
import Combine

extension String {
    func onlyEmoji() -> String {
        return self.filter({$0.isEmoji})
    }
}

extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }

}
#if os(iOS)

class UIEmojiTextField: UITextField {
    
    var isEmoji = false {
        didSet {
            setEmoji()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func setEmoji() {
        self.reloadInputViews()
    }
    
    override var textInputContextIdentifier: String? {
        return ""
    }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" && self.isEmoji{
                self.keyboardType = .default
                return mode
                
            } else if !self.isEmoji {
                return mode
            }
        }
        return nil
    }
    
}

struct EmojiTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""
    @Binding var isEmoji: Bool
    
    func makeUIView(context: Context) -> UIEmojiTextField {
        let emojiTextField = UIEmojiTextField()
        emojiTextField.placeholder = placeholder
        emojiTextField.text = text
        emojiTextField.delegate = context.coordinator
        emojiTextField.isEmoji = self.isEmoji
        emojiTextField.becomeFirstResponder()
        return emojiTextField
    }
    
    func updateUIView(_ uiView: UIEmojiTextField, context: Context) {
        uiView.text = text
        uiView.isEmoji = isEmoji
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: EmojiTextField
        
        init(parent: EmojiTextField) {
            self.parent = parent
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}

#endif
struct EmojiContentView: View {
    
    @State private var text: String = ""
    @State private var isEmoji: Bool = true
    
    var body: some View {
        
        HStack{
            EmojiTextField(text: $text, placeholder: "Enter emoji", isEmoji: $isEmoji)
                .onReceive(Just(text), perform: { _ in
                    // This allow only emoji
                    self.text = self.text.onlyEmoji()
                    self.text = String(self.text.onlyEmoji().prefix(3))
                    /*
                     //This allow only emoji and allow only 3 emoji
                    
                     */
                })
        }
    }
}
