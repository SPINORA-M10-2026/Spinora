//
//  GameTutorialOverlayView.swift
//  Spinora
//
//  Created by Stanley Young on 20/05/26.
//

//
//  GameTutorialOverlayView.swift
//  Spinora
//

import SwiftUI

struct GameTutorialOverlayView: View {
    @Binding var isPresented: Bool

    @State private var step: Int = 1

    // MARK: - Easy Adjustment Values

    // Bubble size
    private let bubbleWidthRatio: CGFloat = 0.68

    // Step 1 bubble position
    // Increase Y = lower, decrease Y = higher
    private let reelBubbleXRatio: CGFloat = 0.50
    private let reelBubbleYRatio: CGFloat = 0.62

    // Step 2 bubble position
    // Increase Y = lower, decrease Y = higher
    private let attackBubbleXRatio: CGFloat = 0.56
    private let attackBubbleYRatio: CGFloat = 0.42

    // Reel emphasize border
    private let reelBorderXRatio: CGFloat = 0.50
    private let reelBorderYRatio: CGFloat = 0.92
    private let reelBorderWidthRatio: CGFloat = 0.86
    private let reelBorderHeightRatio: CGFloat = 0.22

    // Attack button emphasize border
    private let attackBorderXRatio: CGFloat = 0.80
    private let attackBorderYRatio: CGFloat = 0.61
    private let attackBorderWidthRatio: CGFloat = 0.38
    private let attackBorderHeightRatio: CGFloat = 0.105

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.58)
                    .ignoresSafeArea()

                if step == 1 {
                    reelMachineStep(in: geometry)
                } else {
                    attackButtonStep(in: geometry)
                }
            }
            .ignoresSafeArea()
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.25), value: step)
        }
    }

    // MARK: - Step 1: Reel Machine

    private func reelMachineStep(in geometry: GeometryProxy) -> some View {
        let width = geometry.size.width
        let height = geometry.size.height

        return ZStack {
            // MARK: Reel Emphasize Border
            // This is placed directly on top of the reel machine.

            PixelHighlightBorder()
                .frame(
                    width: width * reelBorderWidthRatio,
                    height: height * reelBorderHeightRatio
                )
                .position(
                    x: width * reelBorderXRatio,
                    y: height * reelBorderYRatio
                )

            // MARK: Explanation Bubble
            // Placed higher so it does not cover the reel machine.

            tutorialBubble(
                title: "REEL MACHINE",
                description: "Roll each reel segment once per attempt. You have 3 segments, so you can roll up to 3 times total.",
                progressText: "1/2",
                button: AnyView(
                    Button {
                        SoundFeedback.shared.playButtonPressSound()
                        ExploreHaptic.shared.play(.buttonClickHeavy)
                        step = 2
                    } label: {
                        GamePixelText("NEXT", size: 16)
                            .foregroundStyle(pixelDarkBrown)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                PixelPanelShape(cornerSize: 7)
                                    .fill(pixelCream)
                            )
                            .overlay(
                                PixelPanelShape(cornerSize: 7)
                                    .stroke(pixelDarkBrown, lineWidth: 3)
                            )
                    }
                    .buttonStyle(.plain)
                )
            )
            .frame(width: width * bubbleWidthRatio)
            .position(
                x: width * reelBubbleXRatio,
                y: height * reelBubbleYRatio
            )
        }
    }

    // MARK: - Step 2: Attack Button

    private func attackButtonStep(in geometry: GeometryProxy) -> some View {
        let width = geometry.size.width
        let height = geometry.size.height

        return ZStack {
            // MARK: Attack Button Emphasize Border
            // This is placed directly on top of the attack button.

            PixelHighlightBorder()
                .frame(
                    width: width * attackBorderWidthRatio,
                    height: height * attackBorderHeightRatio
                )
                .position(
                    x: width * attackBorderXRatio,
                    y: height * attackBorderYRatio
                )

            // MARK: Explanation Bubble
            // Placed above the attack button so the button remains visible.

            tutorialBubble(
                title: "ATTACK BUTTON",
                description: "Attack directly, or reroll first if you still have available reel segments.",
                progressText: "2/2",
                button: AnyView(
                    Button {
                        SoundFeedback.shared.playButtonPressSound()
                        ExploreHaptic.shared.play(.buttonClickHeavy)
                        finishTutorial()
                    } label: {
                        GamePixelText("FINISH", size: 16)
                            .foregroundStyle(pixelDarkBrown)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                PixelPanelShape(cornerSize: 7)
                                    .fill(pixelCream)
                            )
                            .overlay(
                                PixelPanelShape(cornerSize: 7)
                                    .stroke(pixelDarkBrown, lineWidth: 3)
                            )
                    }
                    .buttonStyle(.plain)
                )
            )
            .frame(width: width * bubbleWidthRatio)
            .position(
                x: width * attackBubbleXRatio,
                y: height * attackBubbleYRatio
            )
        }
    }

    // MARK: - Bubble

    private func tutorialBubble(
        title: String,
        description: String,
        progressText: String,
        button: AnyView
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            GamePixelText(title, size: 18)
                .foregroundStyle(pixelCream)

            Text(description)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(pixelCream.opacity(0.95))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Spacer()

                GamePixelText(progressText, size: 16)
                    .foregroundStyle(pixelCream.opacity(0.9))

                button
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(
            PixelPanelShape(cornerSize: 13)
                .fill(pixelWood)
        )
        .overlay(
            PixelPanelShape(cornerSize: 13)
                .stroke(pixelDarkBrown, lineWidth: 4)
        )
        .overlay(
            PixelPanelShape(cornerSize: 13)
                .stroke(pixelCream.opacity(0.55), lineWidth: 2)
                .padding(5)
        )
        .shadow(color: .black.opacity(0.45), radius: 0, x: 5, y: 5)
    }

    private func finishTutorial() {
        UserDefaults.standard.set(true, forKey: "hasCompletedFirstGameTutorial")
        isPresented = false
    }

    // MARK: - Palette

    private var pixelDarkBrown: Color {
        Color(red: 0.16, green: 0.08, blue: 0.04)
    }

    private var pixelWood: Color {
        Color(red: 0.43, green: 0.22, blue: 0.12)
    }

    private var pixelGold: Color {
        Color(red: 0.86, green: 0.55, blue: 0.27)
    }

    private var pixelCream: Color {
        Color(red: 1.0, green: 0.78, blue: 0.48)
    }
}

