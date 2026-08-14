//
//  OSNavigationButton.swift
//  speakEZ (macOS)
//
//  Created by Ahmad naeem on 10/3/21.
//

import SwiftUI

struct OSNavigationButton: View {
    
    var image: String
    var title: String
    @Binding var selectedTab : String
    
    var body: some View {
        
        Button(action: {withAnimation{selectedTab = title}}, label: {
            
            VStack(spacing: 7){
                
                Image(image)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(selectedTab == title ? .primary : .gray)
                
                Text(title)
                    .fontWeight(.semibold)
                    .font(.system(size: 11))
                    .foregroundColor(selectedTab == title ? .primary : .gray)
            }
            .padding(.vertical,8)
            .contentShape(Rectangle())
            .frame(width: 75, height: 75)
            .background(Color.purple.opacity(selectedTab == title ? 0.15 : 0))
            .cornerRadius(10)
        })
        .buttonStyle(PlainButtonStyle())
    }
}

struct MacOSNavigationButton: View {
    let detail :  MacOSHome.Detail
    @Binding var selectedTab : String
    
    var body: some View {
        
        Button(action: {withAnimation{selectedTab = detail.selectionKey}}, label: {
            
            VStack(spacing: 7){
                
                Image(detail.imageName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(selectedTab == detail.selectionKey ? .primary : .gray)
                
                Text(detail.title)
                    .fontWeight(.semibold)
                    .font(.system(size: 11))
                    .foregroundColor(selectedTab == detail.selectionKey ? .primary : .gray)
            }
            .padding(.vertical,8)
            .contentShape(Rectangle())
            .frame(width: 75, height: 75)
            .background(Color.purple.opacity(selectedTab == detail.selectionKey ? 0.15 : 0))
            .cornerRadius(10)
        })
        .buttonStyle(PlainButtonStyle())
    }
    
    
    
}
struct SideMenuConstant  {
    static let width : CGFloat = 110.0
}



//struct NavigationButtons_Previews: PreviewProvider {
//    static var previews: some View {
//        SideBar()
//    }
//}
