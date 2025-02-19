//
//  HowLongHaveScreen.swift
//  Resolved
//
//  Created by Gursewak Singh on 03/10/24.
//

import SwiftUI

struct HowLongHaveScreen: View {
    @Binding var frequency: String
    @EnvironmentObject var mainVM: MainViewModel
    @State private var animateContent = false
    let options = ["1 year or less", "1-3 years", "3-5 years", "5-10 years", "10 years +"]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            //
            VStack(spacing: 32) {
                // Animate the title
                SharedComponents.CustomBoldHeading(title: "How long have you been struggling with porn?", color: .white)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5), value: animateContent)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                    let minsSavedPerDay = calculateTimeSavedPerDay(frequency: frequency, duration: option)
//                                    mainVM.currUser.minsSavedPerDay = minsSavedPerDay
//                                    DataManager.shared.saveContext(context: modelContext)
                                Analytics.shared.logActual(event: "HowLongScreen: Tapped Continue", parameters: ["length": option])
                                withAnimation {
                                    mainVM.onboardingProgress += 0.125
                                    mainVM.onboardingScreen = .duration
                                }
                            }) {
                                SharedComponents.OnboardVoteOption(title: option, height: 80)
                                    .opacity(animateContent ? 1 : 0)
                                    .offset(y: animateContent ? 0 : 20)
                                    .animation(.easeOut(duration: 0.5).delay(0.1 * Double(options.firstIndex(of: option)! + 1)), value: animateContent)
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
            animateContent = true
        }
        .onAppearAnalytics(event: "RelapseReasonScreen: Screenload")
        .navigationBarHidden(true)
    }

    func calculateTimeSavedPerDay(frequency: String, duration: String) -> Double {
        let frequencyMap: [String: Double] = [
            "3+ times a day": 3.5,
            "Twice a day": 2.0,
            "Once a day": 1.0,
            "A few times a week": 0.5,
            "Less than once a week": 0.14,
        ]

        let durationMap: [String: Double] = [
            "less than 5 minutes": 2.5,
            "About 10-20  minutes": 15.0,
            "30 minutes": 30.0,
            "30-60 minutes": 45.0,
            "1-2 hours": 90.0,
            "2+ hours": 150.0,
        ]

        guard let timesPerDay = frequencyMap[frequency],
              let minutesPerSession = durationMap[duration]
        else {
            return 0.0
        }

        let minutesSavedPerDay = timesPerDay * minutesPerSession
        return minutesSavedPerDay
    }
}

#Preview {
    HowLongHaveScreen(frequency: .constant(""))
        .environmentObject(MainViewModel())
}
