//
//  FrameAnimation.swift
//  Spinora
//
//  Created by ahmadfarhanqf on 20/05/26.
//

import SwiftUI

// MARK: - Struct

/*
 HOW TO CALL THIS STRUCT?
 
 
 FrameAnimation(
     imagePrefix: "double",
     startFrame: 0,
     endFrame: 38,
     frameDuration: 0.04,
     loop: true
 )
 
 */

struct FrameAnimation: View {
    let imagePrefix: String
    let startFrame: Int
    let endFrame: Int
    let frameDuration: Double
    let loop: Bool

    @State private var currentFrame: Int = 0
    @State private var timer: Timer?

    private var frameNumbers: [Int] {
        Array(startFrame...endFrame)
    }

    private var currentImageName: String {
        let frame = frameNumbers[currentFrame]
        return "\(imagePrefix)_\(String(format: "%05d", frame))"
    }

    var body: some View {
        Image(currentImageName)
            .resizable()
            .scaledToFit()
            .onAppear {
                startAnimation()
            }
            .onDisappear {
                stopAnimation()
            }
    }

    private func startAnimation() {
        stopAnimation()

        currentFrame = 0

        timer = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true) { _ in
            if currentFrame < frameNumbers.count - 1 {
                currentFrame += 1
            } else if loop {
                currentFrame = 0
            } else {
                stopAnimation()
            }
        }
    }

    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
}


// MARK: - extension

/*
 IF YOU NEED CLEANER CALL
    Just use code below.
    So u just only to call like this
 
 
    FrameAnimation.double()
 
 
 */

extension FrameAnimation {

    static func double(loop: Bool = true) -> FrameAnimation {
        FrameAnimation(
            imagePrefix: "double",
            startFrame: 0,
            endFrame: 38,
            frameDuration: 0.06,
            loop: loop
        )
    }

    static func jackpot(loop: Bool = false) -> FrameAnimation {
        FrameAnimation(
            imagePrefix: "jackpot",
            startFrame: 0,
            endFrame: 38,
            frameDuration: 0.06,
            loop: loop
        )
    }
}
