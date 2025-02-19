//
//  QuizScreen.swift
//  Resolved
//
//  Created by Dante Kim on 10/20/24.
//

import SwiftUI

struct QuizScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @State private var animateContent = false // State variable for animations

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 12) {
                // Title Text
                Text("Let’s understand how bad your addiction to porn is.")
                    .overusedFont(weight: .semiBold, size: .h1)
                    .foregroundColor(.white)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5), value: animateContent)

                // Subtitle Text
                SharedComponents.CustomSubtitleText(
                    title: "Using your answers, we will then craft the perfect plan to help you quit forever.\n\nAll your data is encrypted.",
                    color: .white
                )
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.1), value: animateContent)

                Spacer()
                Spacer()
                Spacer()
                Spacer()

                // Start Quiz Button
                SharedComponents.PrimaryButton(title: "Start Quiz") {
                    mainVM.onboardingScreen = .gender
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: animateContent)

                Spacer()
            }
            .padding()
            .padding(.horizontal)
            .onAppear {
                animateContent = true // Trigger animations when view appears
            }
            .onAppearAnalytics(event: "QuizScreen: Screenload")
        }
    }
}

#Preview {
    QuizScreen()
}

struct
GoodNews: View {
    @EnvironmentObject var mainVM: MainViewModel
    @State private var animateContent = false // State variable for animations

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 12) {
                // Title Text
                Text("Good news. All of these symptoms can be reversed. ")
                    .overusedFont(weight: .semiBold, size: .h1)
                    .foregroundColor(.white)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.75), value: animateContent)
                    .padding(.horizontal)
                HStack {
                    Spacer()
                    VStack(alignment: .center) {
                        LottieView(loopMode: .loop, animation: "calendar", isVisible: .constant(true))
                            .frame(width: 800)
                    }.frame(width: 300, alignment: .center)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 12 : 32)
                        .animation(.easeOut(duration: 0.5).delay(0.5), value: animateContent)
                    Spacer()

                }.offset(x: 16, y: -64)

                // Subtitle Text
//                SharedComponents.CustomSubtitleText(
//                    title: "Using these answers, we will then craft a unique, personal plan to help you quit forever",
//                    color: .white
//                )
//                .opacity(animateContent ? 1 : 0)
//                .offset(y: animateContent ? 0 : 20)
//                .animation(.easeOut(duration: 0.5).delay(0.1), value: animateContent)

                // Start Quiz Button
                SharedComponents.PrimaryButton(title: "Define Motivations") {
                    mainVM.optionType = .motivation
                    mainVM.onboardingScreen = .options
                }
                .padding(.horizontal)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 12 : 32)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: animateContent)
                .offset(y: -96)
                Spacer()
            }
            .padding()
            .onAppear {
                animateContent = true // Trigger animations when view appears
            }
            .onAppearAnalytics(event: "GoodNews: Screenload")
        }
    }
}
