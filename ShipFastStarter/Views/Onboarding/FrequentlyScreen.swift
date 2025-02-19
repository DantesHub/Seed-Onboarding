//
//  FrequentlyScreen.swift
//  Resolved
//
//  Created by Dante Kim on 7/19/24.
//

import SwiftUI

enum FrequencyPage: String {
    case arousal = "Do you find it challenging to experience arousal without using porn?"
    case escape = "Do you use porn to avoid or escape your feelings and problems or to alter your mood?"
    case restless = "Do you become restless, moody, or irritable when attempting to cut down or stop viewing porn?"
    case preoccupied = "How often do you find yourself thinking about porn?"
    case empty = "Do you feel empty or shameful after viewing porn and wish you could stop?"
    case promised = "Have you ever promised yourself that you would never watch porn again?"
    case lied = "Have you lied to your family members, friends, or others about your porn use?"
    case cope = "Do you use porn to cope with your emotional discomfort or pain?"
    case bored = "Do you find yourself watching porn when you’re bored?"

    func name() -> String {
        switch self {
        case .arousal:
            return "arousal"
        case .escape:
            return "escape"
        case .restless:
            return "restless"
        case .preoccupied:
            return "preoccupied"
        case .empty:
            return "empty"
        case .promised:
            return "promised"
        case .lied:
            return "lied"
        case .cope:
            return "cope"
        case .bored:
            return "bored"
        default:
            return ""
        }
    }
}

struct FrequentlyScreen: View {
    @Binding var frequency: FrequencyPage
    @EnvironmentObject var mainVM: MainViewModel
    @State private var animateContent = false // Add this line
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            ///
            ///

            VStack(spacing: 32) {
                // Centered text and options
                VStack(spacing: 12) {
                    // Animate the title
                    SharedComponents.CustomBoldHeading(title: frequency.rawValue, color: .white)
//                        .opacity(animateContent ? 1 : 0)
//                        .offset(y: animateContent ? 0 : 20)
//                        .animation(.easeOut(duration: 0.5), value: animateContent)
                        .frame(height: 175)
                        .padding(.horizontal, 4)
                }.padding(.top, 16)
                ScrollView {
                    // Gender options buttons
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(["Never", "Rarely", "Sometimes", "Often", "Always"], id: \.self) { option in
                            Button(action: {
                                DataManager.shared.saveContext(context: modelContext)
                                frequentlyTap(option: option)
                            }) {
                                SharedComponents.OnboardVoteOption(title: option, height: 64)
                                    .opacity(animateContent ? 1 : 0)
                                    .offset(y: animateContent ? 0 : 20)
                                    .animation(.easeOut(duration: 0.5).delay(0.1 * Double(["Never", "Rarely", "Sometimes", "Often", "Always"].firstIndex(of: option)! + 1)), value: animateContent)
                            }
                        }
                    }
                }
                Spacer()
                    .frame(height: 100)
            }
            .padding(.horizontal, 12)

            Spacer() // Pushes content up to center it
        }
        .onAppear {
            animateContent = true // Trigger animations when view appears
        }
        .onAppearAnalytics(event: "FrequentlyScreen: Screenload")
    }

    func frequentlyTap(option: String) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation {
            mainVM.onboardingProgress += 0.08
        }
        mainVM.currUser.onboardingQuestions[frequency.name()] = option
        DataManager.shared.saveContext(context: modelContext)

        switch frequency {
        case .arousal:
            Analytics.shared.logActual(event: "ArousalScreen    : Tapped Option", parameters: ["option": option])
            frequency = .escape
        case .escape:
            Analytics.shared.logActual(event: "EscapeScreen: Tapped Option", parameters: ["option": option])
            frequency = .restless
        case .restless:
            Analytics.shared.logActual(event: "RestlessScreen: Tapped Option", parameters: ["option": option])
            frequency = .preoccupied
        case .preoccupied:
            Analytics.shared.logActual(event: "PreoccupiedScreen: Tapped Option", parameters: ["option": option])
            frequency = .empty
        case .empty:
            Analytics.shared.logActual(event: "EmptyScreen: Tapped Option", parameters: ["option": option])
            frequency = .promised
        case .promised:
            Analytics.shared.logActual(event: "PromisedScreen: Tapped Option", parameters: ["option": option])
            frequency = .lied
        case .lied:
            Analytics.shared.logActual(event: "LiedScreen: Tapped Option", parameters: ["option": option])
            frequency = .cope
        case .cope:
            Analytics.shared.logActual(event: "CopeScreen: Tapped Option", parameters: ["option": option])
            mainVM.onboardingScreen = .haveQuittingBeforeScreen

        default:
            break
        }
    }
}

#Preview {
    FrequentlyScreen(frequency: .constant(.arousal))
        .environmentObject(MainViewModel())
}
