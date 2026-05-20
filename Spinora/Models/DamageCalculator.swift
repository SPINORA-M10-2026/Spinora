//
//  DamageCalculator.swift
//  Spinora
//
//  Created by oky faishal on 15/05/26.
//

import Foundation

struct DamageCalculator {
    
    /// Menghitung total damage berdasarkan elemen di slot pemain, elemen musuh, dan base attack
    static func calculateDamage(playerElements: [Element], enemyElement: Element, baseAttack: Int) -> Int {
        var totalMultiplier: Double = 0.0
        
        // 1. Hitung kemunculan tiap elemen
        var counts: [Element: Int] = [:]
        for element in playerElements {
            counts[element, default: 0] += 1
        }
        
        // 2. Kalkulasi Combo Multiplier
        for (element, count) in counts {
            // Jika mendapat 3 elemen yang sama (C3), hitungannya menjadi 4 (combo bonus)
            let effectiveCount = (count == 3) ? 4 : count
            let multiplier = element.damageMultiplier(against: enemyElement)
            
            totalMultiplier += Double(effectiveCount) * multiplier
        }
        
        // 3. Kalkulasi Final
        let finalDamage = Double(baseAttack) * totalMultiplier
        return Int(ceil(finalDamage)) // Dibulatkan ke atas sesuai permintaan
    }
}
