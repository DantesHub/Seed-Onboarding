//
//  NewReflectionDetailScreen.swift
//  Resolved
//
//  Created by Gursewak Singh on 11/10/24.
//

import SwiftUI

struct NewReflectionDetailScreen: View {
    let reflection: Reflection // Pass the reflection object to show details
    let date: String

    @Environment(\.presentationMode) var presentationMode // Add this to access presentation mode

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(uiImage: UIImage(named: "back")!)
                            .overusedFont(weight: .semiBold, size: .h1Big)
                            .foregroundColor(.white)
                    }

                    Spacer()
                    SharedComponents.CustomSmallMediumText(title: reflection.date.toString(format: "MMM, dd h:mm a"), color: .white)

                    Spacer()
                    Button(action: {
                        // Menu button action
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .overusedFont(weight: .semiBold, size: .h2)
                            .foregroundColor(.white.opacity(0.5))
                    }.opacity(0)
                }
                .safeAreaPadding(.top)
                .padding()
                .padding(.horizontal, 16)
//                HStack {
//
//                    SharedComponents.CustomMediumText(title: date, color: .white)
//                        .padding(.leading)
//                        .padding(.trailing)
//                        .padding(.top)
//                    Spacer()
//                }

                ScrollView {
                    ReflectionDetailCardView(date: date, reflection: reflection)
                }
            }
        }
        .navigationBarHidden(true)
        .padding(.top, 10)
        .offset(x: dragOffset.width)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if gesture.translation.width > 0 {
                        self.dragOffset = gesture.translation
                    }
                }
                .onEnded { gesture in
                    if gesture.translation.width > 50 {
                        // Swipe right detected, dismiss the view
                        withAnimation {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    } else {
                        // Reset the offset if the swipe wasn't far enough
                        withAnimation {
                            self.dragOffset = .zero
                        }
                    }
                }
        )
        .onAppearAnalytics(event: "ReflectionDetail: Screenload")
    }

    // Helper function to format dates
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

// #Preview {
//    NewReflectionDetailScreen()
// }
struct ReflectionDetailCardView: View {
    var date: String
    @StateObject private var recorderManager = VoiceRecorderManager() // Recording manager

    let reflection: Reflection
    let speechManager = SpeechManager()
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if reflection.is_audio_available {
                if let url = recorderManager.getRecordingIfExists(with: "userReflection-" + date) {
                    let estimatedDuration = speechManager.estimateSpeechDuration(for: reflection.reflectionText, rate: 0.5)

                    ReflectionDetailsPlayerView(duration: estimatedDuration.rounded(), text: reflection.reflectionText, date: date, playAction: {}).padding()
                }
            }
            SharedComponents.CustomMediumTwenty(title: reflection.reflectionText, color: .white)
                .padding(20)
                .cornerRadius(10)
                .multilineTextAlignment(.leading)
                .offset(y: 4)
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, alignment: .leading)
        .padding(.bottom, 8)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1),
                                lineWidth: 6)
                        .shadow(color: Color.white.opacity(0.1),
                                radius: 2, x: 3, y: 6)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 24)
                        )
                        .shadow(color: Color.white.opacity(0.1), radius: 3, x: -4, y: -2)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 24)
                        )
                )
        )
    }
}

struct ReflectionDetailsPlayerView: View {
    let duration: Double
    let text: String
    @StateObject private var recorderManager = VoiceRecorderManager() // Recording manager
    @StateObject private var audioPlayer = AudioPlayer()

