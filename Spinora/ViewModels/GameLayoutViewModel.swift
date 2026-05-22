//
//  GameLayoutViewModel.swift
//  Spinora
//
//  Created by Stanley Young on 15/05/26.
//

import Foundation
import Combine
import SwiftUI
import SwiftData

@MainActor
final class GameLayoutViewModel: ObservableObject {
    @Published var layoutData: BattleLayoutData = .preview
    @Published var overlay: GameOverlayType? = nil
    @Published var confirmAction: ConfirmAction? = nil
    @Published var playerAnimationState: PlayerAnimationState = .idle
    // enemyAnimationState: dikontrol di attack() saat giliran monster balas serang.
    // Diteruskan ke ArenaLayout via GameBattleView untuk trigger efek visual di player.
    @Published var enemyAnimationState: EnemyAnimationState = .idle
    @Published var enemyAppearance: EnemyAppearance = EnemyAppearance.random()
    
    @Published var hpRewardPercent: Int = 2
    @Published var atkRewardPercent: Int = 2
    
    // MARK: - Persistence
    
    private var savedRunRepository: SavedRunRepository?
    private var runUpgradeRepository: RunUpgradeRepository?
    private var runHistoryRepository: RunHistoryRepository?
    
    private var hasConfiguredPersistence = false
    private var hasLoadedSavedRun = false
    
    // MARK: - Reel Logic
    
    private let reelManager = ReelManager()
    
    private var symbols: [Element] = [.water, .fire, .earth]
    private var rolledThisTurn: [Bool] = [false, false, false]
    private var isRolling: Bool = false
    
    private var currentReelColumns: [[String]] = [
        ["water", "fire", "fire"],
        ["fire", "water", "earth"],
        ["earth", "earth", "water"]
    ]
    
    private let maxRollsPerTurn = 3
    
    // MARK: - Battle State

    private var currentWave: Int = 1
    private var accumulatedBonusHP: Int = 0
    private var accumulatedBonusAttack: Int = 0

    private var isMonsterTurn: Bool = false
    private var hasDismissedTapToPlay: Bool = false

    private var enemyAttackValue: Int { 8 + currentWave * 3 }
//    private var enemyAttackValue: Int { 9999 }

    init() {
        startNewTurn()
    }
    
    // MARK: - Persistence Setup
    
    func configurePersistenceIfNeeded(modelContext: ModelContext) {
        guard !hasConfiguredPersistence else {
            return
        }
        
        savedRunRepository = SavedRunRepository(context: modelContext)
        runUpgradeRepository = RunUpgradeRepository(context: modelContext)
        runHistoryRepository = RunHistoryRepository(context: modelContext)
        
        hasConfiguredPersistence = true
    }
    
    func loadSavedRunIfAvailable() {
        guard !hasLoadedSavedRun else {
            return
        }
        
        guard let savedRunRepository else {
            return
        }
        
        do {
            guard let savedRun = try savedRunRepository.load() else {
                persistCurrentRun()
                hasLoadedSavedRun = true
                return
            }
            
            currentWave = savedRun.currentWave
            accumulatedBonusHP = savedRun.accumulatedBonusHP
            accumulatedBonusAttack = savedRun.accumulatedBonusAttack
            
            layoutData.waveText = String(format: "%03d", savedRun.currentWave)
            
            layoutData.playerHP = savedRun.playerHP
            layoutData.playerMaxHP = savedRun.playerMaxHP
            layoutData.playerAttackText = "\(savedRun.playerBaseAttack)"
            
            layoutData.enemyHP = savedRun.enemyHP
            layoutData.enemyMaxHP = savedRun.enemyMaxHP
            layoutData.enemyAttackText = "\(savedRun.enemyBaseAttack)"
            
            rolledThisTurn = savedRun.rolledThisTurn
            
            symbols = savedRun.currentReelSymbols.compactMap {
                Element(rawValue: $0)
            }
            
            if symbols.count != 3 {
                symbols = [.water, .fire, .earth]
            }
            
            currentReelColumns = makeColumnsFromCenterSymbols(symbols)
            
            layoutData.reelColumns = currentReelColumns
            layoutData.reelRolledThisTurn = rolledThisTurn
            layoutData.lastRolledIndex = nil
            layoutData.canAttack = !savedRun.isPlayerDead
            
            overlay = nil
            confirmAction = nil
            
            syncLayout()
            hasLoadedSavedRun = true
        } catch {
            print("Failed to load saved run:", error)
            hasLoadedSavedRun = true
        }
    }
    
