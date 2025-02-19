//
//  HowLongScreen.swift
//  Resolved
//
//  Created by Dante Kim on 7/19/24.
//

import SwiftUI

struct HowLongScreen: View {
    @Binding var frequency: String
    @EnvironmentObject var mainVM: MainViewModel
    @State private var animateContent = false
    let options = ["less than 5 minutes", "About 10-20 minutes", "30 minutes", "30-60 minutes", "1-2 hours", "2+ hours"]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: "gender_bg")!)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 32) {
                // Animate the title
                SharedComponents.CustomBoldHeading(title: "How long do you typically spend watching porn in one session?", color: .white)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5), value: animateContent)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                let minsSavedPerDay = calculateTimeSavedPerDay(frequency: frequency, duration: option)
                                mainVM.currUser.minsSavedPerDay = minsSavedPerDay
                                DataManager.shared.saveContext(context: modelContext)
                                Analytics.shared.logActual(event: "HowLongScreen: Tapped Continue", parameters: ["length": option])
                                mainVM.calculateTimeSaved()
                                withAnimation {
                                    mainVM.onboardingProgress += 0.08
                                    mainVM.onboardingScreen = .when
                                }
                            }) {
                                SharedComponents.OnboardVoteOption(title: option, height: 64)
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
        .onAppearAnalytics(event: "HowLongScreen: Screenload")
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
            "About 10-20 minutes": 15.0,
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
    HowLongScreen(frequency: .constant(""))
        .environmentObject(MainViewModel())
}

//
// struct HowLongScreen: View {
//    @Binding var frequency: String
//    @EnvironmentObject var mainVM: MainViewModel{
//    let options = ["less than 5 minutes", "About 10-20  minutes", "30 minutes", "30-60 minutes", "1-2 hours", "2+ hours"]
//    @Environment(\.modelContext) private var modelContext
//
//    var body: some View {
//        ZStack {
//            Color.primaryBackground.edgesIgnoringSafeArea(.all)
//            GeometryReader { g in
//                VStack(alignment: .leading, spacing: 12) {
//                    (Text("How ")
//                        .foregroundStyle(Color.white)
//                        + Text("long ")
//                        .foregroundStyle(Color.primaryPurple)
//                     + Text("do you view porn?")
//                        .foregroundStyle(Color.white)
//                    ).sfFont(weight: .bold, size: .h2)
//                    .padding(.horizontal)
//                    Text("This should be an average")
//                        .foregroundStyle(Color.primaryForeground)
//                        .sfFont(weight: .medium, size: .h3p1)
//                        .padding(.horizontal)
//                        .padding(.bottom)
//                    VStack(alignment: .leading, spacing: 24) {
//                        ForEach(options, id: \.self) { option in
//                            Button(action: {
//                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                let minsSavedPerDay = calculateTimeSavedPerDay(frequency: frequency, duration: option)
//                                mainVM.currUser.minsSavedPerDay = minsSavedPerDay
//                                DataManager.shared.saveContext(context: modelContext)
//                                Analytics.shared.logActual(event: "HowLongScreen: Tapped Continue", parameters: ["length": option])
//                                 withAnimation {
//                                     mainVM.onboardingProgress += 0.15
//                                 mainVM.onboardingScreen = .lastRelapse
//                                }
//                            }) {
//                                Text(option)
//                                    .foregroundColor(.white)
//                                    .frame(maxWidth: .infinity)
//                                    .frame(height: 64)
//                                    .background(Color.secondaryBackground)
//                                    .cornerRadius(16)
//
//                                    .sfFont(weight: .semibold, size: .h3p1)
//                            }
//                        }
//                    }
//
//                            Spacer()
//
//
//                }
//                .padding()
//            }
//        }.onAppearAnalytics(event: "RelapseReasonScreen: Screenload")
//    }
//
//
//    func calculateTimeSavedPerDay(frequency: String, duration: String) -> Double {
//        let frequencyMap: [String: Double] = [
//            "3+ times a day": 3.5,
//            "Twice a day": 2.0,
//            "Once a day": 1.0,
//            "A few times a week": 0.5,
//            "Less than once a week": 0.14
//        ]
//
//        let durationMap: [String: Double] = [
//            "less than 5 minutes": 2.5,
//            "About 10-20  minutes": 15.0,
//            "30 minutes": 30.0,
//            "30-60 minutes": 45.0,
//            "1-2 hours": 90.0,
//            "2+ hours": 150.0
//        ]
//
//        guard let timesPerDay = frequencyMap[frequency],
//              let minutesPerSession = durationMap[duration] else {
//            return 0.0
//        }
//
//        let minutesSavedPerDay = timesPerDay * minutesPerSession
//        return minutesSavedPerDay
//    }
//
// }
//
//
//
//
// #Preview {
//    HowLongScreen(frequency: .constant(""))
//        .environmentObject(MainViewModel())
// }
