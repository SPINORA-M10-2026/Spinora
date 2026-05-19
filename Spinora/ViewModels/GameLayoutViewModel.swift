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
    @Published var enemyAppearance: EnemyAppearance = EnemyAppearance.random()
    
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
        hasDismissedTapToPlay = true
        
        guard let result = reelManager.createRollResult(
            index: index,
            rolledThisTurn: rolledThisTurn,
            isRolling: isRolling,
            isGameOver: false,
            showingUpgradeSheet: false
        ) else {
            return
        }
        
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

        // --- Player turn ---
        let enemyElement = enemyAppearance.bodyElement
        let playerDamage = DamageCalculator.calculateDamage(
            playerElements: symbols,
            enemyElement: enemyElement,
            baseAttack: currentAttackValue()
        )

        let strongCount = symbols.filter { $0.damageMultiplier(against: enemyElement) == 2.0 }.count
        let comboLabel = strongCount == 3 ? "TRIPLE x4" : strongCount == 2 ? "DOUBLE x2" : "none"
        print("⚔️ PLAYER: \(playerDamage) DMG | [\(symbols.map { $0.rawValue }.joined(separator: ", "))] vs \(enemyElement.rawValue) | Combo: \(comboLabel)")

        playerAnimationState = .attack
        layoutData.enemyHP = max(0, layoutData.enemyHP - playerDamage)

        Task {
            try? await Task.sleep(nanoseconds: 600_000_000)
            playerAnimationState = .idle
        }

        if layoutData.enemyHP <= 0 {
            layoutData.isEnemyDefeated = true
            Task {
                try? await Task.sleep(nanoseconds: 900_000_000)
                showWaveCleared()
                persistCurrentRun()
            }
            return
        }

        // --- Monster turn ---
        isMonsterTurn = true
        syncLayout()

        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            let monsterDamage = enemyAttackValue
            print("👹 MONSTER: \(monsterDamage) DMG | Element: \(enemyElement.rawValue)")
            layoutData.playerHP = max(0, layoutData.playerHP - monsterDamage)
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
        guard let savedRunRepository else {
            return
        }
        
        do {
            try savedRunRepository.markPlayerDead()
            
            layoutData.playerHP = 0
            layoutData.canAttack = false
            
            showRestartWaveConfirmation()
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
        overlay = .waveCleared
        syncLayout()
        persistCurrentRun()
    }
    
    func showPause() {
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
        overlay = nil
        confirmAction = nil
        syncLayout()
    }
    
    func backToPause() {
        overlay = .pause
        confirmAction = nil
        syncLayout()
    }
    
    func confirmCurrentAction() {
        switch confirmAction {
        case .restartWave:
            retryCurrentWave()
            
        case .resetGame:
            rerunFromFirstWave()
            
        case .none:
            break
        }
        
        closeOverlay()
    }
    
    // MARK: - Reward
    
    func selectReward(_ reward: RewardChoice) {
        switch reward {
        case .hp:
            applyHPReward()
            
        case .attack:
            applyAttackReward()
        }
        
        nextWave()
    }
    
    private func applyHPReward() {
        
        let bonusHP = 10

        accumulatedBonusHP += bonusHP

        layoutData.playerMaxHP += bonusHP
        layoutData.playerHP = min(layoutData.playerMaxHP, layoutData.playerHP + bonusHP)

        do {
            try runUpgradeRepository?.addRunUpgrade(
                upgradeKey: "hp_plus_10",
                upgradeName: "+10 HP",
                bonusHP: bonusHP
            )
        } catch {
            print("Failed to save HP upgrade:", error)
        }
//
//        let bonusHP = 10
//        
//        accumulatedBonusHP += bonusHP
//        
//         layoutData.waveText = String(format: "%03d", nextWave)
//         layoutData.enemyHP = layoutData.enemyMaxHP
//         enemyAppearance = EnemyAppearance.random()
//        
//        layoutData.playerMaxHP += bonusHP
//        layoutData.playerHP = min(layoutData.playerMaxHP, layoutData.playerHP + bonusHP)
//        
//        do {
//            try runUpgradeRepository?.addRunUpgrade(
//                upgradeKey: "hp_plus_10",
//                upgradeName: "+10 HP",
//                bonusHP: bonusHP
//            )
//        } catch {
//            print("Failed to save HP upgrade:", error)
//        }
    }
    
    private func applyAttackReward() {
        let bonusAttack = 10
        
        accumulatedBonusAttack += bonusAttack
        
        let newAttack = currentAttackValue() + bonusAttack
        layoutData.playerAttackText = "\(newAttack)"
        
        do {
            try runUpgradeRepository?.addRunUpgrade(
                upgradeKey: "attack_plus_10",
                upgradeName: "+10 Attack",
                bonusAttack: bonusAttack
            )
        } catch {
            print("Failed to save attack upgrade:", error)
        }
    }
    
    // MARK: - Wave
    
    private func nextWave() {
        currentWave += 1

        layoutData.enemyMaxHP = enemyMaxHP(for: currentWave)
        layoutData.enemyHP = layoutData.enemyMaxHP
        layoutData.isEnemyDefeated = false
        enemyAppearance = EnemyAppearance.random()

        layoutData.playerHP = layoutData.playerMaxHP

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
        func enemyMaxHP(for wave: Int) -> Int {
            150 + ((wave - 1) * 20)
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
