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
                GamePixelText("Wave", size: 38)
                GamePixelText(waveText, size: 44)
            }
            .position(x: 202, y: 164)

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


// main frame (header, box slot, dll)
struct TopFrameLayout: View {
    var body: some View {
        ZStack {
            // backround map
            Image("background_environment")
                .resizable()
//                .frame(width: 832, height: 1750)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .position(x: 416, y: 875)
                .zIndex(5)
            
            // backround top & bottom bar (wood)
            Image("background_wood")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .zIndex(10)
        }
    }
}
