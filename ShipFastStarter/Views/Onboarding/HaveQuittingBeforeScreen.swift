//
//  HaveQuittingBeforeScreen.swift
//  Resolved
//
//  Created by Gursewak Singh on 03/10/24.
//

import SwiftUI

struct HaveQuittingBeforeScreen: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var mainVM: MainViewModel
    @State private var animateContent = false
    let options = ["Never", "Tried once", "Tried a couple times", "Tried many times"]

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Centered text and options
                VStack(spacing: 32) {
                    SharedComponents.CustomBoldHeading(title: "Have you tried\nquitting porn\nbefore?", color: .white)
                        .padding(.top)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5), value: animateContent)

                    // Options buttons
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                mainVM.currUser.age = option
                                DataManager.shared.saveContext(context: modelContext)
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                Analytics.shared.logActual(event: "HaveQuittingBefore: Tapped Option", parameters: ["option": option])
                                withAnimation {
                                    mainVM.onboardingProgress += 0.08
                                    mainVM.onboardingScreen = .religion
                                }
                            }) {
                                SharedComponents.OnboardVoteOption(title: option, height: 100)
                            }
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.1 * Double(options.firstIndex(of: option)! + 1)), value: animateContent)
                        }
                    }

                    Spacer()
                        .frame(height: 100)
                }
                .padding(.horizontal)

                Spacer() // Pushes content up to center it
            }
        }
        .onAppear {
            animateContent = true
        }
        .onAppearAnalytics(event: "HaveQuittingBeforeScreen: Screenload")
    }
}

#Preview {
    HaveQuittingBeforeScreen()
        .environmentObject(MainViewModel())
}
