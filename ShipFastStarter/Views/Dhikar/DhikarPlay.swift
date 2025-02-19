//
//  DhikarPlay.swift
//  Resolved
//
//  Created by Dante Kim on 8/21/24.
//

import SwiftUI

struct CustomTooltip: View {
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "hand.tap.fill")
                .foregroundColor(.white)
                .font(.system(size: 24))

            Text("Tap to count Dhikr")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            Text("Tap the circle while reciting your Dhikr")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}

struct DhikarPlay: View {
    @ObservedObject var viewModel: DhikrViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @State private var textOffset: CGSize = .zero
    @State private var textOpacity: Double = 1.0
    @State private var textScale: CGFloat = 1.0
    @State private var isTapped = false
    @State private var musicOn: Bool = false
    @State private var displayTimer: Bool = true
    @Binding var page: PanicPage
    @State private var showTooltip = false

    var body: some View {
        ZStack(alignment: .top) {
            AnimatedBackground(colors: [Color.primaryPurple, Color.primaryPurple, Color.secondaryBackground])
                .edgesIgnoringSafeArea(.all)
                .blur(radius: 50)

            VStack {
                HStack {
                    if homeVM.showCheckIn || homeVM.showRelapse || mainVM.startDhikr {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24)
                            .bold()
                            .foregroundColor(.white)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation {
                                    Analytics.shared.log(event: "DhikrPlay Relapse: Tapped X")
                                    homeVM.showCheckIn = false
                                    homeVM.showRelapse = false
                                    homeVM.currentScreen = .itsOkay
                                    mainVM.startDhikr = false
                                }
                            }
                    } else {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24)
                            .bold()
                            .foregroundColor(.white)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation {
                                    page = .home
                                    viewModel.stopAudio()
                                    viewModel.resetTimer()
                                }
                            }
                    }

                    Spacer()

                    ZStack {
                        Image(systemName: "music.note")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16)
                            .foregroundColor(.white)
                            .bold()
                        if !musicOn {
                            SlashOverlay()
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 20, height: 20)
                        }
                    }.onTapGesture {
                        Analytics.shared.log(event: "Dhikr: Music Tapped")
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation {
                            musicOn.toggle()
                            if musicOn {
                                viewModel.startAudio()
                            } else {
                                viewModel.stopAudio()
                            }
                            UserDefaults.standard.setValue(musicOn, forKey: Constants.showMusic)
                        }
                    }.padding(.trailing)
                    ZStack {
                        Image(systemName: "number")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24)
                            .foregroundColor(.white)
                            .bold()
                        if !displayTimer {
                            SlashOverlay()
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 20, height: 20)
                        }
                    }.onTapGesture {
                        Analytics.shared.log(event: "Dhikr: Music Tapped")
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation {
                            displayTimer.toggle()
                            UserDefaults.standard.setValue(displayTimer, forKey: Constants.displayTimer)
                        }
                    }
                    .padding(.trailing)

                    // Duration menu
                    Menu {
                        Button("1 minute") { viewModel.setDuration(1) }
                        Button("5 minutes") { viewModel.setDuration(5) }
                        Button("10 minutes") { viewModel.setDuration(10) }
                        Button("15 minutes") { viewModel.setDuration(15) }
                        Button("20 minutes") { viewModel.setDuration(20) }
                    } label: {
                        Image(systemName: "clock")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24)
                            .foregroundColor(.white)
                            .bold()
                    }
                }.padding(.horizontal, 32)
                    .padding(.top, 32)
                Spacer()
                    .frame(height: UIDevice.hasNotch ? 50 : 25)

                VStack {
                    ZStack(alignment: .top) {
                        CircularProgressBar(viewModel: viewModel, textOpacity: $textOpacity, textScale: $textScale, textOffset: $textOffset)
                            .frame(width: 300, height: 300)
                            .padding()
                            .onTapGesture {
                                handleTap()
                                if showTooltip {
                                    withAnimation {
                                        showTooltip = false
                                        UserDefaults.standard.set(true, forKey: "hasSeenDhikrTip")
                                    }
                                }
                            }

                        if showTooltip {
                            CustomTooltip()
                                .offset(y: 200)
                                .transition(.opacity)
                        }
                    }
                }

                Spacer()
                if displayTimer {
                    Text(timeString())
                        .sfFont(weight: .bold, size: .title)
                        .foregroundColor(.white)
                        .padding(.top, 32)
                }

                playPauseButton
                Spacer()
            }
        }

        .onAppear {
            viewModel.startTimer()
            musicOn = UserDefaults.standard.bool(forKey: Constants.showMusic)
            displayTimer = UserDefaults.standard.bool(forKey: Constants.displayTimer)
            viewModel.counter = 0

            // Check if user has seen the tip before
            let hasSeenTip = UserDefaults.standard.bool(forKey: "hasSeenDhikrTip")
            if !hasSeenTip {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showTooltip = true
                    }
                }
            }

            if musicOn {
                viewModel.startAudio()
            } else {
                viewModel.stopAudio()
            }
        }
        .onDisappear {
            viewModel.stopAudio()
        }
    }

    private var playPauseButton: some View {
        Button(action: {
            viewModel.togglePlayPause()
        }) {
            Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundColor(.white)
        }
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

    private func handleTap() {
        isTapped = true
        viewModel.counter += 1
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
        let remaining = max(Double(viewModel.selectedDuration) - viewModel.elapsedTime, 0)
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct CircularProgressBar: View {
    @ObservedObject var viewModel: DhikrViewModel
    @Binding var textOpacity: Double
    @Binding var textScale: CGFloat
    @Binding var textOffset: CGSize

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 14)
                .foregroundColor(Color(red: 0.39, green: 0.63, blue: 1).opacity(0.2))

            Circle()
                .trim(from: 0.0, to: CGFloat(min(viewModel.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color(red: 0.39, green: 0.63, blue: 1))
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: viewModel.progress)
            if viewModel.completedDhikr {
                VStack {
                    Text("Dhikr\nis complete.")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
            } else {
                VStack {
                    Text(viewModel.selectedDhikir.arabic)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(viewModel.selectedDhikir.mantra)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white)

                    Text("\(viewModel.counter)")
                        .font(.system(size: 48, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top)
                }

                .opacity(textOpacity)
                .scaleEffect(textScale)
                .offset(textOffset)
            }
        }
    }
}

// DhikrViewModel remains the same as in the previous example

// #Preview {
//    DhikarPlay(viewModel: DhikrViewModel(), page: .dhikr)
// }

// Add this struct outside of your main view
struct SlashOverlay: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
    }
}

