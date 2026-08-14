//
//  OnBoardingLottieConfetti.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 10/4/21.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    typealias UIViewType = UIView
    
    func makeUIView(context:
        UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        
        let animationView = AnimationView()
        let animation = Animation.named("newnewconfetti")
        
        
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.play()
//        animationView.loopMode = .loop
        animationView.translatesAutoresizingMaskIntoConstraints
            = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo:
               view.heightAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context:
        UIViewRepresentableContext<LottieView>) {
 
    }
}


