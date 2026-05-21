//
//  ReelPanel.swift
//  Spinora
//
//  Created by Stanley Young on 15/05/26.
//

import SwiftUI

struct BottomFrameLayout: View {
    var body: some View {
        ZStack {
            AssetSlot(
                "bottom_frame",
                fill: GameColor.woodDark,
                cornerRadius: 0,
                showLabel: false
            )
            .frame(width: 832, height: 720)
            .position(x: 416, y: 1450)

            AssetSlot(
                "bottom_frame_top_curve",
                fill: GameColor.wood,
                cornerRadius: 0,
                showLabel: false
            )
            .frame(width: 832, height: 96)
            .position(x: 416, y: 1128)
        }
    }
}

struct ReelLayout: View {
    let rerollText: String
    let reelColumns: [[String]]
    let reelRolledThisTurn: [Bool]
    let lastRolledIndex: Int?
    let showTapToPlay: Bool
    let onGuidebookTap: () -> Void
    let onReelTap: (Int) -> Void

    @State private var sharedBlinkPhase = false

    var body: some View {
        ZStack {
            // MARK: - Guidebook Button

            Button(action: {
                
                SoundFeedback.shared.playButtonPressSound()
                ExploreHaptic.shared.play(.buttonClickHeavy)

                onGuidebookTap()
            }) {
                
                Image("button_element_book")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(18)
            }
            .buttonStyle(.plain)
            .frame(height: 270)
            .position(x: 10, y: 1195)

            // MARK: - Reroll Counter

            HStack(spacing: 10) {
                Image("icon_reroll_images")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)

                GamePixelText(cleanRerollText, size: 36)
            }
            .position(x: 416, y: 1200)

            // Down arrows
            // ZStack {
            //     // SpriteKit reel panel only
            //     ReelSceneView(
            //         reelColumns: reelColumns,
            //         reelRolledThisTurn: reelRolledThisTurn,
            //         lastRolledIndex: lastRolledIndex,
            //         showTapToPlay: showTapToPlay,
            //         onReelTap: onReelTap

            // MARK: - Top Arrows
            // All active arrows use the same shared blink phase.

            ForEach(0..<3, id: \.self) { index in
                BlinkingReelArrow(
                    symbol: "⌄",
                    isActive: canBlinkArrow(index),
                    isBright: sharedBlinkPhase
                )
                .position(
                    x: reelXPosition(index),
                    y: 1250
                )
            }

            // MARK: - Reel Machine

            ReelSceneView(
//                reelColumns: reelColumns,
//                reelRolledThisTurn: reelRolledThisTurn,
//                lastRolledIndex: lastRolledIndex,
//                onReelTap: onReelTap
                reelColumns: reelColumns,
                reelRolledThisTurn: reelRolledThisTurn,
                lastRolledIndex: lastRolledIndex,
                showTapToPlay: showTapToPlay,
                onReelTap: onReelTap
            )
            .frame(width: 670, height: 390)
            .position(x: 416, y: 1485)
            .zIndex(10)

            // MARK: - Bottom Arrows
            // All active arrows use the same shared blink phase.

            ForEach(0..<3, id: \.self) { index in
                BlinkingReelArrow(
                    symbol: "⌃",
                    isActive: canBlinkArrow(index),
                    isBright: sharedBlinkPhase
                )
                .position(
                    x: reelXPosition(index),
                    y: 1740
                )
            }
        }
        .task {
            await runSharedBlinkLoop()
        }
        .onChange(of: resetKey) { _, _ in
            // When a new attempt starts and reelRolledThisTurn resets,
            // force all arrows back into the same phase.
            sharedBlinkPhase = false
        }
    }

    private var cleanRerollText: String {
        rerollText.replacingOccurrences(of: "↻ ", with: "")
    }

    private var resetKey: String {
        reelRolledThisTurn.map { $0 ? "1" : "0" }.joined()
    }

    private func reelXPosition(_ index: Int) -> CGFloat {
        switch index {
        case 0:
            return 215
        case 1:
            return 416
        case 2:
            return 617
        default:
            return 416
        }
    }

    private func canBlinkArrow(_ index: Int) -> Bool {
        guard index >= 0 && index < reelRolledThisTurn.count else {
            return false
        }

        // false = this reel can still be rolled
        // true = this reel has already been used
        return reelRolledThisTurn[index] == false
    }

    private func runSharedBlinkLoop() async {
        while !Task.isCancelled {
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.5)) {
                    sharedBlinkPhase.toggle()
                }
            }

            try? await Task.sleep(for: .milliseconds(500))
        }
    }
}

struct BlinkingReelArrow: View {
    let symbol: String
    let isActive: Bool
    let isBright: Bool

    private let arrowSize: CGFloat = 52
    private let arrowFrameSize: CGFloat = 70

    var body: some View {
        GamePixelText(symbol, size: arrowSize)
            .frame(width: arrowFrameSize, height: arrowFrameSize)
            .opacity(currentOpacity)
            .scaleEffect(currentScale)
            .animation(.easeInOut(duration: 0.5), value: isBright)
            .animation(.easeOut(duration: 0.15), value: isActive)
    }

    private var currentOpacity: Double {
        if isActive {
            return isBright ? 1.0 : 0.25
        } else {
            return 0.30
        }
    }

    private var currentScale: CGFloat {
        if isActive {
            return isBright ? 1.16 : 1.0
        } else {
            return 1.0
        }
    }
}
