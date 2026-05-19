//
//  SavedRunRepository.swift
//  Spinora
//

import Foundation
import SwiftData

@MainActor
final class SavedRunRepository {
    private let context: ModelContext
    private let playerProgressRepository: PlayerProgressRepository

    init(context: ModelContext) {
        self.context = context
        self.playerProgressRepository = PlayerProgressRepository(context: context)
    }

    // MARK: - Load

    func load() throws -> SavedRunModel? {
        let descriptor = FetchDescriptor<SavedRunModel>(
            predicate: #Predicate { run in
                run.id == "active_run"
            }
        )

        return try context.fetch(descriptor).first
    }

    func fetchOrCreateActiveRun() throws -> SavedRunModel {
        if let activeRun = try load() {
            return activeRun
        }

        let profile = try playerProgressRepository.fetchOrCreateProfile()

        let newRun = SavedRunModel(
            currentWave: 1,
            playerHP: profile.baseMaxHP,
            playerMaxHP: profile.baseMaxHP,
            playerBaseAttack: profile.baseAttack,
            enemyHP: 150,
            enemyMaxHP: 150,
            enemyBaseAttack: 15,
            accumulatedBonusHP: 0,
            accumulatedBonusAttack: 0,
            currentReelSymbols: ["water", "fire", "earth"],
            rolledThisTurn: [false, false, false],
            isPlayerDead: false,
            canRetryWave: false
        )

        context.insert(newRun)
        try context.save()

        return newRun
    }

    // MARK: - Save

    func save(_ model: SavedRunModel) throws {
        let existingRuns = try context.fetch(FetchDescriptor<SavedRunModel>())

        for run in existingRuns {
            context.delete(run)
        }

        context.insert(model)
        try playerProgressRepository.updateHighestWave(model.currentWave)
        try context.save()
    }

    func saveCurrentRun(
        currentWave: Int,
        playerHP: Int,
        playerMaxHP: Int,
        playerBaseAttack: Int,
        enemyHP: Int,
        enemyMaxHP: Int,
        accumulatedBonusHP: Int,
        accumulatedBonusAttack: Int,
        currentReelSymbols: [String],
        rolledThisTurn: [Bool]
    ) throws {
        let run = try fetchOrCreateActiveRun()

        run.currentWave = currentWave

        run.playerHP = playerHP
        run.playerMaxHP = playerMaxHP
        run.playerBaseAttack = playerBaseAttack

        run.enemyHP = enemyHP
        run.enemyMaxHP = enemyMaxHP
        // (enemyBaseAttack omitted here since it's not in the method signature, but we can update it if needed. For now keeping it simple)

        run.accumulatedBonusHP = accumulatedBonusHP
        run.accumulatedBonusAttack = accumulatedBonusAttack

        run.currentReelSymbols = currentReelSymbols
        run.rolledThisTurn = rolledThisTurn

        run.isPlayerDead = false
        run.canRetryWave = false

        run.savedAt = Date()

        try playerProgressRepository.updateHighestWave(currentWave)
        try context.save()
    }

    // MARK: - Death / Retry / Rerun

    func markPlayerDead() throws {
        let run = try fetchOrCreateActiveRun()

        run.playerHP = 0
        run.isPlayerDead = true
        run.canRetryWave = true
        run.savedAt = Date()

        try playerProgressRepository.recordDeath()
        try context.save()
    }

    func retryCurrentWave() throws -> SavedRunModel {
        let run = try fetchOrCreateActiveRun()

        // Retry keeps current wave, accumulated stats, and run upgrades.
        run.playerHP = run.playerMaxHP
        run.enemyHP = run.enemyMaxHP

        run.currentReelSymbols = ["water", "fire", "earth"]
        run.rolledThisTurn = [false, false, false]

        run.isPlayerDead = false
        run.canRetryWave = false
        run.savedAt = Date()

        try context.save()

        return run
    }

    func rerunFromFirstWave() throws -> SavedRunModel {
        let profile = try playerProgressRepository.fetchOrCreateProfile()

        try delete()

        let upgradeRepository = RunUpgradeRepository(context: context)
        try upgradeRepository.deleteAll()

        let newRun = SavedRunModel(
            currentWave: 1,
            playerHP: profile.baseMaxHP,
            playerMaxHP: profile.baseMaxHP,
            playerBaseAttack: profile.baseAttack,
            enemyHP: 150,
            enemyMaxHP: 150,
            enemyBaseAttack: 15,
            accumulatedBonusHP: 0,
            accumulatedBonusAttack: 0,
            currentReelSymbols: ["water", "fire", "earth"],
            rolledThisTurn: [false, false, false],
            isPlayerDead: false,
            canRetryWave: false
        )

        context.insert(newRun)

        try playerProgressRepository.recordNewRun()
        try context.save()

        return newRun
    }

    // MARK: - Delete

    func delete() throws {
        let existingRuns = try context.fetch(FetchDescriptor<SavedRunModel>())

        for run in existingRuns {
            context.delete(run)
        }

        try context.save()
    }
}