    private func persistCurrentRun() {
        guard let savedRunRepository else {
            return
        }
        
        do {
            try savedRunRepository.saveCurrentRun(
                currentWave: currentWave,
                playerHP: layoutData.playerHP,
                playerMaxHP: layoutData.playerMaxHP,
                playerBaseAttack: currentAttackValue(),
                enemyHP: layoutData.enemyHP,
                enemyMaxHP: layoutData.enemyMaxHP,
                enemyBaseAttack: Int(layoutData.enemyAttackText) ?? 15,
                accumulatedBonusHP: accumulatedBonusHP,
                accumulatedBonusAttack: accumulatedBonusAttack,
                currentReelSymbols: symbols.map { $0.rawValue },
                rolledThisTurn: rolledThisTurn
            )
        } catch {
            print("Failed to persist current run:", error)
        }
    }
    
    private func currentAttackValue() -> Int {
        if let intValue = Int(layoutData.playerAttackText) {
            return intValue
        }
        
        if let doubleValue = Double(layoutData.playerAttackText) {
            return Int(doubleValue)
        }
        
        return 80
    }
    
    // MARK: - Turn
    
    func startNewTurn() {
        let reelState = reelManager.makeNewTurnState(count: 3)
        
        symbols = reelState.symbols
        rolledThisTurn = reelState.rolledThisTurn
        isRolling = reelState.isRolling
        
        layoutData.lastRolledIndex = nil
        currentReelColumns = makeAllReelColumns()
        
        syncLayout()
        persistCurrentRun()
    }
    
    // MARK: - Reel
    
    func rollReel(index: Int) {
        guard overlay == nil else { return }
        guard !isMonsterTurn else { return }
        
        guard let result = reelManager.createRollResult(
            index: index,
            rolledThisTurn: rolledThisTurn,
            isRolling: isRolling,
            isGameOver: false,
            showingUpgradeSheet: false
        ) else {
            return
        }
        
        // Play roll sound and haptic
        SoundFeedback.shared.rollPressSound()
        ExploreHaptic.shared.play(.slotRoll)
        
        hasDismissedTapToPlay = true
        
        isRolling = true
        layoutData.lastRolledIndex = nil
        syncLayout()
        
        let newState = reelManager.commitRoll(
            result: result,
            symbols: symbols,
            rolledThisTurn: rolledThisTurn
        )
        
        symbols = newState.symbols
        rolledThisTurn = newState.rolledThisTurn
        isRolling = newState.isRolling
        
        updateOnlyRolledReelColumn(index: index)
        layoutData.lastRolledIndex = index
        
        syncLayout()
        persistCurrentRun()
    }
    
    func canRollReel(index: Int) -> Bool {
        reelManager.canRoll(
            index: index,
            rolledThisTurn: rolledThisTurn,
            isRolling: isRolling,
            isGameOver: false,
            showingUpgradeSheet: overlay != nil
        )
    }
    
    private func remainingRollCount() -> Int {
        let usedRollCount = reelManager.usedRollCount(rolledThisTurn)
        return max(0, maxRollsPerTurn - usedRollCount)
    }
    
    // MARK: - Reel Columns
    
    private func makeAllReelColumns() -> [[String]] {
        symbols.map { centerSymbol in
            makeReelColumn(centerSymbol: centerSymbol)
        }
    }
    
    private func makeColumnsFromCenterSymbols(_ centerSymbols: [Element]) -> [[String]] {
        centerSymbols.map { centerSymbol in
            makeReelColumn(centerSymbol: centerSymbol)
        }
    }
    
