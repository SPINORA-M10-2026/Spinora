//
//  GameBattleView.swift
//  Spinora
//
//  Created by Stanley Young on 15/05/26.
//

import SwiftUI

struct GameBattleView: View {
    let data: BattleLayoutData
    var playerState: PlayerAnimationState = .idle
    // enemyState: diteruskan dari GameLayoutDemoView → GameBattleView → ArenaLayout
    // agar ArenaLayout bisa trigger efek visual saat monster menyerang
    var enemyState: EnemyAnimationState = .idle
    var enemyAppearance: EnemyAppearance? = nil

    let onPauseTap: () -> Void
    let onAttackTap: () -> Void
    let onGuidebookTap: () -> Void
    let onReelTap: (Int) -> Void

    private let designWidth: CGFloat = 832
    private let designHeight: CGFloat = 1800

    @State private var activeAnimation: ActiveAnimationType? = nil
    @State private var dismissTask: Task<Void, Never>? = nil

    enum ActiveAnimationType {
        case double
        case jackpot
    }

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let scale = min(
                screenWidth / designWidth,
                screenHeight / designHeight
            )

            let fittedWidth = designWidth * scale
            let fittedHeight = designHeight * scale

            ZStack {
                GameColor.screenBackground
                    .ignoresSafeArea()

                gameCanvas
                    .frame(width: designWidth, height: designHeight)
                    .scaleEffect(scale)
                    .frame(width: fittedWidth, height: fittedHeight)
                    .position(
                        x: screenWidth / 2,
                        y: screenHeight / 2
                    )
            }
            .frame(width: screenWidth, height: screenHeight)
        }
        .ignoresSafeArea()
        .onChange(of: data.lastRolledIndex) { oldValue, newValue in
            if newValue == nil {
                withAnimation {
                    activeAnimation = nil
                }
            } else {
                // Wait for the 0.5s reel spin animation to finish before checking results
                dismissTask?.cancel()
                Task {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    checkWeaknessAnimation()
                }
            }
        }
        .onDisappear {
            dismissTask?.cancel()
            dismissTask = nil
        }
    }

    private var gameCanvas: some View {
        ZStack {
            
            EnvironmentBackgroundView()
            
            // enemyState diteruskan dari GameBattleView ke ArenaLayout
            ArenaLayout(data: data, playerState: playerState, enemyState: enemyState, enemyAppearance: enemyAppearance)
            
            if let animation = activeAnimation {
                switch animation {
                case .double:
                    FrameAnimation.double()
                        .position(x: designWidth/2, y: designHeight/2 )
                        .transition(.opacity)
//                        .zIndex(5)
                case .jackpot:
                    FrameAnimation.jackpot()
                        .position(x: designWidth/2, y: designHeight/2)
                        .transition(.opacity)
//                        .zIndex(5)
                }
            }
            
            WoodBackgroundView()


//            BottomFrameLayout()

            ReelLayout(
                rerollText: data.rerollText,
                reelColumns: data.reelColumns,
                reelRolledThisTurn: data.reelRolledThisTurn,
                lastRolledIndex: data.lastRolledIndex,
                showTapToPlay: data.showTapToPlay,
                onGuidebookTap: onGuidebookTap,
                onReelTap: onReelTap
            )
            
            HUDLayout(
                waveText: data.waveText,
                onPauseTap: onPauseTap
            )
            
            BottomButtonLayout(
                canAttack: data.canAttack,
                onAttackTap: onAttackTap
            )
        }
        .frame(width: designWidth, height: designHeight)
        .clipped()
    }

    private func checkWeaknessAnimation() {
        guard let enemyElement = enemyAppearance?.bodyElement else { return }

        // Determine weakness of the enemy element
        let weaknessElement: Element
        switch enemyElement {
        case .fire:
            weaknessElement = .water
        case .water:
            weaknessElement = .earth
        case .earth:
            weaknessElement = .fire
        }

        // Count how many middle symbols match the weakness
        var matchingCount = 0
        for column in data.reelColumns {
            if column.count > 1 {
                let middleSymbol = column[1]
                if middleSymbol == weaknessElement.rawValue {
                    matchingCount += 1
                }
            }
        }

        // Trigger the correct animation based on count
        withAnimation {
            if matchingCount == 3 {
                activeAnimation = .jackpot
                SoundFeedback.shared.jackpot()
                ExploreHaptic.shared.play(.jackpot)
                startDismissTimer()
            } else if matchingCount == 2 {
                activeAnimation = .double
                SoundFeedback.shared.double()
                startDismissTimer()
            } else {
                activeAnimation = nil
            }
        }
    }

    private func startDismissTimer() {
        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // Keep animation on screen for 2 seconds
            guard !Task.isCancelled else { return }
            withAnimation {
                activeAnimation = nil
            }
        }
    }
}
