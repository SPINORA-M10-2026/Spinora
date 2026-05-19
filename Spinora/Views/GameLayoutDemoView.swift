//
//  GameLayoutDemoView.swift
//  Spinora
//
//  Created by Stanley Young on 15/05/26.
//

import SwiftUI
import SwiftData

struct GameLayoutDemoView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = GameLayoutViewModel()

    var body: some View {
        ZStack {
            GameBattleView(
                data: viewModel.layoutData,
                playerState: viewModel.playerAnimationState,
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
            }
        }
        .task {
            viewModel.configurePersistenceIfNeeded(modelContext: modelContext)
            viewModel.loadSavedRunIfAvailable()
        }
    }
}

#Preview {
    GameLayoutDemoView()
        .modelContainer(AppModelContainer.shared)
}
