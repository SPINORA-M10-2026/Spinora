//
//  StartBackgroundMusic.swift
//  Spinora
//
//  Created by ahmadfarhanqf on 22/05/26.
//

import AVFoundation

/*
    HOW TO USE IT?

    StartBackgroundMusic.shared.startBackgroundMusic()
    StartBackgroundMusic.shared.stopBackgroundMusic()
*/

final class StartBackgroundMusic {
    static let shared = StartBackgroundMusic()

    private var queuePlayer: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .default,
            options: .mixWithOthers
        )

        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func startBackgroundMusic() {
        guard queuePlayer == nil else {
            queuePlayer?.play()
            return
        }

        guard let firstURL = Bundle.main.url(
            forResource: "Background Music Start 1",
            withExtension: "wav"
        ) ?? Bundle.main.url(
            forResource: "Background Music Start 1",
            withExtension: "wav",
            subdirectory: "Sounds"
        ) else {
            assertionFailure("Could not find Background Music Start 1.wav")
            return
        }

        guard let loopURL = Bundle.main.url(
            forResource: "Background Music Start 2",
            withExtension: "wav"
        ) ?? Bundle.main.url(
            forResource: "Background Music Start 2",
            withExtension: "wav",
            subdirectory: "Sounds"
        ) else {
            assertionFailure("Could not find Background Music Start 2.wav")
            return
        }

        let firstItem = AVPlayerItem(url: firstURL)
        let loopItem = AVPlayerItem(url: loopURL)

        let queuePlayer = AVQueuePlayer(items: [firstItem])
        queuePlayer.actionAtItemEnd = .advance

        self.queuePlayer = queuePlayer

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(startLoopingMusic),
            name: .AVPlayerItemDidPlayToEndTime,
            object: firstItem
        )

        queuePlayer.play()

        self.playerLooper = AVPlayerLooper(
            player: queuePlayer,
            templateItem: loopItem
        )
    }

    func stopBackgroundMusic() {
        queuePlayer?.pause()
        queuePlayer?.removeAllItems()

        queuePlayer = nil
        playerLooper = nil

        NotificationCenter.default.removeObserver(self)
    }

    @objc private func startLoopingMusic() {
        queuePlayer?.play()
    }
}