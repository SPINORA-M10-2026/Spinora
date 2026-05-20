//
//  GameLayoutDemoView.swift
//  Spinora
//
//  Created by Stanley Young on 15/05/26.
//

import SwiftUI
import SwiftData

struct GameLayoutDemoView: View {
    @AppStorage("hasCompletedFirstGameTutorial") private var hasCompletedFirstGameTutorial = false
    @State private var showTutorialOverlay = false
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = GameLayoutViewModel()

    var body: some View {
        ZStack {
            GameBattleView(
                data: viewModel.layoutData,
                playerState: viewModel.playerAnimationState,
                // enemyState: dikirim dari ViewModel ke View chain agar ArenaLayout
                // bisa trigger efek visual saat monster balas serang
                enemyState: viewModel.enemyAnimationState,
                enemyAppearance: viewModel.enemyAppearance,
                onPauseTap: {
                    viewModel.showPause()
                },
                onAttackTap: {
                    viewModel.attack()
                },
                onGuidebookTap: {
                    viewModel.openGuidebook()
                },
                onReelTap: { index in
                    viewModel.rollReel(index: index)
                }
            )

            if let overlay = viewModel.overlay {
                GameOverlayView(
                    overlay: overlay,
                    confirmAction: viewModel.confirmAction,
                    hpRewardPercent: viewModel.hpRewardPercent,
                    atkRewardPercent: viewModel.atkRewardPercent,
                    onRewardSelected: { reward in
                        viewModel.selectReward(reward)
                    },
                    onOK: {
                        viewModel.closeOverlay()
                    },
                    onResume: {
                        viewModel.closeOverlay()
                    },
                    onRestartWave: {
                        viewModel.showRestartWaveConfirmation()
                    },
                    onResetGame: {
                        viewModel.showResetGameConfirmation()
                    },
                    onConfirm: {
                        viewModel.confirmCurrentAction()
                    },
                    onCancel: {
                        viewModel.backToPause()
                    }
                )
                .zIndex(100)
            }

            // MARK: - First-Time Tutorial Overlay

            if showTutorialOverlay {
                GameTutorialOverlayView(isPresented: $showTutorialOverlay)
                    .zIndex(999)
            }
        }
        .task {
            viewModel.configurePersistenceIfNeeded(modelContext: modelContext)
            viewModel.loadSavedRunIfAvailable()

            // FINAL: only show tutorial once after first download/install.
            if hasCompletedFirstGameTutorial == false {
                showTutorialOverlay = true
            }
        }
    }
}

#Preview {
    GameLayoutDemoView()
        .modelContainer(AppModelContainer.shared)
}