    private func updateOnlyRolledReelColumn(index: Int) {
        guard index >= 0 else {
            return
        }
        
        guard index < symbols.count else {
            return
        }
        
        guard index < currentReelColumns.count else {
            return
        }
        
        currentReelColumns[index] = makeReelColumn(centerSymbol: symbols[index])
    }
    
    private func makeReelColumn(centerSymbol: Element) -> [String] {
        [
            decorativeSymbol(excluding: centerSymbol).rawValue,
            centerSymbol.rawValue,
            decorativeSymbol(excluding: centerSymbol).rawValue
        ]
    }
    
    private func decorativeSymbol(excluding symbol: Element) -> Element {
        let options = Element.allCases.filter { $0 != symbol }
        return options.randomElement() ?? symbol
    }
    
    // MARK: - Attack

    func attack() {
        guard layoutData.canAttack else { return }
        guard overlay == nil else { return }
        hasDismissedTapToPlay = true

        let enemyElement = enemyAppearance.bodyElement
        let playerDamage = DamageCalculator.calculateDamage(
            playerElements: symbols,
            enemyElement: enemyElement,
            baseAttack: currentAttackValue()
        )

        let strongCount = symbols.filter { $0.damageMultiplier(against: enemyElement) == 2.0 }.count
        let comboLabel = strongCount == 3 ? "TRIPLE x4" : strongCount == 2 ? "DOUBLE x2" : "none"
        print("⚔️ PLAYER: \(playerDamage) DMG | [\(symbols.map { $0.rawValue }.joined(separator: ", "))] vs \(enemyElement.rawValue) | Combo: \(comboLabel)")

        // --- Phase 1: Player attack ---
        // Button langsung disabled (isMonsterTurn = true) agar tidak bisa attack ganda
        // selama seluruh sequence animasi berlangsung.
        layoutData.lastPlayerDamage = playerDamage
        playerAnimationState = .attack
        isMonsterTurn = true
        syncLayout()

        Task {
            // T+600ms: animasi player selesai, baru apply damage ke enemy HP bar
            try? await Task.sleep(for: .milliseconds(600))
            playerAnimationState = .idle
            layoutData.enemyHP = max(0, layoutData.enemyHP - playerDamage)
            
            // --- Healing dari sisa reroll ---
            let unusedRolls = remainingRollCount()
            var healAmount = 0
            if unusedRolls == 1 {
                healAmount = Int(Double(layoutData.playerMaxHP) * 0.02)
            } else if unusedRolls == 2 {
                healAmount = Int(Double(layoutData.playerMaxHP) * 0.03)
            } else if unusedRolls >= 3 {
                healAmount = Int(Double(layoutData.playerMaxHP) * 0.05)
            }
            
            if healAmount > 0 {
                layoutData.playerHP = min(layoutData.playerMaxHP, layoutData.playerHP + healAmount)
                layoutData.statIncreaseText = "+\(healAmount) Heal"
                layoutData.statIncreaseTrigger = UUID()
            }

            // Jika enemy kalah, selesaikan giliran tanpa monster balas serang
            if layoutData.enemyHP <= 0 {
                layoutData.isEnemyDefeated = true
                try? await Task.sleep(for: .milliseconds(900))
                showWaveCleared()
                persistCurrentRun()
                isMonsterTurn = false
                syncLayout()
                return
            }

            // jeda sebelum monster balas serang agar player sempat melihat hasil serangannya
            try? await Task.sleep(for: .milliseconds(1000))
            // --- Phase 2: Monster counter-attack ---
            // enemyAnimationState = .attack → ArenaLayout menangkap via onChange(of: enemyState)
            // dan menampilkan: sprite serangan, flash merah, shake di sisi player
            layoutData.lastMonsterDamage = enemyAttackValue
            enemyAnimationState = .attack

            // T+1500ms: apply damage ke player bersamaan puncak animasi serangan monster
            try? await Task.sleep(for: .milliseconds(600))
            let monsterDamage = enemyAttackValue
            print("👹 MONSTER: \(monsterDamage) DMG | Element: \(enemyElement.rawValue)")
            layoutData.playerHP = max(0, layoutData.playerHP - monsterDamage)
            SoundFeedback.shared.hitPressSound()
            ExploreHaptic.shared.play(.buttonClickHeavy)

            // Reset state monster dan buka button kembali
            enemyAnimationState = .idle
            isMonsterTurn = false

            if layoutData.playerHP <= 0 {
                markPlayerDead()
            } else {
                startNewTurn()
            }

            persistCurrentRun()
        }
    }
    
