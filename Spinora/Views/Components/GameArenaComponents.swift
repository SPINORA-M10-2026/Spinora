//
//  ArenaLayout.swift
//  Spinora
//
//  Created by Stanley Young on 15/05/26.
//

import SwiftUI

struct ArenaLayout: View {
    let data: BattleLayoutData
    var playerState: PlayerAnimationState = .idle
    var enemyAppearance: EnemyAppearance? = nil

    @State private var enemyFloat: CGFloat = 0
    @State private var showAttackEffect = false
    @State private var enemyHitFlash = false
    @State private var enemyShakeOffset: CGFloat = 0

    private let knightAttackDuration: TimeInterval = 0.6
    private let effectDuration: TimeInterval = 0.6

    var body: some View {
        ZStack {
            // enemy HP bar
            HealthBarSlot(
                label: "enemy_hp_bar",
                value: "\(data.enemyHP)",
                current: data.enemyHP,
                max: data.enemyMaxHP,
                fillColor: GameColor.hpRed
            )
            .frame(width: 220, height: 40)
            .position(x: 430, y: 430)
            // .frame(width: 270, height: 30)
            .opacity(data.isEnemyDefeated ? 0.0 : 1.0)
            .animation(.easeOut(duration: 0.3), value: data.isEnemyDefeated)
            // .position(x: 445, y: 455)
            
            // enemy evatar
//            PlayerSpriteView()
//                .frame(width: 220, height: 220)
//                .position(x: 690, y: 427)

            // enemy avatar
            Group {
                if let appearance = enemyAppearance {
                    EnemySpriteView(appearance: appearance)
                        .frame(width: 270, height: 270)
                } else {
                    AssetSlot(
                        "enemy_idle",
                        fill: Color.purple.opacity(0.18),
                        cornerRadius: 16
                    )
                    .frame(width: 270, height: 270)
                }
            }
            .overlay(
                Rectangle()
                    .fill(Color.red.opacity(enemyHitFlash ? 0.45 : 0))
                    .blendMode(.screen)
                    .allowsHitTesting(false)
            )
            .offset(x: enemyShakeOffset)
            .position(x: 660, y: 490 + enemyFloat)
            .scaleEffect(data.isEnemyDefeated ? 0.2 : 1.0)
            .opacity(data.isEnemyDefeated ? 0.0 : 1.0)
            .animation(.easeOut(duration: 0.6), value: data.isEnemyDefeated)
            // .position(x: 690, y: 525 + enemyFloat)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    enemyFloat = -12
                }
            }

            // attack effect on enemy — plays after knight_attack finishes
            if showAttackEffect {
                FrameAnimatedSprite(
                    frames: (1...6).map { "effect_atk_0\($0)" },
                    duration: effectDuration,
                    repeats: false,
                    cornerRadius: 0
                )
                .frame(width: 270, height: 270)
                .position(x: 600, y: 550)
                .id(showAttackEffect)
            }

            // player avatar
            PlayerSpriteView(state: playerState)
                .frame(width: 270)
                .position(x: 150, y: 820)

            // player HP bar
            HealthBarSlot(
                label: "player_hp_bar",
                value: "\(data.playerHP)",
                current: data.playerHP,
                max: data.playerMaxHP,
                fillColor: GameColor.hpGreen
            )
            .frame(width: 220, height: 40)
            .position(x: 360, y: 830)

            // player ATK bar
            AttackStatSlot(text: data.playerAttackText)
                .frame(width: 120, height: 32)
                .position(x: 311, y: 870)
        }
        .onChange(of: playerState) { _, newState in
            guard newState == .attack else { return }
            Task {
                try? await Task.sleep(nanoseconds: UInt64(knightAttackDuration * 1_000_000_000))
                showAttackEffect = true

                // hit flash
                withAnimation(.easeOut(duration: 0.1)) { enemyHitFlash = true }
                try? await Task.sleep(nanoseconds: 120_000_000)
                withAnimation(.easeOut(duration: 0.15)) { enemyHitFlash = false }

                // shake knockback
                for _ in 0..<3 {
                    withAnimation(.easeInOut(duration: 0.05)) { enemyShakeOffset = -10 }
                    try? await Task.sleep(nanoseconds: 50_000_000)
                    withAnimation(.easeInOut(duration: 0.05)) { enemyShakeOffset = 10 }
                    try? await Task.sleep(nanoseconds: 50_000_000)
                }
                withAnimation(.easeOut(duration: 0.08)) { enemyShakeOffset = 0 }

                try? await Task.sleep(nanoseconds: UInt64(effectDuration * 1_000_000_000))
                showAttackEffect = false
            }
        }
    }
}

struct HealthBarSlot: View {
    let label: String
    let value: String
    let current: Int
    let max: Int
    let fillColor: Color

    private var ratio: CGFloat {
        guard max > 0 else { return 0 }
        return Swift.max(0, Swift.min(1, CGFloat(current) / CGFloat(max)))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 7)
                    .fill(GameColor.wood)

                RoundedRectangle(cornerRadius: 6)
                    .fill(fillColor)
                    .frame(width: Swift.max(10, (geo.size.width - 12) * ratio))
                    .padding(.leading, 7)
                    .padding(.vertical, 5)

                GamePixelText(value, size: 17)
                    .padding(.leading, 18)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(GameColor.woodDark.opacity(0.6), lineWidth: 4) // Border gelap
            )
            .shadow(color: .black, radius: 1, x: 1, y: 1) // Kedalaman ekstra
        }
    }
}

struct AttackStatSlot: View {
    let text: String

    var body: some View {
        ZStack {
            Image("Hero_atk_point")
                .resizable()
                .scaledToFill()

            GamePixelText(text, size: 17)
                .padding(.leading, 18)
        }
        .clipped()
    }
}

