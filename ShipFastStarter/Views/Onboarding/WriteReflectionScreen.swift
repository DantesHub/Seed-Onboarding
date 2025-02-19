//
//  WriteReflectionScreen.swift
//  Resolved
//
//  Created by Gursewak Singh on 05/10/24.
//

import AVFoundation
import Combine
import StoreKit
import SwiftData
import SwiftUI

struct WriteReflectionScreen: View {
    @StateObject private var recorderManager = VoiceRecorderManager() // Recording manager

    @State private var text: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @StateObject public var speechManager = SpeechManager() // StateObject to persist synthesizer
    @StateObject private var speechAnalyzer = SpeechAnalyzer()
    @EnvironmentObject var reflectionVM: ReflectionsViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @Environment(\.modelContext) var modelContext
    @Query private var sessionHistory: [SoberInterval]

    @State private var utteranceRate: Float = 0.5
//    @ObservedObject private var speechAnalyzer = SpeechAnalyzer()
    @State private var noteType: NoteType = .thought
    @FocusState private var isTextEditorFocused: Bool

    enum NoteType: String, CaseIterable {
        case thought = "Thought"
        case motivation = "Motivation"
        case trigger = "Trigger"
    }

    enum NoteGroup: String, CaseIterable {
        case exercises = "Exercises"
        case motivations = "Motivations"
        case triggers = "Triggers"
        case thoughts = "Thoughts"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Image(.justBackground)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                VStack(alignment: .center) {
                    Spacer().frame(height: 80)
                    // Title text ("Reflections")
                    HStack {
                        if homeVM.showCheckIn == false && homeVM.showRelapse == false {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 28)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation {
                                        reflectionVM.showWriteReflection = false
                                    }
                                }
                                .foregroundColor(.white)
                        }

                        Spacer()
                        SharedComponents.CustomMediumText(
                            title: "Note to self",
                            color: .white
                        ).padding(.horizontal)
                            .padding(.trailing)
                        Menu {
                            ForEach(NoteType.allCases, id: \.self) { type in
                                Button(type.rawValue) {
                                    noteType = type
                                }
                            }
                        } label: {
                            HStack {
                                Text(noteType.rawValue)
                                Image(systemName: "chevron.down")
                            }
                            .overusedFont(weight: .medium, size: .p3)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.secondaryBackground)
                            .cornerRadius(8)
                            .frame(height: 48) // Move the frame modifier here
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 0)
                    .padding(.horizontal, 24)
                    // Subtitle text
                    Spacer().frame(height: 8)
                    HStack {
                        SharedComponents.CustomSmallMediumText(
                            title: "Write down anything you want to remember later or why you want to quit porn.",
                            color: Color.white
                        ).padding(.horizontal, 48)
                    }

                    // Text Editor
                    CustomTextEditor(text: $text, placeholder: "Enter your reflections here...", speechAnalyzer: speechAnalyzer, action: {
                        DispatchQueue.main.async {
                            if !speechAnalyzer.isProcessing {
                                text = ""
                            }

                            toggleSpeechRecognition()
                        }
                    })
                    .focused($isTextEditorFocused)
                    .padding()
                    .onChange(of: speechAnalyzer.recognizedText) { newText in
                        if let recognizedText = newText, !recognizedText.isEmpty {
                            // Append new recognized text to the existing text
                            text += " " + (recognizedText.components(separatedBy: .whitespacesAndNewlines).last ?? "")
                        }
                    }
                    .frame(height: 220)
                    /*  ==== speech player
                     AudioPlayerView(onPlay: {
                         if speechManager.isSpeaking() {
                             speechManager.stopSpeaking()
                         }else {
                             speechManager.speakText(text, rate: utteranceRate)
                         }
                     }, rate: utteranceRate, text: text)
                         .frame(height: 100)*/
                    Spacer()
                        .frame(height: keyboardHeight > 0 ? 0 : .infinity)
                    // Reflections summary text
//                    SharedComponents.CustomLightText(
//                        title: "42 reflections total\nLast reflected September 30, 2024.",
//                        color: Color.white.opacity(0.5)
//                    )
//                    .padding()
//                    .lineLimit(2)

