//
//  HowOftenScreen.swift
//  Resolved
//
//  Created by Dante Kim on 7/19/24.
//

import SwiftUI

struct HowOftenScreen: View {
    @Binding var frequency: String
    @EnvironmentObject var mainVM: MainViewModel
    @State private var animateContent = false

    let options = ["3+ times a day", "Twice a day", "Once a day", "A few times a week", "Less than once a week"]

    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: "gender_bg")!)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 32) {
                // Animate the title
                SharedComponents.CustomBoldHeading(title: "How often do you watch porn?", color: .white)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5), value: animateContent)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                frequency = option
                                mainVM.currUser.howOften = option
                                Analytics.shared.logActual(event: "HowOftenScreen: Tapped Continue", parameters: ["frequency": option])
                                withAnimation {
                                    mainVM.onboardingProgress += 0.08
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
    }
}

#Preview {
    HowOftenScreen(frequency: .constant(""))
        .environmentObject(MainViewModel())
}

// struct HowOftenScreen: View {
//    @Binding var frequency: String
//    @EnvironmentObject var mainVM: MainViewModel
//
//    let options = ["3+ times a day", "Twice a day", "Once a day", "A few times a week", "Less than once a week"]
//
//    var body: some View {
//        ZStack {
//            Color.primaryBackground.edgesIgnoringSafeArea(.all)
//            GeometryReader { g in
//                VStack(alignment: .leading, spacing: 12) {
//                    (Text("How ")
//                        .foregroundStyle(Color.white)
//                        + Text("often ")
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
//                                frequency = option
//                                Analytics.shared.logActual(event: "HowOftenScreen: Tapped Continue", parameters: ["frequency": option])
//                                 withAnimation {
//                                     mainVM.onboardingProgress += 0.15
//                                     mainVM.onboardingScreen = .duration
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
//                   Spacer()
//
//                }
//                .padding()
//            }
//        }.onAppearAnalytics(event: "RelapseReasonScreen: Screenload")
//
//    }
// }
//
// #Preview {
//    HowOftenScreen(frequency: .constant(""))
//        .environmentObject(MainViewModel())
// }
