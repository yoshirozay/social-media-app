//
//  OSPostLabel.swift
//  speakEZ (macOS)
//
//  Created by Ahmad naeem on 10/4/21.
//

import SwiftUI
import AppKit
//FIXME: - we need a a NSTextField like active label or our. for now its just normal NSTextField and UIImpactFeedbackGenerator as well 
typealias PostLabel = OSPostLabel
struct OSPostLabel: NSViewRepresentable {
    
    typealias NSViewType = NSTextField
    
    @Environment(\.colorScheme) var colorScheme
    private(set) var width: CGFloat
    private(set) var content = String()
    var OpenProfileMatchedGeometry = String()
    
    func makeNSView(context: Context) -> NSTextField {
        let label = NSTextField(string: content)
        label.maximumNumberOfLines = 1
        label.preferredMaxLayoutWidth = width
        label.textColor = colorScheme == .light ? .black : UIColor(white: 1, alpha: 0.6)
        label.font = .preferredFont(forTextStyle: .title3)
        
//        label.enabledTypes = [.mention, .hashtag, .url]
//        label.mentionColor = .speakerPurpleUI
//        label.hashtagColor = .speakerPinkUI
//        label.handleMentionTap { mention in
//            print("Success. You just tapped the \(mention) mention")
//        }
        return label
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
         
    }
 }

typealias CommentReplyLabel =  OSCommentReplyLabel 
struct OSCommentReplyLabel: NSViewRepresentable {
    
    typealias NSViewType = NSTextField
    @Environment(\.colorScheme) var colorScheme
    private(set) var width: CGFloat
    private(set) var content = String()
    var OpenProfileMatchedGeometry = String()
    func makeNSView(context: Context) -> NSTextField {
        let label = NSTextField(string: content)
        label.maximumNumberOfLines = 0
        label.preferredMaxLayoutWidth = width
//        label.enabledTypes = [.mention, .hashtag, .url]
//        label.text = content
//        label.mentionColor = .speakerPurpleUI
//        label.hashtagColor = .speakerPinkUI
        
        label.textColor = colorScheme == .light ? .black : UIColor(white: 1, alpha: 0.6)
        label.font = .preferredFont(forTextStyle: .caption1)
//        label.handleMentionTap { mention in
//            print("Success. You just tapped the \(mention) mention")
//        }
        return label
    }
    func updateNSView(_ nsView: NSTextField, context: Context) {
      
    }
    
     
}
//struct CommentLabel: UIViewRepresentable {
//    @Environment(\.colorScheme) var colorScheme
//    private(set) var width: CGFloat
//    private(set) var content = String()
//    var OpenProfileMatchedGeometry = String()
//    func makeUIView(context: UIViewRepresentableContext<CommentLabel>) -> UILabel {
//        let label = ActiveLabel()
//        label.numberOfLines = 0
//        label.preferredMaxLayoutWidth = width
//        label.enabledTypes = [.mention, .hashtag, .url]
//        label.text = content
//        label.mentionColor = .speakerPurpleUI
//        label.hashtagColor = .speakerPinkUI
//
//        label.textColor = colorScheme == .light ? .black : UIColor(white: 1, alpha: 0.6)
//        label.font = .preferredFont(forTextStyle: .caption1)
//        label.handleMentionTap { mention in
//            print("Success. You just tapped the \(mention) mention")
//        }
//        return label
//    }
//
//    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<CommentLabel>) { }
//}
typealias CommentLabel = OSCommentLabel
struct OSCommentLabel: NSViewRepresentable {
    
    typealias NSViewType = NSTextField
    
    @Environment(\.colorScheme) var colorScheme
    private(set) var width: CGFloat
    private(set) var content = String()
    var OpenProfileMatchedGeometry = String()
    
    func makeNSView(context: Context) -> NSTextField {
        let label = NSTextField(string: content)
        label.maximumNumberOfLines = 1
        label.preferredMaxLayoutWidth = width
        label.textColor = colorScheme == .light ? .black : UIColor(white: 1, alpha: 0.6)
        label.font = .preferredFont(forTextStyle: .title3) 
//
//        label.enabledTypes = [.mention, .hashtag, .url]
//        label.mentionColor = .speakerPurpleUI
//        label.hashtagColor = .speakerPinkUI
//        label.handleMentionTap { mention in
//            print("Success. You just tapped the \(mention) mention")
//        }
        return label
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
         
    }
 }
