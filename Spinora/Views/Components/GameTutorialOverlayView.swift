//
//  GameTutorialOverlayView.swift
//  Spinora
//
//  Created by Stanley Young on 20/05/26.
//

import SwiftUI

struct GameTutorialOverlayView: View {
    @Binding var isPresented: Bool
    @Binding var step: Int

    // MARK: - Easy Adjustment Values

    // Step 1 full-screen overlay asset position
    private let reelOverlayXRatio: CGFloat = 0.50
    private let reelOverlayYRatio: CGFloat = 0.54

    // Step 1 full-screen overlay asset size
    // Increase height = light space becomes taller vertically
    // Decrease height = light space becomes shorter vertically
    private let reelOverlayWidthRatio: CGFloat = 1.0
    private let reelOverlayHeightRatio: CGFloat = 1.30

    // Step 2 full-screen overlay asset position
    // Lower Y = light space moves higher
    // Higher Y = light space moves lower
    private let attackOverlayXRatio: CGFloat = 0.50
    private let attackOverlayYRatio: CGFloat = 0.50

    // Step 2 full-screen overlay asset size
    // Increase height = light space becomes taller vertically
    // Decrease height = light space becomes shorter vertically
    private let attackOverlayWidthRatio: CGFloat = 1.0
    private let attackOverlayHeightRatio: CGFloat = 0.998

    // Alert asset size
    private let alertWidthRatio: CGFloat = 0.63

    // Step 1 alert position: Reel Machine
    // Increase Y = lower, decrease Y = higher
    private let reelAlertXRatio: CGFloat = 0.65
    private let reelAlertYRatio: CGFloat = 0.45

    // Step 2 alert position: Attack Button
    // Increase Y = lower, decrease Y = higher
    private let attackAlertXRatio: CGFloat = 0.43
    private let attackAlertYRatio: CGFloat = 0.80

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if step == 1 {
                    tutorialStep(
                        overlayAssetName: "tutorial_overlay_1",
                        alertAssetName: "tutorial_alert_1",
                        overlayXRatio: reelOverlayXRatio,
                        overlayYRatio: reelOverlayYRatio,
                        overlayWidthRatio: reelOverlayWidthRatio,
                        overlayHeightRatio: reelOverlayHeightRatio,
                        alertXRatio: reelAlertXRatio,
                        alertYRatio: reelAlertYRatio,
                        in: geometry
                    )
                } else {
                    tutorialStep(
                        overlayAssetName: "tutorial_overlay_2",
                        alertAssetName: "tutorial_alert_2",
                        overlayXRatio: attackOverlayXRatio,
                        overlayYRatio: attackOverlayYRatio,
                        overlayWidthRatio: attackOverlayWidthRatio,
                        overlayHeightRatio: attackOverlayHeightRatio,
                        alertXRatio: attackAlertXRatio,
                        alertYRatio: attackAlertYRatio,
                        in: geometry
                    )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .ignoresSafeArea()
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.25), value: step)
        }
        .ignoresSafeArea()
    }

    // MARK: - Tutorial Step

    private func tutorialStep(
        overlayAssetName: String,
        alertAssetName: String,
        overlayXRatio: CGFloat,
        overlayYRatio: CGFloat,
        overlayWidthRatio: CGFloat,
        overlayHeightRatio: CGFloat,
        alertXRatio: CGFloat,
        alertYRatio: CGFloat,
        in geometry: GeometryProxy
    ) -> some View {
        let width = geometry.size.width
        let height = geometry.size.height

        return ZStack {
            Image(overlayAssetName)
                .resizable()
                .frame(
                    width: width * overlayWidthRatio,
                    height: height * overlayHeightRatio
                )
                .position(
                    x: width * overlayXRatio,
                    y: height * overlayYRatio
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)

            Image(alertAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: width * alertWidthRatio)
                .position(
                    x: width * alertXRatio,
                    y: height * alertYRatio
                )
                .allowsHitTesting(false)
        }
        .frame(width: width, height: height)
        .ignoresSafeArea()
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


#Preview("Tutorial Step 2 - Attack") {
    GameTutorialOverlayView(
        isPresented: .constant(true),
        step: .constant(2)
    )
}
