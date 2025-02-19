//
//  CoursesScreen.swift
//  Resolved
//
//  Created by Dante Kim on 10/26/24.
//

import AVFoundation
import FirebaseStorage
import SuperwallKit
import SwiftUI

struct CoursesScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var educationVM: EducationViewModel

    
    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack {
                ScrollView(showsIndicators: false) {
                    DiscordCard()
                        .environmentObject(mainVM)
                    VStack {
                        HStack {
                            Text("Rewire Tapes")
                                .overusedFont(weight: .semiBold, size: .h1Big)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                            Spacer()
                        }
                        
                        Text("The 5 day audio course to help train your subconscious mind.")
                            .overusedFont(weight: .medium, size: .p2)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                        
                        VStack(spacing: 32) {
                            ForEach(RewireTape.tapes, id: \.id) { tape in
                                if tape.focus != "Mastery Tape" {
                                    TapeCard(tape: tape)
                                }
                            }
//                            Text("Mastery Tapes")
//                                .overusedFont(weight: .semiBold, size: .h1)
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .padding(.horizontal, 12)
//                            Text("After completing the 5 day training course, you will now have the tools to begin to actually rewire your brain in the mastery course.")
//                                .overusedFont(weight: .medium, size: .p2)
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .padding(.horizontal, 12)
//                                .offset(y: -16)
//                            ForEach(RewireTape.tapes, id: \.id) { tape in
//                                if tape.focus == "Mastery Tape" {
//                                    TapeCard(tape: tape)
//                                }
//                            }
                        }
                        .padding(.vertical)
                        .padding(.bottom, 164)
                    }.padding(.horizontal, 8)
                        .padding(.horizontal)
                }
                Spacer()
            }
        }.fullScreenCover(isPresented: $educationVM.showAudioDetails) {
            AudioDetailScreen()
                .environmentObject(educationVM)
                .environmentObject(mainVM)
        }
        .onAppearAnalytics(event: "TapeScreen: Screenload")

    }
}

struct TapeCard: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var educationVM: EducationViewModel
    let tape: RewireTape
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    SharedComponents.CustomMediumSmallMediumText(title: tape.title, color: Color(hex: "#64A2FF"))
                        .padding(.top)
                        .padding(.leading)
                    Spacer()
                    Text(getStatusText(for: tape))
                        .font(FontManager.overUsedGrotesk(type: .bold, size: .p3))
                        .foregroundColor(getStatusColor(for: tape))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(getStatusColor(for: tape).opacity(0.2))
                        .cornerRadius(12)
                        .padding(.top)
                        .padding(.trailing)
                }
                
                Image(tape.coverImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .cornerRadius(24)
                    .opacity(!educationVM.isTapeAvailable(tape) ? 0.5 : 1)
                
                Text(tape.description)
                    .overusedFont(weight: .medium, size: .p2)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .opacity(!educationVM.isTapeAvailable(tape) ? 0.5 : 1)
                
                playButton(for: tape)
                
                if tape.id <= 5 {
                    completionCount
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(!educationVM.isTapeAvailable(tape) ? Color.black.opacity(0.5) : Color.white.opacity(0.1))
                    .overlay(SharedComponents.clearShadow)
            )
        }
    }
    
    private var completionCount: some View {
        HStack {
            Spacer()
            SharedComponents.CustomMediumSmallMediumText(
                title: "\(tape.id == 1 ? 32421 : tape.id == 2 ? 30421 : tape.id == 3 ? 29421 : tape.id == 4 ? 27421 : 25671)  users completed",
                color: .white
            )
            .padding(.trailing)
            .padding(.bottom)
            .opacity(educationVM.isTapeAvailable(tape) ? 1 : 0.4)
        }
    }
    
    private func playButton(for tape: RewireTape) -> some View {
        HStack {
            if !mainVM.currUser.isPro {
                Text("Unlock Seed Pro")
                    .overusedFont(weight: .medium, size: .h3p1)
            } else {
                if educationVM.isTapeAvailable(tape) {
                    Image(systemName: "play.fill")
                    Text("Play Tape \(tape.id)")
                        .overusedFont(weight: .medium, size: .h3p1)
                } else {
                    Image(systemName: "lock.fill")
                    Text("\(tape.focus == "Mastery Tape" ? "Mastery Tape Locked" : "Tape \(tape.id) Locked")")
                        .overusedFont(weight: .medium, size: .h3p1)
                }
            }
        }
        .foregroundColor(.white)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            SharedComponents.Gradients.primary
                .clipShape(Capsule())
                .background(
                    SharedComponents.Gradients.primary
                        .clipShape(Capsule())
                )
        )
        .frame(height: 60)
        .padding(16)
        .opacity(mainVM.currUser.isPro && !educationVM.isTapeAvailable(tape) ? 0.5 : 1)
        .onTapGesture {
            handleTapAction(for: tape)
        }
    }
    
    private func handleTapAction(for tape: RewireTape) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if !mainVM.currUser.isPro {
            Analytics.shared.log(event: "TapeScreen: Locked Seed Pro")
            Superwall.shared.register(event: "feature_locked", params: ["screen":"tapes"], handler: mainVM.handler)
        } else {
            if educationVM.isTapeAvailable(tape) {
                Analytics.shared.log(event: "TapeScreen: Tapped Play Tape")
                educationVM.selectedTape = tape
                educationVM.showAudioDetails = true
            }
        }
    }
    
    private func getStatusText(for tape: RewireTape) -> String {
        if educationVM.isTapeCompleted(tape) {
            return "Completed"
        } else if educationVM.isTapeAvailable(tape) {
            return "Unlocked"
        } else if educationVM.willBeTapeAvailableTomorrow(tape) {
            return "Available Tomorrow"
        } else {
            return mainVM.currUser.isPro ? "Locked" : "Seed Pro Only"
        }
    }
    
    private func getStatusColor(for tape: RewireTape) -> Color {
        if educationVM.isTapeCompleted(tape) {
            return .green
        } else if educationVM.isTapeAvailable(tape) {
            return .blue
        } else {
            return .gray
        }
    }
}

#Preview {
    CoursesScreen()
}
