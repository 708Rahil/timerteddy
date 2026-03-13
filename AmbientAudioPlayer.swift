// AmbientAudioPlayer.swift
// Timer Teddy 🧸
// Manages looping ambient background sounds during focus sessions.
// Add audio files to your Xcode project target and they'll be picked up automatically.

import AVFoundation
import SwiftUI
import Combine
// MARK: - Sound Definition

enum AmbientSound: String, CaseIterable, Identifiable {
    case off        = "off"
    case rain       = "rainsound"
    case cafe       = "cafesound"
    case forest     = "forestsound"
    case whiteNoise = "whitenoise"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .off:        return "Off"
        case .rain:       return "Rain"
        case .cafe:       return "Café"
        case .forest:     return "Forest"
        case .whiteNoise: return "White Noise"
        }
    }

    var emoji: String {
        switch self {
        case .off:        return "🔇"
        case .rain:       return "🌧"
        case .cafe:       return "☕️"
        case .forest:     return "🌲"
        case .whiteNoise: return "🤍"
        }
    }

    /// File extensions to try, in order of preference.
    /// Covers both the ideal format and common alternatives users might add.
    var fileExtensions: [String] { ["mp3", "m4a", "mp4", "wav", "aac"] }
}

// MARK: - Player

@MainActor
final class AmbientAudioPlayer: ObservableObject {

    @Published var currentSound: AmbientSound = .off
    @Published var volume: Float = 0.5

    private var player: AVAudioPlayer?

    // MARK: - Public API

    /// Switch to a new sound (or silence). Crossfades smoothly.
    func select(_ sound: AmbientSound) {
        guard sound != currentSound else { return }
        currentSound = sound

        if sound == .off {
            fadeOut()
        } else {
            play(sound)
        }
    }

    /// Set volume (0.0 – 1.0). Applies immediately.
    func setVolume(_ v: Float) {
        volume = v
        player?.volume = v
    }

    /// Called when the timer starts or resumes.
    func resume() {
        guard currentSound != .off else { return }
        if player == nil { play(currentSound) }
        else {
            player?.play()
            fadeIn()
        }
    }

    /// Called when the timer is paused or ended.
    func pause() {
        fadeOut(then: { [weak self] in self?.player?.pause() })
    }

    /// Called when the timer ends completely — stops and resets.
    func stop() {
        fadeOut(then: { [weak self] in
            self?.player?.stop()
            self?.player = nil
        })
    }

    // MARK: - Private helpers

    private func play(_ sound: AmbientSound) {
        player?.stop()
        player = nil

        // Try each extension until we find a bundled file
        guard let url = resolveURL(for: sound) else {
            // File not found — silently do nothing so the app doesn't crash
            return
        }

        do {
            // Allow audio to mix with other apps (e.g. Music) rather than ducking them
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)

            let p = try AVAudioPlayer(contentsOf: url)
            p.numberOfLoops = -1      // loop forever
            p.volume        = 0       // start silent, fade in
            p.prepareToPlay()
            p.play()
            player = p
            fadeIn()
        } catch {
            // Audio setup failed — degrade gracefully
            print("[AmbientAudioPlayer] Failed to play \(sound.rawValue): \(error)")
        }
    }

    private func resolveURL(for sound: AmbientSound) -> URL? {
        for ext in sound.fileExtensions {
            if let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ext) {
                return url
            }
        }
        return nil
    }

    private func fadeIn(duration: TimeInterval = 1.2) {
        guard let player else { return }
        let target = volume
        player.volume = 0
        // AVAudioPlayer doesn't have native fade, so we step it manually
        let steps    = 20
        let interval = duration / Double(steps)
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) { [weak player] in
                player?.volume = target * Float(i) / Float(steps)
            }
        }
    }

    private func fadeOut(duration: TimeInterval = 0.8, then completion: (() -> Void)? = nil) {
        guard let player else { completion?(); return }
        let start    = player.volume
        let steps    = 16
        let interval = duration / Double(steps)
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) { [weak player] in
                player?.volume = start * (1.0 - Float(i) / Float(steps))
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion?()
        }
    }
}
