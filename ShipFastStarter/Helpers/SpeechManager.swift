//
//  SpeechManager.swift
//  Resolved
//
//  Created by Gursewak Singh on 08/10/24.
//

import AVFAudio
import Foundation
import Speech

class SpeechManager: ObservableObject {
    private var synthesizer = AVSpeechSynthesizer()

    func speakText(_ text: String, rate: Float) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        synthesizer.speak(utterance)
    }

    func isSpeaking() -> Bool {
        return synthesizer.isSpeaking
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    func pauseSpeaking() {
        synthesizer.pauseSpeaking(at: .word)
    }

    func resumeSpeaking() {
        synthesizer.continueSpeaking()
    }

    /// Estimate duration of the speech
    func estimateSpeechDuration(for text: String, rate: Float) -> TimeInterval {
        // Base duration per character (in seconds) at a normal speaking rate
        let baseDurationPerCharacter = 0.04 // approximately 5 characters per second
        // Adjust the duration based on the speech rate (higher rate = shorter duration)
        let adjustedDurationPerCharacter = baseDurationPerCharacter / Double(rate)

        // Calculate total duration based on number of characters in the text
        let estimatedDuration = adjustedDurationPerCharacter * Double(text.count)

        return estimatedDuration
    }

    /// Convert duration to "mins secs" format
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60

        if minutes > 0 {
            return "\(minutes) mins \(seconds) secs"
        } else {
            if seconds == 0 {
                if duration > 0 {
                    return "1 secs"
                } else {
                    return "0 secs"
                }
            }
            return "\(seconds == 0 ? 1 : seconds) secs"
        }
    }
}

// class SpeechManager: ObservableObject {
//    private var synthesizer = AVSpeechSynthesizer()
//    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//    private let audioEngine = AVAudioEngine()
//
//    func speakText(_ text: String, rate: Float) {
//        let utterance = AVSpeechUtterance(string: text)
//        utterance.rate = rate
//        synthesizer.speak(utterance)
//    }
//
//    func stopSpeaking() {
//        synthesizer.stopSpeaking(at: .immediate)
//    }
//
//    // Start speech-to-text
//    func startRecording(completion: @escaping (String) -> Void) {
//        SFSpeechRecognizer.requestAuthorization { authStatus in
//            if authStatus == .authorized {
//                self.setupAndStartRecognition(completion: completion)
//            } else {
//                print("Speech recognition authorization denied.")
//            }
//        }
//    }
//
//    private func setupAndStartRecognition(completion: @escaping (String) -> Void) {
//        let node = audioEngine.inputNode
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//
//        guard let recognitionRequest = recognitionRequest else { return }
//
//        recognitionRequest.shouldReportPartialResults = true
//
//        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
//            if let result = result {
//                completion(result.bestTranscription.formattedString)
//            }
//            if error != nil || result?.isFinal == true {
//                self.stopRecording()
//            }
//        }
//
//        let recordingFormat = node.outputFormat(forBus: 0)
//        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
//            self.recognitionRequest?.append(buffer)
//        }
//
//        audioEngine.prepare()
//        try? audioEngine.start()
//    }
//
//    // Stop recording
//    func stopRecording() {
//        audioEngine.stop()
//        recognitionRequest?.endAudio()
//        recognitionTask?.cancel()
//        recognitionTask = nil
//        recognitionRequest = nil
//
//        audioEngine.inputNode.removeTap(onBus: 0)
//    }
// }

final class SpeechAnalyzer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    private let audioEngine = AVAudioEngine()
    private var inputNode: AVAudioInputNode?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    @Published var recognizedText: String?
    @Published var isProcessing: Bool = false

    func start() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Couldn't configure the audio session properly")
        }

        inputNode = audioEngine.inputNode

        speechRecognizer = SFSpeechRecognizer()
        print("Supports on device recognition: \(speechRecognizer?.supportsOnDeviceRecognition == true ? "✅" : "🔴")")

        // Force specified locale
        // self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "pl_PL"))
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        // Disable partial results
        // recognitionRequest?.shouldReportPartialResults = false

        // Enable on-device recognition
        // recognitionRequest?.requiresOnDeviceRecognition = true

        guard let speechRecognizer = speechRecognizer,
              speechRecognizer.isAvailable,
              let recognitionRequest = recognitionRequest,
              let inputNode = inputNode
        else {
            assertionFailure("Unable to start the speech recognition!")
            return
        }

        speechRecognizer.delegate = self

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, _: AVAudioTime) in
            recognitionRequest.append(buffer)
        }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            self?.recognizedText = result?.bestTranscription.formattedString

            guard error != nil || result?.isFinal == true else { return }
            self?.stop()
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
            isProcessing = true
        } catch {
            print("Coudn't start audio engine!")
            stop()
        }
    }

    func stop() {
        recognitionTask?.cancel()

        audioEngine.stop()
        inputNode?.removeTap(onBus: 0)

        isProcessing = false

        recognitionRequest = nil
        recognitionTask = nil
        speechRecognizer = nil
        inputNode = nil
    }

    public func speechRecognizer(_: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            print("✅ Available")
        } else {
            print("🔴 Unavailable")
            recognizedText = "Text recognition unavailable. Sorry!"
            stop()
        }
    }
}
