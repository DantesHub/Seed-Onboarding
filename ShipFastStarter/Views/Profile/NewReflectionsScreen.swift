//
//  NewReflectionsScreen.swift
//  Resolved
//
//  Created by Gursewak Singh on 11/10/24.
//

import SuperwallKit
import SwiftData
import SwiftUI

struct NewReflectionsScreen: View {
    @StateObject private var recorderManager = VoiceRecorderManager() // Recording manager
    @EnvironmentObject var viewModel: ReflectionsViewModel
    @Environment(\.modelContext) var modelContext
    @State var userInput: String = ""
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @Query var user: [User]
    @State private var noteType: NoteType = .thought
    @State private var motivationalNotes: [String: String] = [:]
    @State private var thoughtNotes: [String: String] = [:]
    @State private var triggerNotes: [String: String] = [:]
    @State private var allNotes: [String: [String: String]] = [:]
    @State private var sortedNotes: [(date: String, category: String, text: String)] = []
    @State private var selectedGroup: NoteGroup = .thoughts
    @State private var notesCount = 0

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

    @Query private var sessionHistory: [SoberInterval]
    @FocusState private var isTextEditorFocused: Bool
    @State private var showAllNotes = false // Add this to access presentation mode

    var body: some View {
        NavigationView {
            ZStack {
                Image(.justBackground)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                VStack {
          
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            
                            if sortedNotes.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Spacer()
                                        SharedComponents.CustomMediumSmallMediumText(title: "No reflections yet", color: Color(hex: "#64A2FF"))
                                            .padding(.top)
                                        Spacer()
                                    }

                                    Text("Quitting porn is a science experiment. Gather your findings, observations, and thoughts here.")
                                        .overusedFont(weight: .medium, size: .h3p1)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .transition(.opacity) // Use transition for fading
                                        .truncationMode(.tail)
                                        .padding(.leading)
                                        .padding(.trailing)
                                        .padding(.bottom)
                                        .cornerRadius(10)

                                }.padding(.bottom)
                                    .background(
                                        SharedComponents.clearShadow
                                    )
                                    .padding(.leading)
                                    .padding(.trailing)
                                    .padding(.top)

                                if !UserDefaults.standard.bool(forKey: "tappedCommunity") {
                                    DiscordCard()
                                        .environmentObject(mainVM)
                                }
                            } else {
                                ForEach(sortedNotes, id: \.date) { note in
                                    if let date = Date.fromString(note.date) {
                                        let reflection =
                                            Reflection(reflectionText: note.text, duration: "", date: date, category: note.category, is_audio_available: true)
                                        NavigationLink(destination: NewReflectionDetailScreen(reflection: reflection, date: note.date)) {
                                            ReflectionCardView(reflection: reflection)
//                                                .onTapGesture {
//                                                    if let url =  recorderManager.getRecordingIfExists(with: reflection.date.toString()) {
//                                                        recorderManager.playRecording(url: url)
//                                                    }
//                                                }
                                        }
                                    }
                                }
                            }
                        }.padding(.bottom, 96)
                    }.padding(.top, 48)
                }
                .padding(.top, 10)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadNotes()

            //            updateNotes()
            //
            //            for session in sessionHistory {
            //                notesCount += session.motivationalNotes.count
            //                notesCount += session.thoughtNotes.count
            //                notesCount += session.lapseNotes.count
            //            }
        }
        .onChange(of: viewModel.showWriteReflection) {
            updateNotes()
        }
    }

