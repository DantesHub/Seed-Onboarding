//
//  PanicTypingScreen.swift
//  Resolved
//
//  Created by Dante Kim on 1/27/25.
//


import SwiftUI
import SplineRuntime
import CoreMotion
import PencilKit

struct PanicTypingScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var reflectionVM: ReflectionsViewModel
    @EnvironmentObject var manager: ShieldViewModel

    @Binding var showPanicScreen: Bool
    @Binding var showPlusModal: Bool
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
    @State private var showActivityPicker = false
    @State var randNum = Int.random(in: 0...9)

    // Create a computed property for sentences
    private var sentences: [String] {
        [
            "Hey \(mainVM.currUser.name).",
            "Take a slow deep breath.",
            "Remember why you started this.",
            "\(mainVM.yesterdayCheckInDay.failed - 317) others pressed this button today.",
            "\(Int.random(in: 63...91))% were able to fight it off and continue their journey.",
            "Try some of the exercises below."
        ]
    }
    private var christianSentences: [[String]] {
        [
            [
                "Therefore, since we are surrounded",
                "by so great a cloud of witnesses,",
                "let us also lay aside every weight,",
                "and sin which clings so closely,",
                "and let us run with endurance",
                "the race that is set before us.",
                "- Hebrews 12:1 (ESV)",
                "\(mainVM.yesterdayCheckInDay.failed - 317) others pressed this button today.",
                "\(Int.random(in: 63...91))% were able to fight it off and continue their journey.",
                "Try some of the exercises below."
            ],
            [
                "Beloved, I urge you as sojourners and exiles",
                "to abstain from the passions of the flesh,",
                "which wage war against your soul.",
                "- 1 Peter 2:11 (ESV)",
                "\(mainVM.yesterdayCheckInDay.failed - 317) others pressed this button today.",
                "\(Int.random(in: 63...91))% were able to fight it off and continue their journey.",
                "Try some of the exercises below."
            ],
            [
                "Let not sin therefore reign in your mortal body,",
                "to make you obey its passions.",
                "Do not present your members to sin",
                "as instruments for unrighteousness,",
                "but present yourselves to God",
                "as those who have been brought from death to life.",
                "- Romans 6:12–13 (ESV)",
                "\(mainVM.yesterdayCheckInDay.failed - 317) others pressed this button today.",
                "\(Int.random(in: 63...91))% were able to fight it off and continue their journey.",
                "Try some of the exercises below."
            ],
            [
                "No temptation has overtaken you",
                "that is not common to man.",
                "God is faithful, and he will not",
                "let you be tempted beyond your ability,",
                "but with the temptation he will also",
                "provide the way of escape,",
                "that you may be able to endure it.",
                "- 1 Corinthians 10:13 (ESV)",
                "\(mainVM.yesterdayCheckInDay.failed - 317) others pressed this button today.",
                "\(Int.random(in: 63...91))% were able to fight it off and continue their journey.",
                "Try some of the exercises below."
            ],
            [
                "But I say, walk by the Spirit,",
                "and you will not gratify the desires of the flesh.",
                "For the desires of the flesh are against the Spirit,",
                "and the desires of the Spirit are against the flesh,",
                "for these are opposed to each other.",
                "- Galatians 5:16–17 (ESV)",
                "\(mainVM.yesterdayCheckInDay.failed - 317) others pressed this button today.",
                "\(Int.random(in: 63...91))% were able to fight it off and continue their journey.",
                "Try some of the exercises below."
            ],
            [
                "So flee youthful passions",
                "and pursue righteousness, faith, love, and peace,",
                "along with those who call on the Lord",
                "from a pure heart.",
                "- 2 Timothy 2:22 (ESV)",
                "\(mainVM.yesterdayCheckInDay.failed - 317) others pressed this button today.",
                "\(Int.random(in: 63...91))% were able to fight it off and continue their journey.",
                "Try some of the exercises below."
            ],
            [
                "But put on the Lord Jesus Christ,",
                "and make no provision for the flesh,",
                "to gratify its desires.",
                "- Romans 13:14 (ESV)",
                "\(mainVM.yesterdayCheckInDay.failed - 317) others pressed this button today.",
                "\(Int.random(in: 63...91))% were able to fight it off and continue their journey.",
                "Try some of the exercises below."
            ],
            [
                "Finally, be strong in the Lord",
                "and in the strength of his might.",
                "Put on the whole armor of God,",
                "that you may be able to stand",
                "against the schemes of the devil.",
                "- Ephesians 6:10–11 (ESV)",
                "\(mainVM.yesterdayCheckInDay.failed - 317) others pressed this button today.",
                "\(Int.random(in: 63...91))% were able to fight it off and continue their journey.",
                "Try some of the exercises below."
            ],
            [
                "Blessed is the man who remains steadfast",
                "under trial, for when he has stood the test",
                "he will receive the crown of life,",
                "which God has promised to those who love him.",
                "Let no one say when he is tempted,",
                "'I am being tempted by God,'",
                "for God cannot be tempted with evil,",
                "and he himself tempts no one.",
                "- James 1:12–13 (ESV)",
                "\(mainVM.yesterdayCheckInDay.failed - 317) others pressed this button today.",
                "\(Int.random(in: 63...91))% were able to fight it off and continue their journey.",
                "Try some of the exercises below."
            ],
            [
                "For this is the will of God, your sanctification:",
                "that you abstain from sexual immorality;",
                "that each one of you know how to control",
                "his own body in holiness and honor.",
                "- 1 Thessalonians 4:3–4 (ESV)",
                "\(mainVM.yesterdayCheckInDay.failed - 317) others pressed this button today.",
                "\(Int.random(in: 63...91))% were able to fight it off and continue their journey.",
                "Try some of the exercises below."
            ]
        ]
    }
    
    @State var reasons = ["Take a 10 minute walk", "20 pushups right now", "20 situps right now.", "20 squats right now.", "Take a cold shower.", "30 deep inhales through the nose, exhales through the mouth.", "Listen to your lock-in song.", "Waking up tomorrow is gonna be exhausting.", "What would your ideal self do right now?.", "Think about someone you look up to.", "Simulate in detail what will happen after you relapse today/tomorrow"]

    // Adjust typing speed here (seconds per character)
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: "gender_bg")!)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            ScrollView(showsIndicators: false) {
                VStack {
                    Text(typedTitle)
                        .overusedFont(weight: .semiBold, size: .h1)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(height: 150, alignment: .center)
                        .padding(.vertical)
                        .contentTransition(.identity)
                        .transaction { transaction in
                            transaction.animation = nil
                            transaction.disablesAnimations = true
                        }
                        .padding(.top, 48)
                        .padding(.horizontal)
                    
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
                    
                    // checklist
                    if showCard {
                        VStack {
                            VStack(alignment: .center, spacing: 20) {
                                
                                Image(systemName: "hand.raised")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                                    .padding(.top, 12)
                                Text("Science-backed exercises")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                Text("Before you decide to give-in. Try a couple of exercises below.")
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 12)
                                    .foregroundColor(.white)
                                                                                                                         
                                Text("lock-in king.")
                                    .sfFont(weight: .semibold, size: .h3p1)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("In no specific order: ")
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.white)
                                        .sfFont(weight: .semibold, size: .h3p1)
                                        .padding(.top)
                                    //
                                    ForEach(reasons, id: \.self) { reason in
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 28)
                                                .foregroundColor(Color.white)
                                                .padding(.trailing)
                                            Text(reason)
                                                .sfFont(weight: .medium, size: .h3p1)
                                                .foregroundColor(Color.white)
                                            
                                        }.padding(.horizontal)
                                            .padding(.vertical, 8)
                                    }
                                    
                                
                                }.padding(.bottom, 12)
                            }.padding(16)
                        }.background(.black.opacity(0.5)).cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                            .padding(24)
                        if manager.remainingTime > 0 {
                            Text("Simply pausing for 2 minutes before giving-in can at the very least improve mindfulness, making future relapses harder.")
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .sfFont(weight: .semibold, size: .h3p1)
                                .padding(.horizontal, 28)
                                .padding(.top, 28)
                        }
