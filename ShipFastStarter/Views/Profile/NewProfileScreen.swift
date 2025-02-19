//
//  NewProfileScreen.swift
//  Resolved
//
//  Created by Dante Kim on 10/10/24.
//

import SwiftUI
import SwiftData
import SplineRuntime
import AuthenticationServices
import SuperwallKit

struct NewProfileScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessionHistory: [SoberInterval]
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var shieldVM: ShieldViewModel
    @EnvironmentObject var timerVM: TimerViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @State private var currentSeed = ""
    @Query private var user: [User]
    @State private var daysCount: Int = 0

    @State private var currentStreak: Int = 0
    @State private var notesCount = 0
    
    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Text("Profile")
                            .overusedFont(weight: .semiBold, size: .h1Big)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                        Spacer()
                        Image(systemName: "flag.checkered")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28)
                            .foregroundColor(.white)
                            .opacity(0.4)
                            .padding(.trailing, 12)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation {
                                    Analytics.shared.log(event: "ProfileScreen: Tapped Milestones")
                                    profileVM.showMilestones = true
                                }
                            }
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28)
                            .foregroundColor(.white)
                            .opacity(0.4)
                            .padding(.trailing, 12)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation {
                                    Analytics.shared.log(event: "ProfileScreen: Tapped Settings")
                                    profileVM.showSettings = true
                                }
                            }
                    }
                    .padding(.horizontal)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            VStack(spacing: 16) {
                                Image(mainVM.currentInterval.seed)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)
                                    .offset(y: 12)
                                    .onTapGesture {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation {
                                            profileVM.showMilestones = true
                                        }
                                    }
                                HStack(alignment: .center) {
                                    Text("\(mainVM.currUser.name)")
                                        .font(FontManager.overUsedGrotesk(type: .bold, size: .h1))
                                        .foregroundColor(.white)
                                    if mainVM.currUser.isPro {
                                        Text("Seed+ Pro")
                                            .font(FontManager.overUsedGrotesk(type: .bold, size: .p3))
                                            .foregroundColor(.blue)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(12)
                                            .offset(y: 2)
                                    }
                                }
                                
                                HStack(spacing: 0) {
                                    StatItem(value: daysCount, label: "days")
                                    Spacer()
                                    StatItem(value: currentStreak, label: "streak")
                                    Spacer()
                                    StatItem(value: notesCount, label: "notes")
                                        .onTapGesture {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            withAnimation {
                                                mainVM.currentPage = .course
                                            }
                                        }
                                }.padding(.bottom)
                                .padding(.horizontal, 32)
                            }
                            .padding()
                            .frame(maxWidth: .infinity) // Make width span entire screen
                            .background(Color.white.opacity(0.1)    .cornerRadius(16))
                            .padding(.horizontal, 20)
                            .cornerRadius(16)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Challenges")
                                    .font(FontManager.overUsedGrotesk(type: .semiBold, size: .h3))
                                    .foregroundColor(.white)
                                    .padding(.leading, 8)
                                
                                ForEach(profileVM.allChallenges, id: \.id) { challenge in
                                    ChallengeCard(challenge: challenge)
                                        .environmentObject(homeVM)
                                        .environmentObject(profileVM)
                                        .onTapGesture {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            withAnimation {
                                                profileVM.selectedChallenge = challenge
                                                if challenge.currentStatus == "in progress" || challenge.currentStatus == "(joined) starts soon.." {
                                                    Analytics.shared.log(event: "ProfileScreen: Tap Card Show Timer")
                                                    profileVM.showTimer = true
                                                    profileVM.presentChallenge = true
                                                } else {
                                                    Analytics.shared.log(event: "ProfileScreen: Tapped Challenge Card")
                                                    profileVM.presentChallenge = true
                                                }
                                            }
                                        }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity) // Make width span entire screen
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(16)
                            
                            VStack {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("History")
                                        .font(FontManager.overUsedGrotesk(type: .semiBold, size: .h3))
                                        .foregroundColor(.white)
                                        .padding(.leading, 20)
                                    
                                    ForEach(sessionHistory.reversed(), id: \.self) { session in
                                        HistoryCard(session: session)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                // Add more components here as needed
                                if !UserDefaults.standard.bool(forKey: "tappedCommunity") || !mainVM.currUser.isPro {
                                    DiscordCard()
                                        .environmentObject(mainVM)
                                }
                            }
                            .padding(.bottom, 144)

                            
                        }
                    }
                }
                .frame(maxWidth: .infinity) // Make width span entire screen
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .identity))
        }
   
        .onAppear {
            currentSeed = sessionHistory.first?.seed ?? ""


            for session in sessionHistory {
                notesCount += session.motivationalNotes.count
                notesCount += session.thoughtNotes.count
                notesCount += session.lapseNotes.count
            }
            
            if let currentSession = sessionHistory.last {
                currentStreak = Date.getCurrentStreak(date1: currentSession.startDate, date2: Date().toString(format: "dd-MM-yyyy HH:mm:ss"))
            }
            
            fetchSoberIntervals()
            
        }
        .task {
            await profileVM.fetchChallenge()
        }
        .fullScreenCover(isPresented: $profileVM.presentChallenge) {
            ChallengeScreen()
                .environmentObject(profileVM)
                .environmentObject(mainVM)
                .environmentObject(timerVM)
        }.sheet(isPresented: $profileVM.showSettings) {
            ProfileScreen()
                .environmentObject(mainVM)
                .environmentObject(homeVM)
                .environmentObject(timerVM)
                .environmentObject(profileVM)
                .environmentObject(authVM)
                .environmentObject(shieldVM)

        }.sheet(isPresented: $profileVM.showMilestones) {
            Milestones()
                .environmentObject(mainVM)
                .environmentObject(homeVM)
                .environmentObject(timerVM)
                .environmentObject(profileVM)
        }
        .sheet(isPresented: $profileVM.showReferral) {
            ReferralScreen()
                .environmentObject(mainVM)
//                .environmentObject(profileVM)
        }
      
        .onChange(of: mainVM.currUser.challenges) {
         
        
        }
    }
    
    
    func fetchSoberIntervals() {
           let descriptor = FetchDescriptor<SoberInterval>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
           do {
               let currentIntervals = try modelContext.fetch(descriptor)
               daysCount = currentIntervals.reduce(0) { daysCount, interval in
                   let endDate = interval.endDate.toDate() ?? Date()
                   if let startDate = interval.startDate.toDate() {
                       return daysCount + Calendar.current.numberOfDaysBetween(startDate, and: endDate)
                   } else {
                       return daysCount
                   }
               }
               
           } catch {
               print("Error saving new interval: \(error)")
           }
       }
}

