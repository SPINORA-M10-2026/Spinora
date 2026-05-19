//
//  RibbonBanner.swift
//  Spinora
//
//  Created by Stanley Young on 15/05/26.
//

import SwiftUI

struct RibbonBanner: View {
    let text: String

    var body: some View {
        ZStack {
            AssetSlot(
                "wave_clear_banner",
                fill: GameColor.buttonYellow,
                cornerRadius: 12,
                showLabel: false
            )
            .frame(width: 620, height: 110)

            GamePixelText(text, size: 38)
                .foregroundStyle(.white)
        }
    }
}

struct RewardCardView: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .cornerRadius(18)
                
                GamePixelText(title, size: 20)
                    .foregroundStyle(.white)
                    .offset(x: 0, y: 20)
            }
        }
        .buttonStyle(.plain)
    }
}

// for menu pause [ resume - restart wave - reset game ] in pause game
struct MenuPauseButton: View {
    let image: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 250)
        }
        .buttonStyle(.plain)
    }
}

// for menu approval [ restart wave - reset game ] in pause game
struct MenuApprovalPauseButton: View {
    let image: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 80)
        }
        .buttonStyle(.plain)
    }
}

struct SquareChoiceButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            AssetSlot(
                "choice_button",
                fill: GameColor.wood,
                cornerRadius: 16,
                showLabel: false
            )
            .overlay(
                GamePixelText(symbol, size: 52)
                    .foregroundStyle(.white)
            )
            .frame(width: 112, height: 112)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(GameColor.buttonYellow, lineWidth: 6)
            )
        }
        .buttonStyle(.plain)
    }
}

struct HelmetBadgeView: View {
    var body: some View {
        AssetSlot(
            "helmet_icon",
            fill: Color.gray.opacity(0.55),
            cornerRadius: 16,
            showLabel: true
        )
        .frame(width: 120, height: 86)
    }
}
