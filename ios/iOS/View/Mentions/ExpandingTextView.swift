//
//  ExpandingTextView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 8/20/21.
//
 
import SwiftUI

struct ExpandingTextView: View {
    @Binding var text: String
    @Binding var maxHeight: CGFloat
    @State var isFirstResponder: Bool = true
    @State var height: CGFloat = 0
    @State var isNewMoment: Bool = false
    var body: some View {
        WrappedTextView(text: $text, isFirstResponder: self.isFirstResponder, isNewMoment: self.isNewMoment, textDidChange: self.textDidChange)
            .frame(height: height )
//            .onChange(of: text){}
    }

    private func textDidChange(_ textView: UITextView) {
        if textView.contentSize.height != self.height{
            DispatchQueue.main.async {
                self.height = min(textView.contentSize.height, maxHeight).magnitude
//                if  self.height < 0{
//                      assert(false, " what happend self.height < 0   ")
//                }
            }
        }
    }
}
extension UIFont {
    static func preferredFont(for style: TextStyle, weight: Weight) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont.systemFont(ofSize: desc.pointSize, weight: weight)
        return metrics.scaledFont(for: font)
    }
}
struct WrappedTextView: UIViewRepresentable {
    typealias UIViewType = UITextView

    @Binding var text: String
    @State var isFirstResponder: Bool
    @State var isNewMoment: Bool
    let textDidChange: (UITextView) -> Void

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
  
        
        view.showsVerticalScrollIndicator = false
      
//            view.font =   UIFont.systemFont(ofSize: 17)
        if isNewMoment {
            view.font =  UIFont.preferredFont(for: .subheadline, weight: .light)
        } else {
        view.font =  UIFont.preferredFont(for: .subheadline, weight: .light)
        }
        view.textColor = .black
        view.isEditable = true
        view.delegate = context.coordinator
        if isFirstResponder {
        view.becomeFirstResponder()
        }
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = self.text
        DispatchQueue.main.async {
            self.textDidChange(uiView)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, textDidChange: textDidChange)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        let textDidChange: (UITextView) -> Void

        init(text: Binding<String>, textDidChange: @escaping (UITextView) -> Void) {
            self._text = text
            self.textDidChange = textDidChange
        }

        func textViewDidChange(_ textView: UITextView) {
            self.text = textView.text
            self.textDidChange(textView)
        }
    }
} 

struct NumberPadFirstResponder: View {
    @Binding var text: String
    @State var placeHolderText: String
    @State var isPhoneNumber = false
    var body: some View {
        ZStack () {
            if text == "" {
                Text(placeHolderText)
                    .opacity(0.4)
            }
        NumberPadCustomTextField(text: $text, isFirstResponder: true, isPhoneNumber: isPhoneNumber)
        }
    }
}
struct FirstResponder: View {
    @Binding var text: String
    @State var placeHolderText: String
    @State var isFromMessages = false
    var body: some View {
        ZStack (alignment: .leading) {
            if text == "" {
                Text(placeHolderText)
                    .font(isFromMessages ? .title : .body)
                    .opacity(0.2)
                 
            }
            FirstResponderCustomTextField(text: $text, isFromMessages: isFromMessages, isFirstResponder: true)
        }
    }
}

struct NumberPadCustomTextField: UIViewRepresentable {

    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String
        var didBecomeFirstResponder = false

        init(text: Binding<String>) {
            _text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }

    }

    @Binding var text: String
    var isFirstResponder: Bool = false
    var isPhoneNumber = false
    func makeUIView(context: UIViewRepresentableContext<NumberPadCustomTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.keyboardType = .numberPad
        if isPhoneNumber {
        textField.textContentType = UITextContentType.telephoneNumber
        }
        return textField
    }

    func makeCoordinator() -> NumberPadCustomTextField.Coordinator {
        return Coordinator(text: $text)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<NumberPadCustomTextField>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}

struct FirstResponderCustomTextField: UIViewRepresentable {

    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String
        var didBecomeFirstResponder = false

        init(text: Binding<String>) {
            _text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }

    }

    @Binding var text: String
    @State var isFromMessages: Bool
    var isFirstResponder: Bool = false

    func makeUIView(context: UIViewRepresentableContext<FirstResponderCustomTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        if isFromMessages {
            textField.font =  UIFont.preferredFont(forTextStyle: .title1)
            textField.font = UIFont.boldSystemFont(ofSize: 30)
            textField.textColor = .black
        }
        return textField
    }

    func makeCoordinator() -> FirstResponderCustomTextField.Coordinator {
        return Coordinator(text: $text)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<FirstResponderCustomTextField>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}
