//
//  SavedRunModel.swift
//  Spinora
//

import Foundation
import SwiftData

@Model
final class SavedRunModel {
    @Attribute(.unique) var id: String

    var runID: UUID

    var currentWave: Int

    var playerHP: Int
    var playerMaxHP: Int
    var playerBaseAttack: Int

    var enemyHP: Int
    var enemyMaxHP: Int
    var enemyBaseAttack: Int = 15

    var accumulatedBonusHP: Int
    var accumulatedBonusAttack: Int

    var currentReelSymbols: [String]
    var rolledThisTurn: [Bool]

    var isPlayerDead: Bool
    var canRetryWave: Bool

    var savedAt: Date

    init(
        id: String = "active_run",
        runID: UUID = UUID(),
        currentWave: Int = 1,
        playerHP: Int = 100,
        playerMaxHP: Int = 100,
        playerBaseAttack: Int = 20,
        enemyHP: Int = 150,
        enemyMaxHP: Int = 150,
        enemyBaseAttack: Int = 15,
        accumulatedBonusHP: Int = 0,
        accumulatedBonusAttack: Int = 0,
        currentReelSymbols: [String] = ["water", "fire", "earth"],
        rolledThisTurn: [Bool] = [false, false, false],
        isPlayerDead: Bool = false,
        canRetryWave: Bool = false,
        savedAt: Date = Date()
    ) {
        self.id = id
        self.runID = runID

        self.currentWave = currentWave

        self.playerHP = playerHP
        self.playerMaxHP = playerMaxHP
        self.playerBaseAttack = playerBaseAttack

        self.enemyHP = enemyHP
        self.enemyMaxHP = enemyMaxHP
        self.enemyBaseAttack = enemyBaseAttack

        self.accumulatedBonusHP = accumulatedBonusHP
        self.accumulatedBonusAttack = accumulatedBonusAttack

        self.currentReelSymbols = currentReelSymbols
        self.rolledThisTurn = rolledThisTurn

        self.isPlayerDead = isPlayerDead
        self.canRetryWave = canRetryWave

        self.savedAt = savedAt
    }
}
