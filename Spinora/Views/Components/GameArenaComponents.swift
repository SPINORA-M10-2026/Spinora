//
//  ArenaLayout.swift
//  Spinora
//
//  Created by Stanley Young on 15/05/26.
//

import SwiftUI

// EnemyAnimationState — enum state animasi monster.
// Dikontrol oleh GameLayoutViewModel.attack() dan diteruskan ke ArenaLayout
// melalui GameBattleView → ArenaLayout.enemyState.
// .attack = monster sedang menyerang player, .idle = tidak ada aksi.
enum EnemyAnimationState {
    case idle
    case attack
}

struct ArenaLayout: View {
    let data: BattleLayoutData
    var playerState: PlayerAnimationState = .idle
    // enemyState: dikirim dari GameLayoutViewModel → GameBattleView → ArenaLayout.
    // Berubah ke .attack saat monster balas serang, kembali .idle setelah selesai.
    var enemyState: EnemyAnimationState = .idle
    var enemyAppearance: EnemyAppearance? = nil

    // --- Efek visual saat PLAYER menyerang ENEMY ---
    @State private var showAttackEffect = false      // sprite animasi di sisi enemy
    @State private var enemyHitFlash = false         // flash merah di atas enemy sprite
    @State private var enemyShakeOffset: CGFloat = 0 // getaran horizontal enemy

    // --- Efek visual saat MONSTER menyerang PLAYER ---
    @State private var showEnemyAttackEffect = false  // sprite animasi di sisi player
    @State private var playerHitFlash = false         // flash merah di atas player sprite
    @State private var playerShakeOffset: CGFloat = 0 // getaran horizontal player

    // --- Damage popup ---
    @State private var showPlayerDamagePopup = false
    @State private var playerDamagePopupValue = 0
    @State private var playerDamagePopupID = 0

    @State private var showMonsterDamagePopup = false
    @State private var monsterDamagePopupValue = 0
    @State private var monsterDamagePopupID = 0

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
            .opacity(data.isEnemyDefeated ? 0.0 : 1.0)
            .animation(.easeOut(duration: 0.3), value: data.isEnemyDefeated)