    // MARK: - Player Death
    
    func markPlayerDead() {
        layoutData.playerHP = 0
        layoutData.canAttack = false
        // Trigger animasi mati player — PlayerSpriteView akan memainkan deadFrames
        playerAnimationState = .dead
        MainBackgroundMusic.shared.stopBackgroundMusic()
        SoundFeedback.shared.playerDied()

        Task {
            // Tunda overlay konfirmasi agar animasi mati sempat selesai (durasi 1.2s)
            try? await Task.sleep(for: .seconds(1.4))

            showRestartWaveConfirmation()
            
            // Setelah animasi dead selesai + 1 detik, kembali ke idle
            // (terlihat di belakang overlay sebelum player memilih retry)
            try? await Task.sleep(for: .seconds(1.0))
            playerAnimationState = .idle
        }

        guard let savedRunRepository else {
            return
        }

        do {
            try savedRunRepository.markPlayerDead()
        } catch {
            print("Failed to mark player dead:", error)
        }
    }
    
    // MARK: - Retry / Rerun
    
    func retryCurrentWave() {
        guard let savedRunRepository else {
            return
        }
        
        do {
            let run = try savedRunRepository.retryCurrentWave()
            
            currentWave = run.currentWave
            accumulatedBonusHP = run.accumulatedBonusHP
            accumulatedBonusAttack = run.accumulatedBonusAttack
            
            layoutData.waveText = String(format: "%03d", run.currentWave)
            
            layoutData.playerHP = run.playerHP
            layoutData.playerMaxHP = run.playerMaxHP
            layoutData.playerAttackText = "\(run.playerBaseAttack)"
            
            layoutData.enemyHP = run.enemyHP
            layoutData.enemyMaxHP = run.enemyMaxHP
            layoutData.enemyAttackText = "\(run.enemyBaseAttack)"
            
            rolledThisTurn = run.rolledThisTurn
            
            symbols = run.currentReelSymbols.compactMap {
                Element(rawValue: $0)
            }
            
            if symbols.count != 3 {
                symbols = [.water, .fire, .earth]
            }
            
            currentReelColumns = makeColumnsFromCenterSymbols(symbols)
            
            overlay = nil
            confirmAction = nil
            
            syncLayout()
            persistCurrentRun()
        } catch {
            print("Failed to retry current wave:", error)
        }
    }
    
    func rerunFromFirstWave() {
        guard let savedRunRepository else {
            return
        }
        
        do {
            let run = try savedRunRepository.rerunFromFirstWave()
            
            currentWave = run.currentWave
            accumulatedBonusHP = 0
            accumulatedBonusAttack = 0
            
            layoutData.waveText = String(format: "%03d", run.currentWave)
            
            layoutData.playerHP = run.playerHP
            layoutData.playerMaxHP = run.playerMaxHP
            layoutData.playerAttackText = "\(run.playerBaseAttack)"
            
            layoutData.enemyHP = run.enemyHP
            layoutData.enemyMaxHP = run.enemyMaxHP
            layoutData.enemyAttackText = "\(run.enemyBaseAttack)"
            
            rolledThisTurn = run.rolledThisTurn
            
            symbols = run.currentReelSymbols.compactMap {
                Element(rawValue: $0)
            }
            
            if symbols.count != 3 {
                symbols = [.water, .fire, .earth]
            }
            
            currentReelColumns = makeColumnsFromCenterSymbols(symbols)
            
            overlay = nil
            confirmAction = nil
            
            syncLayout()
            persistCurrentRun()
        } catch {
            print("Failed to rerun from first wave:", error)
        }
    }
    
