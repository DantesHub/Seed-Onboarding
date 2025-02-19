//
//  AgeScreen.swift
//  Resolved
//
//  Created by Dante Kim on 7/19/24.
//

import SwiftUI

enum AgeQuestion: String {
    case when = "When did you start watching porn?"
    case active = "How old were you when you first became sexually active?"
    case age = "What is your age range?"

    func name() -> String {
        switch self {
        case .when:
            return "whenStarted"
        case .active:
            return "whenFirstActive"
        case .age:
            return "ageRange"
        }
    }
}

struct WhenStartScreen: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var mainVM: MainViewModel
    @Binding var ageQuestion: AgeQuestion

    let options = ["Before 13", "14-17", "18-24", "25-30", "35-40", "40+"]

    @State private var animateContent = false // State variable for animations

    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: "gender_bg")!)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Centered text and options
                VStack(spacing: 32) {
                    VStack(spacing: 12) {
                        SharedComponents.CustomBoldHeading(title: ageQuestion.rawValue, color: .white)
                            .animation(nil)
//                            .opacity(animateContent ? 1 : 0)
//                            .offset(y: animateContent ? 0 : 20)
//                            .animation(Animation.easeOut(duration: 0.5).delay(0.1), value: animateContent)
                    }
                    .frame(height: 120)
                    .padding(.top, 16)
                    .padding(.horizontal, 12)

                    ScrollView {
                        // Options buttons
                        VStack(alignment: .leading, spacing: 24) {
                            ForEach(Array(options.enumerated()), id: \.1) { index, option in
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    tappedAgeQuestion(range: option)
                                }) {
                                    SharedComponents.OnboardVoteOption(title: option, height: 64)
                                }
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(Animation.easeOut(duration: 0.5).delay(0.2 + Double(index) * 0.1), value: animateContent)
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
                animateContent = true
            }
        }
        .onAppearAnalytics(event: "RelapseReasonScreen: Screenload")
    }

    func tappedAgeQuestion(range: String) {
        // Reset animation state
//        animateContent = false
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            animateContent = true
//        }

        mainVM.currUser.onboardingQuestions[ageQuestion.name()] = range
        DataManager.shared.saveContext(context: modelContext)
        withAnimation {
            mainVM.onboardingProgress += 0.08
            switch ageQuestion {
            case .when:
                Analytics.shared.logActual(event: "WhenStarted: Tapped Option", parameters: ["age": range])
                ageQuestion = .active
            case .active:
                Analytics.shared.logActual(event: "WhenActive: Tapped Option", parameters: ["age": range])
                mainVM.onboardingScreen = .yesNo
            case .age:
                mainVM.currUser.age = range
                Analytics.shared.logActual(event: "AgeScreen: Tapped Option", parameters: ["age": range])
                ageQuestion = .when
            }
        }
    }
}
