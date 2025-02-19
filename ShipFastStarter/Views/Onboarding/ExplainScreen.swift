//
//  ExplainScreen.swift
//  FitCheck
//
//  Created by Dante Kim on 11/21/23.
//

import SplineRuntime
import SwiftUI

struct ExplainScreen: View {
    @EnvironmentObject private var mainVM: MainViewModel
    @State private var selectedTab = 0
    @State private var showAnimation = false
    @State private var hasAppeared = false

    var body: some View {
        ZStack(alignment: .center) {
            Color(.primaryBackground).edgesIgnoringSafeArea(.all)
            HStack {
                Spacer()
                GeometryReader { g in
                    let width = g.size.width
                    let height = g.size.height
                    VStack {
                        TabView(selection: $selectedTab) {
                            ForEach(0 ..< 4, id: \.self) { index in
                                VStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color(.primaryBackground))
                                        .frame(height: 60)
                                    ZStack {
                                        if index == 0 {
                                            VStack {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("How it works")
                                                        .sfFont(weight: .bold, size: .h2)
                                                        .foregroundColor(Color(.primaryPurple))
                                                    Text("The more you abstain, the more your seed grows and evolves")
                                                        .sfFont(weight: .medium, size: .h3p1)
                                                        .foregroundColor(Color(.primaryForeground))
                                                }
                                                .padding(.horizontal, 4)
                                                HStack(alignment: .top) {
                                                    ZStack {
                                                        RoundedRectangle(cornerRadius: 24)
                                                            .fill(Color.secondaryBackground)
                                                            .frame(width: 150, height: 200)

                                                        VStack(spacing: -12) {
                                                            SplineView(sceneFileURL: Bundle.main.url(forResource: "originalSeed", withExtension: "splineswift"))
                                                                .frame(width: 50, height: 50)
                                                                .ignoresSafeArea(.all)
                                                                .background(.clear)
                                                                //                        .shadow(color: .white, radius: 3)
                                                                .padding()
                                                                .offset(y: -12)
                                                            Text("Day 0")
                                                                .sfFont(weight: .semibold, size: .h3p1)
                                                                .foregroundColor(Color(.primaryForeground))
                                                                .opacity(0.7)
                                                                .padding()
                                                                .offset(y: 12)
                                                        }
                                                    }
                                                    .frame(width: 150, height: height * 0.15)
                                                    .offset(x: -12)
                                                    Spacer()
                                                    ZStack {
                                                        RoundedRectangle(cornerRadius: 24)
                                                            .fill(Color.secondaryBackground)
                                                            .frame(width: 150, height: 200)

                                                        VStack {
                                                            SplineView(sceneFileURL: Bundle.main.url(forResource: "originalSeed", withExtension: "splineswift"))
                                                                .frame(width: 150, height: 150)
                                                                .ignoresSafeArea(.all)
                                                                //                        .shadow(color: .white, radius: 3)
                                                                .padding()
                                                            Text("Day 2")
                                                                .sfFont(weight: .semibold, size: .h3p1)
                                                                .foregroundColor(Color(.primaryForeground))
                                                                .opacity(0.7)

                                                        }.offset(y: -48)
                                                    }
                                                    .frame(height: height * 0.15)
                                                }
                                                .frame(width: width * 0.9)
                                                .padding(.top, 64)
                                                .offset(x: 12)
                                                Spacer()
                                                HStack {
                                                    ZStack {
                                                        RoundedRectangle(cornerRadius: 24)
                                                            .fill(Color.secondaryBackground)
                                                            .frame(width: 150, height: 200)

                                                        VStack(spacing: -12) {
                                                            SplineView(sceneFileURL: Bundle.main.url(forResource: "blueOrb", withExtension: "splineswift"))
                                                                .frame(width: 150, height: 150)
                                                                .ignoresSafeArea(.all)
                                                                //                        .shadow(color: .white, radius: 3)
                                                                .padding()
                                                            Text("Day 3")
                                                                .sfFont(weight: .semibold, size: .h3p1)
                                                                .foregroundColor(Color(.primaryForeground))
                                                                .opacity(0.7)
                                                                .offset(y: -12)
                                                        }
                                                        .offset(y: -16)
                                                    }
                                                    .frame(width: 150, height: height * 0.15)

                                                    Spacer()
                                                    ZStack {
                                                        RoundedRectangle(cornerRadius: 24)
                                                            .fill(Color.secondaryBackground)
                                                            .frame(width: 150, height: 200)
                                                        VStack(spacing: -12) {
                                                            SplineView(sceneFileURL: Bundle.main.url(forResource: "marbleDyson", withExtension: "splineswift"))
                                                                .frame(width: 150, height: 150)
                                                                .ignoresSafeArea(.all)
                                                                .background(.clear)
                                                                //                        .shadow(color: .white, radius: 3)
                                                                .padding()
                                                            Text("Day 89")
                                                                .sfFont(weight: .semibold, size: .h3p1)
                                                                .foregroundColor(Color(.primaryForeground))
                                                                .opacity(0.7)
                                                                .offset(y: -12)
                                                        }
                                                        .offset(y: -16)
                                                    }
                                                    .frame(width: 150, height: height * 0.15)
                                                }
                                                .frame(width: width * 0.9)
                                                .padding(.bottom)
                                                .offset(y: -24)

                                                Spacer()
                                            }
                                        } else if index == 1 {
                                            VStack {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("When you're triggered")
                                                        .sfFont(weight: .bold, size: .h2)
                                                        .foregroundColor(Color(.primaryPurple))

                                                    Text("Complete exercises, do breathwork, or talk to your AI coach")
                                                        .sfFont(weight: .medium, size: .h3p1)
                                                        .foregroundColor(Color(.primaryForeground))
                                                }
                                                .padding(.horizontal)
                                                Spacer()
                                                Image(.explainer2)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: width * 0.95)
                                                    .shadow(color: .white.opacity(0.5), radius: 4)
                                                    .offset(x: 4, y: -48)
                                                Spacer()
                                            }
                                        } else if index == 2 {
                                            VStack(alignment: .leading) {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("Science backed lessons")
                                                        .sfFont(weight: .bold, size: .h2)
                                                        .foregroundColor(Color(.primaryPurple))

                                                    Text("Educate yourself, and grow on your journey.")
                                                        .sfFont(weight: .medium, size: .h3p1)
                                                        .foregroundColor(Color(.primaryForeground))
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal, 32)
                                                Spacer()
                                                Image(.explainer3)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: width, height: height * 0.7)
                                                    .offset(y: -12)
                                                Spacer()
                                            }
                                        } else if index == 3 {
                                            VStack {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("Statistics")
                                                        .sfFont(weight: .semibold, size: .h2)
                                                        .foregroundColor(Color(.primaryPurple))

                                                    (Text("See how you're making,")
                                                        .foregroundColor(Color(.primaryForeground))
                                                        + Text(" progress over time.")
                                                        .foregroundColor(Color(.secondaryPurple))
                                                    )
                                                    .sfFont(weight: .bold, size: .h3p1)
                                                }
                                                Spacer()
                                                Image(.explainer4)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: width * 0.9, height: height * 0.7)
                                                    .offset(x: 4, y: -12)
                                                Spacer()
                                            }
                                        }
                                    }.frame(width: 325, height: height / 1.1)
                                    Spacer()
                                }
                                .frame(width: 325, alignment: .center)
                                .tag(index)
                            }.frame(width: 375)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                        .animation(.easeInOut(duration: 0.3), value: selectedTab)

                        SharedComponents.PrimaryButton(title: selectedTab == 3 ? "Let's Start!" : "Continue") {
                            DispatchQueue.main.async {
                                mainVM.onboardingProgress += 0.08
                            }
                            Analytics.shared.log(event: "Explainer: Click Continue")

                            if selectedTab < 3 {
                                withAnimation {
                                    selectedTab += 1
                                }
                            } else {
                                // Immediately change the page without animation
                                mainVM.currentPage = .home
                            }
                        }
                        .padding()
                    }
                }
                Spacer()

            }.frame(width: UIScreen.main.bounds.width)

        }.onAppear {
            let calendar = Calendar.current
            let targetDateComponents = DateComponents(year: 2024, month: 1, day: 26)
            let targetDate = calendar.date(from: targetDateComponents)
            let targetDateComponents2 = DateComponents(year: 2024, month: 1, day: 27)
            let targetDate2 = calendar.date(from: targetDateComponents2)
            if calendar.isDateInToday(targetDate ?? Date()) || calendar.isDateInToday(targetDate2 ?? Date()) {
            } else {
                showAnimation = true
                //                mainVM.loadingText = "😎 welcome to the club"
                //                mainVM.showToast = true
            }
        }.onAppearAnalytics(event: "ExplainScreen: Screenload")
    }
}

#Preview {
    ExplainScreen()
        .environmentObject(MainViewModel())
}

extension AnyTransition {
    static var slideInFromLeft: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        )
    }
}