    // MARK: - Overlay
    
    func showWaveCleared() {
        MainBackgroundMusic.shared.lowerVolume()
        SoundFeedback.shared.playerWin()
        hpRewardPercent = Int.random(in: 1...3)
        atkRewardPercent = Int.random(in: 1...3)
        overlay = .waveCleared
        syncLayout()
        persistCurrentRun()
    }
    
    func showPause() {
        MainBackgroundMusic.shared.pauseBackgroundMusic()
        overlay = .pause
        syncLayout()
    }
    
    func showRestartWaveConfirmation() {
        confirmAction = .restartWave
        overlay = .confirmation
        syncLayout()
    }
    
    func showResetGameConfirmation() {
        confirmAction = .resetGame
        overlay = .confirmation
        syncLayout()
    }
    
    func closeOverlay() {
        MainBackgroundMusic.shared.resumeBackgroundMusic()
        overlay = nil
        confirmAction = nil
        syncLayout()
    }

    func resumeGame() {
        MainBackgroundMusic.shared.resumeBackgroundMusic()
        overlay = nil
        confirmAction = nil
        syncLayout()
    }
    
    func backToPause() {
        MainBackgroundMusic.shared.pauseBackgroundMusic()
        overlay = .pause
        confirmAction = nil
        syncLayout()
    }
    
    func confirmCurrentAction() {
        switch confirmAction {
        case .restartWave:
            retryCurrentWave()
            
            MainBackgroundMusic.shared.stopBackgroundMusic()
            MainBackgroundMusic.shared.playBackgroundMusic()

        case .resetGame:
            rerunFromFirstWave()

            MainBackgroundMusic.shared.stopBackgroundMusic()
            MainBackgroundMusic.shared.playBackgroundMusic()
            
        case .none:
            break
        }
        
        closeOverlay()
    }
    
    // MARK: - Reward
    
    func selectReward(_ reward: RewardChoice) {
        MainBackgroundMusic.shared.restoreVolume()

        let waveStr = layoutData.waveText
        let targetWave = (Int(waveStr) ?? 1) + 1
        
        let hpPercent = (reward == .hp) ? hpRewardPercent : 0
        let atkPercent = (reward == .attack) ? atkRewardPercent : 0
        
        let currentMaxHP = layoutData.playerMaxHP
        let currentATK = currentAttackValue()
        
        let newHP = calculateNewHP(current: currentMaxHP, wave: targetWave, rewardPercent: hpPercent)
        let hpIncrease = newHP - currentMaxHP
        
        let newATK = calculateNewATK(current: currentATK, wave: targetWave, rewardPercent: atkPercent)
        let atkIncrease = newATK - currentATK
        
        accumulatedBonusHP += hpIncrease
        layoutData.playerMaxHP = newHP
        layoutData.playerHP += hpIncrease
        
        accumulatedBonusAttack += atkIncrease
        layoutData.playerAttackText = "\(newATK)"
        
        layoutData.statIncreaseText = "+\(hpIncrease) HP\n+\(atkIncrease) ATK"
        layoutData.statIncreaseTrigger = UUID()
        
        do {
            if hpIncrease > 0 {
                try runUpgradeRepository?.addRunUpgrade(
                    upgradeKey: "hp_plus_\(hpIncrease)",
                    upgradeName: "+\(hpIncrease) HP",
                    bonusHP: hpIncrease
                )
            }
            if atkIncrease > 0 {
                try runUpgradeRepository?.addRunUpgrade(
                    upgradeKey: "attack_plus_\(atkIncrease)",
                    upgradeName: "+\(atkIncrease) Attack",
                    bonusAttack: atkIncrease
                )
            }
        } catch {
            print("Failed to save upgrade:", error)
        }
        
        nextWave()
    }
    
