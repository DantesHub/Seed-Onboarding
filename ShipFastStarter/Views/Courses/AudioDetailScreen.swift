//
//  AudioDetailScreen.swift
//  Resolved
//
//  Created by Dante Kim on 10/28/24.
//

//tape1
import SwiftUI
import FirebaseStorage
import AlertToast
import AVFoundation

struct AudioDetailScreen: View {
    @EnvironmentObject var educationVM: EducationViewModel
@Environment(\.presentationMode) var presentationMode  // Add this to access presentation mode
    @EnvironmentObject var mainVM: MainViewModel

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
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20)
                            .overusedFont(weight: .semiBold, size: .h1Big)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    if educationVM.completedTapes.contains(educationVM.selectedTape.id) {
                        Text("Completed")
                            .font(FontManager.overUsedGrotesk(type: .bold, size: .p3))
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.green.opacity(0.2))
                            .cornerRadius(12)
                            .padding(.top)
                    }
                  
                }
                .safeAreaPadding(.top)
                .padding(24)

                Image(educationVM.selectedTape.coverImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .cornerRadius(24)
                HStack {
                    Text(educationVM.selectedTape.title)
                        .overusedFont(weight: .semiBold, size: .h1Big)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .transition(.opacity) // Use transition for fading
                    Spacer()
                }.padding()
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Image(.headphone)
                            .frame(width: 15, height: 15)
                            .foregroundColor(.white)
                        
                    SharedComponents.CustomMediumTwenty(title: "Listen with headphones", color: .white)
                        Spacer()
                    }.padding(.leading)
                    HStack(spacing: 10) {
                        Image(.lotusPosition)
                            .frame(width: 15, height: 15)

                            .foregroundColor(.white)
                        SharedComponents.CustomMediumTwenty(title: "Find a silent, relaxing environment.", color: .white)
                        Spacer()
                    }.padding(.leading)
                    HStack(spacing: 10) {
                        Image(.targ)
                            .frame(width: 15, height: 15)

                            .foregroundColor(.white)
                        SharedComponents.CustomMediumTwenty(title: "Lock in.", color: .white)
                        Spacer()
                    }.padding(.leading)

                }
                .padding(.horizontal, 12)

                if educationVM.selectedTape.id <= 5 {
                    AudioDetailPlayerView()
                    .frame(maxWidth: .infinity) // Set AudioDetailPlayerView to full width and fixed height
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.1))
                            .overlay(SharedComponents.clearShadow)
                    ).padding()
                } else {
                    SharedComponents.CustomExtraSemiboldHeading(title: "Releasing on January 11th..", color: .white)
                    .frame(maxWidth: .infinity) // Set AudioDetailPlayerView to full width and fixed height
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.1))
                            .overlay(SharedComponents.clearShadow)
                    ).padding()
                }
                
                if educationVM.selectedTape.id >= 3 {
                    HStack {
                        Spacer()
                        SharedComponents.CustomMediumSmallMediumText(title: "\(Int.random(in: 72...84)) listening now", color: .white)
                            .padding(.trailing)
                            .padding(.bottom)
                    }
                }
                Spacer()
            }
        }
        .onAppearAnalytics(event: "AudioDetailScreen: Screenload")
        .padding(.top, 10)
     
    }
}

struct AudioDetailPlayerView: View {
    @StateObject private var audioPlayer = AudiovPlayer()
    @EnvironmentObject var educationVM: EducationViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @State private var isPlaying: Bool = false
    @State private var hasCompletedTape: Bool = false

    var body: some View {
        VStack {
            HStack {
                ProgressView(value: audioPlayer.currentTime, total: max(audioPlayer.duration, 0.01))
                    .accentColor(.white)
                    .frame(height: 5)
                    .tint(.white)
                    .background(Color.white.opacity(0.25))
                
                Spacer()
                SharedComponents.customVerySmallMediumText(
                    title: (timeFormatted(audioPlayer.currentTime) + " / " + timeFormatted(audioPlayer.duration)), 
                    color: .white
                )
            }.padding()
            HStack(spacing: 20) {
                Spacer()
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()

                        audioPlayer.skipBackward(seconds: 15)
                }) {
                    Image(systemName: "gobackward.15")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                }
                
                // Play / Pause button
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    audioPlayer.isPlaying ? audioPlayer.pause() : audioPlayer.play()
                    isPlaying = audioPlayer.isPlaying
                }) {
                        Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                    
                }
