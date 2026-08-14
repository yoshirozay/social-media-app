//
//  MessageBottomSheetVC.swift
//  testingSwiftUI
//
//  Created by Ahmad naeem on 7/11/21.
//

import UIKit
import Combine
import PanModal

class MessageBottomSheetVC: UIViewController { 
    
    private var cancelButton : UIButton!
    private var doneButton : UIButton!
    private var textView:UITextView!
    private var ViewKeyboardHeight: CGFloat = 0
    private var currentHeight: CGFloat = 0
    private var text : String = ""
    private var parentView : ParentView = .other
    let typedTextSubject = PassthroughSubject<String, Never>()
    
    public required init(text : String, parentView : ParentView) {
        self.text = text
        self.parentView = parentView
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() { 
        view.backgroundColor = .white
        currentHeight = calculatedHeight
        setupViews()
        addKeyboardNotifications()
    }
    
    var calculatedHeight : CGFloat {
        return screenHeight*0.33
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(currentHeight)
    }
    
    func updateHeigth(_ newHeight : CGFloat){
        currentHeight = newHeight
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
    }
    
    func setupViews() {
        setupCancelButton()
        setupDoneButton()
        setupTextView()
    }
    
    func setupCancelButton() {
        
        let cancelButton = UIButton ()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.speakerPurple, for: .normal)
        cancelButton.isUserInteractionEnabled = true
        cancelButton.addAction(UIAction(handler: { [weak self] (_) in
            print("dismissButton tapped")
            self?.dismiss(animated: true)
            
        }), for: .touchUpInside)
        
        self.view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: cancelButton , attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 10))
        view.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 5))
        view.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40))
        
        self.cancelButton = cancelButton
    }
    
    func setupTextView() {
        
        let textView : UITextView = UITextView()
        
        if  text.isEmpty {
            textView.text =  "Start typing ..."
            textView.textColor = UIColor.lightGray
        }else{
            textView.text = text
            textView.textColor = UIColor.black
        }
       
        textView.autocorrectionType = .no
        textView.backgroundColor = UIColor.white 
        textView.textAlignment = .left
        textView.font = UIFont.systemFont(ofSize: 16)
        view.addSubview( textView )
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: textView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 10))
        view.addConstraint(NSLayoutConstraint(item: textView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -10))
        view.addConstraint(NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: cancelButton, attribute: .bottom, multiplier: 1, constant: 0))
        //        view.addConstraint(NSLayoutConstraint(item: textView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: currentHeight-40))
        
        self.textView = textView
        self.textView.delegate = self
        textView.becomeFirstResponder()
    }
    
    
    func setupDoneButton() {
        
        let doneButton = UIButton ()
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.speakerPurple, for: .normal)
        doneButton.isUserInteractionEnabled = true
        doneButton.addAction(UIAction(handler: { [weak self] (_) in
            let txt = self?.textView?.text ?? ""
            self?.typedTextSubject.send( txt)
//            self?.textView.resignFirstResponder()
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        
        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: doneButton , attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -10))
        view.addConstraint(NSLayoutConstraint(item: doneButton, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 5))
        view.addConstraint(NSLayoutConstraint(item: doneButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40))
        
        self.doneButton = doneButton
    } 
    deinit {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
    }
    
}
///Notifcation funcs
extension MessageBottomSheetVC {
    
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillHide),
//            name: UIResponder.keyboardWillHideNotification,
//            object: nil
//        )
    }
    
    @objc func keyboardWillHide(_ notification: Foundation.Notification) {
        if let keyboardHeight = notification.keyboardHeight   {
            ViewKeyboardHeight = keyboardHeight
            updateHeigth(calculatedHeight)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Foundation.Notification) {
        guard currentHeight == calculatedHeight else {
            return
        }
        if let keyboardHeight = notification.keyboardHeight   {
            ViewKeyboardHeight = keyboardHeight
            updateHeigth(currentHeight + ViewKeyboardHeight - UIApplication.getSafeAreaBottomInsets())
            print("keyboardWillShow")
        }
    }
    
}

extension MessageBottomSheetVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard parentView != .post else {
            return true
        }
        if let character = text.first, character.isNewline {
//            textView.resignFirstResponder()
            typedTextSubject.send( textView.text)
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return false
        }
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text =  "Start typing ..."
            textView.textColor = UIColor.lightGray
        }
    }
}

extension MessageBottomSheetVC: PanModalPresentable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var anchorModalToLongForm: Bool {
        return false
    }
}

extension Foundation.Notification {
    var keyboardHeight : CGFloat? {
        if let keyboardFrame: NSValue = self.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            return keyboardHeight
        }
        return nil
    }
}