                    // Move Done button based on keyboard height
                    if homeVM.showRelapse {
                        Text("Skip")
                            .underline()
                            .foregroundColor(.gray)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation {
                                    hideKeyboard() // Dismiss keyboard on tap
                                    if homeVM.showRelapse || homeVM.showCheckIn {
//                                        homeVM.currentScreen = .nextSteps
                                    } else {
                                        homeVM.showRelapse = false
                                        reflectionVM.showWriteReflection = false
                                    }
                                }
                            }
                            .padding(.bottom)
                    }
                    SharedComponents.PrimaryButton(title: "Save Note", action: {
                        saveNote()
                        hideKeyboard() // Dismiss keyboard on Done tap
                        if homeVM.showCheckIn {}
                    })
                    .padding(.bottom, 64)
                    .padding(.horizontal, 24)
                    .disabled(text.isEmpty)
                    .opacity(text.isEmpty ? 0.5 : 1)
                }
//                .padding(.bottom)

                .onReceive(Publishers.keyboardHeight) { height in
                    withAnimation {
                        keyboardHeight = height
                    }
                }
            }
        }
        .onAppear(perform: {
//            speechAnalyzer
        })
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextEditorFocused = true
            }
        }
        .navigationBarBackButtonHidden()
    }

    func saveNote() {
        let str = Date().toString()
        if noteType == .thought {
            mainVM.currentInterval.thoughtNotes[str] = text
        } else if noteType == .motivation {
            mainVM.currentInterval.motivationalNotes[str] = text
        } else if noteType == .trigger {
            mainVM.currentInterval.lapseNotes[str] = text
        }

        Analytics.shared.log(event: "WriteReflectionScreen: Tapped Save")
        if let savedURL = recorderManager.saveRecording(finalFileName: "userReflection-\(str).m4a") {
            print("Recording saved at: \(savedURL)")
            // You can also add this URL to the notes or save it to a database
        }
        Task {
            try await FirebaseService.shared.updateDocument(collection: FirebaseCollection.intervals, object: mainVM.currentInterval)
        }
        DataManager.shared.saveContext(context: modelContext)
        reflectionVM.showWriteReflection = false
//        for session in sessionHistory {
//            print(session.id, mainVM.currentInterval.id, "it breaks my heart")
//            if session.id == mainVM.currentInterval.id {
//                print(session.thoughtNotes[str] ?? "", "hurts")
//            }
//        }
        mainVM.loadingText = "Note Saved ✅"
        mainVM.showToast = true

        if homeVM.showRelapse || homeVM.showCheckIn {
//            homeVM.currentScreen = .nextSteps
        }

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            Analytics.shared.log(event: "WriteReflections: Trigger Review")
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    func toggleSpeechRecognition() {
        if speechAnalyzer.isProcessing {
            recorderManager.stopRecording()
            speechAnalyzer.stop()
        } else {
            recorderManager.startRecording()
            speechAnalyzer.start()
        }
    }
}

// Extension to observe keyboard height
// extension Publishers {
//    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
//        let publisher = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
//            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
//            .map { notification -> CGFloat in
//                if let userInfo = notification.userInfo,
//                   let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
//                    return notification.name == UIResponder.keyboardWillShowNotification.name ? frame.height : 0
//                }
//                return 0
//            }
//            .eraseToAnyPublisher()
//
//        return publisher
//    }
// }

// Function to hide the keyboard
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Extension to observe keyboard height
extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let publisher = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .map { notification -> CGFloat in
                if let userInfo = notification.userInfo,
                   let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                {
                    return notification.name == UIResponder.keyboardWillShowNotification ? frame.height : 0
                }
                return 0
            }
            .eraseToAnyPublisher()

        return publisher
    }
}

// Function to hide the keyboard
// extension View {
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
// }

#Preview {
//    WriteReflectionScreen(text: "")
    WriteReflectionScreen()
}

import Combine
import SwiftUI

