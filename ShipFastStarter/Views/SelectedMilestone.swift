//
//  SelectedMilestone.swift
//  Resolved
//
//  Created by Dante Kim on 10/12/24.
//

import SwiftData
import SwiftUI

struct SelectedMilestone: View {
    @Query private var sessionHistory: [SoberInterval]
    @Query private var user: [User]
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @Binding var farthestOrb: Orb
    @Binding var orbs: [Orb]
    @Binding var isMilestone: Bool
    @State private var unlockedDates: [String] = []

    // Animation state variable
    @State private var animateContent = false

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 12) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                profileVM.presentOrb = false
                            }
                        }
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.top, 64)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.0), value: animateContent)

                ScrollView(showsIndicators: false) {
                    VStack {
                        // Status Text ("Collected", "Up Next", or "Locked")
                        Group {
                            if profileVM.selectedMilestone == farthestOrb || farthestOrb > profileVM.selectedMilestone || (!isMilestone && mainVM.currUser.rewards.keys.contains(profileVM.selectedMilestone.name())) {
                                Text("Collected")
                                    .font(FontManager.overUsedGrotesk(type: .bold, size: .p3))
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(12)
                                    .offset(y: 2)
                            } else if orbs.contains(profileVM.selectedMilestone) {
                                Text("Up Next")
                                    .font(FontManager.overUsedGrotesk(type: .bold, size: .p3))
                                    .foregroundColor(.yellow)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.yellow.opacity(0.2))
                                    .cornerRadius(12)
                                    .offset(y: 2)
                            } else {
                                Text("Locked")
                                    .font(FontManager.overUsedGrotesk(type: .bold, size: .p3))
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red.opacity(0.2))
                                    .cornerRadius(12)
                                    .offset(y: 2)
                            }
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: animateContent)

                        // Milestone Display Name
                        Text("\(profileVM.selectedMilestone.displayName())")
                            .overusedFont(weight: .bold, size: .h1Big)
                            .foregroundColor(.white)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.2), value: animateContent)

                        // Orb Image
                        HStack(spacing: -64) {
                            Image(profileVM.selectedMilestone.name())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 128)
                                .shadow(color: Color.primaryBlue, radius: 45)
                        }
                        .frame(height: 130)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: animateContent)

                        // Motivational Content
                        Text(profileVM.selectedMilestone.motivationalContent())
                            .overusedFont(weight: .medium, size: .h2)
                            .foregroundColor(.white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 32)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.4), value: animateContent)

                        // Time to Nurture
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Time to nurture")
                                .overusedFont(weight: .medium, size: .h2)
                                .foregroundColor(.primaryBlue)
                                .padding(.top)

                            Text(profileVM.selectedMilestone.timeToNurture())
                                .foregroundColor(.white)
                                .overusedFont(weight: .bold, size: .title)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 32)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.5), value: animateContent)

                        // Benefits
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Benefits")
                                .overusedFont(weight: .medium, size: .h2)
                                .foregroundColor(.primaryBlue)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 32)
                                .padding(.top)
                                .padding(.bottom, 32)
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(Array(profileVM.selectedMilestone.benefits().enumerated()), id: \.element) { index, benefit in
                                    HStack {
                                        Text("\(index + 1).")
                                            .overusedFont(weight: .bold, size: .h3p1)
                                            .foregroundColor(.primaryBlue)
                                        Text("\(benefit)")
                                            .overusedFont(weight: .medium, size: .h3p1)
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 32)
                                }
                            }
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.6), value: animateContent)

                        // Unlocked Dates
                        if !unlockedDates.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Unlocked on")
                                    .overusedFont(weight: .medium, size: .h2)
                                    .foregroundColor(.primaryBlue)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 32)
                                    .padding(.top)
                                    .padding(.bottom)
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(Array(unlockedDates.enumerated()), id: \.element) { index, date in
                                        HStack {
                                            Text("\(index + 1).")
                                                .overusedFont(weight: .bold, size: .h3p1)
                                                .foregroundColor(.primaryBlue)
                                            Text("\(date)")
                                                .overusedFont(weight: .medium, size: .h3p1)
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 32)
                                    }
                                }
                            }
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.7), value: animateContent)
                        }

                        if !isMilestone {
                            SharedComponents.PrimaryButton(
                                title: mainVM.currUser.rewards.keys.contains(profileVM.selectedMilestone.name()) && mainVM.currUser.currentOrb != profileVM.selectedMilestone.name() ? "Equip Orb" : user.first?.currentOrb == profileVM.selectedMilestone.name() ? "Equipped" : "Must unlock to equip"
                            ) {
                                if !isMilestone && mainVM.currUser.rewards.keys.contains(profileVM.selectedMilestone.name()) {
                                    equipOrb()
                                } else if isMilestone {
                                    equipOrb()
                                }
                            }
                            .padding()
                            .padding(.horizontal, 12)
                            .opacity(mainVM.currUser.currentOrb == profileVM.selectedMilestone.name() || !mainVM.currUser.rewards.keys.contains(profileVM.selectedMilestone.name()) ? 0.5 : 1)
                            // Animate the button
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.8), value: animateContent)
                        } else {
                            SharedComponents.PrimaryButton(
                                title: profileVM.selectedMilestone != farthestOrb && orbs.contains(profileVM.selectedMilestone) && mainVM.currUser.currentOrb != profileVM.selectedMilestone.name() ? "Must unlock to equip" : mainVM.currUser.currentOrb == profileVM.selectedMilestone.name() ? "Equipped" : "Equip Orb"
                            ) {
                                if mainVM.currUser.currentOrb == profileVM.selectedMilestone.name() || (orbs.contains(profileVM.selectedMilestone) && profileVM.selectedMilestone != farthestOrb) {
                                    // Do nothing
                                } else {
                                    equipOrb()
                                }
                            }
                            .padding()
                            .padding(.horizontal, 12)
                            .opacity(mainVM.currUser.currentOrb == profileVM.selectedMilestone.rawValue || (orbs.contains(profileVM.selectedMilestone) && profileVM.selectedMilestone != farthestOrb) ? 0.5 : 1)
                            // Animate the button
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.8), value: animateContent)
                        }
                    }
                    .padding(.bottom, 48)
                }
            }
            .onAppear {
                for (idx, session) in sessionHistory.reversed().enumerated() {
                    if session.seed == profileVM.selectedMilestone.rawValue {
                        let startDate = Date.changeDateFormat(dateString: session.startDate, fromFormat: "dd-MM-yyyy HH:mm:ss", toFormat: "MMM dd, yyyy")
                        unlockedDates.append(startDate)
                    }
                }
                animateContent = true // Trigger the animations
            }
            .onAppearAnalytics(event: "MilestoneDetail: Screenload")
        }
    }

    func equipOrb() {
        Analytics.shared.logActual(event: "MilestoneDetail: Tapped Equip Orb", parameters: ["Orb": profileVM.selectedMilestone.name()])
        profileVM.presentOrb = false
        profileVM.showMilestones = false
        mainVM.currUser.currentOrb = profileVM.selectedMilestone.name()
        print(profileVM.selectedMilestone.name(), "deja vu deja vu", mainVM.currUser.id)
        homeVM.selectedOrb = (profileVM.selectedMilestone, OrbSize.extraLarge)
        Task {
            do {
                try await FirebaseService.shared.updateField(collection: "users", documentId: mainVM.currUser.id, field: "currentOrb" , value: profileVM.selectedMilestone.name())
                let userId =  UserDefaults.standard.string(forKey: Constants.userId) ?? ""
                try await FirebaseService.shared.updateField(collection: "users", documentId: userId, field: "currentOrb" , value: profileVM.selectedMilestone.name())
            } catch {
                print("shibal")
            }
        }
     
        DataManager.shared.saveContext(context: modelContext)
    }
}
