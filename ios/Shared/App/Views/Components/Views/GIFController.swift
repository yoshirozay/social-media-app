//
//  GIFController.swift
//  speakEZ crossplatform (iOS)
//
//  Created by Carson O'Sullivan on 5/11/22.
//

import Foundation
import GiphyUISDK
import SwiftUI
import UIKit


class GVC: UIViewController,GiphyDelegate,GPHMediaViewDelegate  {


    var gifButton: UIButton = {
        let button = UIButton()
        button.setImage(GPHIcons.giphyLogo(), for: .normal)
        button.accessibilityLabel = "GIF_BUTTON"
        return button
    }()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.gifButtonTapped()
    }

    let videoPlayer = GPHVideoPlayer()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return view.backgroundColor == .black ? .lightContent : .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    

    func updateChatColors(_ theme: GPHThemeType) {

        view.backgroundColor = .red
    }



    @objc func gifButtonTapped() {
        videoPlayer.pause()

        let giphy = GiphyViewController()
//        giphy.theme = GPHTheme(type: settingsViewController.theme)
//        giphy.mediaTypeConfig = settingsViewController.mediaTypeConfig
        GiphyViewController.trayHeightMultiplier = 0.7
//        giphy.showConfirmationScreen = settingsViewController.confirmationScreen == .on
        giphy.shouldLocalizeSearch = true
        giphy.delegate = self
        giphy.dimBackground = true
//        giphy.enableDynamicText = settingsViewController.dynamicResultsInTextSearch == .on

        giphy.modalPresentationStyle = .overCurrentContext

        if let contentType = self.selectedContentType {
            giphy.selectedContentType = contentType
        }
        if let user = self.showMoreByUser {
            giphy.showMoreByUser = user
            self.showMoreByUser = nil
        }

        present(giphy, animated: true, completion: nil)
    }


    public override var prefersStatusBarHidden: Bool {
        return true
    }

    var selectedContentType: GPHContentType?
    var showMoreByUser: String?

    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia, contentType: GPHContentType) {
        print(contentType.rawValue)
    }

    func didSearch(for term: String) {
        print("your user made a search! ", term)
    }

    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
          print("didSelectMedia \(media)")
        GPHCache.shared.clear()
    }

    func didDismiss(controller: GiphyViewController?) {
        GPHCache.shared.clear()
    }
    func didPressMoreByUser(_ user: String) {
        showMoreByUser = user
        gifButtonTapped()
    }
}

struct GVCController: UIViewControllerRepresentable {
    
    
    
    @Binding var url : String
    @Binding var present : Bool
    
    func makeUIViewController(context: Context) -> GVC {
        if !Self.isGiphyConfigured{
            Giphy.configure(apiKey: "YOUR_GIPHY_API_KEY")
            Self.isGiphyConfigured = true
        }
//        Giphy.configure(apiKey: "YOUR_GIPHY_API_KEY")
//        let controller = GiphyViewController()
//        //
//        controller.mediaTypeConfig = [.emoji, .gifs, .stickers, .text]
//        controller.swiftUIEnabled = true
//        controller.delegate = context.coordinator
//
//        GiphyViewController.trayHeightMultiplier = 1.05
//        controller.theme = GPHTheme(type: .light)
        return GVC()
    }
    func updateUIViewController(_ uiViewController: GVC, context: Context) {
        
    }
    static var isGiphyConfigured : Bool = false
}

struct GIFController: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        return GIFController.Coordinator(parent: self)
    }
    
    
    @Binding var url : String
    @Binding var present : Bool
    
    func makeUIViewController(context: Context) -> GiphyViewController {
        Giphy.configure(apiKey: "YOUR_GIPHY_API_KEY")
        let controller = GiphyViewController()
        //
        controller.mediaTypeConfig = [.emoji, .gifs, .stickers, .text]
        controller.swiftUIEnabled = true
        controller.delegate = context.coordinator
        
        GiphyViewController.trayHeightMultiplier = 1.05
//        controller.theme = GPHTheme(type: .light)
        return controller
    }
    func updateUIViewController(_ uiViewController: GiphyViewController, context: Context) {
        
    }
    class Coordinator : NSObject, GiphyDelegate {
        var parent : GIFController
        init(parent: GIFController) {
            self.parent = parent
        }
        func didDismiss(controller: GiphyViewController?) {
            
        }
        func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
            let url = media.url(rendition: .fixedWidth, fileType: .gif)
            parent.url = url ?? ""
            parent.present.toggle()
        }
    }
}
