//
//  VideoOnceViewVM.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/19/21.
//

import Combine
//import YPImagePicker
import AVKit
import SDWebImage.SDWebImageManager
  
class VideoOnceViewVM : VideoThumbnailVM { 
    @Published private var isImageDownloaded = false
    var message: MessageModel
    var isMediaDownloaded : Bool {
        isImageDownloaded || (videoDocURL != nil)
    }
     
    private var sub : AnyCancellable?
    
    required init(message: MessageModel) {
       
//        print("VideoOnceViewVM ,",message.id)
        self.message = message
        super.init()
        guard message.alreadyViewOnce == false else { return  } 
        if let photoLink = message.photoLink{
            SDWebImageManager.shared.loadImage(with: photoLink, progress: nil) {[weak self]  image, data, error, cachyType, bol, url in
                  self?.isImageDownloaded = (image != nil)
            }
        }else if let videoFirebaseURL = message.videoUrl{
            fetchVideoFrom(videoFirebaseURL : videoFirebaseURL)
        }
    }
 
// we can just use a class func. that way we can also add the delay that might be case if the user take screen shot while view is been dismissed. because we will first dismiss and then it will be animated
    var screenShotSub: AnyCancellable?
    func userTappedToViewMedia() {//xcrun simctl UIApplication.userDidTakeScreenshotNotification
        let chatUID = message.chatID 
        let messageUID = message.id
        //FIXME: - need to use the macOS apis for screen shoot detection
#if os(iOS)
        screenShotSub = NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)
            .sink { _ in  
            print("Screenshot taken!")
                SendMessageFunctions.didTakeScreenShotOf(messageUID: messageUID, chatUID: chatUID)
            //so here we will call a cloud func no need to update the timeline messages array.
        }
        
#endif
//        SendMessageFunctions.didTakeScreenShotOf(messageUID: messageUID, chatUID: chatUID)
    }
    deinit {
        screenShotSub?.cancel()
    }
}
