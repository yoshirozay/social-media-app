//
//  ActivityViewController.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/11/21.
//

import SwiftUI
import UIKit
import LinkPresentation
import SDWebImage


struct ShareActivityView: View {
   @StateObject var shareActivity = ShareActivityOO()
    @State var isAnEvent: Bool
    var body: some View {
        ZStack {
            Button(action: {
                shareActivity.getDynamicLink(isAnEvent: isAnEvent, eventID: "")
            }){
                Text("Share")
                    .font(.headline)
                    .foregroundColor(Color.blue)
                    .padding(.trailing,20)
            }
            
            if let _ = shareActivity.shareURL {
                ActivityViewController(shareURL: $shareActivity.shareURL, isAnEvent: isAnEvent )
            }
        }
    }
}

class ActivityVC : UIViewController {
     
    var actionVC : (()->UIActivityViewController?)?
    var activityVController : UIActivityViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {[self] in
            activityVController = actionVC?()
            if let activityVController = activityVController {
                present(activityVController, animated: true, completion: nil)
            }
        }
    }
    
    deinit {
        print("ActivityVC ActivityVC deinit")
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = ActivityVC
    @EnvironmentObject var friendsDictionary: FriendsDictionary

    @Binding var shareURL: URL?
    @State var isAnEvent: Bool = false
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
        func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) ->  ActivityVC {
        let containerViewController = ActivityVC()
            var userWebLink: URL?
            if let userId = currentUserID {
                userWebLink = friendsDictionary.friendsDictionary[userId]?.webLink
            }
            containerViewController.actionVC = {
                guard let shareURL = shareURL, context.coordinator.presented == false else { return nil}
                
                context.coordinator.presented = true
                let textToShare: [Any] = [ MyActivityItemSource(url: shareURL,userWebLink: userWebLink, isAnEvent: isAnEvent) ]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.completionWithItemsHandler = { activity, completed, returnedItems, activityError in
                    self.shareURL = nil
                    context.coordinator.presented = false
                }
                return activityViewController
            }
        return containerViewController

    }
      
        func updateUIViewController(_ uiViewController: ActivityVC, context: UIViewControllerRepresentableContext<ActivityViewController>) {
             
            }
    
    class Coordinator: NSObject {
        let parent: ActivityViewController
        
        var presented: Bool = false
        
        init(_ parent: ActivityViewController) {
            self.parent = parent
        }
    }
}

class MyActivityItemSource: NSObject, UIActivityItemSource {
    let title: String = "Add me on speakEZ!"
    let url : URL
    let userWebLink: URL?
    let isAnEvent: Bool
    init(url: URL,userWebLink: URL?, isAnEvent: Bool) {
        self.url = url
        self.userWebLink = userWebLink
        self.isAnEvent = isAnEvent
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return url
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return url
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }
 
    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.originalURL = url
        metadata.url = url
        metadata.title = isAnEvent ? "I'm planning an event, you're invited!" : title
        
        if let userWebLink = userWebLink,
           let cacheImage =  SDImageCache.shared.imageFromCache(forKey: userWebLink.absoluteString, context: nil){
            metadata.iconProvider = NSItemProvider(object: cacheImage)
        }else if let tristanImage = UIImage(named: "Tristan copy (2)"){
            metadata.iconProvider = NSItemProvider(object: tristanImage)
        } 
        return metadata
    }
}
