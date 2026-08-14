//
//  IndividualTag.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 8/27/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import Combine

struct IndividualTag: View {

           var tagName: String
    @State var color1: Color = .backgroundColor
    @State var color2: Color = .accent
    @Binding var selected: Bool
    var isDummy = false
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeController: ThemeController

    var body: some View {
        
        ZStack {
            //FIXME: - need to check do we need to update the screenWidth for 13 inch and 14 inch macbook or not.
#if os(macOS)
            let screenWidth = Self.screenWidth
#endif
            LinearGradient(gradient: .init(colors: selected ? [themeController.theme.primary.opacity(0.7), themeController.theme.accent.opacity(0.7)] : [themeController.theme.accent.opacity(0.7), themeController.theme.accent.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                .frame(width: (screenWidth - 40) / 3, height: 125)
                .clipShape(Hexagon())
            
            LinearGradient(gradient: .init(colors: [Color.mainColorInverse.opacity(0.2), Color.mainColorInverse.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                .frame(width: (screenWidth - 65) / 3, height: 115)
                .clipShape(Hexagon())
            //                .shadow(radius: 4, x: 0, y: 3)
            //                .shadow(radius: 4, x: 3, y: 0)
            LinearGradient(gradient: .init(colors: [themeController.theme.accent.opacity(0.1), Color.blue.opacity(0.01)]), startPoint: .top, endPoint: .bottom)
                .frame(width: (screenWidth - 65) / 3, height: 115)
                .clipShape(Hexagon())
            
            if isDummy{
                LinearGradient(gradient: .init(colors: colorScheme == .light ? [themeController.theme.primary.opacity(0.2), Color.blue.opacity(0.01)] : [themeController.theme.primary.opacity(0.2), Color.blue.opacity(0.01)] ), startPoint: .top, endPoint: .bottom)
                    .frame(width: (screenWidth - 65) / 3, height: 115)
                    .clipShape(Hexagon()) 
                ProgressViewPurpleCircular(color: Color.white)
                    .scaleEffect(2)
                    .padding(.top,65)
                    .frame(width: (screenWidth - 65) / 3, height: 115)
            }
            
            Text(tagName)
                .foregroundColor(.mainColor)
                .font(.largeTitle)
        }
    }
    
#if os(macOS)
    static let screenWidth = speakEZ.screenWidth*0.58
#endif
}
