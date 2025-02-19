//
//  WhyScreen.swift
//  Resolved
//
//  Created by Dante Kim on 7/13/24.
//

import SwiftUI

struct WhyScreen: View {
    let options = ["Boredom", "Stress", "Loneliness", "Social Media", "Random Urge"]
    @State private var selectedOptions: Set<String> = []
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
//            Image(.justBackground)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .edgesIgnoringSafeArea(.all)
            GeometryReader { _ in
                VStack(alignment: .leading, spacing: 12) {
//                    HStack {
//                        Image(systemName: "arrow.left")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 32)
//                            .onTapGesture {
//                                withAnimation {
//                                    Analytics.shared.log(event: homeVM.tappedRelapse ? "RelapseScreen: Tapped X" : "CheckInScreen: Tapped X")
//                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
//
//                                }
//                            }
//                            .foregroundColor(.white)
//                    }.padding(.horizontal)
                    VStack(alignment: .leading) {
                        Text("Why do you")
                            .foregroundStyle(Color.white)
                            .overusedFont(weight: .bold, size: .h1)
                        Text("think you relapsed?")
                            .foregroundStyle(Color.white)
                            .overusedFont(weight: .bold, size: .h1)
                    }
                    .padding(.horizontal)
                    .padding(.vertical)

//                    Text("Really reflect and think. Awareness is the 1st step to change.")
//                        .foregroundStyle(Color.primaryForeground)
//                        .overusedFont(weight: .medium, size: .h3p1)
//                        .padding(.horizontal)
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                if selectedOptions.contains(option) {
                                    selectedOptions.remove(option)
                                } else {
                                    selectedOptions.insert(option)
                                }
                            }) {
                                Text(option)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 64)
                                    .background(Color.secondaryBackground)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.primaryPurple, lineWidth: selectedOptions.contains(option) ? 3 : 0)
                                    )
                                    .opacity(selectedOptions.contains(option) ? 0.8 : 1)
                                    .overusedFont(weight: .semiBold, size: .h3p1)
                            }
                        }
                    }

                    SharedComponents.PrimaryButton(title: "Continue") {
                        Analytics.shared.log(event: "RelapseReasonScreen: Click Continue")
                        mainVM.currentInterval.reasonsForLapsing = Array(selectedOptions)

                        DataManager.shared.saveContext(context: modelContext)
                        withAnimation {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            homeVM.currentScreen = .trigger
                        }

                    }.disabled(selectedOptions.isEmpty)
                        .opacity(selectedOptions.isEmpty ? 0.5 : 1)
                        .padding(.vertical)
                }
                .padding()
            }
        }.onAppearAnalytics(event: "RelapseReasonScreen: Screenload")
    }
}

#Preview {
    WhyScreen()
}
