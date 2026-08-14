//
//  Mentions.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 4/20/21.
//

import SwiftUI
import ActiveLabel

class ActiveLabelOO: ObservableObject {
    @Published var label = ActiveLabel()
    @Published var OpenProfileMatchedGeometry = String()
    init(content: String){
        label.numberOfLines = 0
        label.enabledTypes = [.mention, .hashtag, .url]
        label.text = content
        label.mentionColor = .blue
        label.hashtagColor = .systemPink
        label.textColor = .black
        label.handleHashtagTap { hashtag in
            print("Success. You just tapped the \(hashtag) hashtag")
        }

    }
    func setOpenProfileMatchedGeometry(item: String) {
        OpenProfileMatchedGeometry = item
    }
}

struct PostLabel: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    let width: CGFloat
    let content : String
    let tappedMention : ((String) -> ())
    func makeUIView(context: UIViewRepresentableContext<PostLabel>) -> UILabel {
        let label = ActiveLabel()
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = width
//        label.preferredMaxLayoutHeight = height
        label.enabledTypes = [.mention, .hashtag, .url]
        label.text = content
        label.mentionColor = .speakerPurpleUI
        label.hashtagColor = .speakerPinkUI
        
        label.textColor = colorScheme == .light ? .black : UIColor(white: 1, alpha: 1)
        label.font = .preferredFont(forTextStyle: .title3)
        label.handleMentionTap {  tappedMention($0) }
        return label
    }

    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<PostLabel>) { }
}
struct PostLabel2: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    private(set) var width: CGFloat
    private(set) var content = String()
    var OpenProfileMatchedGeometry = String()
    var isFromLongPost = false
    var tappedMention : ((String) -> ())
    func makeUIView(context: UIViewRepresentableContext<PostLabel2>) -> UILabel {
        let label = ActiveLabel()
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = width
        label.enabledTypes = [.mention, .hashtag, .url]
        label.text = content
        label.mentionColor = .speakerPurpleUI
        label.hashtagColor = .speakerPinkUI
        label.textAlignment = .center
        label.textColor = .black
        
//        label.textColor = colorScheme == .light ? .black : UIColor(white: 1, alpha: 1)
        label.font = .preferredFont(forTextStyle: .headline)
        label.handleMentionTap(tappedMention)
        if isFromLongPost != true {
        label.numberOfLines = 6
        }
        return label
    }

    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<PostLabel2>) { }
}
struct PostLabel3: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    private(set) var width: CGFloat
    private(set) var content = String()
    var OpenProfileMatchedGeometry = String()
    var isFromLongPost = false
    var isFromOpenedPost = false
    var tappedMention : ((String) -> ())
    var tappedLink : ((URL) -> ())
    func makeUIView(context: UIViewRepresentableContext<PostLabel3>) -> UILabel {
        let label = ActiveLabel()
        if isFromOpenedPost {
            label.numberOfLines = 4
        } else {
            label.numberOfLines = 6
        }
        label.preferredMaxLayoutWidth = width
        label.enabledTypes = [.mention, .hashtag, .url]
        label.text = content
        label.mentionColor = .accent
        label.hashtagColor = .accent
        label.URLColor = .accent
        label.textAlignment = .left
        label.textColor = .black
        if isFromOpenedPost {
            label.font = .preferredFont(for: .subheadline, weight: .light)
        } else {
            label.font = .preferredFont(for: .headline, weight: .regular)
        }
        label.handleMentionTap(tappedMention)
        label.handleURLTap(tappedLink)
        label.urlMaximumLength = 20
        // doesn't work sadly ^
        if isFromLongPost != false {
        label.numberOfLines = 13
        }
        return label
    }

    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<PostLabel3>) { }
}

