import SwiftUI
import SplineRuntime
import CoreMotion
import PencilKit

struct TypingScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel

    @State private var typedTitle = ""
    @State private var currentSentenceIndex = 0
    @State private var indexInSentence = 0
    @State private var isAnimating = true
    @State private var isPaused = false
    @State private var rotation: CGSize = .zero
    @State private var showCard = false
    @State private var cardOffset: CGFloat = 1500 // Increased from 1000 for more dramatic entrance
    @State private var cardScale: CGFloat = 0.5   // Decreased from 0.6 for more dramatic scale change
    private let motionManager = CMMotionManager()
    @State private var url: URL?
    @State private var savedSignature: PKDrawing?
    @State private var canvasView = PKCanvasView()
    @State private var currentStreak = 0
    // Create a computed property for sentences
    private var sentences: [String] {
        [
            "Hey \(mainVM.currUser.name).",
            "Welcome to Seed, your path to freedom.",
            "Based off your answers, we built your training card.",
            "It's designed to help you quit porn forever.",
            "Now it's time to invest in yourself."
        ]
    }
    
    // Adjust typing speed here (seconds per character)
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: "gender_bg")!)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text(typedTitle)
                    .overusedFont(weight: .semiBold, size: .h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(height: 100, alignment: .center)
                    .padding(.vertical)
                    .contentTransition(.identity)
                    .transaction { transaction in
                        transaction.animation = nil
                        transaction.disablesAnimations = true
                    }
                    .padding(.top, 32)
                
                // Card View with 3D rotation
                ZStack {
                   
                    VStack(alignment: .leading, spacing: 24) {
                        // Top section with gradient
                        ZStack {
                            VStack(alignment: .leading, spacing: 24) {
                                VStack(alignment: .center) {
                                    HStack {
                                        Image(.stamp)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 48, height: 48)
                                            .opacity(0)
                                        Spacer()
                                        Text(homeVM.selectedOrb.0.displayName())
                                            .foregroundColor(.white.opacity(0.7))
                                        Spacer()
                                        Image(.stamp)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 48, height: 48)
                                            .offset(x: 12, y: 4)
                                    }
                                    if let url = url {
                                        SplineView(sceneFileURL: url)
                                            .frame(width: 150, height: 150)
                                            .ignoresSafeArea(.all)
                                    }
                                }
                                .padding()
                                .frame(width: UIScreen.main.bounds.width - 96)
                                
                                VStack(alignment: .leading) {
                                    Text("Current Streak")
                                        .sfFont(weight: .regular, size: .p3)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("\(currentStreak) days")
                                        .sfFont(weight: .semibold, size: .h1)
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading)  {
                                    Text("Orbs Collected")
                                        .sfFont(weight: .regular, size: .p3)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("1")
                                        .sfFont(weight: .semibold, size: .h1)
                                        .foregroundColor(.white)
                                }
                                
                            }
                            // position the stamp in the top right
                            // if let signature = savedSignature {
                            //     SignatureDisplayView(drawing: signature)
                            //         .frame(height: 60)
                            //         .disabled(true)
                            //         .offset(x: 72, y: 32)
                            //         .rotationEffect(.degrees(-24))
                            // }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(.darkPurple),
                                    Color(.primaryPurple)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        
                        // Bottom section
                        HStack {
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Name")
                                    .sfFont(weight: .regular, size: .p4)
                                    .foregroundColor(.white.opacity(0.6))
                                Text("\(mainVM.currUser.name)")
                                    .sfFont(weight: .medium, size: .p2)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Free since")
                                    .sfFont(weight: .regular, size: .p4)
                                    .foregroundColor(.white.opacity(0.6))
                                Text("\(newDateFormat())")
                                    .sfFont(weight: .medium, size: .p2)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                        .overlay(
                            Group {
                                if let signature = savedSignature {
                                    SignatureDisplayView(drawing: signature)
                                        .frame(height: 140)
                                        .disabled(true)
                                        .rotationEffect(.degrees(-24))
                                        .offset(x: 90, y: -140) // Adjust this to position above the text
                                        
                                }
                            }
                        )
                    }
                    
                 
                }
                .background(Color.black.opacity(0.3))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .white.opacity(0.25), radius: 20, x: 0, y: 0)
                .shadow(color: .white.opacity(0.35), radius: 1, x: 0, y: 0)
                .frame(width: UIScreen.main.bounds.width - 48)
                .rotation3DEffect(
                    .degrees(rotation.width),
                    axis: (x: 0, y: 1, z: 0)
                )
                .rotation3DEffect(
                    .degrees(rotation.height),
                    axis: (x: 1, y: 0, z: 0)
                )
                .offset(y: cardOffset)
                .scaleEffect(cardScale)
                .opacity(showCard ? 1 : 0)
                
             
                
                Spacer()
    
            }
        }
        .onAppearAnalytics(event: "TypingScreen: Screenload")
        .onAppear {
            savedSignature = SignatureManager.shared.loadSignature()
            print(savedSignature, "gardina")
            startMotionUpdates()
            startTypingAnimation()
            
            if homeVM.selectedOrb.0.rawValue.contains("https") {
                url = URL(string: homeVM.selectedOrb.0.rawValue)
            } else {
                url = Bundle.main.url(forResource: homeVM.selectedOrb.0.rawValue, withExtension: "splineswift")
            }
            
            currentStreak = Date.getCurrentStreak(date1: mainVM.currentInterval.startDate, date2: Date().toString(format: "dd-MM-yyyy HH:mm:ss"))
        }
        .onReceive(timer) { _ in
            // Call the typing function on every timer tick
            if isAnimating {
                typeNextCharacter()
            }
        }
        .onDisappear {
            stopMotionUpdates()
            isAnimating = false
        }
        .onChange(of: currentSentenceIndex) { newIndex in
            if newIndex == 2 { // Index of "Based off your answers..." sentence
                withAnimation(
                    .spring(
                        response: 1.2,      // Increased from 0.6 to 1.2 for slower animation
                        dampingFraction: 0.8, // Increased from 0.7 to 0.8 for smoother movement
                        blendDuration: 0.3   // Increased from 0 to 0.3 for smoother blending
                    )
                ) {
                    showCard = true
                    cardOffset = 0
                    cardScale = 1
                }
            }
        }
    }
    
    private func newDateFormat() -> String {
        let dateString = mainVM.currentInterval.startDate
        
        // Create input date formatter to parse the string
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        // Parse the string to Date
        guard let date = inputFormatter.date(from: dateString) else { return dateString }
        
        // Get the user's locale
        let locale = Locale.current
        
        // Create output date formatter
        let outputFormatter = DateFormatter()
        outputFormatter.locale = locale
        
        // Check if locale is US
        if locale.identifier.contains("US") {
            outputFormatter.dateFormat = "MM/dd"
        } else {
            outputFormatter.dateFormat = "dd/MM"
        }
        
        return outputFormatter.string(from: date)
    }
    
    // Reset all state & begin typing
    private func startTypingAnimation() {
        typedTitle = ""
        currentSentenceIndex = 0
        indexInSentence = 0
        isPaused = false
        isAnimating = true
        // Reset card state
        showCard = false
        cardOffset = 1500
        cardScale = 0.5
    }
    
    private func typeNextCharacter() {
        // If we've finished all sentences, stop entirely
        guard currentSentenceIndex < sentences.count else {
            isAnimating = false
            return
        }
        
        // If we're currently paused between sentences, do nothing
        guard !isPaused else { return }
        
        let sentence = sentences[currentSentenceIndex]
        
        // If we still have characters to type in the current sentence:
        if indexInSentence < sentence.count {
            let nextChar = sentence[sentence.index(sentence.startIndex, offsetBy: indexInSentence)]
            typedTitle.append(nextChar)
            indexInSentence += 1
            
            // Haptic feedback for every character
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
        } else if indexInSentence == sentence.count {
            // We just finished this entire sentence, so pause for 1 second
            isPaused = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Move on to the next sentence
                self.currentSentenceIndex += 1
                if self.currentSentenceIndex < self.sentences.count {
                    // Reset typed text and character index for the next sentence
                    self.typedTitle = ""
                    self.indexInSentence = 0
                    self.isPaused = false
                } else {
                    // No more sentences left
                    self.isAnimating = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        mainVM.onboardingScreen = .pricing
                    }
                }
            }
        }
    }
    
    private func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 1/60
        motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
            guard let motion = motion else { return }
            
            withAnimation(.interactiveSpring()) {
                // Side-to-side tilt
                let roll = motion.attitude.roll * 15
                
                // Calculate pitch relative to vertical position
                // When phone is vertical (90 degrees), pitch will be 0
                let relativePitch = motion.attitude.pitch - .pi/2 // Subtract 90 degrees
                let pitch = max(0, relativePitch * 15)
                
                rotation = CGSize(
                    width: roll,    // Side-to-side tilt
                    height: pitch   // Forward tilt relative to vertical
                )
            }
        }
    }
    
    private func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
