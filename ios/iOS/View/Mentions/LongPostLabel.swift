//
//  LongPostLabel.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 4/12/22.
//


import SwiftUI
import ActiveLabel

class LongPostLabelView : UIView{
 
    init(width: CGFloat,content : String,tappedMention  : @escaping ((String) -> ()), textColor: UIColor) {
        super.init(frame: CGRect(x: 0, y: 0, width: width-100, height: 0))
        let label = ActiveLabel()
        label.numberOfLines = 0 
        label.enabledTypes = [.mention, .hashtag, .url]
        label.text = content
        label.mentionColor = .speakerPurpleUI
        label.hashtagColor = .speakerPinkUI
        label.textAlignment = .left
        label.textColor = textColor
        label.font = .preferredFont(forTextStyle: .title3)
        label.handleMentionTap {  tappedMention($0) }
        label.numberOfLines = 0
        label.sizeToFit()
        label.frame = CGRect(x: 0, y: 0, width: width, height: 0)
        label.sizeToFit()
        addSubview(label)
        backgroundColor = .red
        label.backgroundColor = .green
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct LongPostLabel: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    let width: CGFloat
    let content : String
    let tappedMention : ((String) -> ())
    func makeUIView(context: UIViewRepresentableContext<LongPostLabel>) -> LongPostLabelView {
        LongPostLabelView(width: width,
                          content: content,
                          tappedMention: tappedMention,
                          textColor: colorScheme == .light ? .black : UIColor(white: 1, alpha: 0.6))
    }

    func updateUIView(_ uiView: LongPostLabelView, context: UIViewRepresentableContext<LongPostLabel>) { }
}