// MARK: - Pixel Highlight Border

struct PixelHighlightBorder: View {
    var body: some View {
        PixelPanelShape(cornerSize: 16)
            .stroke(Color(red: 1.0, green: 0.78, blue: 0.48), lineWidth: 4)
            .background(
                PixelPanelShape(cornerSize: 16)
                    .fill(Color(red: 1.0, green: 0.78, blue: 0.48).opacity(0.08))
            )
            .overlay(
                PixelPanelShape(cornerSize: 16)
                    .stroke(Color(red: 0.16, green: 0.08, blue: 0.04), lineWidth: 2)
                    .padding(5)
            )
            .shadow(color: .black.opacity(0.45), radius: 0, x: 4, y: 4)
    }
}

// MARK: - Pixel Panel Shape

struct PixelPanelShape: Shape {
    let cornerSize: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let c = min(cornerSize, rect.width / 4, rect.height / 4)

        path.move(to: CGPoint(x: rect.minX + c, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - c, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - c, y: rect.minY + c))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + c))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - c))
        path.addLine(to: CGPoint(x: rect.maxX - c, y: rect.maxY - c))
        path.addLine(to: CGPoint(x: rect.maxX - c, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + c, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + c, y: rect.maxY - c))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - c))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + c))
        path.addLine(to: CGPoint(x: rect.minX + c, y: rect.minY + c))
        path.closeSubpath()

        return path
    }
}
