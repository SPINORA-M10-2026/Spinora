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
    @State private var showElementGuidebookOverlay = false
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = GameLayoutViewModel()

    var body: some View {
        ZStack {
            GameBattleView(
                data: viewModel.layoutData,
                playerState: viewModel.playerAnimationState,
                enemyState: viewModel.enemyAnimationState,
                enemyAppearance: viewModel.enemyAppearance,
                onPauseTap: {
                    viewModel.showPause()
                },
                onAttackTap: {
                    viewModel.attack()
                },
                onGuidebookTap: {
                    showElementGuidebookOverlay = true
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
                        SoundFeedback.shared.chooseUpgrade()
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

            if showElementGuidebookOverlay {
                ElementGuidebookOverlayView(isPresented: $showElementGuidebookOverlay)
                    .zIndex(800)
            }

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
        .onAppear {
            MainBackgroundMusic.shared.playBackgroundMusic()
        }
        .onDisappear {
            MainBackgroundMusic.shared.stopBackgroundMusic()
        }
    }
}

#Preview {
    GameLayoutDemoView()
        .modelContainer(AppModelContainer.shared)
}
