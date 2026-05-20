//
//  SoundFeedback.swift
//  Spinora
//
//  Created by ahmadfarhanqf on 20/05/26.
//

import AVFoundation

final class SoundFeedback {
    static let shared = SoundFeedback()

    private var buttonPressPlayer: AVAudioPlayer?
    private var rollPressPlayer: AVAudioPlayer?

    private init() {}

    func playButtonPressSound() {
        guard let url = Bundle.main.url(
            forResource: "button-press SFX05_1",
            withExtension: "wav"
        ) ?? Bundle.main.url(
            forResource: "button-press SFX05_1",
            withExtension: "wav",
            subdirectory: "Audio/SFX"
        ) else {
            assertionFailure("Could not find button-press SFX05_1.wav")
            return
        }

        do {
            if buttonPressPlayer?.url != url {
                buttonPressPlayer = try AVAudioPlayer(contentsOf: url)
                buttonPressPlayer?.prepareToPlay()
            }

            buttonPressPlayer?.currentTime = 0
            buttonPressPlayer?.play()
        } catch {
            assertionFailure("Failed to play button press SFX: \(error.localizedDescription)")
        }
    }

    func rollPressSound() {
        guard let url = Bundle.main.url(
            forResource: "Roll SFX05",
            withExtension: "wav"
        ) ?? Bundle.main.url(
            forResource: "Roll SFX05",
            withExtension: "wav",
            subdirectory: "Audio/SFX"
        ) else {
            assertionFailure("Could not find Roll SFX05.wav")
            return
        }

        do {
            if rollPressPlayer?.url != url {
                rollPressPlayer = try AVAudioPlayer(contentsOf: url)
                rollPressPlayer?.prepareToPlay()
            }

            rollPressPlayer?.currentTime = 0
            rollPressPlayer?.play()
        } catch {
            assertionFailure("Failed to play roll SFX: \(error.localizedDescription)")
        }
    }
    
    func attackPressSound() {
        guard let url = Bundle.main.url(
            forResource: "sword slash SFX",
            withExtension: "wav"
        ) ?? Bundle.main.url(
            forResource: "sword slash SFX",
            withExtension: "wav",
            subdirectory: "Audio/SFX"
        ) else {
            assertionFailure("Could not find sword slash SFX.wav")
            return
        }

        do {
            if rollPressPlayer?.url != url {
                rollPressPlayer = try AVAudioPlayer(contentsOf: url)
                rollPressPlayer?.prepareToPlay()
            }

            rollPressPlayer?.currentTime = 0
            rollPressPlayer?.play()
        } catch {
            assertionFailure("Failed to play roll SFX: \(error.localizedDescription)")
        }
    }
    
    func hitPressSound() {
        guard let url = Bundle.main.url(
            forResource: "Hit SFX05",
            withExtension: "wav"
        ) ?? Bundle.main.url(
            forResource: "Hit SFX05",
            withExtension: "wav",
            subdirectory: "Audio/SFX"
        ) else {
            assertionFailure("Could not find Hit SFX05.wav")
            return
        }

        do {
            if rollPressPlayer?.url != url {
                rollPressPlayer = try AVAudioPlayer(contentsOf: url)
                rollPressPlayer?.prepareToPlay()
            }

            rollPressPlayer?.currentTime = 0
            rollPressPlayer?.play()
        } catch {
            assertionFailure("Failed to play roll SFX: \(error.localizedDescription)")
        }
    }
    
}