//    func updateNotes() {
//        allNotes = [:]
//        for session in sessionHistory {
//            updateNotesForCategory("Thoughts", notes: session.thoughtNotes)
//            updateNotesForCategory("Motivations", notes: session.motivationalNotes)
//            updateNotesForCategory("Triggers", notes: session.lapseNotes)
//        }
//
//        sortedNotes = allNotes.flatMap { (category, notes) in
//            notes.map { (date, text) in
//                (date: date, category: category, text: text)
//            }
//        }.sorted { $0.date > $1.date }
//    }

    private func loadNotes() {
        DispatchQueue.global(qos: .userInitiated).async {
            updateNotes()
            DispatchQueue.main.async {
                for session in sessionHistory {
                    notesCount += session.motivationalNotes.count
                    notesCount += session.thoughtNotes.count
                    notesCount += session.lapseNotes.count
                }
            }

            if !mainVM.currUser.rewards.keys.contains("earth") && notesCount >= 50 {
                Analytics.shared.log(event: "UnlockedReward: Earth Notes Screen")
                mainVM.currUser.rewards["earth"] = Date().toString()
                mainVM.currUser.currentOrb = "earth"
                homeVM.selectedOrb = (Orb.getOrb(forName: "earth"), OrbSize.extraLarge)
                DataManager.shared.saveContext(context: modelContext)
                homeVM.showEvolution = true
            }
        }
    }

    func updateNotes() {
        allNotes = [:]
        for session in sessionHistory {
            updateNotesForCategory("Thoughts", notes: session.thoughtNotes)
            updateNotesForCategory("Motivations", notes: session.motivationalNotes)
            updateNotesForCategory("Triggers", notes: session.lapseNotes)
        }

        print("All notes count: \(allNotes.count)")
        for (category, notes) in allNotes {
            print("Category: \(category), Notes count: \(notes.count)")
        }

        sortedNotes = allNotes.flatMap { category, notes in
            notes.compactMap { date, text -> (date: String, category: String, text: String)? in
                print("Processing date: \(date) for category: \(category)")
                return (date: date, category: category, text: text)
            }
        }.sorted {
            guard let date1 = Date.fromString($0.date), let date2 = Date.fromString($1.date) else {
                print("Failed to parse dates: \($0.date) or \($1.date)")
                return false
            }
            return date1 > date2
        }

        print("Sorted notes count: \(sortedNotes.count)")
        for note in sortedNotes.prefix(5) {
            print("Sorted note: Date: \(note.date), Category: \(note.category)")
        }
    }

    private func updateNotesForCategory(_ category: String, notes: [String: String]) {
        if allNotes[category] == nil {
            allNotes[category] = [:]
        }
        allNotes[category]?.merge(notes) { _, new in new }
        print("Updated \(category) with \(notes.count) notes")
    }

    // Helper function to format dates
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

struct ReflectionCardView: View {
    let reflection: Reflection
    let speechManager = SpeechManager()
    @State private var isSpeaking: Bool = false

    @State private var utteranceRate: Float = 0.5

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                SharedComponents.CustomMediumSmallMediumText(title: reflection.date.toString(format: "MMM, dd h:mm a"), color: Color(hex: "#64A2FF"))
                    .padding(.top)
                    .padding(.leading)
                Spacer()
                Text("\(reflection.category)")
                    .font(FontManager.overUsedGrotesk(type: .bold, size: .p3))
                    .foregroundColor(reflection.category == "Triggers" ? .red : .blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(reflection.category == "Triggers" ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.top)
                    .padding(.trailing)
            }

            Text(reflection.reflectionText)
                .overusedFont(weight: .medium, size: .h3p1)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .transition(.opacity) // Use transition for fading
                .animation(.easeInOut(duration: 0.5), value: reflection.reflectionText)
                .lineLimit(3)
                .truncationMode(.tail)
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom)
                .cornerRadius(10)

        }.padding(.bottom)
            .background(
                SharedComponents.clearShadow
            )
            .padding(.leading)
            .padding(.trailing)
            .padding(.top)
    }
}

#Preview {
    NewReflectionsScreen()
}

struct Reflection: Identifiable {
    let id = UUID()
    let reflectionText: String
    let duration: String
    let date: Date
    let category: String
    let is_audio_available: Bool
}

class ReflectionsViewModel: ObservableObject {
    @Published var reflections: [Reflection] = [
        Reflection(reflectionText: "I am making this effort because it holds significant importance for me, and I need to be as resilient as possible, or I am in serious trouble bludski", duration: "03:24", date: Date(), category: "Motivation", is_audio_available: false), // Yesterday
        Reflection(reflectionText: "Today, I am embracing this effort wholeheartedly because it is crucial...", duration: "03:24", date: Date(), category: "Motivation", is_audio_available: true), // Today
    ]

    @Published var showWriteReflection = false
}

struct ReflectionPlayerView: View {
    let duration: Double
    let text: String
    @State private var currentTime: Double = 0.0 // Start at 0
    @State private var isPlaying: Bool = false
    var playAction: () -> Void
    @State private var timer: Timer? // Manage a timer for progress updates
    let manager = SpeechManager()
    var body: some View {
        HStack(spacing: 20) {
            // Rewind 15 seconds button
            Button(action: {
                rewind15()
            }) {
                Image(systemName: "gobackward.15")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 13, height: 13)
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
                    .frame(width: 13, height: 15)
                    .foregroundColor(.gray)
            }

            // Forward 15 seconds button
            Button(action: {
                forward15()
            }) {
                Image(systemName: "goforward.15")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 13, height: 13)
                    .foregroundColor(.gray)
            }

