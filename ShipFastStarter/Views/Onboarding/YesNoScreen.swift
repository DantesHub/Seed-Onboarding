//
//  YesNoScreen.swift
//  Resolved
//
//  Created by Dante Kim on 10/20/24.
//

import SwiftUI

enum YesNoPage: String {
    case amount = "Has the amount of porn you watch increased over time?"
    case explicit = "Have you started to watch content that is more explicit or extreme over time?"
    case spentMoney = "Have you spent money on porn or explicit content?"

    func name() -> String {
        switch self {
        case .amount: return "amount"
        case .explicit: return "explicit"
        case .spentMoney: return "spentMoney"
        }
    }
}

struct YesNo: View {
    @EnvironmentObject var mainVM: MainViewModel
    @Binding var pageType: YesNoPage
    @State private var animateContent = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack {
                // Centered text and options
                VStack(spacing: 32) {
                    VStack(spacing: 12) {
                        SharedComponents.CustomBoldHeading(title: pageType.rawValue, color: .white)
                            .frame(height: 165)
                            .padding(.horizontal, 4)
//                            .opacity(animateContent ? 1 : 0)
//                            .offset(y: animateContent ? 0 : 20)
//                            .animation(.easeOut(duration: 0.5), value: animateContent && pageType == .amount)
                    }.padding(.top, 16)

                    // Options buttons
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(["Yes", "No"], id: \.self) { option in
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                yesNoTap(option: option)
                            }) {
                                SharedComponents.OnboardVoteOption(title: option, height: 80)
                            }
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.1 * Double(["Yes", "No"].firstIndex(of: option)! + 1)), value: animateContent)
                        }

                        if pageType == .amount {
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                yesNoTap(option: "Stayed the same")
                            }) {
                                SharedComponents.OnboardVoteOption(title: "Stayed the same", height: 80)
                            }
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.3), value: animateContent)
                        }
                    }

                    Spacer()
                        .frame(height: 100)
                }
                .padding(.horizontal, 12)

                Spacer() // Pushes content up to center it
            }
            .onAppearAnalytics(event: "YesNoScreen: Screenload")
        }
        .onAppear {
            animateContent = true
        }
    }

    func yesNoTap(option: String) {
        mainVM.currUser.onboardingQuestions[pageType.name()] = option
        DataManager.shared.saveContext(context: modelContext)
        withAnimation {
            mainVM.onboardingProgress += 0.08
        }

        switch pageType {
        case .amount:
            Analytics.shared.logActual(event: "AmountScreen: Tapped Option", parameters: ["option": option])
            pageType = .explicit
        case .explicit:
            Analytics.shared.logActual(event: "ExplicitScreen: Tapped Option", parameters: ["option": option])
            pageType = .spentMoney
        case .spentMoney:
            Analytics.shared.logActual(event: "SpentMoneyScreen: Tapped Option", parameters: ["option": option])
            mainVM.onboardingScreen = .haveQuittingBeforeScreen
        }

//        // Reset animation for next question
//        animateContent = false
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            withAnimation {
//                animateContent = true
//            }
//        }
    }
}
