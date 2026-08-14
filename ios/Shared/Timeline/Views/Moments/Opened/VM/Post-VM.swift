//
//  P-VM.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//


import Foundation
import Combine
import FirebaseFirestoreSwift
import FirebaseFirestore
import SwiftUI

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

struct PostUserInteractionModel : Decodable {
    var documentId : String
    var sentBy : String
    /** as we do not time for now we will not decode it from the like*/
    var time : Timestamp
    
    enum CodingKeys: String, CodingKey {
        case documentId
        case sentBy
        case time
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        documentId = try FirestoreDocumentID(from: decoder).documentId
        sentBy = try container.decode(String.self, forKey: .sentBy)
        time = try container.decode(Timestamp.self, forKey: .time)
    }
    static func getCollRef(authorId : String,postID : String) -> CollectionReference {
        Firestore.firestore().collection("Posts").document(authorId.nonEmpty).collection("UserPosts").document(postID.nonEmpty).collection("Likes")
    }
}
extension PostUserInteractionModel : Identifiable,Hashable,Equatable {
    var id : String { documentId }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(documentId)
    }
    static func == (lhs: PostUserInteractionModel, rhs: PostUserInteractionModel) -> Bool {
        return lhs.documentId == rhs.documentId
    }
}


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
