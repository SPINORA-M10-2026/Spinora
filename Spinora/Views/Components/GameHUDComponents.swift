//
//  TopHUD.swift
//  Spinora
//
//  Created by Stanley Young on 15/05/26.
//

import SwiftUI

struct HUDLayout: View {
    let waveText: String
    let onPauseTap: () -> Void

    var body: some View {
        ZStack {
            
            // icon wave / level
            Image("icon_wave")
                .resizable()
                .scaledToFit()
                .frame(width: 105, height: 105)
//                .background(GameColor.buttonYellow.opacity(0.9))
                .cornerRadius(18)
                .position(x: 96, y: 165)

            VStack(alignment: .leading, spacing: 0) {
                GamePixelText("Wave", size: 28)
                GamePixelText(waveText, size: 44)
            }
            .position(x: 202, y: 174)

            // icon / button pause
            Button(action: onPauseTap) {
                Image("button_pause")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(20)
            }
            .buttonStyle(.plain)
            .frame(width: 88, height: 88)
            .position(x: 742, y: 165)
        }
    }
}


// background map
struct EnvironmentBackgroundView: View {
    var body: some View {
        Image("background_environment")
            .resizable()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .position(x: 416, y: 875)
    }
}

// background top & bottom bar wood
struct WoodBackgroundView: View {
    var body: some View {
        Image("background_wood")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
    }
}

