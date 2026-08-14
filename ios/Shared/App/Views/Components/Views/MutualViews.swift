//
//  MutualViews.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 10/4/21.
//

import SwiftUI

extension View{
    public func mutualFullScreenCover<Content>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View  {
#if os(iOS)
            return self.fullScreenCover(isPresented: isPresented, onDismiss: onDismiss, content: content)
#elseif os(macOS)
            return self.sheet(isPresented: isPresented, onDismiss: onDismiss, content: content)
#endif
        }
        
    }
extension View{
    func mutualTabViewStyle() -> some View {
#if os(macOS)
        
        return self.tabViewStyle(DefaultTabViewStyle())
#endif
        
#if os(iOS)
        return self.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
#endif
    }
}
