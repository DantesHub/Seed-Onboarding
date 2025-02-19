//
//  DhikrViewModel.swift
//  Resolved
//
//  Created by Dante Kim on 8/21/24.
//

import Combine
import Foundation

//
struct Dhikr {
    var title: String
    var mantra: String
    var arabic: String
    var description: String
    static var dhikrs = [Dhikr(title: "Alhumdulillah", mantra: "Praise to be God.", arabic: "الحمد لله", description: "“Alhamdulillah” is an Arabic phrase that translates to “All praise is due to Allah” or “Praise be to God.” It is used by Muslims to express gratitude, joy, and acknowledgment of God’s blessings in their daily lives. By frequently saying “Alhamdulillah,” one fosters a sense of gratitude, positivity, and spiritual connection, recognizing even the smallest blessings. Whether after completing a task, enjoying a meal, or experiencing a moment of happiness, this phrase serves as a reminder to appreciate and give thanks for all that is good in life."), Dhikr(title: "Astagfirullah", mantra: "Forgive me Allah.", arabic: "أستغفر الله", description: "“Astagfirullah” is an Arabic phrase that translates to “I seek forgiveness from Allah.” It is commonly used by Muslims when they seek forgiveness for their sins, express regret, or reflect on their mistakes. In the context of relapsing with pornography, saying “Astagfirullah” signifies a recognition of wrongdoing and a sincere plea for divine forgiveness and guidance.")]
}

import AVFoundation
import Combine
import Foundation

// ... (Keep the Dhikr struct as is)

class DhikrViewModel: ObservableObject {
    @Published var selectedDuration: Int = 5 // Default to 5 minutes
    @Published var progress: Double = 0.0
    @Published var isPlaying: Bool = false
    @Published var counter: Int = 0
    @Published var completedDhikr = false
    @Published var selectedDhikir: Dhikr = .dhikrs.first!
    @Published var elapsedTime: TimeInterval = 0

    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?

    // Audio-related properties
    private var audioURL: URL?
    @Published var isAudioPlaying: Bool = false

    init() {
        selectedDuration = 5 // 5 minutes
        setupAudioSession()
        setupAudioPlayer()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    private func setupAudioPlayer() {
        guard let audioURL = Bundle.main.url(forResource: "dhikr", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.volume = 0.4
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
        } catch {
            print("Error setting up audio player: \(error.localizedDescription)")
        }

        let duration = UserDefaults.standard.integer(forKey: "selectedDuration")
        if duration != 0 {
            setDuration(duration)
        } else {
            setDuration(1)
        }
    }

    func resetTimer() {
        stopTimer()
        elapsedTime = 0
        progress = 0.0
        counter = 0
        updateProgress()
    }

    func setDuration(_ minutes: Int) {
        completedDhikr = false
        selectedDuration = minutes * 60
        updateProgress()
        UserDefaults.standard.setValue(minutes, forKey: "selectedDuration")
    }

    private func updateProgress() {
        progress = min(elapsedTime / Double(selectedDuration), 1.0)
    }

    func startTimer() {
        isPlaying = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 1
            self.updateProgress()
            print(self.elapsedTime, self.selectedDuration)
            if self.elapsedTime >= Double(self.selectedDuration) {
                completedDhikr = true
                self.stopTimer()
            }
        }
    }

    func stopTimer() {
        isPlaying = false
        timer?.invalidate()
    }

    func togglePlayPause() {
        if isPlaying {
            stopTimer()
        } else {
            startTimer()
        }
    }

    // Audio control functions
    func startAudio() {
        audioPlayer?.play()
        isAudioPlaying = true
    }

    func pauseAudio() {
        audioPlayer?.pause()
        isAudioPlaying = false
    }

    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isAudioPlaying = false
    }

    func toggleAudio() {
        if isAudioPlaying {
            pauseAudio()
        } else {
            startAudio()
        }
    }
}
