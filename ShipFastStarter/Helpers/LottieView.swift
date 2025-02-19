//
//  LottieView.swift
//  FitCheck
//
//  Created by Dante Kim on 11/14/23.
//

import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
    let loopMode: LottieLoopMode
    let animation: String
    @Binding var isVisible: Bool // Add a binding to control the visibility

    func updateUIView(_: UIViewType, context _: Context) {}

    func makeUIView(context _: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: animation)
        animationView.contentMode = .scaleAspectFit
        if animation == "streak" || animation == "calendar" {
            animationView.loopMode = .loop // We control the loop manually
        } else {
            animationView.loopMode = .playOnce // We control the loop manually
        }

        // Set up the animation view
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        if animation == "heart" {
            // Decrease width and height by half
            NSLayoutConstraint.activate([
                animationView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
                animationView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            ])

        } else if animation == "streak" {
            NSLayoutConstraint.activate([
                animationView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75),
                animationView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            ])
        } else {
            // Normal size
            NSLayoutConstraint.activate([
                animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
                animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            ])
        }

        // Get the total number of frames in the animation
        let endFrame = animationView.animation?.endFrame ?? 0

        // Define a function that plays the animation and handles completion
        func playAnimation() {
            animationView.play(fromFrame: 0, toFrame: endFrame, loopMode: loopMode) { finished in
                if finished {
                    DispatchQueue.main.async {
                        self.isVisible = false // This will trigger the view to be hidden
                    }
                }
            }
        }

        // Start playing the animation
        playAnimation()

        return view
    }
}
