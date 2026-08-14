//
//  DisplayMediaVC.swift
//  testingSwiftUI
//
//  Created by Ahmad naeem on 5/30/21.
//

import UIKit
import AVFoundation
import AVKit
import Photos
import CLImageEditor
import PanModal
import Combine

class DisplayMediaVC: UIViewController, VideoPlayerProtocol, ImagePreviewProtocol {
    
    var leadingConstraint: NSLayoutConstraint!
    var doneClouser: ((NewMedia) -> Void)?
    internal var imageView : UIImageView!
    internal var saveButton : UIButton!
    internal var editButton : UIButton!
    internal var messageTextButton : UIButton!
    internal var playerView : LoopedVideoPlayerView!
    internal var media : NewMedia
    internal var parentView : ParentView
    public required init(media : NewMedia, parentView : ParentView) {
        self.media = media
        self.parentView = parentView
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: true)
        if let videoURL = media.videoUrl {
            title = "Recored Video"
            setupAndPlay(url: videoURL)
        }else {
            title = "Edited Image"
            setupImageView(image: media.image)
        }
        
    }
    
    @objc func dismissEditorVC(){
        //            self.navigationController?.setNavigationBarHidden(true, animated: false)
        //        self.navigationController?.popViewController(animated: true)
        self.presentedViewController?.dismiss(animated: true)
    }
    
    func showEditorVC() {
        let selectedImage = media.image
        if let editor = CLImageEditor(image: selectedImage, delegate: self) { 
            editor.modalPresentationStyle = .overFullScreen
            self.present(editor, animated: true)
            editor.view.backgroundColor = .black 
        }
    }
    var subscriptions = Set<AnyCancellable>()
    
    func showMessageBottomSheetVC() {
        
        let bottomSheetVC = MessageBottomSheetVC(text: media.description, parentView: parentView)
        bottomSheetVC.typedTextSubject
            .sink {[weak self] typedText in 
                self?.media.description = typedText
            }
            .store(in: &subscriptions)
        presentPanModal(bottomSheetVC)
    }
    
    @objc internal func done() {
        doneClouser?(media)
    }
    
    @objc  private func back() {
        if media.videoUrl != nil{
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        //    print("DisplayMediaVC deinit called")
    }
}












extension DisplayMediaVC : CLImageEditorDelegate{
    
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        DispatchQueue.main.async { [self] in
            imageView.image = image
            self.media.image = image
            editor.dismiss(animated: true)
        }
    }
    
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        editor.dismiss(animated: true, completion: nil)
    }
}










//DisplayMediaProtocol:-
protocol DisplayMediaProtocol : DisplayMediaVC {
    var doneClouser: ((NewMedia) -> Void)? { get set }
    var saveButton : UIButton! { get set }
    var editButton : UIButton! { get set }
    var messageTextButton : UIButton! { get set }
    var parentView : ParentView { get }
    var media : NewMedia { get }
    var buttonViewHeight :  CGFloat { get }
    var buttonViewCurve : CGFloat { get }
    func setupDismissButton(mediaSizeOnScreen: CGSize?)
    func done()
    func setUpSendToButton()
    func saveMediaInPhotosAlbum()
    func showSavedLabel(gotError : Bool )
    func setUpSaveButton()
    func saveButtonTapped(buttonView : UIView)
    func setUpMessageTextButton()
}

extension DisplayMediaProtocol {
    
    var buttonViewHeight :  CGFloat {
        screenWidth*0.08702659146
    }
    
    var  buttonViewCurve : CGFloat{
        buttonViewHeight*0.5
    }
    
    var saveButtonViewWidth : CGFloat{
        buttonViewHeight*1.6666666667
    }
    
    func saveButtonTapped(buttonView : UIView){
        saveMediaInPhotosAlbum()
        saveButton.removeFromSuperview()
        buttonView.removeFromSuperview()
        if var leadingConstraint = leadingConstraint {
            leadingConstraint.isActive = false
            var leadingButton : UIButton! = editButton
            
            if  media.kind == .video , 
                let messageTextButton = messageTextButton  {
                leadingButton = messageTextButton
            }
            
            if let leadingButton = leadingButton{
                leadingConstraint = NSLayoutConstraint(item: leadingButton , attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 5)
                leadingConstraint.isActive = true
                view.layoutIfNeeded()
            }
        }
    }
    
