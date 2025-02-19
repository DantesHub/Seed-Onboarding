//
//  ChallengeScreen.swift
//  Resolved
//
//  Created by Dante Kim on 10/10/24.
//

import SwiftUI
import SwiftData
import SplineRuntime
import UserNotifications

struct ChallengeScreen: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var timerVM: TimerViewModel
    @EnvironmentObject var homeVM: HomeViewModel

    @Environment(\.modelContext) private var modelContext
    @Query private var user: [User]
    @State  var currentOrbURL: String = ""
    @State  var url: URL?
    @State  var isAnimating: Bool = true
    @State private var isVisible: Bool = true
    @State private var notificationsEnabled = false
    let startDate = Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 1, hour: 0, minute: 0, second: 0)) ?? Date()
    
    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            if !profileVM.showTimer {
                VStack {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(.white))
                            .onTapGesture {
                                withAnimation {
                                    Analytics.shared.log(event: "ChallengeScreen: Tapped X")
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    profileVM.presentChallenge = false
                                }
                            }
                            .padding(.top, 64)
                            .foregroundColor(.white)
                        Spacer()
                    }.padding(.horizontal, 24)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            ChallengeCard(challenge: profileVM.selectedChallenge)
                                .environmentObject(profileVM)
                                .padding()
                            
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 12) {
                                    VStack {
                                        Image(systemName: "hourglass")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20)
                                            .foregroundColor(.primaryBlue)
                                    }
                                    .frame(width: 24)
                                    
                                    Text("\(profileVM.selectedChallenge.length) days")
                                        .font(FontManager.overUsedGrotesk(type: .medium, size: .p2))
                                        .foregroundColor(.white)
                                }
                                
                                HStack(spacing: 12) {
                                    VStack {
                                        Image(systemName: "calendar")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24)
                                            .foregroundColor(.blue)
                                    }
                                    .frame(width: 24)
                                    Text("\(profileVM.selectedChallenge.startDate.toString(format: "MMM dd"))")
                                        .font(FontManager.overUsedGrotesk(type: .medium, size: .p2))
                                        .foregroundColor(.white)
                                }
                                
                                
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "bell.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24)
                                        .foregroundColor(.blue)
                                    Text("Check-ins are at 9 PM! Not allowed to miss more than 3x this month.")
                                        .font(FontManager.overUsedGrotesk(type: .medium, size: .p2))
                                        .foregroundColor(.white)
                                }
                                if !notificationsEnabled {
                                    SharedComponents.PrimaryButton(title: "Turn on notifications") {
                                        Analytics.shared.log(event: "ChallengeScreen: Tapped Turn On Reminders")
                                        requestNotificationPermission()
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    //                                Text("CHALLENGERS")
                                    //                                    .overusedFont(weight: .medium, size: .p2)
                                    //                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    //                                    .foregroundColor(.white)
                                    Text("\(profileVM.selectedChallenge.challengers > 2000 ? profileVM.selectedChallenge.challengers  : 11371)")
                                        .overusedFont(weight: .bold, size: .titleHuge)
                                        .foregroundColor(.primaryBlue)
                                    Text("total challengers")
                                        .overusedFont(weight: .medium, size: .p2)
                                        .foregroundColor(.white)
                                        .offset(y: -4)
                                }.padding(.top, 24)
                                if FirebaseService.isLoggedIn() {
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack(alignment: .bottom, spacing: 10)  {
                                            Text("\(profileVM.selectedChallenge.noRelapse)")
                                                .overusedFont(weight: .bold, size: .title)
                                                .foregroundColor(.white)
                                            Text("did not relapse")
                                                .overusedFont(weight: .medium, size: .p2)
                                                .foregroundColor(.primaryBlue)
                                                .offset(y: -8)
                                            
                                        }
                                        HStack(alignment: .bottom, spacing: 10) {
                                            Text("\(profileVM.selectedChallenge.oneRelapse)")
                                                .overusedFont(weight: .bold, size: .title)
                                                .foregroundColor(.white)
                                            Text("relapsed once")
                                                .overusedFont(weight: .medium, size: .p2)
                                                .foregroundColor(.primaryBlue)
                                                .offset(y: -8)
                                        }
                                        HStack(alignment: .bottom, spacing: 10)  {
                                            Text("\(profileVM.selectedChallenge.twoRelapse)")
                                                .overusedFont(weight: .bold, size: .title)
                                                .foregroundColor(.white)
                                            Text("relapsed twice")
                                                .overusedFont(weight: .medium, size: .p2)
                                                .foregroundColor(.primaryBlue)
                                                .offset(y: -8)
                                        }
                                        HStack(alignment: .bottom, spacing: 10)  {
                                            Text("\(profileVM.selectedChallenge.threeRelapse)")
                                                .overusedFont(weight: .bold, size: .title)
                                                .foregroundColor(.white)
                                            Text("relapsed 3x")
                                                .overusedFont(weight: .medium, size: .p2)
                                                .foregroundColor(.primaryBlue)
                                                .offset(y: -8)
                                        }
                                        HStack(alignment: .bottom, spacing: 10)  {
                                            Text("\(profileVM.selectedChallenge.fourRelapse)")
                                                .overusedFont(weight: .bold, size: .title)
                                                .foregroundColor(.white)
                                            
                                            Text("relapsed 4x")
                                                .overusedFont(weight: .medium, size: .p2)
                                                .foregroundColor(.primaryBlue)
                                                .offset(y: -8)
                                        }
                                        HStack(alignment: .bottom, spacing: 10)  {
                                            Text("\(profileVM.selectedChallenge.fiveRelapse)")
                                                .overusedFont(weight: .bold, size: .title)
                                                .foregroundColor(.white)
                                            Text("relapsed 5x")
                                                .overusedFont(weight: .medium, size: .p2)
                                                .foregroundColor(.primaryBlue)
                                                .offset(y: -8)
                                        }
                                        HStack(alignment: .bottom, spacing: 10)  {
                                            Text("\(profileVM.selectedChallenge.sixRelapse)")
                                                .overusedFont(weight: .bold, size: .title)
                                                .foregroundColor(.white)
                                            Text("relapsed 6x")
                                                .overusedFont(weight: .medium, size: .p2)
                                                .foregroundColor(.primaryBlue)
                                                .offset(y: -8)
                                        }
                                    }
                                    
                                }
                                
                                Text("\(profileVM.selectedChallenge.description)")
                                    .frame(minHeight: 100)
                                    .font(FontManager.overUsedGrotesk(type: .medium, size: .p2))
                                    .foregroundColor(.white)
                                    .padding(.top, 8)
                                
                                
                            }
                            .padding()
                            .cornerRadius(16)
                            .padding(.horizontal)
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Reward: \(profileVM.selectedChallenge.title == "Winter Arc Challenge" ? "The Snowglobe" : "The Nut")")
                                            .font(FontManager.overUsedGrotesk(type: .bold, size: .h2))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                        Text("How to unlock")
                                            .font(FontManager.overUsedGrotesk(type: .semiBold, size: .h3p1))
                                            .foregroundColor(.gray)
                                        Text("Must be sober on at least 15 days")
                                            .font(FontManager.overUsedGrotesk(type: .medium, size: .p2))
                                            .foregroundColor(.primaryBlue)
                                    }.padding(.leading)
                                    
                                    VStack {
                                        SplineView(sceneFileURL: Bundle.main.url(forResource: "winterArc", withExtension: "splineswift"))
                                            .frame(width: 180, height: 180)
                                            .ignoresSafeArea(.all)
                                            .shadow(color: Color.primaryPurple, radius: 30)
                                            .padding()
                                    }
                                    .frame(width: 110, height: 175)
                                }
                                
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        SharedComponents.clearShadow
                                    )
                            )
                            .padding()
                            HStack(spacing: 12) {
                                SharedComponents.PrimaryButton(title: profileVM.selectedChallenge.currentStatus) {
                                    if !FirebaseService.isLoggedIn() {
                                        homeVM.showSignUpModal = true
                                    } else {
                                        if !mainVM.currUser.challenges.keys.contains(profileVM.selectedChallenge.title) {
                                            //                                                Task {
                                            //                                                    await profileVM.fetchChallenge()
                                            //                                                }
                                            Analytics.shared.logActual(event: "ChallengeScreen: Tapped Join Challegnge", parameters: ["challegne": profileVM.selectedChallenge.title])
                                            mainVM.currUser.challenges[profileVM.selectedChallenge.title] = Date().toString(format: "dd-MM-yyyy")
                                            profileVM.userJoinedChallenges = mainVM.currUser.challenges
                                            profileVM.selectedChallenge.challengers += 1
                                            profileVM.selectedChallenge = profileVM.setChallengeStatus(for: profileVM.selectedChallenge)
                                            DataManager.shared.saveContext(context: modelContext)
                                            // need to update firebase challenges firebase right here as well as user
                                            Task {
                                                try await FirebaseService.shared.updateDocument(collection: FirebaseCollection.users, object: mainVM.currUser)
                                                try await FirebaseService.shared.updateDocument(collection: FirebaseCollection.challenges, object: profileVM.selectedChallenge)
                                            }
                                        }
                                    }
                                }.padding()
                                    .opacity(profileVM.selectedChallenge.currentStatus == "Join Challenge" ? 1 : 0.5)
                            }
                            .padding(.vertical)
                            .padding(.bottom, 96)
                        }
                    }
                }
            } else {
                GeometryReader { geometry in
                    ZStack {
                        Image(.justBackground)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .edgesIgnoringSafeArea(.all)
                        VStack {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 28)
                                    .onTapGesture {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation {
                                            //                                                profileVM.showTimer = false
                                            profileVM.presentChallenge = false
                                        }
                                    }
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "info.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 28)
                                    .onTapGesture {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation {
                                            profileVM.showTimer = false
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .padding(.trailing)
                            }
                            .padding(.horizontal, 48)
                            .padding(.bottom)
                            .padding(.top, 48)
                            .offset(x: -8)
                            
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
//                                    TimeDisplay(timerVM: timerVM)
//                                    //                            .frame(width: 300)
//                                        .foregroundColor(.white)
                                    if (Date() < startDate) {
                                        Text("time left in\nWinter Arc")
                                            .frame(width: geometry.size.width / 2, alignment: .leading)
                                            .overusedFont(weight: .semiBold, size: .h2)
                                            .foregroundColor(.white)
                                            .opacity(0.65)
                                            .padding(.top, 4)
                                        Spacer()
                                        Text("\(profileVM.selectedChallenge.challengers > 2000 ? profileVM.selectedChallenge.challengers : 11371)")
                                            .overusedFont(weight: .bold, size: .titleHuge)
                                            .foregroundColor(.primaryBlue)
                                        Text("challengers")
                                            .overusedFont(weight: .medium, size: .p2)
                                            .foregroundColor(.white)
                                        Spacer()
                                    } else {
                                        Text("time left")
                                            .frame(width: geometry.size.width / 2, alignment: .leading)
                                            .overusedFont(weight: .semiBold, size: .h2)
                                            .foregroundColor(.white)
                                            .opacity(0.65)
                                            .padding(.top, 4)
                                    }
                                }
                                .offset(y: -48)
                                
                                VStack {
                                    VStack {
                                        SplineView(sceneFileURL: Bundle.main.url(forResource: "winterArc", withExtension: "splineswift"))
                                            .frame(width: 500, height: 500)
                                            .ignoresSafeArea(.all)
                                            .padding()
                                            .id(url)
                                            .animation(isAnimating ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : nil, value: isAnimating)
                                            .shadow(color: Color.primaryPurple, radius: 120)
                                            .shadow(color: .black.opacity(0.25), radius: 2.74199, x: 0, y: 5.48398)
                                    }.frame(width: 175, height: 400)
                                        .offset(x: 50, y: 0)
                                }
                            }.padding(.horizontal, 32)
                            Spacer()
                        }
                    }.offset(y: -32)
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .identity))
                .onAppearAnalytics(event: "NNNTimerScreen: Screenload")
            }
        }  .onAppear {
                    if let first = user.first {
                        profileVM.userJoinedChallenges = first.challenges
                        profileVM.selectedChallenge = profileVM.setChallengeStatus(for: profileVM.selectedChallenge)
                        mainVM.currUser = first
                        timerVM.initNNNTimer()
                    }
                    checkNotificationStatus()
                }
        }
    
     func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                notificationsEnabled = granted
                if granted {
                    mainVM.loadingText = "✅ notifications on"
                    mainVM.showToast = true
                    NotificationManager.scheduleFallenNotification(mainVM: mainVM)
                    // Schedule notifications if permission granted
                    profileVM.initializeChallenge()
                }
            }
        }
    }
}

#Preview {
    ChallengeScreen()
        .environmentObject(ProfileViewModel())
        .environmentObject(MainViewModel())
}