struct StatItem: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 0) {
            Text("\(value)")
                .font(FontManager.overUsedGrotesk(type: .bold, size: .huge))
                .foregroundColor(.white)
            Text(label)
                .font(FontManager.overUsedGrotesk(type: .medium, size: .p2))
                .foregroundColor(.primaryBlue)
        }
    }
}

struct ChallengeCard: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var user: [User]
    var challenge: Challenge
    @State private var updatedChallenge: Challenge
    
    init(challenge: Challenge) {
        self.challenge = challenge
        _updatedChallenge = State(initialValue: challenge)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                Text(updatedChallenge.title)
                    .font(FontManager.overUsedGrotesk(type: .bold, size: .h2))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(updatedChallenge.challengers > 2000 ? updatedChallenge.challengers : 11987) participants")
                        .font(FontManager.overUsedGrotesk(type: .medium, size: .p2))
                        .foregroundColor(.gray)
                    Text(updatedChallenge.currentStatus == "challenge completed" ? "finished" : "")
                        .font(FontManager.overUsedGrotesk(type: .medium, size: .p2))
                        .foregroundColor(.primaryBlue)
                }

                Button(action: {
                    handleChallengeAction()
                }) {
                    Text(updatedChallenge.currentStatus)
                        .font(FontManager.overUsedGrotesk(type: .medium, size: .p3))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .cornerRadius(12)
                        .opacity(updatedChallenge.currentStatus == "Join Challenge" ? 1 : 0.5)
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 12)
            VStack {
                SplineView(sceneFileURL:  Bundle.main.url(forResource: updatedChallenge.title == "Winter Arc Challenge" ? "winterArc" : "nut", withExtension: "splineswift"))
                    .frame(width: 220, height: 220)
                    .ignoresSafeArea(.all)
                    .shadow(color: Color.primaryPurple, radius: 30)
                    .padding()
            }
            .frame(width: 130, height: 170)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(updatedChallenge.title == "Winter Arc Challenge" ? Color.darkBlue : Color.darkPurple)
                .overlay(SharedComponents.clearShadow)
        )
        .opacity(updatedChallenge.currentStatus == "challenge completed" ? 0.5 : 1)
        .padding(.vertical)
        .onAppear {
            if let first = user.first {
                profileVM.userJoinedChallenges = first.challenges
                updatedChallenge = profileVM.setChallengeStatus(for: challenge)
            }
        }
        .onChange(of: profileVM.selectedChallenge.challengers) {
            if updatedChallenge.title == "Winter Arc Challenge" {
                self.updatedChallenge = profileVM.selectedChallenge
                updatedChallenge = profileVM.setChallengeStatus(for: challenge)
            }
        }
    }
    
    private func handleChallengeAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation {
            if !FirebaseService.isLoggedIn() {
                homeVM.showSignUpModal = true
                return
            }
            
            if profileVM.presentChallenge {
                handleJoinChallenge()
            } else {
                if challenge.currentStatus == "in progress" {
                    Analytics.shared.log(event: "ProfileScreen: Tap Show Timer")
                    profileVM.showTimer = true
                } else {
                    Analytics.shared.log(event: "ProfileScreen: Tapped Join Challenge")
                    profileVM.selectedChallenge = challenge
                    profileVM.presentChallenge = true
                }
            }
        }
    }
    
    private func handleJoinChallenge() {
        Analytics.shared.log(event: "ChallengeScreen: Tapped Join Challenge Card")
        if !mainVM.currUser.challenges.keys.contains(challenge.title) {
            Task {
                do {
                    var updatedChallenge = challenge
                    updatedChallenge.challengers += 1
                    try await FirebaseService.shared.updateDocument(collection: FirebaseCollection.challenges, object: updatedChallenge)
                    
                    mainVM.currUser.challenges[challenge.title] = Date().toString(format: "dd-MM-yyyy")
                    try await FirebaseService.shared.updateDocument(collection: FirebaseCollection.users, object: mainVM.currUser)
                    
                    await MainActor.run {
                        profileVM.selectedChallenge = updatedChallenge
                        profileVM.userJoinedChallenges = mainVM.currUser.challenges
                        DataManager.shared.saveContext(context: modelContext)
                        profileVM.showTimer = true
                    }
                } catch {
                    print("Error updating challenge: \(error)")
                }
            }
        }
    }
}