    func setUpSaveButton() {
        let size : CGSize = CGSize(width: 20, height: 20)
        let  saveButton = UIButton (frame: CGRect(origin: .zero, size: size))
        saveButton.tintColor = UIColor.speakerPurple!
        var  saveImage = UIImage(named: "down-arrow2nd")
        saveImage = saveImage?.withTintColor(UIColor.speakerPurple ?? .black)
        saveButton.setImage(saveImage, for: .normal)
        saveButton.imageView?.contentMode = .scaleAspectFit
        saveButton.contentHorizontalAlignment = .fill
        saveButton.contentVerticalAlignment = .fill
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0);
        saveButton.isUserInteractionEnabled = true
        let buttonView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 70, height: 30)))
        
        saveButton.addAction(UIAction(handler: { [weak self] (_) in
            self?.saveButtonTapped(buttonView: buttonView)
        }), for: .touchUpInside)
        
        self.saveButton = saveButton
        let buttonViewWidth = saveButtonViewWidth
        buttonView.layer.cornerRadius = self.buttonViewCurve
        buttonView.layer.backgroundColor =  #colorLiteral(red: 0.2000528872, green: 0.195928216, blue: 0.2041634917, alpha: 1).cgColor
        buttonView.layer.masksToBounds = true
        buttonView.backgroundColor =  #colorLiteral(red: 0.2000528872, green: 0.195928216, blue: 0.2041634917, alpha: 1)
        
        self.view.addSubview(buttonView)
        view.bringSubviewToFront(buttonView)
        buttonView.addSubview(saveButton)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: saveButton, attribute: .leading, relatedBy: .equal, toItem: buttonView, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: saveButton, attribute: .trailing, relatedBy: .equal, toItem: buttonView, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: saveButton, attribute: .top, relatedBy: .equal, toItem: buttonView, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: saveButton, attribute: .bottom, relatedBy: .equal, toItem: buttonView, attribute: .bottom, multiplier: 1, constant: 0))
        
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: buttonView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonViewWidth))
        
        view.addConstraint(NSLayoutConstraint(item: buttonView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonViewHeight))
        
        view.addConstraint(NSLayoutConstraint(item: buttonView , attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 5))
        
        let bottomConstraint : CGFloat = UIApplication.getSafeAreaTopInsets() == 0 ? -5 : -30
        
        view.addConstraint(NSLayoutConstraint(item: buttonView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: bottomConstraint))
        
    }
    
    func showSavedLabel(gotError : Bool = false) {
        let label = UILabel()
        label.textAlignment = .center
        let mediaName = media.videoUrl == nil ? "Image" : "Video"
        label.text = "\(mediaName) Saved"
        if gotError {
            label.text = "Error Saving \(mediaName)"
        }
        label.textColor = .white
        label.layer.cornerRadius = 8
        label.layer.backgroundColor = UIColor.black.withAlphaComponent(0.9).cgColor
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()
        
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        view.addConstraint(NSLayoutConstraint(item: label , attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 5))
        
        let bottomConstraint : CGFloat = UIApplication.getSafeAreaTopInsets() == 0 ? -5 : -30
        
        view.addConstraint(NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: bottomConstraint-35))
        
        let labelWidth =  label.frame.width + 30
        label.addConstraint( NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30))
        
        label.addConstraint( NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: labelWidth))
        
        weak var weakLabel = label
        let hiddingAnimation = {
            let _ =  Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [weak self] (_) in
                DispatchQueue.main.async {
                    guard let strongView = self?.view else { return  }
                    UIView.transition(with: strongView, duration: 0.5,
                                      options: .transitionCrossDissolve,
                                      animations: {
                                        weakLabel?.removeFromSuperview()
                                      })
                }
                
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] (_) in
            DispatchQueue.main.async {
                guard let strongView = self?.view else { return  }
                
                UIView.transition(with: strongView, duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    weakLabel?.isHidden = false
                                  },completion: { _ in
                                    hiddingAnimation()
                                  })
            }
        }
    }
    
    func saveMediaInPhotosAlbum(){
        NewMedia.saveInPhotosAlbum(newMedia: media) {[weak self]  error in
            self?.showSavedLabel(gotError: error != nil)
            print(error?.localizedDescription ?? "media saved in PhotosAlbum")
        }
        
        DispatchQueue.main.async {[weak self]  in
            guard let strongSelf = self  else { return  }
            UIView.transition(with: strongSelf.view , duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: {
                                strongSelf.saveButton?.removeFromSuperview()
                              } )
        }
        
    }
    
    func setUpSendToButton() {
        
        let sendToButton = UIView()
        let  bindableTap = BindableGestureRecognizer { [weak self] in
            self?.done()
        }
        sendToButton.isUserInteractionEnabled = true
        sendToButton.addGestureRecognizer(bindableTap)
        
        let buttonViewWidth = buttonViewHeight*2.8240740741
        sendToButton.layer.cornerRadius = buttonViewCurve
        sendToButton.layer.masksToBounds = true
        sendToButton.backgroundColor =  .speakerPurple
        
        self.view.addSubview(sendToButton)
        view.bringSubviewToFront(sendToButton)
        
        sendToButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: sendToButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonViewWidth))
        
        view.addConstraint(NSLayoutConstraint(item: sendToButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonViewHeight))
        
        view.addConstraint(NSLayoutConstraint(item: sendToButton , attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -5))
        let bottomConstraint : CGFloat = UIApplication.getSafeAreaTopInsets() == 0 ? -5 : -30
        
        view.addConstraint(NSLayoutConstraint(item: sendToButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: bottomConstraint))
        
        let label = UILabel()
        
        let labelText : String
        let textAlignment: NSTextAlignment
        
        if parentView == .sendTo {
            labelText = "Send To"
            textAlignment = .left
        }else{
            labelText = "Done"
            textAlignment = .center
        }
        
        label.textAlignment = textAlignment
        label.text = labelText
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        sendToButton.addSubview(label)
        
        let leadingConstrant : CGFloat = buttonViewHeight*0.4351851852
        let HeightConstrant : CGFloat =  (buttonViewHeight*0.3703703704) + 1
        
        sendToButton.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: sendToButton, attribute: .centerY, multiplier: 1, constant: 0))
        
        sendToButton.addConstraint(NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: sendToButton, attribute: .leading, multiplier: 1, constant: leadingConstrant))
        
        sendToButton.addConstraint(NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: HeightConstrant))
        
        label.sizeToFit()
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        
        let imageView = UIImageView(image: UIImage(named: "right-arrow"))
        sendToButton.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        sendToButton.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: sendToButton, attribute: .centerY, multiplier: 1, constant: 0))
        
        sendToButton.addConstraint(NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: sendToButton, attribute: .trailing, multiplier: 1, constant: 10))
        
        sendToButton.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: HeightConstrant))
    }
    
    func getMediaRequiredSize(resolution: CGSize?) -> CGSize? {
        guard  let resolution = resolution else {
            return nil
        }
        let resolutionRatio = resolution.height / resolution.width
        let mediaHeightOnDevice = screenWidth * resolutionRatio
        let mediaSizeOnDevice = CGSize(width: screenWidth, height: mediaHeightOnDevice)
        return   mediaSizeOnDevice
    }
    
    func setupDismissButton(mediaSizeOnScreen: CGSize?) {
        let size : CGSize = CGSize(width: 50, height: 50)
        let  dismissButton = UIButton (frame: CGRect(origin: .zero, size: size))
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .medium)
        let saveImage = UIImage(systemName: "xmark", withConfiguration:configuration)
        dismissButton.tintColor = UIColor.white
        dismissButton.setImage(saveImage, for: .normal)
        dismissButton.isUserInteractionEnabled = true
        dismissButton.addAction(UIAction(handler: { [weak self] (_) in
            self?.navigationController?.setNavigationBarHidden(false, animated: false)
            self?.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        
        self.view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        let topConstraintConstant: CGFloat = 25
//        if let mediaSizeOnScreen =  mediaSizeOnScreen,mediaSizeOnScreen.height != screenHeight {
//            topConstraintConstant += ((screenHeight - mediaSizeOnScreen.height)/2)
//        }else{
//            topConstraintConstant += (UIApplication.getSafeAreaTopInsets() == 0 ? 0 : 30)
//        }
        view.addConstraint(NSLayoutConstraint(item: dismissButton , attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 25))
        
        view.addConstraint(NSLayoutConstraint(item: dismissButton, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: topConstraintConstant))
    }
}

protocol ImagePreviewProtocol : DisplayMediaProtocol {
    var  imageView : UIImageView! {get set}
    var leadingConstraint: NSLayoutConstraint!  {get set}
    func  setupImageView(image : UIImage)
    func setUpEditButton()
    func showEditorVC()
    func showMessageBottomSheetVC()
}
// CLImageEditorDelegate


extension ImagePreviewProtocol {
    func setupImageView(image : UIImage){
        let imageView = UIImageView(image: image)
        
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .lessThanOrEqual, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .lessThanOrEqual, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
        self.imageView = imageView
        let imageRequiredSize = getMediaRequiredSize(resolution: image.size)
        setupDismissButton(mediaSizeOnScreen: imageRequiredSize)
        setUpSaveButton()
        setUpSendToButton()
        setUpEditButton()
        setUpMessageTextButton()
    }
    
    func setUpEditButton()  {
        let size : CGSize = CGSize(width: 30, height: 30)
        let editButton = UIButton (frame: CGRect(origin: .zero, size: size))
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        
        editButton.tintColor = UIColor.speakerPurple ?? UIColor.black
        let  saveImage = UIImage(systemName: "pencil" , withConfiguration:configuration)
        editButton.setImage(saveImage, for: .normal)
        editButton.imageView?.contentMode = .scaleAspectFit
        editButton.contentHorizontalAlignment = .fill
        editButton.contentVerticalAlignment = .fill
        editButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0);
        editButton.isUserInteractionEnabled = true
        
        let editButtonView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 70, height: 30)))
        
        editButton.addAction(UIAction(handler: { [weak self] (_) in
            print("show edit screen")
            self?.showEditorVC()
            
        }), for: .touchUpInside)
        
        editButtonView.layer.cornerRadius =  buttonViewCurve
        editButtonView.layer.backgroundColor =  #colorLiteral(red: 0.2000528872, green: 0.195928216, blue: 0.2041634917, alpha: 1).cgColor
        editButtonView.layer.masksToBounds = true
        editButtonView.backgroundColor =  #colorLiteral(red: 0.2000528872, green: 0.195928216, blue: 0.2041634917, alpha: 1)
        
        
        self.view.addSubview(editButtonView)
        view.bringSubviewToFront(editButtonView)
        editButtonView.addSubview(editButton)
        
        editButton.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: editButton, attribute: .leading, relatedBy: .equal, toItem: editButtonView, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: editButton, attribute: .trailing, relatedBy: .equal, toItem: editButtonView, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: editButton, attribute: .top, relatedBy: .equal, toItem: editButtonView, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: editButton, attribute: .bottom, relatedBy: .equal, toItem: editButtonView, attribute: .bottom, multiplier: 1, constant: 0))
        
        editButtonView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: editButtonView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: saveButtonViewWidth))
        
        view.addConstraint(NSLayoutConstraint(item: editButtonView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonViewHeight))
        
        self.leadingConstraint = NSLayoutConstraint(item: editButtonView , attribute: .leading, relatedBy: .equal, toItem: saveButton, attribute: .trailing, multiplier: 1, constant: 15)
        view.addConstraint(leadingConstraint)
        
        
        let bottomConstraint : CGFloat = UIApplication.getSafeAreaTopInsets() == 0 ? -5 : -30
        view.addConstraint(NSLayoutConstraint(item: editButtonView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: bottomConstraint))
        self.editButton = editButton
        
    }
    
    func setUpMessageTextButton()  {
        guard parentView != .userProfile else {
            return
        }
        
        let size : CGSize = CGSize(width: 30, height: 30)
        let messageTextButton = UIButton (frame: CGRect(origin: .zero, size: size))
        messageTextButton.tintColor = UIColor.speakerPurple ?? UIColor.black
        var  saveImage = UIImage(named: "TypeMessageText2nd")
        saveImage = saveImage?.withTintColor(UIColor.speakerPurple ?? .black)
        messageTextButton.setImage(saveImage, for: .normal)
        messageTextButton.imageView?.contentMode = .scaleAspectFit
        messageTextButton.contentHorizontalAlignment = .fill
        messageTextButton.contentVerticalAlignment = .fill
        messageTextButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0);
        messageTextButton.isUserInteractionEnabled = true
        
        let         messageTextButtonView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 70, height: 30)))
        
        messageTextButton.addAction(UIAction(handler: { [weak self] (_) in 
            self?.showMessageBottomSheetVC()
        }), for: .touchUpInside)
        
        messageTextButtonView.layer.cornerRadius =  buttonViewCurve
        messageTextButtonView.layer.backgroundColor =  #colorLiteral(red: 0.2000528872, green: 0.195928216, blue: 0.2041634917, alpha: 1).cgColor
        messageTextButtonView.layer.masksToBounds = true
        messageTextButtonView.backgroundColor =  #colorLiteral(red: 0.2000528872, green: 0.195928216, blue: 0.2041634917, alpha: 1)
        
        
        self.view.addSubview(messageTextButtonView)
        view.bringSubviewToFront(messageTextButtonView)
        messageTextButtonView.addSubview(messageTextButton)
        
        messageTextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: messageTextButton, attribute: .leading, relatedBy: .equal, toItem:         messageTextButtonView, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: messageTextButton, attribute: .trailing, relatedBy: .equal, toItem:         messageTextButtonView, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: messageTextButton, attribute: .top, relatedBy: .equal, toItem:         messageTextButtonView, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: messageTextButton, attribute: .bottom, relatedBy: .equal, toItem:         messageTextButtonView, attribute: .bottom, multiplier: 1, constant: 0))
        
        messageTextButtonView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: messageTextButtonView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: saveButtonViewWidth))
        
        view.addConstraint(NSLayoutConstraint(item: messageTextButtonView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonViewHeight))
        
        //        view.addConstraint(NSLayoutConstraint(item: messageTextButtonView, attribute: .width, relatedBy: .equal, toItem: saveButton, attribute: .width, multiplier: 1, constant: 0))
        //
        //        view.addConstraint(NSLayoutConstraint(item: messageTextButtonView, attribute: .height, relatedBy: .equal, toItem: saveButton, attribute: .height, multiplier: 1, constant: 0))
        
        var leadingButton : UIButton? = editButton
        if  media.kind == .video {
            leadingButton = saveButton
        }
        let leadingConstraint = NSLayoutConstraint(item: messageTextButtonView , attribute: .leading, relatedBy: .equal, toItem: leadingButton, attribute: .trailing, multiplier: 1, constant: 15)
        view.addConstraint(leadingConstraint)
        
        if  media.kind == .video{
            self.leadingConstraint = leadingConstraint
        }
        
        let bottomConstraint : CGFloat = UIApplication.getSafeAreaTopInsets() == 0 ? -5 : -30
        view.addConstraint(NSLayoutConstraint(item: messageTextButtonView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: bottomConstraint))
        self.messageTextButton = messageTextButton
    }
    
}

