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
    }

    private var gameCanvas: some View {
        ZStack {
            TopFrameLayout()

            // enemyState diteruskan dari GameBattleView ke ArenaLayout
            ArenaLayout(data: data, playerState: playerState, enemyState: enemyState, enemyAppearance: enemyAppearance)

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

            BottomButtonLayout(
                canAttack: data.canAttack,
                onAttackTap: onAttackTap
            )

            HUDLayout(
                waveText: data.waveText,
                onPauseTap: onPauseTap
            )
        }
        .frame(width: designWidth, height: designHeight)
        .clipped()
    }
}
