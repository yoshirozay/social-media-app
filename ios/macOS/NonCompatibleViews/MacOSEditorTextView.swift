//
//  MacOSEditorTextView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 11/21/21.
//
import Combine
import SwiftUI
import Cocoa

struct MacOSEditorTextView: NSViewRepresentable {
    @Binding var text: String
    @Binding var dynamicHeight: CGFloat
    
    var isEditable: Bool = true
    var font: NSFont = .systemFont(ofSize: 14, weight: .regular)
    var maxHeight: CGFloat
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> CustomTextView {
        let textView = CustomTextView(
            text: text,
            isEditable: isEditable,
            font: font
        )
        textView.delegate = context.coordinator
        
        return textView
    }
    
    func updateNSView(_ view: CustomTextView, context: Context) {
        view.text = text
        view.selectedRanges = context.coordinator.selectedRanges
    }
}


// MARK: - Coordinator

extension MacOSEditorTextView {
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MacOSEditorTextView
        var selectedRanges: [NSValue] = []
        
        init(_ parent: MacOSEditorTextView) {
            self.parent = parent
        }
        
        func textDidBeginEditing(_ notification: Foundation.Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
        }
        
        func textDidChange(_ notification: Foundation.Notification) {
            
            guard let textView = notification.object as? NSTextView else {
                return
            }
            self.recalculateHeight(textView: textView)
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
        }
        
        func textDidEndEditing(_ notification: Foundation.Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
        }
        
        var oldText = ""
        func recalculateHeight(textView: NSTextView ) {
            if textView.string.count < oldText.count {
                textView.frame = NSRect(x: textView.frame.minX, y:  textView.frame.minY, width:  textView.frame.size.width, height: 0)
                textView.sizeToFit()
            }
            oldText = textView.string
            let latestHeight = textView.frame.height
//            print(" \n latestSize \(latestHeight)")
            if self.parent.dynamicHeight != latestHeight,self.parent.maxHeight >= latestHeight{
                self.parent.dynamicHeight = latestHeight
            }
        }
        
    }
}

// MARK: - CustomTextView

final class CustomTextView: NSView {
    private var isEditable: Bool
    private var font: NSFont?
    
    weak var delegate: NSTextViewDelegate?
    
    var text: String {
        didSet {
            textView.string = text
        }
    }
    
    var selectedRanges: [NSValue] = [] {
        didSet {
            guard selectedRanges.count > 0 else {
                return
            }
            
            textView.selectedRanges = selectedRanges
        }
    }
    
    private lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = true
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalRuler = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.drawsBackground = false
        return scrollView
    }()
    
    private lazy var textView: NSTextView = {
        let contentSize = scrollView.contentSize
        let textStorage = NSTextStorage()
        
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        
        let textContainer = NSTextContainer(containerSize: scrollView.frame.size)
        textContainer.widthTracksTextView = true
        textContainer.containerSize = NSSize(
            width: contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        layoutManager.addTextContainer(textContainer)
        
        
        let textView                     = NSTextView(frame: .zero, textContainer: textContainer)
        textView.autoresizingMask        = .width
        textView.backgroundColor         = NSColor.textBackgroundColor
        textView.delegate                = self.delegate
        textView.drawsBackground         = true
        textView.font                    = self.font
        textView.isEditable              = self.isEditable
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable   = true
        textView.maxSize                 = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize                 = NSSize(width: 0, height: contentSize.height)
        textView.textColor               = NSColor.labelColor
        textView.allowsUndo              = true 
        return textView
    }()
    
    // MARK: - Init
    init(text: String, isEditable: Bool, font: NSFont?) {
        self.font       = font
        self.isEditable = isEditable
        self.text       = text
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func viewWillDraw() {
        super.viewWillDraw()
        
        setupScrollViewConstraints()
        setupTextView()
    }
    
    func setupScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
    
    func setupTextView() {
        scrollView.documentView = textView
    }
}

#if os(macOS)
var isLight: Bool { NSApp.effectiveAppearance.name == NSAppearance.Name.aqua }
var isDark: Bool { NSApp.effectiveAppearance.name == NSAppearance.Name.darkAqua }
#endif