struct KeyboardAwareModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue }
                .map { $0.cgRectValue.height },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
        ).eraseToAnyPublisher()
    }

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(keyboardHeightPublisher) { self.keyboardHeight = $0 }
    }
}

extension View {
    func KeyboardAwarePadding() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAwareModifier())
    }
}

struct AudioPlayerView: View {
    var onPlay: () -> Void
    let speechManager = SpeechManager()
    let rate: Float // Normal rate

    var text: String // Dynamic duration
    var body: some View {
        ZStack {
            // Background with border
            RoundedRectangle(cornerRadius: 17)
                .fill(Color(hex: "#070921")) // Background color
                .overlay(
                    RoundedRectangle(cornerRadius: 17)
                        .stroke(Color(hex: "#212786"), lineWidth: 1) // Border
                )

            // HStack content above the border
            HStack {
                // Play Button
                Button(action: {
                    onPlay() // Trigger the action when the play button is tapped
                }) {
                    ZStack {
                        Image(uiImage: UIImage(named: "play")!)
                            .foregroundColor(.gray)
                            .font(.system(size: 30))
                            .offset(y: -33)
                    }
                }
                .padding(.leading, 12) // Slightly increased leading padding

                Spacer()
                let estimatedDuration = speechManager.estimateSpeechDuration(for: text, rate: rate)

                // Timer Text
                Text(speechManager.formatDuration(estimatedDuration))
                    .foregroundColor(.white)
                    .sfFont(weight: .medium, size: .h3p1)
                    .padding(.vertical, 12)

                Spacer()

                // Waveform Icon
                Image(uiImage: UIImage(named: "wave")!)
                    .resizable()
                    .frame(width: 34, height: 34)
                    .foregroundColor(.gray)
                    .padding(.trailing, 12)
                    .offset(y: -30)
            }
            .padding(.horizontal, 15)
            .frame(height: 60)
        }
        .padding() // Optional outer padding
    }
}

class VoiceRecorderManager: ObservableObject {
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var tempRecordingURL: URL? // Store the path of the temporary recording
    var isPlaying = false
    // Start Recording: This will replace any existing temporary recording
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let tempFileName = getDocumentsDirectory().appendingPathComponent("tempReflection.m4a")
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            ]

            // If recording exists, stop and replace
            if let recorder = audioRecorder, recorder.isRecording {
                recorder.stop()
            }

            // Start a new recording
            audioRecorder = try AVAudioRecorder(url: tempFileName, settings: settings)
            audioRecorder?.record()
            tempRecordingURL = tempFileName
        } catch {
            print("Failed to start recording")
        }
    }

    // Stop Recording
    func stopRecording() {
        audioRecorder?.stop()
    }

    // Play the current recording
    func playRecording(url: URL) {
        isPlaying = true
        guard let url = url as? URL else {
            print("No recording found")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()

        } catch {
            print("Playback failed")
        }
    }

    // Final save for recording when user presses Save Note
    func saveRecording(finalFileName: String) -> URL? {
        guard let tempURL = tempRecordingURL else { return nil }

        let finalURL = getDocumentsDirectory().appendingPathComponent(finalFileName)

        do {
            // Replace any existing file at the final location
            if FileManager.default.fileExists(atPath: finalURL.path) {
                try FileManager.default.removeItem(at: finalURL)
            }
            // Move the temporary recording to the final destination
            try FileManager.default.moveItem(at: tempURL, to: finalURL)
            return finalURL
        } catch {
            print("Failed to save the recording")
            return nil
        }
    }

    // Get Documents Directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func getRecordingIfExists(with name: String) -> URL? {
        let documentsDirectory = getDocumentsDirectory()
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            // Filter for .m4a files (or other audio file types)
            let audioFiles = fileURLs.filter { $0.pathExtension == "m4a" }

            // Find the file with the matching name
            if let matchingFile = audioFiles.first(where: { $0.deletingPathExtension().lastPathComponent == name }) {
                return matchingFile
            } else {
                return nil
            }
        } catch {
            print("Error while enumerating files \(documentsDirectory.path): \(error.localizedDescription)")
            return nil
        }
    }
}