protocol VideoPlayerProtocol :  DisplayMediaProtocol {
    var playerView : LoopedVideoPlayerView! {get set}
    func setupAndPlay(url : URL)
}

extension VideoPlayerProtocol {
    
    internal func setupAndPlay(url : URL) {
        
        playerView =  LoopedVideoPlayerView(frame: view.frame)
        view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false

        guard let playerView = playerView else { return  }
        if  let size = getMediaRequiredSize(resolution: resolutionForLocalVideo(url: url)){
            view.addConstraint(NSLayoutConstraint(item: playerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.width))
            
            view.addConstraint(NSLayoutConstraint(item: playerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.height))
            
        }else{
            view.addConstraint(NSLayoutConstraint(item: playerView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
            
            view.addConstraint(NSLayoutConstraint(item: playerView, attribute: .leading, relatedBy: .lessThanOrEqual, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
            
            view.addConstraint(NSLayoutConstraint(item: playerView, attribute: .top, relatedBy: .lessThanOrEqual, toItem: view, attribute: .top, multiplier: 1, constant: 0))
            
            view.addConstraint(NSLayoutConstraint(item: playerView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        }
        
        view.addConstraint(NSLayoutConstraint(item: playerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: playerView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
        playerView.prepareVideo(url)
        
        let videoRequiredSize =  getMediaRequiredSize(resolution: resolutionForLocalVideo(url: url))//getVideoRequiredSize(url: url)
        setupDismissButton(mediaSizeOnScreen: videoRequiredSize)
        setUpSaveButton()
        setUpSendToButton()
        setUpMessageTextButton()
    }
    
    private func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
}

extension UIImage {
    static var backImage : UIImage? {
        let configuration = UIImage.SymbolConfiguration( pointSize: 20, weight: .medium, scale: .large)
        let backImage = UIImage(systemName: "chevron.backward", withConfiguration:configuration)
        return backImage
    }
}

final class BindableGestureRecognizer: UITapGestureRecognizer {
    private var action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }
    
    @objc private func execute() {
        action()
    }
}