//                        SharedComponents.HomeRelapsedButton(title: manager.remainingTime > 0 ? "\(manager.formattedTime) deep breath, lock-in." : "Block Apps Again", action: {
//    //                        isPresented = false
//                            Task {
//                              try await manager.requestAuthorization()
//                            }
//                            Analytics.shared.log(event: "HomeScreen: Tapped Panic")
//                            if manager.remainingTime > 0 {
//                                // display list of activities to do.
//                            } else {
//                                if manager.familyActivitySelection.categoryTokens.count > 0 || manager.familyActivitySelection.applicationTokens.count > 0  {
//                                    showPanicScreen = true
//                                    manager.shieldActivities()
//                                } else {
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
//                                            if success {
//                                                showActivityPicker = true
//                                            } else if let error {
//                                                print(error.localizedDescription)
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }, color: [Color(red: 0.63, green: 0.11, blue: 0.11), Color(red: 0.32, green: 0.12, blue: 0.12).opacity(0.14)])
//                        .padding(.horizontal, 28)
//                        .padding(.vertical)
                        
                        SharedComponents.HomeRelapsedButton(title: "I wanna reflect", action: {
                            showPanicScreen = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                Analytics.shared.log(event: "PanicTypingScreen: Tapped Reflect")
                                showPlusModal = false
                                reflectionVM.showWriteReflection = true
                            }
                        }, color: [Color(red: 0.44, green: 0.45, blue: 1), Color(red: 0.1, green: 0.13, blue: 0.81)])
                        .padding(.horizontal, 28)
                        SharedComponents.HomeRelapsedButton(title: "AI Coach", action: {
                            Analytics.shared.log(event: "PanicTypingScreen: Tapped AI Coach")
                            showPanicScreen = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showPlusModal = false
                                homeVM.showChat = true
                            }

                        }, color: [Color(red: 0.14, green: 0.9, blue: 0.73), Color(red: 0.08, green: 0.31, blue: 0.26).opacity(0.14)])
                        .padding(.horizontal, 28)
                        .padding(.vertical)
                        SharedComponents.PrimaryButton(title: "I'm good now") {
                            Analytics.shared.log(event: "PanicTypingScreen: Tapped I'm Good")
                            showPanicScreen = false
                            showPlusModal = false
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 20)
                        .padding(.bottom, 84)

                    }
                    Spacer()
                    
                }
            }
            if showCard {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .frame(width: 24)
                    .padding()
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation {
                            showPanicScreen = false
                        }
                    }
                    .position(x: UIScreen.main.bounds.width - 36, y: 84)
            }
           
        }
        .familyActivityPicker(
            isPresented: $showActivityPicker,
            selection: $manager.familyActivitySelection
        )
        .onChange(of: manager.familyActivitySelection) {
            manager.shieldActivities()
//            showPanicScreen = true
//            setupDeviceActivitySchedule()
//            startScheduledShielding()
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

          
        if mainVM.currUser.religion == "Christian" {
            randNum = Int.random(in: 0..<christianSentences.count)
        }
    }
    
 private func typeNextCharacter() {
    // If we've finished all sentences, stop entirely
    if mainVM.currUser.religion == "Christian" {
        let safeRandNum = min(randNum, christianSentences.count - 1)
        guard currentSentenceIndex < christianSentences[safeRandNum].count else {
            isAnimating = false
            return
        }
        
        // If we're currently paused between sentences, do nothing
        guard !isPaused else { return }
        
        let sentence = christianSentences[safeRandNum][currentSentenceIndex]
        
        // If we still have characters to type in the current sentence
        if indexInSentence < sentence.count {
            let nextChar = sentence[sentence.index(sentence.startIndex, offsetBy: indexInSentence)]
            typedTitle.append(nextChar)
            indexInSentence += 1
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } else {
            // We just finished this entire sentence, so pause
            isPaused = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.currentSentenceIndex += 1
                if self.currentSentenceIndex < christianSentences[safeRandNum].count {
                    self.typedTitle = ""
                    self.indexInSentence = 0
                    self.isPaused = false
                } else {
                    self.isAnimating = false
                }
            }
        }
    } else {
        // Regular sentences logic
        guard currentSentenceIndex < sentences.count else {
            isAnimating = false
            return
        }
        
        guard !isPaused else { return }
        
        let sentence = sentences[currentSentenceIndex]
        if indexInSentence < sentence.count {
            let nextChar = sentence[sentence.index(sentence.startIndex, offsetBy: indexInSentence)]
            typedTitle.append(nextChar)
            indexInSentence += 1
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } else {
            isPaused = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.currentSentenceIndex += 1
                if self.currentSentenceIndex < self.sentences.count {
                    self.typedTitle = ""
                    self.indexInSentence = 0
                    self.isPaused = false
                } else {
                    self.isAnimating = false
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

// Add this view to display the saved signature
struct SignatureDisplayView: UIViewRepresentable {
    let drawing: PKDrawing
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.isUserInteractionEnabled = false
        canvas.drawing = drawing
        canvas.backgroundColor = .clear
        return canvas
    }
    
    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        canvas.drawing = drawing
    }
}
