//
//  PixelText.swift
//  Spinora
//
//  Created by Stanley Young on 15/05/26.
//

import SwiftUI

struct GamePixelText: View {
    let text: String
    let size: CGFloat
    let maxWidth: CGFloat?

    init(
        _ text: String,
        size: CGFloat,
        maxWidth: CGFloat? = nil
    ) {
        self.text = text
        self.size = size
        self.maxWidth = maxWidth
    }

    var body: some View {
        Text(text)
            .font(.custom("BoldsPixels", size: size))
//            .font(.system(size: size, weight: .heavy, design: .monospaced))
            .textCase(.uppercase)
            .foregroundStyle(.white)
            .shadow(color: GameColor.woodDark, radius: 0, x: 2, y: 2)
            .frame(maxWidth: maxWidth)
    }
}
