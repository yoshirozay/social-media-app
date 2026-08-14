//
//  PostVM.swift
//  speakEZ
//
//  Created by Ahmad naeem on 4/21/22.
//

import Foundation
import Combine
 
class PostVM : ObservableObject {
    
    @Published private (set) var openedTags : [String] = []
    @Published private (set) var commentLikeVM : CommentLikeVM?
   
      var subs = Set<AnyCancellable>()
    
    init(addListener : Bool = true) { 
        startPNRelatedListener(addListener : addListener)
    }
    
    func openPost(commentLikeVM: CommentLikeVM) {
        self.commentLikeVM = commentLikeVM
        setViewInfo()
    }
    
    func dismissOpenedPost() {
        removeViewInfo()
        commentLikeVM = nil
        dismissOpenedFriendTag()
    }
    
    func openPost(commentLikeVM: CommentLikeVM,withTags : [String]) {
        openedTags = withTags
        openPost(commentLikeVM: commentLikeVM)
    }
    
    func dismissOpenedFriendTag(){
        openedTags.removeAll()
    }
    
    deinit {
        subs.cancelAll()
    }
}

extension PostVM : PNViewManagerSetAble{ 
    var docId : String {  commentLikeVM?.post.postID ?? "" }
    var type: PNViewManager.OnScreenView { .post }
    
    func startPNRelatedListener(addListener : Bool){
        if addListener {
           publisherForNewPN.sink {[weak self] _ in
                    self?.dismissOpenedPost()
            }.store(in: &subs)
        }else{
            addPushNotificationViewListener()
                .store(in: &subs)
        }
    }
}
/*
 now we have to options one is to allow the PNVM to change onViewManagerr on screen view. and other is to add notificaiton observers and
 and then we can all the notifications from the.
 i think notifications will be a good approach. because a VM should be the one changing stuff. because it depeneds on VM, so if we set onscreen view to be .post but vm is not inited then it will be cause problem. onScreen depends on view life time or VM of that view life time.
 */
/*
 now this has become quite complex. the issue is that if a view get coverd how will we know that. so when the convering view will dismiss we need to set the onScreen view to back to the old view. and that makes it complicated. as we also remove the 
 */
