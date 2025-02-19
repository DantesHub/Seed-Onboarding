//
//  LoadingIllusion.swift
//  MindGarden
//
//  Created by Dante Kim on 6/24/22.
//

import SwiftUI

struct LoadingIllusion: View {
    @Binding var showStory: Bool
    @State var showComplete: Bool = false
    @State private var percentage: Int = 0

    @EnvironmentObject var mainVM: MainViewModel
    @State private var showCircleProgress = true
    @State var meditateTimer: Timer?
    @State var time = 2.5
    @State var index = -1
    @State var topics = [
        "Personalizing...",
        "Evaluating your answers...",
        "Crafting the perfect plan...",
        "Optimizing your AI Coach...",
    ]

    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: "onboarding_bg")!)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            ZStack {
                if !showComplete {
                    VStack {
                        ForEach(0 ..< topics.count, id: \.self) { idx in
                            if idx <= index {
                                SharedComponents.CustomText(
                                    title: topics[idx],
                                    font: FontManager.overUsedGrotesk(type: .bold, size: .h1Big),
                                    color: index == idx ? Color.white : Color.gray.opacity(0.5)
                                )
                                .offset(y: idx == index ? 0 : -CGFloat(20 * (index - idx)))
                                .animation(.easeInOut(duration: 0.5), value: index)
                            }
                        }
                        Spacer()
                            .frame(height: UIScreen.main.bounds.height / 3)
                    }
                    .padding(.top, 16) // Added padding to respect the top safe area

                } else {
                    VStack(spacing: 20) {
                        Spacer()
                            .frame(height: 64)
                        SharedComponents.CustomExtraBoldHeading(title: "\(mainVM.currUser.name), your assessment is complete.", color: .white)
                            .padding(.horizontal, 32)
                        VStack(spacing: 12) {
                            SharedComponents.CustomMediumText(title: "Some good news...", color: .white)
                            SharedComponents.CustomMediumText(title: "Some not so great news...", color: .white)
                        }
                        SharedComponents.PrimaryButton(title: "Continue", action: {
                            mainVM.onboardingScreen = .problem
                        })
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .frame(height: 60)
                        .padding(.top, 32)
                        Spacer()
                    }
                    .offset(y: showComplete ? 0 : UIScreen.main.bounds.height)
                    .opacity(showComplete ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5), value: showComplete)
                }
            }

            VStack {
                Spacer()
                HStack {
                    Text("\(percentage)%")
                        .font(FontManager.overUsedGrotesk(type: .medium, size: .titleHundred))
                        .foregroundColor(Color(hex: "#474CFF"))
                        .onAppear {
                            index = 0
                            incrementPercentage()
                        }
                        .offset(y: -16)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 0)
                }
                .offset(x: 20, y: 20)
            }.padding()
        }
        .onAppear {
            Analytics.shared.log(event: "OnboardingIllusion: Screenload")
            meditateTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                withAnimation(.easeOut) {
                    if index < topics.count - 1 {
                        index += 1
                    } else {
                        meditateTimer?.invalidate()
                    }
                }
            }
        }
        .onDisappear {
            meditateTimer?.invalidate()
        }
        .fullScreenCover(isPresented: $showStory) {
            OnboardingStory(showStory: $showStory)
                .environmentObject(mainVM)
        }
    }

    func incrementPercentage() {
        Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { timer in
            if self.percentage < 100 {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self.percentage += 1
            } else {
                timer.invalidate()
                withAnimation {
                    showComplete = true
                }
            }
        }
    }
}

#Preview {
    LoadingIllusion(showStory: .constant(false))
        .environmentObject(MainViewModel())
}
