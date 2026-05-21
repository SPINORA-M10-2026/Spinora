//
//  StartPageView.swift
//  Spinora
//
//  Created by Stanley Young on 21/05/26.
//

import SwiftUI

struct StartPageView: View {
    let onStart: () -> Void

    @State private var isStartPressed = false
    @State private var knightFrameIndex = 0

    // MARK: - Easy Adjustment Values

    // Background
    private let backgroundWidthScale: CGFloat = 1.0
    private let backgroundHeightScale: CGFloat = 1.0

    // Move background
    private let backgroundXOffsetRatio: CGFloat = 0.0
    private let backgroundYOffsetRatio: CGFloat = 0.0

    // Knight
    private let knightWidthRatio: CGFloat = 0.60
    private let knightYOffsetRatio: CGFloat = -0.03

    // Start Button
    private let startButtonWidthRatio: CGFloat = 0.36
    private let startButtonYOffsetRatio: CGFloat = 0.28

    private let knightAnimationSpeed: Double = 0.45

    private var currentKnightAsset: String {
        knightFrameIndex == 0 ? "knight_idle_01" : "knight_idle_02"
    }

    private var startButtonAsset: String {
        isStartPressed ? "button_start_pressed" : "button_start_default"
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // MARK: - Background

                Image("background_start")
                    .resizable()
                    .interpolation(.none)
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width * backgroundWidthScale,
                        height: geometry.size.height * backgroundHeightScale
                    )
                    .position(
                        x: geometry.size.width / 2 + geometry.size.width * backgroundXOffsetRatio,
                        y: geometry.size.height / 2 + geometry.size.height * backgroundYOffsetRatio
                    )
                    .clipped()
                    .ignoresSafeArea()

                // MARK: - Player Knight Animation

                Image(currentKnightAsset)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: geometry.size.width * knightWidthRatio)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height * (0.5 + knightYOffsetRatio)
                    )

                // MARK: - Start Button

                Button {
                    SoundFeedback.shared.playButtonPressSound()
                    ExploreHaptic.shared.play(.buttonClickHeavy)

                    StartBackgroundMusic.shared.stopBackgroundMusic()
                    
                    SoundFeedback.shared.playTransition()

                    onStart()
                } label: {
                    Image(startButtonAsset)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: geometry.size.width * startButtonWidthRatio)
                }
                .buttonStyle(.plain)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            isStartPressed = true
                        }
                        .onEnded { _ in
                            isStartPressed = false
                        }
                )
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height * (0.5 + startButtonYOffsetRatio)
                )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .ignoresSafeArea()
            .task {
                await runKnightIdleAnimation()
            }
            .onAppear {
                StartBackgroundMusic.shared.startBackgroundMusic()
            }
            .onDisappear {
                StartBackgroundMusic.shared.stopBackgroundMusic()
            }
        }
        .ignoresSafeArea()
        .background(
            Image("background_start")
                .resizable()
                .interpolation(.none)
                .scaledToFill()
                .ignoresSafeArea()
        )
    }

    private func runKnightIdleAnimation() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(knightAnimationSpeed))

            await MainActor.run {
                knightFrameIndex = knightFrameIndex == 0 ? 1 : 0
            }
        }
    }
}

#Preview {
    StartPageView {
        print("Start tapped")
    }
}