    @State private var isRecordingAvail = false
    var date: String
    @State private var rec_url = URL(string: "")
    @State private var currentTime: Double = 0.0 // Start at 0
    @State private var isPlaying: Bool = false
    var playAction: () -> Void
    @State private var timer: Timer? // Manage a timer for progress updates
    let manager = SpeechManager()
    var body: some View {
        VStack {
            HStack {
                ProgressView(value: isRecordingAvail ? audioPlayer.currentTime : currentTime, total: isRecordingAvail ? audioPlayer.duration : duration)
                    .accentColor(.white)
                    .frame(height: 5)
                    .foregroundColor(.white.opacity(0.25))

                // Current time / Duration label
                if isRecordingAvail {
                    SharedComponents.customVerySmallMediumText(title: timeFormatted(audioPlayer.currentTime) + " / " + timeFormatted(audioPlayer.duration), color: .white)

                } else {
                    SharedComponents.customVerySmallMediumText(title: timeFormatted(currentTime) + " / " + timeFormatted(duration), color: .white)
                }
            }.padding()
            HStack(spacing: 20) {
                // Rewind 15 seconds button
                Button(action: {
                    if isRecordingAvail {
                        audioPlayer.skipBackward(seconds: 15)
                    } else {
                        rewind15()
                    }

                }) {
                    Image(systemName: "gobackward.15")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                }

                // Play / Pause button
                Button(action: {
                    if isRecordingAvail {
                        audioPlayer.isPlaying ? audioPlayer.pause() : audioPlayer.play()
                        isPlaying = audioPlayer.isPlaying
//                        if recorderManager.isPlaying {
//                            recorderManager.isPlaying = false
//                            recorderManager.audioPlayer?.pause()
//                        }else {
//                            recorderManager.playRecording(url: rec_url!)
//                        }
                    } else {
                        if isPlaying {
                            pauseAudio()
                        } else {
                            playAudio()
                        }
                    }
                }) {
                    if isRecordingAvail {
                        Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                    } else {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                    }
                }

                // Forward 15 seconds button
                Button(action: {
                    if isRecordingAvail {
                        audioPlayer.skipForward(seconds: 15)

                    } else {
                        forward15()
                    }
                }) {
                    Image(systemName: "goforward.15")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            if let url = recorderManager.getRecordingIfExists(with: "userReflection-" + date) {
                self.isRecordingAvail = true

                self.rec_url = url
                audioPlayer.loadAudio(from: rec_url!)
            }
        }
        .padding(.leading, 24)
        .padding(.trailing, 24)
        .background(.clear)
    }

    // Function to play audio and start the timer
    func playAudio() {
        // Call the provided play action
        playAction()
        if currentTime != 0 {
            manager.resumeSpeaking()
        } else {
            manager.speakText(text, rate: 0.5)
        }
        // Reset the current time if playing again
        if currentTime >= duration {
            currentTime = 0.0
        }

        // Start the timer to update progress
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            print("current", currentTime)
            print("duration", duration)
            if currentTime < duration {
                currentTime += 1.0
            } else {
                stopAudio() // Stop when it reaches the duration
            }
        }
        isPlaying = true
    }

    // Function to pause audio and stop the timer
    func pauseAudio() {
        manager.pauseSpeaking()
        timer?.invalidate()
        timer = nil

        // Call the provided stop action
        playAction()

        isPlaying = false
    }

    // Function to stop audio and reset the state
    func stopAudio() {
        pauseAudio()
        currentTime = 0.0 // Reset to the beginning
    }

    // Helper to format time as MM:SS
    func timeFormatted(_ totalSeconds: Double) -> String {
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // Function to rewind 15 seconds
    func rewind15() {
//        currentTime = max(currentTime - 15, 0)
    }

    // Function to forward 15 seconds
    func forward15() {
//        currentTime = min(currentTime + 15, duration)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

import AVFoundation
import SwiftUI

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    var player: AVAudioPlayer?

    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0

    override init() {
        super.init()
    }

    func loadAudio(from url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
        } catch {
            print("Error loading audio: \(error)")
        }
    }

    func play() {
        player?.play()
        isPlaying = true
        startTimer()
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func skipForward(seconds: TimeInterval) {
        guard let player = player else { return }
        player.currentTime = min(player.currentTime + seconds, player.duration)
    }

    func skipBackward(seconds: TimeInterval) {
        guard let player = player else { return }
        player.currentTime = max(player.currentTime - seconds, 0)
    }

    var duration: TimeInterval {
        player?.duration ?? 0
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self, let player = self.player else { return }
            if player.isPlaying {
                self.currentTime = player.currentTime
            } else {
                timer.invalidate()
            }
        }
    }

    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentTime = 0 // Reset the current time
        print("Finished playing: \(flag)")
    }
}

/*

 struct NewReflectionDetailScreen: View {
     let reflection: Reflection  // Pass the reflection object to show details
     let date: String
     @Environment(\.presentationMode) var presentationMode  // Access presentation mode

     var body: some View {
         ZStack {
             Image(.justBackground)
                 .resizable()
                 .scaledToFill()
                 .edgesIgnoringSafeArea(.all)
             VStack {
                 HStack {
                     Button(action: {
                         presentationMode.wrappedValue.dismiss()
                         UIImpactFeedbackGenerator(style: .light).impactOccurred()
                     }) {
                         Image(uiImage: UIImage(named: "back")!)
                             .overusedFont(weight: .semiBold, size: .h1Big)
                             .foregroundColor(.white)
                     }

                     Spacer()
                     SharedComponents.CustomSmallMediumText(title: reflection.date.toString(format: "MMM, dd h:mm a"), color: .white)

                     Spacer()
                     Button(action: {
                         // Menu button action
                     }) {
                         Image(systemName: "line.3.horizontal.decrease.circle.fill")
                             .overusedFont(weight: .semiBold, size: .h2)
                             .foregroundColor(.white.opacity(0.5))
                     }.opacity(0)
                 }
                 .safeAreaPadding(.top)
                 .padding(24)

                 ScrollView(showsIndicators: false) {
                     ReflectionDetailCardView(reflection: reflection)
                         .padding(.horizontal)
                 }
             }
         }
         .navigationBarHidden(true)
         .padding(.top, 10)
         // Add the high-priority gesture here
         .highPriorityGesture(
             DragGesture()
                 .onEnded { value in
                     // Detect right swipe
                     if value.translation.width > 100 && abs(value.translation.height) < 50 {
                         // Swiped right sufficiently
                         presentationMode.wrappedValue.dismiss()
                     }
                 }
         )
     }

     // Helper function to format dates
     func formattedDate(_ date: Date) -> String {
         let formatter = DateFormatter()
         formatter.dateStyle = .full
         return formatter.string(from: date)
     }
 }

 //#Preview {
 //    NewReflectionDetailScreen()
 //}
 struct ReflectionDetailCardView: View {
     let reflection: Reflection
     let speechManager = SpeechManager()
     var body: some View {
         VStack(alignment: .leading, spacing: 8) {
 //            if reflection.is_audio_available {
 //                let estimatedDuration = speechManager.estimateSpeechDuration(for: reflection.reflectionText, rate: 0.5)
 //
 //                ReflectionDetailsPlayerView(duration: estimatedDuration.rounded(),text: reflection.reflectionText, playAction: {
 //                }).padding()
 //            }
             SharedComponents.CustomMediumTwenty(title: reflection.reflectionText, color: .white)
                 .padding()
                 .multilineTextAlignment(.leading)
         }
         .frame(width: UIScreen.main.bounds.width * 0.95, alignment: .leading)
         .background(
             RoundedRectangle(cornerRadius: 24)
                 .fill(Color.white.opacity(0.1))

                 .overlay(
                     RoundedRectangle(cornerRadius: 24)
                         .stroke(Color.white.opacity(0.1),
                                 lineWidth: 6)
                         .shadow(color: Color.white.opacity(0.1),
                                 radius: 2, x: 3, y: 6)
                         .clipShape(
                             RoundedRectangle(cornerRadius: 24)
                         )
                         .shadow(color: Color.white.opacity(0.1), radius: 3, x: -4, y: -2)
                         .clipShape(
                             RoundedRectangle(cornerRadius: 24)
                         )
                 )
         )
     }

 }
 struct ReflectionDetailsPlayerView: View {
     let duration: Double
     let text: String
     @State private var currentTime: Double = 0.0 // Start at 0
     @State private var isPlaying: Bool = false
     var playAction: () -> Void
     @State private var timer: Timer? // Manage a timer for progress updates
     let manager = SpeechManager()
     var body: some View {
         VStack {
             HStack {
                 ProgressView(value: currentTime, total: duration)
                   .accentColor(.white)
                   .frame(height: 5)
                   .foregroundColor(.white.opacity(0.25))

               // Current time / Duration label
               SharedComponents.customVerySmallMediumText(title: (timeFormatted(currentTime) + " / " + timeFormatted(duration)), color: .white)
             }.padding()
             HStack(spacing: 20) {
                 // Rewind 15 seconds button
                 Button(action: {
                     rewind15()
                 }) {
                     Image(systemName: "gobackward.15")
                         .resizable()
                         .scaledToFit()
                         .frame(width: 20, height: 20)
                         .foregroundColor(.gray)
                 }

                 // Play / Pause button
                 Button(action: {
                     if isPlaying {
                         pauseAudio()
                     } else {
                         playAudio()
                     }
                 }) {
                     Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                         .resizable()
                         .scaledToFit()
                         .frame(width: 20, height: 20)
                         .foregroundColor(.gray)
                 }

                 // Forward 15 seconds button
                 Button(action: {
                     forward15()
                 }) {
                     Image(systemName: "goforward.15")
                         .resizable()
                         .scaledToFit()
                         .frame(width: 20, height: 20)
                         .foregroundColor(.gray)
                 }

             }
         }

         .padding(.leading, 24)
         .padding(.trailing, 24)
         .background(.clear)
     }

     // Function to play audio and start the timer
     func playAudio() {
         // Call the provided play action
         playAction()
         if currentTime != 0 {
             manager.resumeSpeaking()
         }else {

             manager.speakText(text, rate: 0.5)
         }
         // Reset the current time if playing again
         if currentTime >= duration {
             currentTime = 0.0
         }

         // Start the timer to update progress
         timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
             print("current", currentTime)
             print("duration", duration)
             if currentTime < duration {
                 currentTime += 1.0
             } else {
                 stopAudio() // Stop when it reaches the duration
             }
         }
         isPlaying = true
     }

     // Function to pause audio and stop the timer
     func pauseAudio() {
         manager.pauseSpeaking()
         timer?.invalidate()
         timer = nil

         // Call the provided stop action
         playAction()

         isPlaying = false
     }

     // Function to stop audio and reset the state
     func stopAudio() {
         pauseAudio()
         currentTime = 0.0 // Reset to the beginning
     }

     // Helper to format time as MM:SS
     func timeFormatted(_ totalSeconds: Double) -> String {
         let minutes = Int(totalSeconds) / 60
         let seconds = Int(totalSeconds) % 60
         return String(format: "%02d:%02d", minutes, seconds)
     }

     // Function to rewind 15 seconds
     func rewind15() {
 //        currentTime = max(currentTime - 15, 0)
     }

     // Function to forward 15 seconds
     func forward15() {
 //        currentTime = min(currentTime + 15, duration)
     }
 }
 */
