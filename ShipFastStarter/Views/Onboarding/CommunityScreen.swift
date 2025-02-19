//
//  CommunityScreen.swift
//  Resolved
//
//  Created by Dante Kim on 10/20/24.
//

import SwiftUI

struct CommunityScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @State var nextPage = false
    @State private var animateVStacks = false // New state variable for animation

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            if nextPage {
                CommunityExplainer()
                    .environmentObject(mainVM)
            } else {
                VStack(alignment: .leading, spacing: 24) {
                    // First VStack
                    VStack(alignment: .leading, spacing: 12) {
                        Text("A safe space to defeat the problem millions of men are fighting silently.")
                            .overusedFont(weight: .semiBold, size: .h1)
                            .foregroundColor(.white)
                        SharedComponents.CustomSubtitleText(title: "Science-based approach to help you quit. Finally and forever.", color: .white)
                    }
                    .opacity(animateVStacks ? 1 : 0)
                    .offset(y: animateVStacks ? 0 : 20)
                    .animation(Animation.easeOut(duration: 0.4).delay(0.4), value: animateVStacks)

                    // Second VStack
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 4) {
                            Text("41")
                                .overusedFont(weight: .bold, size: .statNumber)
                                .foregroundColor(.white)
                            Text("billion hours")
                                .overusedFont(weight: .bold, size: .h1Big)
                                .foregroundColor(.white)
                                .offset(y: 20)
                        }
                        SharedComponents.CustomSubtitleText(title: "are wasted every year watching porn around the world.", color: .primaryBlue)
                    }
                    .opacity(animateVStacks ? 1 : 0)
                    .offset(y: animateVStacks ? 0 : 20)
                    .animation(Animation.easeOut(duration: 0.75).delay(0.7), value: animateVStacks)

                    // Third VStack
                    VStack(alignment: .leading, spacing: 24) {
                        HStack(alignment: .center, spacing: 12) {
                            Text("🚀")
                                .overusedFont(weight: .bold, size: .h2)
                            SharedComponents.CustomSubtitleText(title: "Enough time to build 41,000 spaceX starships", color: .white)
                        }
                        HStack(alignment: .center) {
                            Text("⛰️")
                                .overusedFont(weight: .bold, size: .h2)
                            SharedComponents.CustomSubtitleText(title: "Enough time to build the Great Pyramid over 100 times", color: .white)
                        }
                        HStack(alignment: .center) {
                            Text("🔬")
                                .overusedFont(weight: .bold, size: .h2)
                            SharedComponents.CustomSubtitleText(title: "2.5x spent on scientific global research globally ", color: .white)
                        }
                    }
                    .opacity(animateVStacks ? 1 : 0)
                    .offset(y: animateVStacks ? 0 : 20)
                    .animation(Animation.easeOut(duration: 1).delay(1), value: animateVStacks)

                    if UIDevice.isProMax {
                        Spacer()
                    }

                    SharedComponents.PrimaryButton(title: "Continue") {
                        nextPage = true
                    }
                    .padding(.vertical)
                    .opacity(animateVStacks ? 1 : 0)
                    .offset(y: animateVStacks ? -8 : 20)
                    .animation(Animation.easeOut(duration: 1).delay(1.5), value: animateVStacks)

                    Spacer()
                }
                .padding()
                .padding(.horizontal)
                .onAppear {
                    animateVStacks = true
                }
            }
        }.onAppearAnalytics(event: "CommunityStatistic: Screenload")
    }
}

struct CommunityExplainer: View {
    @EnvironmentObject var mainVM: MainViewModel
    @State private var animateContent = false // State variable for animations

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title Text
            Text("You're not alone.")
                .overusedFont(weight: .semiBold, size: .h1)
                .foregroundColor(.white)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5), value: animateContent)

            // Subtitle Text
            SharedComponents.CustomSubtitleText(title: "Daily check-in's with the community.", color: .white)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.1), value: animateContent)

            // Card View
            VStack(alignment: .leading, spacing: 0) {
                Text("🫡")
                    .overusedFont(weight: .bold, size: .h1Big)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                Text("Salute to the 312 soldiers that folded today.")
                    .multilineTextAlignment(.leading)
                    .overusedFont(weight: .semiBold, size: .h1Medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                Text("544")
                    .multilineTextAlignment(.leading)
                    .overusedFont(weight: .semiBold, size: .statNumber)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                Text("are still going strong")
                    .multilineTextAlignment(.leading)
                    .overusedFont(weight: .semiBold, size: .p2)
                    .foregroundColor(.primaryBlue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
            }
            .padding()
            .padding(.vertical)
            .cornerRadius(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
            )
            .rotationEffect(.degrees(-4))
            .shadow(color: Color.primaryBlue.opacity(0.4), radius: 24)
            .padding(.horizontal, 12)
            .padding(.vertical, 36)
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: animateContent)

            if UIDevice.isProMax {
                Spacer()
            }

            // Continue Button
            SharedComponents.PrimaryButton(title: "Continue") {
                mainVM.onboardingScreen = .quiz
            }
            .padding(.vertical)
            .padding(.top)
            .offset(y: -16)
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.3), value: animateContent)

            Spacer()
        }
        .padding()
        .padding(.horizontal)
        .onAppear {
            animateContent = true // Trigger animations when view appears
        }
        .onAppearAnalytics(event: "CommunityCard: Screenload")
    }
}

#Preview {
    CommunityScreen()
        .environmentObject(MainViewModel())
}
