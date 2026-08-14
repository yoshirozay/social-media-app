//
//  ShareActivityOO.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/11/21.
//

import SwiftUI
import FirebaseAuth
class ShareActivityOO : ObservableObject{
    @Published var shareURL: URL?
    @Published var qrCodeImageData: Data?
    
    func getDynamicLink(isAnEvent: Bool, eventID: String){
         #if os(iOS)
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        DynamicLinkManager.shared.createShortDynamicLinkURL(currentUserId: isAnEvent ? eventID : userId, isAnEvent: isAnEvent) {[weak self] url, error in
             if let url = url {
                self?.shareURL = url
            }else {
                assert(false, " what happend   \(error?.localizedDescription ?? "url was nill") ")
            }
        }
         #endif
    }
    func getDynamicLinkQRCode(isAnEvent: Bool){
         #if os(iOS)
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        DynamicLinkManager.shared.createShortDynamicLinkURL(currentUserId: userId, isAnEvent: isAnEvent) {[weak self] url, error in
            if let url = url,
               let imageData = QRCodeManager.shared.generateQRCode(from: url.absoluteString)?.jpegData(compressionQuality: 1.0) {
                self?.qrCodeImageData = imageData
            }else {
                assert(false, " what happend   \(error?.localizedDescription ?? "url was nill") ")
            }
        }
         #endif
    }
}
