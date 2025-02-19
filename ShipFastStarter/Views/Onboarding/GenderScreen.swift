//
//  GenderScreen.swift
//  Resolved
//
//  Created by Dante Kim on 7/19/24.
//

import SwiftUI

struct GenderScreen: View {
    @State private var index = -1
    @State private var timer: Timer?
    let options = ["Male", "Female", "Non-binary"]

    @EnvironmentObject var mainVM: MainViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var progress: Double = 0.12 // Example initial progress value
    @Environment(\.dismiss) private var dismiss // Provides access to pop navigation
    @State private var navigateToReligionScreen = false // To trigger navigation

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
                    Spacer()
                        .frame(height: 12)

                    // Animate the title
                    SharedComponents.CustomBoldHeading(title: "What’s your gender?", color: .white)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5), value: animateContent)

                    ScrollView {
                        // Gender options buttons
                        VStack(alignment: .leading, spacing: 24) {
                            ForEach(Array(options.enumerated()), id: \.element) { idx, option in
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    Analytics.shared.logActual(event: "GenderScreen: Tapped Continue", parameters: ["gender": option])
                                    mainVM.currUser.gender = option
                                    DataManager.shared.saveContext(context: modelContext)
                                    withAnimation {
                                        mainVM.onboardingProgress += 0.08
                                        mainVM.onboardingScreen = .frequency
                                    }
                                }) {
                                    SharedComponents.OnboardVoteOption(title: option, height: 100)
                                        .opacity(animateContent ? 1 : 0)
                                        .offset(y: animateContent ? 0 : 20)
                                        .animation(.easeOut(duration: 0.5).delay(0.1 * Double(idx + 1)), value: animateContent)
                                }
                            }
                        }
                    }
                    Spacer()
                        .frame(height: 100)
                }
                .padding(.horizontal)

                Spacer() // Pushes content up to center it
            }
            .onAppear {
                animateContent = true // Trigger animations when view appears
            }
            .onAppearAnalytics(event: "GenderScreen: Screenload")
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    GenderScreen()
}
