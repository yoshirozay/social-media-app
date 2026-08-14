//
//  AudioMessage.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 5/16/22.
//

import SwiftUI
import Foundation
import AVFoundation
import Combine

struct Audio: View {
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(2, CGFloat(level) + 30) / 2 // between 0.1 and 25
        
        return CGFloat(level * (150 / 25)) // scaled to max at 300 (our height of our bar)
    }
    @State var isAudioSessionOn = true
    @ObservedObject var soundManager: SoundManager
    var body: some View {
        
        HStack(spacing: 4) {
            // 4
            ForEach(soundManager.soundSamples, id: \.self) { level in
                BarView(value: self.normalizeSoundLevel(level: level))
            }
        }
        
    }
}

struct BarView: View {
    var value: CGFloat?
    let numberOfSamples: Int = 30
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(gradient: Gradient(colors: [.speakerPink, .speakerPurple]),
                                     startPoint: .top,
                                     endPoint: .bottom))
                .frame(width: (screenWidth - CGFloat(numberOfSamples) * 6) / CGFloat(numberOfSamples), height: value)
        }
    }
}

public struct AnimatedWaveformView: View {
    var color: Color = .accentColor
    var renderingMode: RenderingMode = .monochrome
    var secondaryColor: Color? = nil
    var animated: Bool = true
    var doesHaveOutterRing: Bool = false
    public init(color: Color = .accentColor, renderingMode: AnimatedWaveformView.RenderingMode = .monochrome, secondaryColor: Color? = nil, animated: Bool = true, doesHaveOutterRing: Bool = true) {
        self.color = color
        self.renderingMode = renderingMode
        self.secondaryColor = secondaryColor
        self.animated = animated
        self.doesHaveOutterRing = doesHaveOutterRing
    }

//    private var ringColor: Color {
//        switch renderingMode {
//        case .hierarchical:
//            return color.opacity(0.5)
//        case .monochrome:
//            return color
//        case .palette:
//            return secondaryColor ?? color
//        }
//    }

    /// The starting values for the bars, from left to right.
    /// These values are choosen to match the `waveform.circle SF Symbol but you can define your own values.
    @State private var lineLenghts: [CGFloat] = [5, 20, 30, 15, 25, 10]

    public var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            // the gradient is used to make multicolor possible. The radius values are best quesses.
            let gradient = RadialGradient(colors: [color, color], center: UnitPoint.center, startRadius: width/2.5, endRadius: width/2.5-1)

            AnimatingWaveform(lineLenghts: lineLenghts, doesHaveOutterRing: doesHaveOutterRing)
                .strokeBorder(gradient, style: StrokeStyle(lineWidth: width/18, lineCap: .round), antialiased: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaledToFit()
                .onAppear {
                    if animated {
                        withAnimation(.linear(duration: 0.7).repeatForever()) {

                            /// The animation values for the bars, from left to right.
                            lineLenghts = [20, 10, 2, 25, 10, 2]
                        }
                    }
                }
        }
    }

    public enum RenderingMode {
        case hierarchical, monochrome, palette
    }
}

/// The actual Shape for the animating wave form.
struct AnimatingWaveform: InsettableShape {
    
    // MARK: - Property
    var lineLenghts: [CGFloat]
    var doesHaveOutterRing: Bool
    // MARK: - Animatable
    var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>>>>> {
        get {
            AnimatablePair(
                lineLenghts[0],
                AnimatablePair(
                    lineLenghts[1],
                    AnimatablePair(
                        lineLenghts[2],
                        AnimatablePair(
                            lineLenghts[3],
                            AnimatablePair(
                                lineLenghts[4],
                                lineLenghts[5]
                            )
                        )
                    )
                )
            )
        }

        set {
            lineLenghts[0] = CGFloat(newValue.first)
            lineLenghts[1] = CGFloat(newValue.second.first)
            lineLenghts[2] = CGFloat(newValue.second.second.first)
            lineLenghts[3] = CGFloat(newValue.second.second.second.first)
            lineLenghts[4] = CGFloat(newValue.second.second.second.second.first)
            lineLenghts[5] = CGFloat(newValue.second.second.second.second.second)
        }
    }

    // MARK: - Conformance to InsettableShape
    var insetAmount = 0.0

    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }

    // MARK: - The path
    func path(in rect: CGRect) -> Path {
        let w = rect.width/100
        let h = rect.height/100

        let lines: [[CGPoint]] = [
            [CGPoint(x: w*25, y: rect.midY - h*lineLenghts[0]),
             CGPoint(x: w*25, y: rect.midY + h*lineLenghts[0])],
            [CGPoint(x: w*35, y: rect.midY - h*lineLenghts[1]),
             CGPoint(x: w*35, y: rect.midY + h*lineLenghts[1])],
            [CGPoint(x: w*45, y: rect.midY - h*lineLenghts[2]),
             CGPoint(x: w*45, y: rect.midY + h*lineLenghts[2])],
            [CGPoint(x: w*55, y: rect.midY - h*lineLenghts[3]),
             CGPoint(x: w*55, y: rect.midY + h*lineLenghts[3])],
            [CGPoint(x: w*65, y: rect.midY - h*lineLenghts[4]),
             CGPoint(x: w*65, y: rect.midY + h*lineLenghts[4])],
            [CGPoint(x: w*75, y: rect.midY - h*lineLenghts[5]),
             CGPoint(x: w*75, y: rect.midY + h*lineLenghts[5])]
        ]

        return Path { path in
            // two arcs to make it wider
            if doesHaveOutterRing {
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2 - insetAmount, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2 - insetAmount - 2, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
            }

            for line in lines {
                path.addLines(line)
            }
        }
    }
}



