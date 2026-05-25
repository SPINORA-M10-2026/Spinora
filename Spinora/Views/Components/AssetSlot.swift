//
//  AssetSlot.swift
//  Spinora
//
//  Created by Stanley Young on 15/05/26.
//

import SwiftUI

struct AssetSlot: View {
    let name: String
    let fill: Color
    let cornerRadius: CGFloat
    let showLabel: Bool

    init(
        _ name: String,
        fill: Color = GameColor.placeholder,
        cornerRadius: CGFloat = 10,
        showLabel: Bool = true
    ) {
        self.name = name
        self.fill = fill
        self.cornerRadius = cornerRadius
        self.showLabel = showLabel
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(fill)
            .opacity(0)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(GameColor.placeholderStroke, lineWidth: 1.5)
            )
            .overlay {
                if showLabel {
                    Text(name)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(4)
                }
            }
    }
}

