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
    @State private var tutorialStep: Int = 1
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
                    if showTutorialOverlay {
                        return
                    }

                    viewModel.showPause()
                },
                onAttackTap: {
                    if showTutorialOverlay {
                        guard tutorialStep == 2 else {
                            return
                        }

                        viewModel.attack()

                        SoundFeedback.shared.playButtonPressSound()
                        ExploreHaptic.shared.play(.buttonClickHeavy)

                        hasCompletedFirstGameTutorial = true
                        showTutorialOverlay = false
                        return
                    }

                    viewModel.attack()
                },
                onGuidebookTap: {
                    if showTutorialOverlay {
                        return
                    }

                    showElementGuidebookOverlay = true
                },
                onReelTap: { index in
                    if showTutorialOverlay {
                        guard tutorialStep == 1 else {
                            return
                        }

                        viewModel.rollReel(index: index)

                        SoundFeedback.shared.playButtonPressSound()
                        ExploreHaptic.shared.play(.buttonClickHeavy)

                        tutorialStep = 2
                        return
                    }

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
                GameTutorialOverlayView(
                    isPresented: $showTutorialOverlay,
                    step: $tutorialStep
                )
                .zIndex(999)
                .allowsHitTesting(false)
            }
        }
        .task {
            viewModel.configurePersistenceIfNeeded(modelContext: modelContext)
            viewModel.repairDeadSavedRunOnLaunchIfNeeded()
            viewModel.loadSavedRunIfAvailable()

            // FINAL: only show tutorial once after first download/install.
            if hasCompletedFirstGameTutorial == false {
                tutorialStep = 1
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