            // ProgressView for audio progress
            ProgressView(value: currentTime, total: duration)
                .accentColor(.white)
                .frame(height: 5)
                .foregroundColor(.white.opacity(0.25))

            // Current time / Duration label
            SharedComponents.customVerySmallMediumText(title: timeFormatted(currentTime) + " / " + timeFormatted(duration), color: .white)
        }
        .padding(.bottom, 12)
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
        currentTime = max(currentTime - 15, 0)
    }

    // Function to forward 15 seconds
    func forward15() {
        currentTime = min(currentTime + 15, duration)
    }
}

/*
 struct NewReflectionsScreen: View {
     @EnvironmentObject var viewModel: ReflectionsViewModel
     @Environment(\.modelContext) var modelContext
     @State var userInput: String = ""
     @EnvironmentObject var mainVM: MainViewModel
     @EnvironmentObject var homeVM: HomeViewModel
     @Query var user: [User]
     @State private var noteType: NoteType = .thought
     @State private var motivationalNotes: [String: String] = [:]
     @State private var thoughtNotes: [String: String] = [:]
     @State private var triggerNotes: [String: String] = [:]
     @State private var allNotes: [String: [String: String]] = [:]
     @State private var sortedNotes: [(date: String, category: String, text: String)] = []
     @State private var selectedGroup: NoteGroup = .thoughts
     @State private var notesCount = 0

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

     @Query private var sessionHistory: [SoberInterval]
     @FocusState private var isTextEditorFocused: Bool
     @State private var showAllNotes = false// Add this to access presentation mode

     var body: some View {
         NavigationView {

             ZStack {
                 Image(.justBackground)
                     .resizable()
                     .scaledToFill()
                     .edgesIgnoringSafeArea(.all)
                 VStack {
                     HStack {
                         NavigationLink(destination: LetsCommitScreen()) {

                             Text("Reflections")
                                 .overusedFont(weight: .semiBold, size: .h1Big)
                                 .foregroundColor(.white)
                                 .frame(maxWidth: .infinity, alignment: .leading)
                                 .padding(.horizontal, 12)
                         }
                         Spacer()
                         Button(action: {
                             // Menu button action
                             UIImpactFeedbackGenerator(style: .light).impactOccurred()
                             Analytics.shared.log(event: "ReflectionsScreen: Tapped Plus")
                             withAnimation {
                                 if !mainVM.currUser.isPro && notesCount > 0 {
                                     mainVM.showPricing = true
                                 } else {
                                     viewModel.showWriteReflection = true
                                 }
                             }
                         }) {
                             Image(systemName: "plus.circle.fill")
                                 .overusedFont(weight: .semiBold, size: .h2)
                                 .foregroundColor(.primaryBlue)
                         }
                     }
                     .safeAreaPadding(.top)
                     .padding()
                     // Scrollable reflections list
                     ScrollView {
                         VStack(alignment: .leading, spacing: 8) {
                             if sortedNotes.isEmpty {
                                 Text("No reflections yet")
                                     .foregroundColor(.white)
                                     .padding()
                             } else {
                                 ForEach(sortedNotes, id: \.date) { note in
                                     if let date = Date.fromString(note.date) {
                                         let reflection = Reflection(reflectionText: note.text, duration: "", date: date, category: note.category, is_audio_available: false)
                                         NavigationLink(destination: NewReflectionDetailScreen(reflection: reflection, date: note.date)) {
                                             ReflectionCardView(reflection: reflection)
                                         }

                                         .simultaneousGesture(TapGesture().onEnded {
                                             UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                             Analytics.shared.log(event: "ReflectionsScreen: Tapped Reflection")
                                         })
                                     }
                                 }
                             }
                         }.padding(.bottom, 96)
                     }
                 }
                 .padding(.top, 10)
             }
         }
         .navigationBarHidden(true)
         .onAppear {
             updateNotes()

             for session in sessionHistory {
                 notesCount += session.motivationalNotes.count
                 notesCount += session.thoughtNotes.count
                 notesCount += session.lapseNotes.count
             }
         }
         .onChange(of: viewModel.showWriteReflection) {
             updateNotes()
         }
     }

     func updateNotes() {
         allNotes = [:]
         for session in sessionHistory {
             updateNotesForCategory("Thoughts", notes: session.thoughtNotes)
             updateNotesForCategory("Motivations", notes: session.motivationalNotes)
             updateNotesForCategory("Triggers", notes: session.lapseNotes)
         }

         sortedNotes = allNotes.flatMap { (category, notes) in
             notes.map { (date, text) in
                 (date: date, category: category, text: text)
             }
         }.sorted { $0.date > $1.date }
     }

     private func updateNotesForCategory(_ category: String, notes: [String: String]) {
         if allNotes[category] == nil {
             allNotes[category] = [:]
         }
         allNotes[category]?.merge(notes) { (_, new) in new }
     }

     // Helper function to format dates
     func formattedDate(_ date: Date) -> String {
         let formatter = DateFormatter()
         formatter.dateStyle = .full
         return formatter.string(from: date)
     }
 }

 struct ReflectionCardView: View {
     let reflection: Reflection
     let speechManager = SpeechManager()
     @State private var isSpeaking: Bool = false

     @State private var utteranceRate: Float = 0.5

     var body: some View {
         VStack(alignment: .leading, spacing: 8) {
             HStack {
                 SharedComponents.CustomMediumSmallMediumText(title: reflection.date.toString(format: "MMM, dd h:mm a"), color: Color(hex: "#64A2FF"))
                     .padding(.top)
                     .padding(.leading)
                 Spacer()
                 Text("\(reflection.category)")
                     .font(FontManager.overUsedGrotesk(type: .bold, size: .p3))
                     .foregroundColor(reflection.category == "Triggers" ? .red : .blue)
                     .padding(.horizontal, 8)
                     .padding(.vertical, 4)
                     .background(reflection.category == "Triggers" ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                     .cornerRadius(12)
                     .padding(.top)
                     .padding(.trailing)
             }

             Text(reflection.reflectionText)
                 .overusedFont(weight: .medium, size: .h3p1)
                 .foregroundColor(.white)
                 .multilineTextAlignment(.center)
                 .transition(.opacity) // Use transition for fading
                 .animation(.easeInOut(duration: 0.5), value: reflection.reflectionText)
                 .lineLimit(3)
                 .truncationMode(.tail)
                 .padding(.leading)
                 .padding(.trailing)
                 .padding(.bottom)
                 .cornerRadius(10)

         }.padding(.bottom)
         .background(
             SharedComponents.clearShadow
         )
         .padding(.leading)
         .padding(.trailing)
         .padding(.top)
     }

 }
     #Preview {
         NewReflectionsScreen()
     }

     struct Reflection: Identifiable {
         let id = UUID()
         let reflectionText: String
         let duration: String
         let date: Date
         let category: String
         let is_audio_available: Bool
     }

     class ReflectionsViewModel: ObservableObject {
         @Published var reflections: [Reflection] = [
             Reflection(reflectionText: "I am making this effort because it holds significant importance for me, and I need to be as resilient as possible, or I am in serious trouble bludski", duration: "03:24", date: Date(), category: "Motivation", is_audio_available: false), // Yesterday
             Reflection(reflectionText: "Today, I am embracing this effort wholeheartedly because it is crucial...", duration: "03:24", date: Date(), category: "Motivation", is_audio_available: true) // Today

         ]

         @Published var showWriteReflection = false
     }

 struct ReflectionPlayerView: View {
     let duration: Double
     let text: String
     @State private var currentTime: Double = 0.0 // Start at 0
     @State private var isPlaying: Bool = false
     var playAction: () -> Void
     @State private var timer: Timer? // Manage a timer for progress updates
     let manager = SpeechManager()
     var body: some View {
         HStack(spacing: 20) {
             // Rewind 15 seconds button
             Button(action: {
                 rewind15()
             }) {
                 Image(systemName: "gobackward.15")
                     .resizable()
                     .scaledToFit()
                     .frame(width: 13, height: 13)
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
                     .frame(width: 13, height: 15)
                     .foregroundColor(.gray)
             }

             // Forward 15 seconds button
             Button(action: {
                 forward15()
             }) {
                 Image(systemName: "goforward.15")
                     .resizable()
                     .scaledToFit()
                     .frame(width: 13, height: 13)
                     .foregroundColor(.gray)
             }

             // ProgressView for audio progress
             ProgressView(value: currentTime, total: duration)
                 .accentColor(.white)
                 .frame(height: 5)
                 .foregroundColor(.white.opacity(0.25))

             // Current time / Duration label
             SharedComponents.customVerySmallMediumText(title: (timeFormatted(currentTime) + " / " + timeFormatted(duration)), color: .white)
         }
         .padding(.bottom, 12)
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
         currentTime = max(currentTime - 15, 0)
     }

     // Function to forward 15 seconds
     func forward15() {
         currentTime = min(currentTime + 15, duration)
     }
 }

 */
