//
//  CodeableBundleExtension.swift
//  Africa
//
//  Created by Carson O'Sullivan on 10/7/20.
//
import Foundation
import SwiftUI

extension Bundle {
    func decode<T: Codable>(_ file: String) -> T {
        // 1. Locate the JSON file in the app Bundle
        
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        // 2. Create a property for the data
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) in bundle.")
        }
        // 3. Create a JSON decoder
        let decoder = JSONDecoder()
        
        // 4. Decode the data and collect the information with a new property
         // a. decoder requests information on type that we are trying to decode, in this case it is Cover Image
         // b. the source data
        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(file) in bundle.")
        }
        // 5. Return the ready-to-use data
        return loaded

    }
}


extension View {
    public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
             .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    var body: some View {
        content($value)
    }

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(wrappedValue: value)
        self.content = content
    }
}
 
extension UIColor {
    static let speakerBlue : UIColor? = UIColor(named: "speakerBlue")
}

extension Date {
    //time interval in milliseconds since 1970
    var jsGetTimeEquivalent:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    func jsToSwiftTime() -> Double {
        return Double(jsGetTimeEquivalent/1000)
    }
}

extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex

        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }

        return indices
    }
}
