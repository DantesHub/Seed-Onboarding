//
//  SelectOptionsScreen.swift
//  Resolved
//
//  Created by Dante Kim on 10/21/24.
//

import SwiftUI

enum OptionType: String {
    case symptoms = "High reliance on porn may lead to these common symptoms"
    case motivation = "Finally, what’s your motivation behind quitting porn?"

    func name() -> String {
        return String(describing: self)
    }

    func getOptions() -> [String] {
        switch self {
        case .symptoms: return ["physical", "mental"]
        case .motivation: return ["reclaim control my life", "improve relationships", "increase energy", "increase libido", "increase mental clarity", "improve mental strength", "save time", "improve confidence", "religious reasons"]
        }
    }

    func getGroupedOptions(option: String) -> [String] {
        switch option {
        case "Physical":
            return [
                "Fatigue and low energy",
                "Weakened erections",
                "Decreased libido",
            ]
        case "Mental":
            return [
                "Anxiety and stress",
                "Depression or low mood",
                "Concentration difficulties",
                "Low to no motivation",
                "Low productivity",
                "Feelings of guilt or shame",
                "Emotional numbness",
                "Relationship struggles",
                "Social isolation",
            ]
        default:
            return []
        }
    }
}

struct SelectOptionsScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @State private var animateVStacks = false // New state variable for animation
    @State private var selectedOptions: [String] = []

    let groups = [
        "Physical",
        "Mental",
    ]

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 24) {
                // First VStack
                VStack(alignment: .leading, spacing: 12) {
                    Text(mainVM.optionType.rawValue)
                        .overusedFont(weight: .semiBold, size: .h1)
                        .foregroundColor(.white)
                    Text("Select all that apply")
                        .font(.headline)
                        .padding(.bottom, 5)
                        .foregroundColor(.white)
                }
                .opacity(animateVStacks ? 1 : 0)
                .offset(y: animateVStacks ? 0 : 20)
                .animation(Animation.easeOut(duration: 0.4).delay(0.4), value: animateVStacks)
                .padding(.horizontal, 12)

                ScrollView(showsIndicators: false) {
                    // Options grouped by category
                    VStack(alignment: .leading, spacing: 24) {
                        if mainVM.optionType == .symptoms {
                            ForEach(Array(groups.enumerated()), id: \.1) { groupIndex, group in
                                VStack(alignment: .leading, spacing: 24) {
                                    // Group title with animation
                                    Text(group)
                                        .font(.headline)
                                        .padding(.bottom, 5)
                                        .foregroundColor(.white)
                                        .opacity(animateVStacks ? 1 : 0)
                                        .offset(y: animateVStacks ? 0 : 20)
                                        .animation(Animation.easeOut(duration: 0.5).delay(0.5 + 0.3 * Double(groupIndex)), value: animateVStacks)

                                    let options = mainVM.optionType.getGroupedOptions(option: group)

                                    ForEach(Array(options.enumerated()), id: \.1) { optionIndex, option in
                                        OptionButton(title: option, selectedOptions: $selectedOptions) {
                                            if selectedOptions.contains(option) {
                                                selectedOptions.removeAll { opt in
                                                    option == opt
                                                }
                                            } else {
                                                selectedOptions.append(option)
                                            }
                                        }
                                        .opacity(animateVStacks ? 1 : 0)
                                        .offset(y: animateVStacks ? 0 : 20)
                                        .animation(Animation.easeOut(duration: 0.5).delay(0.5 + 0.3 * Double(groupIndex) + 0.1 * Double(optionIndex)), value: animateVStacks)
                                    }
                                }
                            }
                        } else {
                            // Handle other option types if necessary
                            ForEach(Array(mainVM.optionType.getOptions().enumerated()), id: \.1) { optionIndex, option in
                                // Option buttons for other types
                                OptionButton(title: option, selectedOptions: $selectedOptions) {
                                    selectedOptions.append(option)
                                }
                                .opacity(animateVStacks ? 1 : 0)
                                .offset(y: animateVStacks ? 0 : 20)
                                .animation(Animation.easeOut(duration: 0.5).delay(0.5 + 0.3 + 0.1 * Double(optionIndex)), value: animateVStacks)
                            }
                        }
                    }
                }

                if UIDevice.isProMax {
                    Spacer()
                }
                SharedComponents.PrimaryButton(title: "Continue") {
                    if !selectedOptions.isEmpty {
                        if mainVM.optionType == .symptoms {
                            mainVM.currUser.onboardingQuestions["symptons"] = selectedOptions.toString()
                            mainVM.onboardingScreen = .goodNews
                            selectedOptions = []
                            Analytics.shared.log(event: "SelectOptionsScreen: Symptoms Continue")
                        } else {
                            mainVM.currUser.onboardingQuestions["motivationToQuit"] = selectedOptions.toString()
                            Analytics.shared.log(event: "SelectOptionsScreen: Motivation Continue")
                            mainVM.onboardingScreen = .graphic
                        }
                    }
                }
                .opacity(selectedOptions.isEmpty ? 0.5 : 1)
                .padding(.vertical)
                .offset(y: -48)

                Spacer()
            }
            .padding()
            .onAppear {
                animateVStacks = true
            }
            .onChange(of: mainVM.optionType) {
                animateVStacks = true
            }
        }.onAppearAnalytics(event: "SelectOptionsScreen: \(mainVM.optionType.name())")
    }
}

struct OptionButton: View {
    let title: String
    @Binding var selectedOptions: [String]
    let action: () -> Void

    var body: some View {
        HStack {
            Spacer()
            SharedComponents.CustomMediumTwenty(title: title, color: .white)
            Spacer()
        }
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation {
                action()
            }
        }
        .padding()
        .frame(height: 72)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(selectedOptions.contains(title) ? Color.primaryBlue.opacity(0.7) : Color.white.opacity(0.1))
                .overlay(SharedComponents.clearShadow)
        )

        .cornerRadius(24)
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation {
                action()
            }
        }
    }
}
