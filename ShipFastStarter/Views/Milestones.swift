//
//  Milestones.swift
//  Resolved
//
//  Created by Dante Kim on 10/12/24.
//
import SwiftData
import SwiftUI

struct Milestones: View {
    @Query private var sessionHistory: [SoberInterval]
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @State private var farthestOrb: Orb = .originalSeed
    @State private var nextTwoOrbs: [Orb] = []
    @State private var earnedOrbs: [Orb] = []
    @State private var rewardOrbs: [Orb] = []
    @State private var milestonesSelected = true

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 12) {
                HStack {
                    Text("Milestones")
                        .overusedFont(weight: .semiBold, size: .h2Big)
                        .foregroundColor(.white.opacity(milestonesSelected ? 1 : 0.5))
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                milestonesSelected = true
                            }
                        }

                    Text("Rewards")
                        .overusedFont(weight: .semiBold, size: .h2Big)
                        .foregroundColor(.white.opacity(!milestonesSelected ? 1 : 0.5))
                        .padding(.horizontal)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                Analytics.shared.log(event: "MilestoneScreen: Tapped Rewards")
                                milestonesSelected = false
                            }
                        }

                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                profileVM.showMilestones = false
                            }
                        }
                        .foregroundColor(.white)
                }
                .padding(.top, 64)
                .padding(.horizontal, 28)
                .padding(.bottom)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 42) {
                        ForEach(Array(milestonesSelected ? Orb.mainOrbs().enumerated() : Orb.rewardOrbs().enumerated()), id: \.element) { index, orb in
                            MilestoneCard(orb: orb, index: index, orbs: nextTwoOrbs, collectedOrbs: earnedOrbs, farthestOrb: farthestOrb, isReward: !milestonesSelected)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation {
                                        if nextTwoOrbs.contains(orb) || farthestOrb > orb || !milestonesSelected {
                                            profileVM.selectedMilestone = orb
                                            profileVM.presentOrb = true
                                        }
                                    }
                                }
                        }
                    }.padding(.bottom, 96)
                }
            }
        }.onAppear {
            for session in sessionHistory {
                let currentOrb = Orb.getOrb(forName: session.seed)
                if currentOrb > farthestOrb {
                    farthestOrb = currentOrb
                }
            }

            let allOrbs = Orb.allCases
            earnedOrbs = []

            for session in sessionHistory {
                if let orbIndex = allOrbs.firstIndex(where: { $0.name() == session.seed }) {
                    // Add this orb and all previous orbs to earnedOrbs
                    earnedOrbs.append(contentsOf: allOrbs[0 ... orbIndex])
                }
            }
            for reward in mainVM.currUser.rewards {
                earnedOrbs.append(Orb.getOrb(forName: reward.key))
            }

            nextTwoOrbs.append(farthestOrb)
            nextTwoOrbs.append(contentsOf: farthestOrb.nextTwoOrbs())

            // Any onAppear logic
        }.sheet(isPresented: $profileVM.presentOrb) {
            SelectedMilestone(farthestOrb: $farthestOrb, orbs: $nextTwoOrbs, isMilestone: $milestonesSelected)
                .environmentObject(homeVM)
                .environmentObject(profileVM)
                .environmentObject(mainVM)
        }
        .onAppearAnalytics(event: "Milestones: Screenload")
    }
}

struct MilestoneCard: View {
    let orb: Orb
    let index: Int
    let orbs: [Orb]
    let collectedOrbs: [Orb]
    let farthestOrb: Orb
    let isReward: Bool

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Text("Milestone \(index + 1)")
                    .font(FontManager.overUsedGrotesk(type: .medium, size: .p2))
                    .foregroundColor(.gray)
                Spacer()
                if orbs.contains(orb) || farthestOrb > orb || isReward && collectedOrbs.contains(orb) {
                    if orb == farthestOrb || farthestOrb > orb || isReward {
                        Text("Collected") // You may want to add logic to determine if it's collected
                            .font(FontManager.overUsedGrotesk(type: .bold, size: .p3))
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(12)
                            .offset(y: 2)
                    } else {
                        Text("Up Next") // You may want to add logic to determine if it's collected
                            .font(FontManager.overUsedGrotesk(type: .bold, size: .p3))
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(12)
                            .offset(y: 2)
                    }

                } else {
                    Text("Locked") // You may want to add logic to determine if it's collected
                        .font(FontManager.overUsedGrotesk(type: .bold, size: .p3))
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(12)
                        .offset(y: 2)
                }
            }
            .padding()

            VStack {
                HStack(spacing: -64) {
                    Image(orb.name())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 128)
                        .shadow(color: Color.primaryBlue, radius: 45)
                }
                .frame(height: 130)

                VStack(alignment: .center) {
                    Text(orb.displayName())
                        .overusedFont(weight: .semiBold, size: .h3p1)
                        .foregroundColor(.white)
                    Text(orb.motivationalContent()) // You may want to add actual descriptions
                        .overusedFont(weight: .semiBold, size: .h3p1)
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }.blur(radius: isReward || orbs.contains(orb) || farthestOrb > orb ? 0 : 20)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.1))
                .overlay(SharedComponents.clearShadow)
        )
        .padding(.horizontal)
    }
}

#Preview {
    Milestones()
        .environmentObject(MainViewModel())
        .environmentObject(ProfileViewModel())
}
