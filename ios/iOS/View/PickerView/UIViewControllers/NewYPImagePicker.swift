//
//  NewYPImagePicker.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 4/26/21.
//

import SwiftUI
import UIKit
import YPImagePicker
import CLImageEditor
import AVKit 
import Combine

class NewYPImagePicker : YPImagePicker {
    
    private var isMediafromCamera : Bool = false 
    var parentView : ParentView = .other
    var text : String = ""
    var subs : AnyCancellable?
    override func viewDidLoad() {
        super.viewDidLoad()
         
        YPImagePickerConfiguration.shared.wordings.cameraTitle = "Camera"
        YPImagePickerConfiguration.shared.wordings.videoTitle = "Camera"
        
        if let image = UIImage(named: "cameraMiddle") {
            YPImagePickerConfiguration.shared.icons.capturePhotoImage = image
            YPImagePickerConfiguration.shared.icons.captureVideoImage = image
            YPImagePickerConfiguration.shared.video.libraryVideoSizeLimit = 64*1000*1000
        }
        setupPickerCallback()
        
        subs = NotificationCenter.default
            .publisher(for: PushNotificationVM.pushNotificationTapped)
            .compactMap{($0.object as? PNViewManager.OnScreenView)}
            .sink { [weak self]  _ in
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                    //we are calling dismiss twice because if user has not given camera permisson then alert will be shown and on dismiss only the alert will be dismissed. so we call dismiss again to dismiss the view.
                    self?.dismiss(animated: true)
                }
            }
    }
    
    func setupPickerCallback() {
        
        self.didFinishPicking {[weak self]   items, er in
            guard !items.isEmpty else {
                self?.dismiss(animated: true)
                return
            }
            if let photo = items.singlePhoto {
                let selectedImage = photo.image
                let isImageFromCamera = photo.fromCamera
                self?.isMediafromCamera =  isImageFromCamera
                let newMedia = NewMedia(image: selectedImage,description:  self?.text ?? "", isFromCamera:isImageFromCamera)
                if isImageFromCamera {
                    let vc = DisplayMediaVC(media: newMedia, parentView: self?.parentView ?? .other)
                    vc.doneClouser = { [weak self] media in
                        self?._didGetEditedImage?( media )
                    }
                    self?.pushViewController(vc, animated: true)
                }else{
                    if let editor = CLImageEditor(image: selectedImage, delegate: self) ,
                       let strongSelf = self {
                        editor.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.backImage,
                                                                                  style: .plain,
                                                                                  target: strongSelf,
                                                                                  action: #selector(strongSelf.back))
                        self?.pushViewController(editor, animated: true)
                        
                        self?.navigationBar.tintColor = UIColor.white;
                        self?.navigationBar.barTintColor = UIColor.black;
                        self?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                        
                    }else{
                        assert(false, "CLImageEditor init error")
                    }
                }
            }
            
            if let video : YPMediaVideo = items.singleVideo{
                let isVideoFromCamera = video.fromCamera
                self?.isMediafromCamera = isVideoFromCamera
                
                let newMedia = NewMedia(image: video.thumbnail, videoUrl: video.url,description:  self?.text ?? "", isFromCamera: isVideoFromCamera)
                if isVideoFromCamera   {
                    let vc = DisplayMediaVC(media: newMedia, parentView: self?.parentView ?? .other)
                    vc.doneClouser = { [weak self] media in
                        self?._didGetEditedImage?( media )
                    }
                    self?.pushViewController(vc, animated: true)
                }else{
                    self?._didGetEditedImage?(newMedia )
                }
                
            }
        }
    }
    
    @objc func back(){
        if isMediafromCamera {
            setNavigationBarHidden(true, animated: false)
        }
        popViewController(animated: true)
         
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
       
           if traitCollection.userInterfaceStyle == .light{
               self.navigationBar.tintColor = .black;
               self.navigationBar.barTintColor = .white;
               self.navigationBar.backgroundColor = .white
           }else{
               self.navigationBar.tintColor = .white;
               self.navigationBar.barTintColor = .black;
               self.navigationBar.backgroundColor = .black
           }
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let ypPhotoFiltersVC = viewController as? YPPhotoFiltersVC{
            ypPhotoFiltersVC.isFromSelectionVC = true
            ypPhotoFiltersVC.didCancel = {[weak ypPhotoFiltersVC] in
                ypPhotoFiltersVC?.navigationController?.popViewController(animated: true)
            }
            super.pushViewController(ypPhotoFiltersVC, animated: animated)
        }else{
            super.pushViewController(viewController, animated: animated)
            if #available(iOS 15, *) ,
               let _ = viewController as? CLImageEditor{
                self.navigationBar.backgroundColor = .black
            }
        }
       
       
    }
    
    static func getConfig(canGetVideo : Bool ) -> YPImagePickerConfiguration  {
        var config = YPImagePickerConfiguration()
        config.screens = [.library ]
        config.library.maxNumberOfItems = 1
        config.isScrollToChangeModesEnabled = true
        config.onlySquareImagesFromCamera = false
        config.usesFrontCamera = true
        config.showsPhotoFilters = false
        config.startOnScreen = YPPickerScreen.library
        config.targetImageSize = YPImageSize.original
        config.hidesStatusBar = true
        config.hidesBottomBar = false
        config.hidesCancelButton = false
        config.shouldSaveNewPicturesToAlbum = false
        config.library.onlySquare = false
        config.library.isSquareByDefault = false
        config.showsVideoTrimmer = false
        config.video.compression = AVAssetExportPresetPassthrough
        config.video.libraryTimeLimit = 60*60
        /*so if the library video is more then 60 sec then only the first 60 will be used.
         for that we can just change the trimmerMaxDuration to one hour as well. and when user tap on next we will show alert and not dismiss the VC  untill user select the trimmer with 60 seconds
         */
        config.video.trimmerMaxDuration = 60
        config.video.recordingTimeLimit = 60
        if canGetVideo {
            config.screens.append(.video)
            config.library.mediaType = .photoAndVideo
            config.startOnScreen = YPPickerScreen.video
        }else{
            config.screens.append(.photo )
            config.library.mediaType = .photo
            config.startOnScreen = YPPickerScreen.photo
        }
        
        //        config.startOnScreen = YPPickerScreen.library
        return config
    } 
    
    var token : NSKeyValueObservation?
    deinit {
        token?.invalidate()
        subs?.cancel()
        //        print("NewYPImagePicker deinit")
    }
    
    
    private var _didGetEditedImage: ((NewMedia?) -> Void)?
    public func didGetEditedImage(completion: @escaping (_ image: NewMedia?) -> Void) {
        _didGetEditedImage = completion
    }
    
}

extension NewYPImagePicker: CLImageEditorDelegate {
    
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        
        let newMedia = NewMedia(image: image,description: text ,isFromCamera: isMediafromCamera)
        self._didGetEditedImage?(newMedia )
    }
    
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        editor.dismiss(animated: true, completion: nil)
        
        self.navigationBar.tintColor = UIColor.black;
        self.navigationBar.barTintColor = UIColor.white;
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
    }
}