struct HistoryCard: View {
    let session: SoberInterval
    @State private var startDate = ""
    @State private var endDate = ""
    @EnvironmentObject var homeVM: HomeViewModel
    @State private var previousSeeds: [String] = []
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Text("")
                    .font(FontManager.overUsedGrotesk(type: .medium, size: .p2))
                    .foregroundColor(.gray)
                Spacer()
                if !endDate.isEmpty {
                    Text("Completed")
                        .font(FontManager.overUsedGrotesk(type: .bold, size: .p3))
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(12)
                        .offset(y: 2)
                } else {
                    Text("In Progress")
                        .font(FontManager.overUsedGrotesk(type: .bold, size: .p3))
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(12)
                        .offset(y: 2)
                }
             
            }
            .padding()
            VStack {
                HStack(spacing: -64) {
                    ForEach(previousSeeds, id: \.self) { seed in
                        Image(seed)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: seed == "originalSeed" ? 128 : 96)
                            .shadow(color: Color.primaryBlue, radius: 45)
                    }
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.85, maxHeight: 130)
                
                HStack {
                    if endDate.isEmpty {
                        VStack {
                            Text("\(startDate) - IN PROGRESS")
                                .overusedFont(weight: .semiBold, size: .h3p1)
                                .foregroundColor(.white)
                            HStack {
//                                Image(systemName: "book.closed.fill")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 24, height: 24)
//                                    .foregroundColor(.primaryBlue)
//                                Text("5 notes")
//                                    .foregroundColor(.white)
//                                    .overusedFont(weight: .medium, size: .h3p1)
                                Spacer()
                                    .frame(width: 32)
                                Image(systemName: "flame.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.red)
                                Text("\((Date.timeDifference(date1: session.startDate, date2: Date().toString(format: "dd-MM-yyyy HH:mm:ss")).1)) \(Date.timeDifference(date1: session.startDate, date2:  Date().toString(format: "dd-MM-yyyy HH:mm:ss")).0)")
                                    .foregroundColor(.white)
                                    .overusedFont(weight: .medium, size: .h3p1)
                            }
                        }
                    } else {
                        VStack {
                            Text("\(startDate) - \(endDate)")
                                .overusedFont(weight: .semiBold, size: .h3p1)
                                .foregroundColor(.white)
                            HStack {
                                Text("🔥 \(Date.timeDifference(date1: session.startDate, date2: session.endDate).1) \((Date.timeDifference(date1: session.startDate, date2: session.endDate).0))")
                                    .foregroundColor(.white)
                            }
                         
                        }
                    }
                }
                .padding(.bottom)
              
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.1))
                .overlay(SharedComponents.clearShadow)
        )
        .padding()
        .onAppear {
            startDate = Date.changeDateFormat(dateString: session.startDate, fromFormat: "dd-MM-yyyy HH:mm:ss", toFormat: "MMM dd, yyyy")
            endDate = Date.changeDateFormat(dateString: session.endDate, fromFormat: "dd-MM-yyyy HH:mm:ss", toFormat: "MMM dd, yyyy")
            previousSeeds = Orb.getPreviousSeeds(currentSeed: session.seed)
        }
    }
}

#Preview {
    NewProfileScreen()
        .environmentObject(MainViewModel())
}
