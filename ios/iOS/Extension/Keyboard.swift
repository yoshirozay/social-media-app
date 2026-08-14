//
//  Keyboard.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/29/21.
//
import Foundation
import SwiftUI
import Combine
import UIKit
#if os(iOS)



struct FirstResponderTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        var becameFirstResponder = false
        
        init(text: Binding<String>) {
            self._text = text
        }
        
        func textFieldDidChangeSelection (_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    func makeUIView(context: Context) -> some UIView {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        return textField
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if !context.coordinator.becameFirstResponder {
            uiView.becomeFirstResponder()
            context.coordinator.becameFirstResponder = true
        }
    }
}


extension UIApplication {
    static var tapGesture: UITapGestureRecognizer?
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        tapGesture.name = "MyTapGesture"
        window.addGestureRecognizer(tapGesture)
        tapGesture.isEnabled = false
        Self.tapGesture = tapGesture
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false // set to `false` if you don't want to detect tap during other gestures
    }
}
// Tap to dismiss keyboard



extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
  

extension View {
    func hideKeyboard() {
#if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
    }
}

class KeyboardOO: ObservableObject {
    @Published  fileprivate(set) var value: CGFloat = 0
    
    private var willShow : NSObjectProtocol?
    private var willHide : NSObjectProtocol?
    
    init() {
#if os(iOS)
        willShow = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) {  [weak self]  (noti) in
            UIApplication.tapGesture?.isEnabled = true
            if let value = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect{
                self?.keyboardWillShow(height : value.height)
            }
        }
        
        willHide = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) {  [weak self]  (noti) in
            UIApplication.tapGesture?.isEnabled = false
            self?.keyboardWillHide()
        }
#endif
    }
    
    fileprivate func keyboardWillShow(height : CGFloat){
        self.value = height
    }
    
    fileprivate func keyboardWillHide(){
        self.value = 0
    }
 
    deinit {
        let center = NotificationCenter.default
        if let willHide = self.willHide{
            center.removeObserver(willHide)
        }
        if let willShow = self.willShow{
            center.removeObserver(willShow)
        }
    }
}
 


class KeyboardViewModel : KeyboardOO {
     
    @Published private var yOffset : CGFloat = 0
    private var initailValue : CGFloat = 0
    private var viewFrameObservation: NSKeyValueObservation?
    private var initalHeight: CGFloat = 0
    let showDismissAnimation : Bool
    var bottomPadding : CGFloat{
        value - yOffset
    }
    init(showDismissAnimation : Bool = true) {
        self.showDismissAnimation = showDismissAnimation
        super.init()
    }
 
    override fileprivate func keyboardWillShow(height : CGFloat) {
        if  value == 0 {
            if  initalHeight == 0 {
                initalHeight = height
            }
            value = self.initalHeight
        }
        checkWindow()
    }
    
    override fileprivate func keyboardWillHide() {
        if showDismissAnimation {
            withAnimation(Animation.linear.speed(0.9)) {
                self.setValuesToZero()
            }
        }else{
            setValuesToZero()
        }
        viewFrameObservation?.invalidate()
        viewFrameObservation = nil
    }
    
    private func setValuesToZero(){
          yOffset = 0
          value = 0
    }
    
  private func checkWindow() {
        if viewFrameObservation == nil,let keyboardWindow = UIApplication.shared.windows.first(where: { NSStringFromClass($0.classForCoder) == "UIRemoteKeyboardWindow" }) {
         
            if let someView  : UIView = (keyboardWindow.subviews.first?.subviews.first){
                if self.initailValue == 0 {
                    self.initailValue = someView.frame.origin.y
                }
                viewFrameObservation?.invalidate()
                viewFrameObservation = someView.observe(\UIView.center) {[weak self] (view, _) in
                    guard let self = self else { return  }
                    self.yOffset = view.frame.origin.y - self.initailValue
                }
               
                return
            }
        }
    }
    
    deinit {
        viewFrameObservation?.invalidate()
    }
}

extension UICollectionReusableView {
    override open var backgroundColor: UIColor? {
        get { .clear }
        set { }

        // default separators use same color as background
        // so to have it same but new (say red) it can be
        // used as below, otherwise we just need custom separators
        //
        // set { super.backgroundColor = .red }

    }
}

