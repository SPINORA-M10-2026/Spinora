//
//  MainBackgroundMusic.swift
//  Spinora
//
//  Created by ahmadfarhanqf on 22/05/26.
//

import AVFoundation

/*
HOW TO USED IT?

MainBackgroundMusic.shared.playBackgroundMusic()
MainBackgroundMusic.shared.lowerVolume()
MainBackgroundMusic.shared.restoreVolume()

*/

final class MainBackgroundMusic {
    static let shared = MainBackgroundMusic()

    private var player: AVAudioPlayer?
    private var fadeTimer: Timer?

    private let normalVolume: Float = 1.0
    private let loweredVolume: Float = 0.25

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .default,
            options: .mixWithOthers
        )

        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func playBackgroundMusic() {
        let songName = "Background Music In Game"

        guard let url = Bundle.main.url(
            forResource: songName,
            withExtension: "wav"
        ) ?? Bundle.main.url(
            forResource: songName,
            withExtension: "wav",
            subdirectory: "Sounds"
        ) else {
            assertionFailure("Could not find \(songName).wav")
            return
        }

        do {
            if player?.url != url {
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = -1
                player?.volume = normalVolume
                player?.prepareToPlay()
            }

            if player?.isPlaying == false {
                player?.play()
            }

        } catch {
            assertionFailure("Failed to play background music: \(error.localizedDescription)")
        }
    }

    func lowerVolume() {
        fadeVolume(to: loweredVolume)
    }

    func restoreVolume() {
        fadeVolume(to: normalVolume)
    }

    func stopBackgroundMusic() {
        fadeTimer?.invalidate()
        fadeTimer = nil

        player?.stop()
        player?.currentTime = 0
    }

    func pauseBackgroundMusic() {
        fadeTimer?.invalidate()
        fadeTimer = nil

        player?.pause()
    }

    func resumeBackgroundMusic() {
        if player?.isPlaying == false {
            player?.play()
        }
    }

    private func fadeVolume(to targetVolume: Float, duration: TimeInterval = 0.5) {
        fadeTimer?.invalidate()

        guard let player else { return }

        let startVolume = player.volume
        let volumeDifference = targetVolume - startVolume

        let steps = 20
        let interval = duration / Double(steps)

        var currentStep = 0

        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }

            currentStep += 1

            let progress = Float(currentStep) / Float(steps)
            player.volume = startVolume + volumeDifference * progress

            if currentStep >= steps {
                player.volume = targetVolume
                timer.invalidate()
                self.fadeTimer = nil
            }
        }
    }
}