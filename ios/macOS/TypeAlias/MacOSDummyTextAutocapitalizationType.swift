//
//  MacOSDummyTextAutocapitalizationType.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 12/4/21.
//

import Cocoa
import SwiftUI

//MARK: - autocapitalization -> autocapitalization (UITextAutocapitalizationType -> MacOSDummyTextAutocapitalizationType)
extension View{
      func autocapitalization(_ style: MacOSDummyTextAutocapitalizationType) -> some View{
       return self
    }
}
typealias UITextAutocapitalizationType = MacOSDummyTextAutocapitalizationType
public enum MacOSDummyTextAutocapitalizationType : Int {

    
    case none = 0

    case words = 1

    case sentences = 2

    case allCharacters = 3
}