struct DurationPickerView: View {
    @ObservedObject var viewModel: DhikrViewModel
    @Environment(\.dismiss) private var dismiss

    let durations = [1, 5, 10, 15, 20]

    var body: some View {
        VStack {
            ForEach(durations, id: \.self) { duration in
                Button(action: {
                    viewModel.setDuration(duration)
                    dismiss()
                }) {
                    Text("\(duration) min")
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.primaryPurple)
                        .cornerRadius(8)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.secondaryBackground)
        .cornerRadius(16)
    }
}

struct AnimatedBackground: View {
    @State var start = UnitPoint(x: 0, y: -2)
    @State var end = UnitPoint(x: 4, y: 0)
    @State var duration = 4.0

    let timer = Timer.publish(every: 0.5, on: .main, in: .default).autoconnect()
    @State var colors: [Color]

    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: start, endPoint: end)
            .animation(Animation.easeInOut(duration: duration).repeatForever())
            .onReceive(timer, perform: { _ in
                self.start = UnitPoint(x: 4, y: 0)
                self.end = UnitPoint(x: 0, y: 2)
                self.start = UnitPoint(x: -4, y: 20)
                self.start = UnitPoint(x: 4, y: 0)
            })
    }
}

struct CircleLoadingView<Content>: View where Content: View {
    struct ActivityIndicator: UIViewRepresentable {
        @Binding var isAnimating: Bool
        let style: UIActivityIndicatorView.Style

        func makeUIView(context _: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
            return UIActivityIndicatorView(style: style)
        }

        func updateUIView(_ uiView: UIActivityIndicatorView, context _: UIViewRepresentableContext<ActivityIndicator>) {
            isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        }
    }

    @Binding var isShowing: Bool
    @State var animationDuration = 6500
    var content: () -> Content

    @State private var playanim = false
    @State private var percentage = 0
    var body: some View {
        GeometryReader { _ in
            ZStack {
                self.content()
                    .disabled(self.isShowing)

                Text("  \(percentage)%  ")
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.5)
                    .sfFont(weight: .bold, size: .h1)
                    .opacity(self.isShowing ? 1 : 0)
            }
            .frame(width: UIScreen.screenWidth, alignment: .center)
            .onAppear {
                withAnimation {
                    playanim = true
                }
                if isShowing { addNumberWithRollingAnimation() }
            }
            .onChange(of: isShowing) { val in
                if val {
                    percentage = 0
                    addNumberWithRollingAnimation()
                }
            }
        }
    }

    private func addNumberWithRollingAnimation() {
        withAnimation {
            let steps = 100
            let stepDuration = (animationDuration / steps)

            percentage += 100 % steps
            for step in 0 ..< steps {
                let updateTimeInterval = DispatchTimeInterval.milliseconds(step * stepDuration)
                let deadline = DispatchTime.now() + updateTimeInterval

                DispatchQueue.main.asyncAfter(deadline: deadline) {
                    self.percentage += Int(100 / steps)
                    if percentage == 99 {
//                        viewRouter.currentPage = .meditate
                    }
                }
            }
        }
    }
}