    private func calculateNewHP(current: Int, wave: Int, rewardPercent: Int) -> Int {
        let waveF = Double(wave)
        let fixedMultiplier = 1.0 + (0.45 * (1.0 - 1.0 / waveF)) / waveF
        let randomMultiplier = 1.0 + (Double(rewardPercent) / 100.0)
        
        let newHP = Double(current) * fixedMultiplier * randomMultiplier
        return Int(ceil(newHP))
    }

    private func calculateNewATK(current: Int, wave: Int, rewardPercent: Int) -> Int {
        let waveF = Double(wave)
        let fixedMultiplier = 1.0 + (0.35 * (1.0 - 1.0 / waveF)) / waveF
        let randomMultiplier = 1.0 + (Double(rewardPercent) / 100.0)
        
        let newATK = Double(current) * fixedMultiplier * randomMultiplier
        return Int(ceil(newATK))
    }
    

    
    // MARK: - Wave
    
    private func nextWave() {
        currentWave += 1

        computeNextEnemyStats(wave: currentWave)
        layoutData.enemyHP = layoutData.enemyMaxHP
        layoutData.isEnemyDefeated = false
        enemyAppearance = EnemyAppearance.random()

        // Removed automatic playerHP reset to maxHP to maintain current damage taken

        overlay = nil
        confirmAction = nil

        startNewTurn()
        persistCurrentRun()
    }
    
    func resetGame() {
        layoutData = .preview
        symbols = [.water, .fire, .earth]
        rolledThisTurn = [false, false, false]
        isRolling = false
        enemyAppearance = EnemyAppearance.random()
        
        currentReelColumns = [
            ["water", "fire", "fire"],
            ["fire", "water", "earth"],
            ["earth", "earth", "water"]
        ]
    }
    private func computeNextEnemyStats(wave: Int) {
        if wave <= 1 {
            layoutData.enemyMaxHP = 150
            layoutData.enemyAttackText = "15"
            return
        }
        
        let waveF = Double(wave)
        let currentHP = layoutData.enemyMaxHP
        let currentATK = Int(layoutData.enemyAttackText) ?? 15
        
        // HP = ROUNDUP(HP*(1+(0.4*(1-1/STAGE))/STAGE)*IF(MOD(STAGE;5)=0; 1.06; 1.005))
        let hpFixedMultiplier = 1.0 + (0.4 * (1.0 - 1.0 / waveF)) / waveF
        let hpBonusMultiplier = (wave % 5 == 0) ? 1.06 : 1.005
        let newHP = Double(currentHP) * hpFixedMultiplier * hpBonusMultiplier
        layoutData.enemyMaxHP = Int(ceil(newHP))
        
        // ATK = ROUNDUP(ATK*(1+(0.2*(1-1/STAGE))/STAGE)*IF(MOD(STAGE;5)=0; 1.07; 1.005))
        let atkFixedMultiplier = 1.0 + (0.2 * (1.0 - 1.0 / waveF)) / waveF
        let atkBonusMultiplier = (wave % 5 == 0) ? 1.07 : 1.005
        let newATK = Double(currentATK) * atkFixedMultiplier * atkBonusMultiplier
        layoutData.enemyAttackText = "\(Int(ceil(newATK)))"
    }
        
        // MARK: - Guidebook
        
        func openGuidebook() {
            print("Guidebook tapped")
        }
        
        // MARK: - Sync
        
        
        private func syncLayout() {
            layoutData.waveText = String(format: "%03d", currentWave)
            layoutData.rerollText = "↻ \(remainingRollCount())/3"
            layoutData.reelColumns = currentReelColumns
            layoutData.reelRolledThisTurn = rolledThisTurn
            layoutData.canAttack = !isRolling && !isMonsterTurn && overlay == nil && layoutData.playerHP > 0
            layoutData.showTapToPlay = currentWave == 1 && !hasDismissedTapToPlay
        }
    
}