struct CommentLabel: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    private(set) var width: CGFloat
    private(set) var content = String()
    var OpenProfileMatchedGeometry = String()
    var tappedMention : ((String) -> ())
    func makeUIView(context: UIViewRepresentableContext<CommentLabel>) -> UILabel {
        let label = ActiveLabel()
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = width
        label.enabledTypes = [.mention, .hashtag, .url]
        label.text = content
        label.mentionColor = .speakerPurpleUI
        label.hashtagColor = .speakerPinkUI
//        label.textAlignment = .center
        
        label.textColor = colorScheme == .light ? .black : UIColor(white: 1, alpha: 1)
        label.font = .preferredFont(for: .subheadline, weight: .light)
        label.handleMentionTap {  tappedMention($0) }
        return label
    }

    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<CommentLabel>) { }
}
struct CommentLabel2: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    private(set) var width: CGFloat
    private(set) var content = String()
    var OpenProfileMatchedGeometry = String()
    var tappedMention : ((String) -> ())
    func makeUIView(context: UIViewRepresentableContext<CommentLabel2>) -> UILabel {
        let label = ActiveLabel()
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = width
        label.enabledTypes = [.mention, .hashtag, .url]
        label.text = content
        label.mentionColor = .speakerPurpleUI
        label.hashtagColor = .speakerPinkUI
        
        label.textColor = colorScheme == .light ? .black : UIColor(white: 1, alpha: 1)
        label.font = .preferredFont(forTextStyle: .body)
        label.handleMentionTap {
            tappedMention($0)
            
        }
        return label
    }

    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<CommentLabel2>) { }
}
struct CommentLabel3: UIViewRepresentable {

    private(set) var content = String()
    var OpenProfileMatchedGeometry = String()
    var tappedMention : ((String) -> ())
    var tappedLink : ((URL) -> ())
    func makeUIView(context: UIViewRepresentableContext<CommentLabel3>) -> UILabel {
        let label = ActiveLabel()

        label.preferredMaxLayoutWidth = screenWidth - 80
        label.enabledTypes = [.mention, .hashtag, .url]
        label.text = content
        label.mentionColor = .accent
        label.hashtagColor = .accent
        label.URLColor = .accent
        label.textColor = .black
        label.font = .preferredFont(for: .subheadline, weight: .light)
        label.numberOfLines = 0
        label.handleMentionTap {
            tappedMention($0)
            
        }
        label.handleURLTap(tappedLink)
        return label
    }

    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<CommentLabel3>) { }
}
struct CommentReplyLabel: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    private(set) var width: CGFloat
    private(set) var content = String()
    var OpenProfileMatchedGeometry = String()
    var tappedMention : ((String) -> ())
    func makeUIView(context: UIViewRepresentableContext<CommentReplyLabel>) -> UILabel {
        let label = ActiveLabel()
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = width
        label.enabledTypes = [.mention, .hashtag, .url]
        label.text = content
        label.mentionColor = .speakerPurpleUI
        label.hashtagColor = .speakerPinkUI
        
        label.textColor = colorScheme == .light ? .black : UIColor(white: 1, alpha: 1)
        label.font = .preferredFont(forTextStyle: .caption1)
        label.handleMentionTap {  tappedMention($0) }
        return label
    }

    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<CommentReplyLabel>) { }
}

struct MessageLabel: UIViewRepresentable {

    private(set) var content = String()
    var OpenProfileMatchedGeometry = String()
    var tappedMention : ((String) -> ())
    var tappedLink : ((URL) -> ())
    func makeUIView(context: UIViewRepresentableContext<MessageLabel>) -> UILabel {
        let label = ActiveLabel()

        label.preferredMaxLayoutWidth = screenWidth - 130
        label.enabledTypes = [.mention, .hashtag, .url]
        label.text = content
        label.mentionColor = .accent
        label.hashtagColor = .accent
        label.URLColor = .accent
        label.textColor = .black
        label.font = .preferredFont(for: .subheadline, weight: .light)
        label.numberOfLines = 0
        label.handleMentionTap {
            tappedMention($0)
            
        }
        label.handleURLTap(tappedLink)
        return label
    }

    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<MessageLabel>) { }
}
