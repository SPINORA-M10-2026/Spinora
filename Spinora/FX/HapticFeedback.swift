//
//  HapticFeedback.swift
//  Spinora
//
//  Created by ahmadfarhanqf on 20/05/26.
//

import UIKit

enum GameHapticAction {
    case buttonClickLight
    case buttonClickMedium
    case buttonClickHeavy
    case slotRoll
    case slotStop
    case attack
    case Hit
    case enemyDefeated
    case victory
    case lose
    case uiOpenClose
    case jackpot
}

final class exploreHaptic {
    
    static let shared = exploreHaptic()
    
    private init() {}
    
    func play(_ action: GameHapticAction) {
        switch action {
        
        case .buttonClickLight:
            impact(.light)
            
        case .buttonClickMedium:
            impact(.medium)
            
        case .buttonClickHeavy:
            impact(.heavy)
            
        case .slotRoll:
            playSlotRollRandom(duration: 4.0)
            
        case .slotStop:
            impact(.medium)
            
        case .attack:
            impact(.rigid)
            
        case .Hit:
            impact(.rigid)
            
        case .enemyDefeated:
            notification(.success)
            
        case .victory:
            notification(.success)
            
        case .lose:
            notification(.error)
            
        case .uiOpenClose:
            impact(.soft)
            
        case .jackpot:
            jackpotPattern()
            
        }
    }
    
    private func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    private func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    private func jackpotPattern() {
        impact(.light)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.impact(.medium)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            self.impact(.heavy)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            self.notification(.success)
        }
    }
    
    func playSlotRollRandom(duration: TimeInterval = 2.0) {
        let startTime = Date()
        
        func roll() {
            let elapsedTime = Date().timeIntervalSince(startTime)
            
            guard elapsedTime < duration else {
                self.play(.slotStop)
                return
            }
            
            let randomHaptic = Int.random(in: 0...2)
            
            switch randomHaptic {
            case 1:
                self.impact(.medium)
            case 2:
                self.impact(.heavy)
            default:
                self.impact(.heavy)
            }
            
            let randomDelay = Double.random(in: 0.06...0.18)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
                roll()
            }
        }
        
        roll()
    }
}
