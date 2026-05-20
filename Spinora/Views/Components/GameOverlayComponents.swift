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
    let pressIcon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Image(isSelected ? pressIcon : icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                
                GamePixelText(title, size: 20)
                    .foregroundStyle(.white)
                    .offset(x: 0, y: 20)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
//struct RewardCardView: View {
//    let icon: String
//    let pressIcon: String
//    let title: String
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            ZStack {
//                GamePixelText(title, size: 20)
//                    .foregroundStyle(.white)
//                    .offset(y: 20)
//            }
//            .frame(width: 150, height: 150)
//        }
//        .buttonStyle(
//            ImagePressButtonStyle(
//                idleImage: icon,
//                pressedImage: pressIcon,
//                width: 150
//            )
//        )
//    }
//}

// for effect button press
struct ImagePressButtonStyle: ButtonStyle {
    let idleImage: String
    let pressedImage: String
    let width: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        Image(configuration.isPressed ? pressedImage : idleImage)
            .resizable()
            .scaledToFit()
            .frame(width: width)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// for menu pause [ resume - restart wave - reset game ] in pause game
struct MenuPauseButton: View {
    let image: String
    let pressImage: String
    let action: () -> Void

    var body: some View {
        
        Button(action: action) {

        }
        .buttonStyle(
            ImagePressButtonStyle(
                idleImage: image,
                pressedImage: pressImage,
                width: 250
            )
        )
    }
}

// for menu approval [ restart wave - reset game ] in pause game
struct MenuApprovalPauseButton: View {
    let image: String
    let pressImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
//            Image(image)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 80)
        }
        .buttonStyle(
            ImagePressButtonStyle(
                idleImage: image,
                pressedImage: pressImage,
                width: 80
            )
        )
//        .buttonStyle(.plain)
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