//                
                // Forward 15 seconds button
                Button(action: {
                    
                        audioPlayer.skipForward(seconds: 15)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                   
                }) {
                    Image(systemName: "goforward.15")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                }
                
                Spacer()
//                Button(action: {
//                                            
//                    
//                }) {
//                    Image(.expand)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 20, height: 20)
//                        .foregroundColor(.gray)
//                }
//                .padding()
            }.padding()
        }
        .padding()
        .toast(isPresenting: $mainVM.showToast, duration: 10) {
            return AlertToast(displayMode: .hud, type: .regular, title: mainVM.loadingText)
        }
        
        .onChange(of: audioPlayer.currentTime) {
            // Check if we're in the last 20 seconds and haven't marked as completed yet
            if !hasCompletedTape &&
               audioPlayer.duration > 0 &&
               (audioPlayer.duration - audioPlayer.currentTime) <= 5 {
                Analytics.shared.logActual(event: "AudioDetailScreen: Completed Tape", parameters: ["tape":"\(educationVM.selectedTape.id)"])
                hasCompletedTape = true
                educationVM.completeTape(educationVM.selectedTape.id)
                mainVM.loadingText = "✅ Completed"
                mainVM.showToast = true
            } else if !hasCompletedTape &&
                        audioPlayer.duration > 0 &&
                        (audioPlayer.duration - audioPlayer.currentTime) <= 30 {
                Analytics.shared.log(event: "AudioDetailScreen: Completed Tape 30 Seconds")
            }
        }
        .onAppear(perform: {
            setupAudioSession()
            loadAndPlayAudio()
        })
        .onDisappear {
            cleanupAudioSession()
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .allowAirPlay]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    private func loadAndPlayAudio() {
        let storage = Storage.storage()
        let audioRef = storage.reference(withPath: "\(educationVM.selectedTape.audioURL).m4a")
        
        audioRef.downloadURL { url, error in
            if let url = url {
                audioPlayer.loadAudio(from: url)
                // Wait briefly for duration to be loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    audioPlayer.play()
                    isPlaying = true
                }
            } else if let error = error {
                print("Error retrieving audio URL: \(error)")
            }
        }
    }
    
    private func cleanupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    func timeFormatted(_ totalSeconds: Double) -> String {
        if totalSeconds.isNaN {
            return String(format: "00:00")

        } else {
            let minutes = Int(totalSeconds) / 60
            let seconds = Int(totalSeconds) % 60
            return String(format: "%02d:%02d", minutes, seconds)

        }
    }
    
}

import AVFoundation
import Combine

class AudiovPlayer: NSObject, ObservableObject {
    var player: AVPlayer?
    private var timeObserverToken: Any?
    
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
    override init() {
        super.init()
        
        // Listen for when the player reaches the end of the track
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    func loadAudio(from url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Use the newer load API for iOS 16+
        Task {
            let duration = try? await playerItem.asset.load(.duration)
            DispatchQueue.main.async { [weak self] in
                self?.duration = CMTimeGetSeconds(duration ?? .zero)
            }
        }
        
        addPeriodicTimeObserver()
    }
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func skipForward(seconds: TimeInterval) {
        guard let player = player, let currentItem = player.currentItem else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + seconds
        player.seek(to: CMTime(seconds: min(newTime, CMTimeGetSeconds(currentItem.duration)), preferredTimescale: 1))
    }
    
    func skipBackward(seconds: TimeInterval) {
        let currentTime = CMTimeGetSeconds(player?.currentTime() ?? .zero)
        let newTime = max(currentTime - seconds, 0)
        player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 1))
    }
    
    private func addPeriodicTimeObserver() {
        guard let player = player else { return }
        
        // Notify every second
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            self?.currentTime = CMTimeGetSeconds(time)
            
            // Update isPlaying status
            if let self = self, let playerItem = player.currentItem {
                self.isPlaying = player.rate != 0 && player.error == nil
            }
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        // Reset to the beginning and play again
        player?.seek(to: .zero)
        
        isPlaying = false
    }
    
    func stopObservingTime() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    deinit {
        stopObservingTime()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}
