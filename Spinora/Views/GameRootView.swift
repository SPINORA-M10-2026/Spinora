//
//  GameRootView.swift
//  Spinora
//
//  Created by Stanley Young on 21/05/26.
//

import SwiftUI

struct GameRootView: View {
    @State private var hasStartedGame = false

    var body: some View {
        ZStack {
            if hasStartedGame {
                GameLayoutDemoView()
                    .transition(.opacity)
            } else {
                StartPageView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        hasStartedGame = true
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    GameRootView()
}