            // enemy avatar — float dihitung dari waktu nyata via TimelineView
            // agar tidak bisa diinterupsi oleh withAnimation lain (shake/flash)
            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let floatY = CGFloat(-6 * (1 - cos(t * .pi / 1.4)))
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
                .offset(x: enemyShakeOffset, y: floatY)
            }
            .position(x: 660, y: 490)
            .scaleEffect(data.isEnemyDefeated ? 0.2 : 1.0)
            .opacity(data.isEnemyDefeated ? 0.0 : 1.0)
            .animation(.easeOut(duration: 0.6), value: data.isEnemyDefeated)

            // Sprite animasi serangan player ke enemy — muncul setelah animasi knight selesai (T+600ms)
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
                // Flash merah di player saat kena serangan monster
                .overlay(
                    Rectangle()
                        .fill(Color.red.opacity(playerHitFlash ? 0.45 : 0))
                        .blendMode(.screen)
                        .allowsHitTesting(false)
                )
                // Shake horizontal player saat kena serangan monster
                .offset(x: playerShakeOffset)
                .position(x: 150, y: 820)

            // Popup damage ke enemy saat player menyerang
            if showPlayerDamagePopup {
                DamagePopupView(value: playerDamagePopupValue, shadowColor: .red)
                    .position(x: 660, y: 390)
                    .id(playerDamagePopupID)
            }

            // Sprite animasi serangan monster ke player — muncul saat enemyState berubah ke .attack.
            // scaleEffect(x: -1) membalik sprite secara horizontal (mirroring) agar efek tampak
            // datang dari arah kanan (dari sisi monster), bukan kiri seperti serangan player.
            if showEnemyAttackEffect {
                FrameAnimatedSprite(
                    frames: (1...6).map { "effect_atk_0\($0)" },
                    duration: effectDuration,
                    repeats: false,
                    cornerRadius: 0
                )
                .frame(width: 270, height: 270)
                .scaleEffect(x: -1, y: -1)
                .position(x: 110, y: 860)
                .id(showEnemyAttackEffect)
            }

            // Popup damage ke player saat monster menyerang
            if showMonsterDamagePopup {
                DamagePopupView(value: monsterDamagePopupValue, shadowColor: .orange)
                    .position(x: 150, y: 760)
                    .id(monsterDamagePopupID)
            }

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
        // Trigger efek visual di ENEMY saat player menyerang (playerState berubah ke .attack)
        .onChange(of: playerState) { _, newState in
            guard newState == .attack else { return }
            let dmg = data.lastPlayerDamage
            Task {
                try? await Task.sleep(for: .seconds(knightAttackDuration))
                showAttackEffect = true

                withAnimation(.easeOut(duration: 0.1)) { enemyHitFlash = true }
                try? await Task.sleep(for: .milliseconds(120))
                withAnimation(.easeOut(duration: 0.15)) { enemyHitFlash = false }

                for _ in 0..<3 {
                    withAnimation(.easeInOut(duration: 0.05)) { enemyShakeOffset = -10 }
                    try? await Task.sleep(for: .milliseconds(50))
                    withAnimation(.easeInOut(duration: 0.05)) { enemyShakeOffset = 10 }
                    try? await Task.sleep(for: .milliseconds(50))
                }
                withAnimation(.easeOut(duration: 0.08)) { enemyShakeOffset = 0 }

                playerDamagePopupValue = dmg
                playerDamagePopupID += 1
                showPlayerDamagePopup = true
                try? await Task.sleep(for: .seconds(effectDuration))
                showAttackEffect = false
                try? await Task.sleep(for: .milliseconds(1000))
                showPlayerDamagePopup = false
            }
        }
        // Trigger efek visual di PLAYER saat monster balas serang (enemyState berubah ke .attack).
        // enemyState dikontrol oleh GameLayoutViewModel.attack() dan diteruskan dari GameBattleView.
        .onChange(of: enemyState) { _, newState in
            guard newState == .attack else { return }
            let dmg = data.lastMonsterDamage
            Task {
                // Sprite serangan muncul saat monster mulai menyerang
                showEnemyAttackEffect = true

                // Flash merah di player
                withAnimation(.easeOut(duration: 0.1)) { playerHitFlash = true }
                try? await Task.sleep(for: .milliseconds(120))
                withAnimation(.easeOut(duration: 0.15)) { playerHitFlash = false }

                // Shake horizontal player
                for _ in 0..<3 {
                    withAnimation(.easeInOut(duration: 0.05)) { playerShakeOffset = -10 }
                    try? await Task.sleep(for: .milliseconds(50))
                    withAnimation(.easeInOut(duration: 0.05)) { playerShakeOffset = 10 }
                    try? await Task.sleep(for: .milliseconds(50))
                }
                withAnimation(.easeOut(duration: 0.08)) { playerShakeOffset = 0 }

                monsterDamagePopupValue = dmg
                monsterDamagePopupID += 1
                showMonsterDamagePopup = true
                try? await Task.sleep(for: .seconds(effectDuration))
                showEnemyAttackEffect = false
                try? await Task.sleep(for: .milliseconds(300))
                showMonsterDamagePopup = false
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

                GamePixelText(value, size: 22)
                    .padding(.leading, 18)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(GameColor.woodDark.opacity(0.6), lineWidth: 4)
            )
            .shadow(color: .black, radius: 1, x: 1, y: 1)
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

            GamePixelText(text, size: 25)
                .padding(.leading, 18)
        }
        .clipped()
    }
}

private struct DamagePopupView: View {
    let value: Int
    let shadowColor: Color

    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        Text("-\(value)")
            .font(.custom("BoldsPixels", size: 44))
            .foregroundStyle(.white)
            .shadow(color: shadowColor, radius: 0, x: 2, y: 2)
            .offset(y: offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    offsetY = -90
                    opacity = 0
                }
            }
    }
}


