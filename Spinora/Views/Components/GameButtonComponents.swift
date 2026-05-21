//
//  BottomActionBarView.swift
//  Spinora
//
//  Created by Stanley Young on 15/05/26.
//

import SwiftUI

struct BottomButtonLayout: View {
    let canAttack: Bool
    let onAttackTap: () -> Void

    var body: some View {
        ZStack {
            Button(action: {
                
                SoundFeedback.shared.attackPressSound()
                ExploreHaptic.shared.play(.buttonClickHeavy)

                onAttackTap()
            }) {
                
            }
            .buttonStyle(
                ImagePressButtonStyle(
                    idleImage: "button_attack_default",
                    pressedImage: "button_attack_pressed",
                    width: 220
                )
            )
            .disabled(!canAttack)
            .position(x: 670, y: 980)
        }
    }
}

//struct AttackButtonSlot: View {
//    let isEnabled: Bool
//
//    var body: some View {
//        Image("button_attack_default")
//        .opacity(isEnabled ? 1.0 : 0.55)
//    }
//}
