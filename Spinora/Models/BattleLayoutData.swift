//
//  BattleLayoutData.swift
//  Spinora
//
//  Created by Stanley Young on 15/05/26.
//

import Foundation

struct BattleLayoutData {
    var waveText: String

    var playerHP: Int
    var playerMaxHP: Int
    var playerAttackText: String

    var enemyHP: Int
    var enemyMaxHP: Int
    var enemyAttackText: String

    var rerollText: String
    var reelColumns: [[String]]
    var reelRolledThisTurn: [Bool]
    var lastRolledIndex: Int?

    var canAttack: Bool
    var isEnemyDefeated: Bool = false
    var showTapToPlay: Bool = true
    
    var statIncreaseText: String? = nil
    var statIncreaseTrigger: UUID? = nil

    var lastPlayerDamage: Int = 0
    var lastMonsterDamage: Int = 0

    static let preview = BattleLayoutData(
        waveText: "001",
        playerHP: 100,
        playerMaxHP: 100,
        playerAttackText: "20",
        enemyHP: 150,
        enemyMaxHP: 150,
        enemyAttackText: "15",
        rerollText: "↻ 3/3",
        reelColumns: [
            ["water", "fire", "fire"],
            ["fire", "water", "earth"],
            ["earth", "earth", "water"]
        ],
        reelRolledThisTurn: [false, false, false],
        lastRolledIndex: nil,
        canAttack: true
    )
}
