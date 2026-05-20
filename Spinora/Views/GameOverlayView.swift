//
//  GameOverlayType.swift
//  Spinora
//
//  Created by Stanley Young on 15/05/26.
//

import SwiftUI

enum GameOverlayType {
    case waveCleared
    case pause
    case confirmation
}

enum ConfirmAction {
    case restartWave
    case resetGame

    var title: String {
        switch self {
        case .restartWave:
            return "ARE YOU SURE YOU WANT TO RESTART FROM WAVE 1?"
        case .resetGame:
            return "ARE YOU SURE YOU WANT TO RESET GAME?"
        }
    }
}

enum RewardChoice: String {
    case hp = "+10% HP"
    case attack = "+10% ATK"
}

struct GameOverlayView: View {
    let overlay: GameOverlayType
    let confirmAction: ConfirmAction?
    let hpRewardPercent: Int
    let atkRewardPercent: Int

    let onRewardSelected: (RewardChoice) -> Void
    let onOK: () -> Void
    let onResume: () -> Void
    let onRestartWave: () -> Void
    let onResetGame: () -> Void
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.66)
                .ignoresSafeArea()

            switch overlay {
            case .waveCleared:
                WaveClearedOverlay(
                    hpRewardPercent: hpRewardPercent,
                    atkRewardPercent: atkRewardPercent,
                    onHP: {
                        onRewardSelected(.hp)
                    },
                    onAttack: {
                        onRewardSelected(.attack)
                    },
                    onOK: onOK
                )

            case .pause:
                PauseOverlay(
                    onResume: onResume,
                    onRestartWave: onRestartWave,
                    onResetGame: onResetGame
                )

            case .confirmation:
                ConfirmationOverlay(
                    title: confirmAction?.title ?? "ARE YOU SURE?",
                    onConfirm: onConfirm,
                    onCancel: onCancel
                )
            }
        }
    }
}

// MARK: - Wave Cleared

private struct WaveClearedOverlay: View {
    let hpRewardPercent: Int
    let atkRewardPercent: Int
    let onHP: () -> Void
    let onAttack: () -> Void
    let onOK: () -> Void

    var body: some View {
//        VStack(spacing: 20) {
//            RibbonBanner(text: "WAVE CLEARED!")
//
//            GamePixelText("pick your reward", size: 25)
//                .foregroundStyle(.white)
            
        ZStack {
            // backround menu pause
            Image("alert_wave_cleared")
                .resizable()
                .scaledToFit()
                .frame(width: 350)
                .offset(y: -150)

            HStack(spacing: 20) {
                RewardCardView(
                    icon: "button_reward_hp_default",
                    pressIcon: "button_reward_hp_pressed",
                    title: "+\(hpRewardPercent)% HP",
                    action: onHP
                )

                RewardCardView(
                    icon: "button_reward_atk_default",
                    pressIcon: "button_reward_atk_pressed",
                    title: "+\(atkRewardPercent)% ATK",
                    action: onAttack
                )
            }

//            GameWideButton(
//                title: "OK",
//                width: 230,
//                height: 68,
//                action: onOK
//            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Pause

private struct PauseOverlay: View {
    let onResume: () -> Void
    let onRestartWave: () -> Void
    let onResetGame: () -> Void

    var body: some View {
        ZStack {
            // backround menu pause
            Image("alert_resume")
                .resizable()
                .scaledToFit()
                .frame(width: 350)
                .offset(y: -20)
            
            VStack(spacing: 20) {
                // button resume
                MenuPauseButton(image: "button_resume_default", pressImage: "button_resume_pushed", action: onResume)
                
                // button restart
                MenuPauseButton(image: "button_restart_wave_default", pressImage: "button_restart_wave_pushed", action: onRestartWave)
                
                // button reset
                MenuPauseButton(image: "button_reset_game_default", pressImage: "button_reset_game_pushed", action: onResetGame)
            }
        }
    }
}

// MARK: - Confirmation

private struct ConfirmationOverlay: View {
    let title: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            // backround menu pause
            Image("alert_resume")
                .resizable()
                .scaledToFit()
                .frame(width: 350)
                .offset(y: -20)

            VStack(spacing: 32) {
                // text alert
                GamePixelText(title, size: 24, maxWidth: 260)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.55)
                    .padding(.horizontal, 12)

                HStack(spacing: 50) {
                    // button confirm
                    MenuApprovalPauseButton(image: "button_check_default", pressImage: "button_check_pressed", action: onConfirm)
                    
                    // button reject
                    MenuApprovalPauseButton(image: "button_cross_default", pressImage: "button_cross_pressed", action: onCancel)
                }
            }
        }
    }
}
