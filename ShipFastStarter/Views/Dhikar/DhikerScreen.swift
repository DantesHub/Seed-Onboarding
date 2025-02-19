//
//  DhikerScreen.swift
//  Resolved
//
//  Created by Gursewak Singh on 14/10/24.
//

import SwiftUI
import TipKit

struct DhikerScreen: View {
    @StateObject var dhikrVM: DhikrViewModel = .init()
    @State private var textOffset: CGSize = .zero
    @State private var textOpacity: Double = 1.0
    @State private var textScale: CGFloat = 1.0
    @State private var isTapped = false
    @State private var musicOn: Bool = false
    @State private var displayTimer: Bool = true
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @Environment(\.modelContext) private var modelContext

    @Environment(\.presentationMode) var presentationMode // Add this to access presentation mode

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            presentationMode.wrappedValue.dismiss()
                            dhikrVM.stopAudio()
                            dhikrVM.resetTimer()
                        }

                    }) {
                        Image(.back)
                            .overusedFont(weight: .semiBold, size: .h1Big)
                            .foregroundColor(.white)
                    }

                    Spacer()
                    HStack(spacing: 20) {
                        Image(systemName: musicOn ? "speaker.fill" : "speaker.slash").onTapGesture {
                            Analytics.shared.log(event: "Dhikr: Music Tapped")
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                musicOn.toggle()
                                if musicOn {
                                    dhikrVM.startAudio()
                                } else {
                                    dhikrVM.stopAudio()
                                }
                                UserDefaults.standard.setValue(musicOn, forKey: Constants.showMusic)
                            }
                        }

                        Image(systemName: displayTimer ? "timer" : "gauge.with.needle.fill")
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation {
                                    displayTimer.toggle()
                                    UserDefaults.standard.setValue(displayTimer, forKey: Constants.displayTimer)
                                }
                            }

                        Menu {
                            Button("1 minute") { dhikrVM.setDuration(1) }
                            Button("5 minutes") { dhikrVM.setDuration(5) }
                            Button("10 minutes") { dhikrVM.setDuration(10) }
                            Button("15 minutes") { dhikrVM.setDuration(15) }
                            Button("20 minutes") { dhikrVM.setDuration(20) }
                        } label: {
                            Image(systemName: "hourglass")
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                        }
                    }
                    .foregroundColor(.white)
                }
                .safeAreaPadding(.top)
                .padding()
                VStack(alignment: .center) {
                    Spacer()
                    CircularProgressBar(viewModel: dhikrVM, textOpacity: $textOpacity, textScale: $textScale, textOffset: $textOffset)
                        .frame(width: 288, height: 288)
                        .padding()
                        .onTapGesture {
                            handleTap()
                        }

                    Spacer()

                    if dhikrVM.completedDhikr {
                        HStack(spacing: 1) {
                            VStack {
                                SharedComponents.CustomSemiBoldTitleText(title: "\(dhikrVM.selectedDuration / 60)", color: .white)
                                SharedComponents.CustomSmallMediumText(title: "Time spent (mins)", color: Color(red: 0.39, green: 0.63, blue: 1)).padding(.bottom)
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(24, corners: [.bottomLeft, .topLeft])

                            Spacer()
                                .frame(width: 2)
                            VStack {
                                SharedComponents.CustomSemiBoldTitleText(title: "\(dhikrVM.counter)", color: .white)
                                SharedComponents.CustomSmallMediumText(title: "Total Dhikrs", color: Color(red: 0.39, green: 0.63, blue: 1)).padding(.bottom)
                            }

                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(24, corners: [.topRight, .bottomRight])
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color.black))

                        }.frame(maxWidth: .infinity)
                        Spacer()

                        SharedComponents.PrimaryButton(title: "Finish") {
                            Analytics.shared.logActual(event: "DhikrCompletition: Clicked Complete")
                            presentationMode.wrappedValue.dismiss()
                            dhikrVM.stopAudio()
                            dhikrVM.resetTimer()
                        }
                        .cornerRadius(24)
                        .padding(.bottom, 20)
                        Spacer()
                    } else {
                        // Timer
                        if displayTimer {
                            SharedComponents.CustomSemiboldText(title: timeString(), color: .white)
                                .padding(.top, 8)
                        }

                        // Play Button
                        Button(action: {
                            // Action to start/stop timer
                            dhikrVM.togglePlayPause()
                        }) {
                            Circle()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(hex: "6F73FF"), Color(hex: "1A20CE")]), startPoint: .top, endPoint: .bottom))
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Image(systemName: dhikrVM.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.title)
                                        .foregroundColor(.white)
                                )
                        }
                        .padding(.bottom, 20)
                        Spacer()
                    }
                }.safeAreaPadding().padding()
                    .offset(y: -48)
                Spacer()
            }
        }
        .onAppearAnalytics(event: "DhikrScreen: Screenload")
        .navigationBarHidden(true)
        .onAppear {
            Task {
                do {
                    try await Tips.resetDatastore()
                    print("Tip defaults have been reset")
                } catch {
                    print("Failed to reset tip defaults: \(error)")
                }
            }
            // Configure and load tips when the view appears
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault),
            ])
            dhikrVM.startTimer()

            startTextAnimation()
            musicOn = UserDefaults.standard.bool(forKey: Constants.showMusic)
            displayTimer = UserDefaults.standard.bool(forKey: Constants.displayTimer)
            dhikrVM.counter = 0

            if musicOn {
                dhikrVM.startAudio()
            } else {
                dhikrVM.stopAudio()
            }
        }.onDisappear {
            dhikrVM.stopAudio()
        }
        .padding(.top, 10)
    }

    private func handleTap() {
        isTapped = true
        dhikrVM.counter += 1
        withAnimation(.easeOut(duration: 0.2)) {
            textOpacity = 1.0
            textScale = 1.0
            textOffset = .zero
        }

        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.15, dampingFraction: 0.3, blendDuration: 0.1)) {
                textOffset = CGSize(width: -2, height: -1)
                textScale = 1.2
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5)) {
                textOffset = .zero
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isTapped = false
            startTextAnimation()
        }
    }

    private func timeString() -> String {
        let remaining = max(Double(dhikrVM.selectedDuration) - dhikrVM.elapsedTime, 0)
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func timeFormatted(_ totalSeconds: TimeInterval) -> String {
        let hours = Int(totalSeconds) / 3600
        let minutes = Int(totalSeconds) % 3600 / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func startTimer() {
        // Implement timer functionality
        // Update timeRemaining and counter when needed
    }

    private func startTextAnimation() {
        withAnimation(.easeInOut(duration: 9)) {
            textOpacity = 0.05
            textScale = 0.95
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if !isTapped {
                startTextAnimation()
            }
        }
    }
}
