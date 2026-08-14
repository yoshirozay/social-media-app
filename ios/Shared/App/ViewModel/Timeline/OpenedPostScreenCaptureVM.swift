//
//  OpenedPostScreenCaptureVM.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/28/21.
//

import Combine
#if os(iOS)
import UIKit
#endif
/*
 no we will just use the same func userTappedToViewMedia in the openedPost and also add capturedDidChangeNotification notification in it. and when
 */

class OpenedPostScreenCaptureVM : ObservableObject {
    /*
     this vm will only init when a opened post will be inited and only thinkg or resposibilty it has that it only needs to listener to screen capture
     */
    var screenShotSub = Set<AnyCancellable>()
    
#if os(iOS)
    func startScreenCaptureListener(postID: String,
                                    postAuthor : String) {
        //FIXME: - need to use the macOS apis for screen shoot detection
        
        guard let userId = currentUserID else { return }
        
        let tookScreenShoot = { [weak self] in
            self?.removeListeners()
            NewPostFunctions.didTakeScreenShotOf(postID: postID, postAuthor: postAuthor, currentUser: userId){ error in
                print("NewPostFunctions.didTakeScreenShotOf \(error?.localizedDescription ?? "successfull")") 
            }
        }
         
        if UIScreen.main.isCaptured{
            tookScreenShoot()
            return
        }
        
        NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)
            .sink { _ in
                print("Screenshot taken!")
                tookScreenShoot()
            }.store(in: &screenShotSub)
        
        NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)
            .sink { _ in
                if UIScreen.main.isCaptured {
                    print("Screen recorded!")
                    tookScreenShoot()
                }
            }.store(in: &screenShotSub)
    }
#else
    func startScreenCaptureListener(postID: String,
                                    postAuthor : String ){
        print("macOS listener not implemeted")
    }
#endif
    
    func removeListeners(){
        screenShotSub.forEach({$0.cancel()})
    }
    
    deinit {
        removeListeners()
    }
}
