//
//    ProblemScreen.swift
//  Resolved
//
//  Created by Dante Kim on 10/20/24.
//

import SwiftUI

struct ProblemScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @State var nextPage = false
    @State private var animateVStacks = false // State variable for animation
    @State private var showGraph = false

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 24) {
                if showGraph {
                    ProblemGraphScreen()
                } else {
                    // First VStack
                    VStack(alignment: .leading, spacing: 12) {
                        Text("If you don’t change anything and keep going the way you are, you’ll spend")
                            .overusedFont(weight: .semiBold, size: .h1)
                            .foregroundColor(.white)
                    }
                    .opacity(animateVStacks ? 1 : 0)
                    .offset(y: animateVStacks ? 0 : 20)
                    .animation(Animation.easeOut(duration: 0.4).delay(0.4), value: animateVStacks)

                    // Second VStack
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 4) {
                            Text("\(formatNumber(mainVM.currUser.minsSavedPerDay * 365))")
                                .overusedFont(weight: .bold, size: .titleHuge)
                                .foregroundColor(.red)
                            Text(" mins")
                                .overusedFont(weight: .bold, size: .h1Big)
                                .foregroundColor(.red)
                                .offset(y: 8)
                        }
                        SharedComponents.CustomSubtitleText(title: "this year watching porn.", color: .primaryBlue)
                    }
                    .opacity(animateVStacks ? 1 : 0)
                    .offset(y: animateVStacks ? 0 : 20)
                    .animation(Animation.easeOut(duration: 0.75).delay(0.7), value: animateVStacks)

                    // Third VStack
                    VStack(alignment: .leading, spacing: 24) {
                        HStack(alignment: .center, spacing: 12) {
                            Text("📸")
                                .overusedFont(weight: .bold, size: .h2)
                            SharedComponents.CustomSubtitleText(title: "Instagram’s first app was built in about 24,000 minutes (400 hours)", color: .white)
                        }
                        HStack(alignment: .center) {
                            Text("🍔️")
                                .overusedFont(weight: .bold, size: .h2)
                            SharedComponents.CustomSubtitleText(title: "If you put that time towards even a minimum wage job, you’d make $4172", color: .white)
                        }
                        HStack(alignment: .center) {
                            Text("📚")
                                .overusedFont(weight: .bold, size: .h2)
                            SharedComponents.CustomSubtitleText(title: "It’s enough time to read 30 average-length books.", color: .white)
                        }
                    }
                    .opacity(animateVStacks ? 1 : 0)
                    .offset(y: animateVStacks ? 0 : 20)
                    .animation(Animation.easeOut(duration: 1).delay(1), value: animateVStacks)
                    if UIDevice.hasNotch {
                        Spacer()
                    }

                    // Animated Primary Button
                    SharedComponents.PrimaryButton(title: "View my dependency score") {
                        showGraph = true
                    }
                    .opacity(animateVStacks ? 1 : 0)
                    .offset(y: animateVStacks ? 0 : 20)
                    .animation(Animation.easeOut(duration: 0.5).delay(1.3), value: animateVStacks)
                    .padding(.vertical)
                    .offset(y: -8)

                    Spacer()
                }
            }
            .padding()
            .padding(.horizontal)
            .onAppear {
                animateVStacks = true
            }
            .onAppearAnalytics(event: "ProblemScreen: Screenload")
        }
    }

    func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
}

struct ProblemGraphScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @State private var animateContent = false
    @State private var youBarHeight: CGFloat = 0
    @State private var averageBarHeight: CGFloat = 0
    @State private var percentage = 12
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title Text
            HStack(spacing: 0) {
                (Text("Your porn dependency is ").foregroundColor(.white) +
                    Text("higher")
                    .foregroundColor(.red) +
                    Text(" than the average person.")
                    .foregroundColor(.white))
                    .overusedFont(weight: .semiBold, size: .h1)
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 20)
            .animation(Animation.easeOut(duration: 0.5).delay(0.1), value: animateContent)
            if UIDevice.hasNotch {
                Spacer()
            }
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    // 'You' bar
                    VStack(spacing: 0) {
                        HStack {
                            Text("\(percentage)")
                                .overusedFont(weight: .bold, size: UIDevice.hasNotch ? .statNumber : .h1)
                                .foregroundColor(.red)
                            Text("%")
                                .overusedFont(weight: .bold, size: .h1)
                                .foregroundColor(.red)
                                .offset(y: 12)
                        }
                        .offset(x: 20)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(Animation.easeOut(duration: 0.5).delay(0.2), value: animateContent)

                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.5))
                            .frame(width: 100, height: youBarHeight)
                            .animation(Animation.easeOut(duration: 0.5).delay(0.3), value: youBarHeight)
                        Text("You")
                            .overusedFont(weight: .medium, size: .h3p1)
                            .foregroundColor(.white)
                            .padding(.top)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(Animation.easeOut(duration: 0.5).delay(0.4), value: animateContent)
                    }.frame(height: 425)

                    Spacer()
                        .frame(width: 40)

                    // 'Average' bar
                    VStack(spacing: 0) {
                        Text("12%")
                            .overusedFont(weight: .bold, size: .h1)
                            .foregroundColor(.green)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(Animation.easeOut(duration: 0.5).delay(0.5), value: animateContent)

                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.5))
                            .frame(width: 100, height: averageBarHeight)
                            .animation(Animation.easeOut(duration: 0.5).delay(0.6), value: averageBarHeight)
                        Text("Average")
                            .foregroundColor(.white)
                            .overusedFont(weight: .medium, size: .h3p1)
                            .padding(.top)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(Animation.easeOut(duration: 0.5).delay(0.7), value: animateContent)
                    }
                }
                .padding(.horizontal)
                if !UIDevice.hasNotch {}
            }
            if UIDevice.hasNotch {
                // Disclaimer Text
                Text("This result is for informational purposes only and does not constitute a medical diagnosis. .")
                    .foregroundColor(.gray)
                    .overusedFont(weight: .medium, size: .p3)
                    .multilineTextAlignment(.center)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(Animation.easeOut(duration: 0.5).delay(0.8), value: animateContent)
                Spacer()
            }

            // Button
            SharedComponents.PrimaryButton(title: "What it means") {
                // Button action here
                if UIDevice.hasNotch {
                    mainVM.onboardingScreen = .options
                } else {
                    mainVM.onboardingScreen = .graphic
                }
            }
            .padding(.vertical)
            .offset(y: -8)
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 20)
            .animation(Animation.easeOut(duration: 0.5).delay(0.9), value: animateContent)
            Spacer()
        }
        .onAppearAnalytics(event: "ProblemGraphScreen: Screenload")
        .onAppear {
            animateContent = true
            // Animate bar heights
            withAnimation(Animation.easeOut(duration: 0.5).delay(0.3)) {
                youBarHeight = UIDevice.hasNotch ? 275 : 225 // Final height for 'You' bar
            }
            withAnimation(Animation.easeOut(duration: 0.5).delay(0.6)) {
                averageBarHeight = 100 // Final height for 'Average' bar
            }

            if mainVM.currUser.minsSavedPerDay >= 60 {
                percentage = Int.random(in: 60 ... 80)
            } else if mainVM.currUser.minsSavedPerDay >= 45 {
                percentage = Int.random(in: 40 ... 60)
            } else if mainVM.currUser.minsSavedPerDay >= 30 {
                percentage = Int.random(in: 40 ... 50)
            } else {
                percentage = Int.random(in: 30 ... 40)
            }
        }
    }
}
