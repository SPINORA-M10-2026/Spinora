//
//  SavedRunMapper.swift
//  Spinora
//

import Foundation

struct SavedRunMapper {

    // MARK: - Simple Character Mapping

    static func toModel(wave: Int, player: Character) -> SavedRunModel {
        SavedRunModel(
            currentWave: wave,
            playerHP: player.hp,
            playerMaxHP: player.maxHp,
            playerBaseAttack: player.baseAttack
        )
    }

    static func toGameState(from model: SavedRunModel) -> (wave: Int, player: Character) {
        let player = Character(
            hp: model.playerHP,
            maxHp: model.playerMaxHP,
            baseAttack: model.playerBaseAttack,
            element: nil
        )

        return (
            wave: model.currentWave,
            player: player
        )
    }

    // MARK: - Full Run Mapping

    static func toModel(
        currentWave: Int,
        player: Character,
        enemy: Character,
        accumulatedBonusHP: Int,
        accumulatedBonusAttack: Int,
        currentReelSymbols: [String],
        rolledThisTurn: [Bool],
        isPlayerDead: Bool = false,
        canRetryWave: Bool = false
    ) -> SavedRunModel {
        SavedRunModel(
            currentWave: currentWave,
            playerHP: player.hp,
            playerMaxHP: player.maxHp,
            playerBaseAttack: player.baseAttack,
            enemyHP: enemy.hp,
            enemyMaxHP: enemy.maxHp,
            accumulatedBonusHP: accumulatedBonusHP,
            accumulatedBonusAttack: accumulatedBonusAttack,
            currentReelSymbols: currentReelSymbols,
            rolledThisTurn: rolledThisTurn,
            isPlayerDead: isPlayerDead,
            canRetryWave: canRetryWave
        )
    }

    static func toFullGameState(
        from model: SavedRunModel
    ) -> (
        wave: Int,
        player: Character,
        enemy: Character,
        accumulatedBonusHP: Int,
        accumulatedBonusAttack: Int,
        currentReelSymbols: [String],
        rolledThisTurn: [Bool],
        isPlayerDead: Bool,
        canRetryWave: Bool
    ) {
        let playableModel = toPlayableLaunchModel(model)

        let player = Character(
            hp: playableModel.playerHP,
            maxHp: playableModel.playerMaxHP,
            baseAttack: playableModel.playerBaseAttack,
            element: nil
        )

        let enemy = Character(
            hp: playableModel.enemyHP,
            maxHp: playableModel.enemyMaxHP,
            baseAttack: playableModel.enemyBaseAttack,
            element: nil
        )

        return (
            wave: playableModel.currentWave,
            player: player,
            enemy: enemy,
            accumulatedBonusHP: playableModel.accumulatedBonusHP,
            accumulatedBonusAttack: playableModel.accumulatedBonusAttack,
            currentReelSymbols: playableModel.currentReelSymbols,
            rolledThisTurn: playableModel.rolledThisTurn,
            isPlayerDead: playableModel.isPlayerDead,
            canRetryWave: playableModel.canRetryWave
        )
    }
    
    // MARK: - Safety Validation

    static func isDeadOrLockedRun(_ model: SavedRunModel) -> Bool {
        model.playerHP <= 0 || model.isPlayerDead || model.canRetryWave
    }

    static func toPlayableLaunchModel(_ model: SavedRunModel) -> SavedRunModel {
        if isDeadOrLockedRun(model) {
            model.playerHP = max(1, model.playerMaxHP)
            model.enemyHP = model.enemyMaxHP
            model.currentReelSymbols = ["water", "fire", "earth"]
            model.rolledThisTurn = [false, false, false]
            model.isPlayerDead = false
            model.canRetryWave = false
            model.savedAt = Date()
        }

        return model
    }
}
