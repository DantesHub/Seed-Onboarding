//
//  SettingsScreen.swift
//  NoFap
//
//  Created by Dante Kim on 7/10/24.
//

import StoreKit
import SuperwallKit
import SwiftUI
import UserNotifications
import FirebaseAuth
import SwiftData
import AuthenticationServices
import RevenueCatUI

struct ProfileScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
//    @EnvironmentObject private var shieldVM: ShieldViewModel
    @EnvironmentObject private var profileVM: ProfileViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var manager: ShieldViewModel
    
//    @StateObject private var manager = ShieldViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query private var user: [User]
    @Query private var sessionHistory: [SoberInterval]
    @State private var showActivityView = false
    @State private var showActivityPicker = false
    @State private var showRatingAlert = false
    @State private var showNotificationAlert = false
    @State private var notificationsEnabled: Bool = true
    @State private var isSignedIn = false
    @State private var syncedData = false
    @State private var signInWithApple = false
    @State private var showReligion = false
    @State private var showTimeSheet = false
    @State private var showCustomerCenter = false
    @State private var selectedOption = "3 mins"
    let checkInOptions = [
        "3 mins",
        "5 mins",
        "10 mins",
        
        "30 mins",
        "1 hour",
        "2 hours",
        "4 hours",
        "8 hours",
        "1 day"
    ]

    
    var body: some View {
        GeometryReader { g in
            let width = g.size.width
            ZStack {
                Color(hex: "#1C1C1E").edgesIgnoringSafeArea(.all)
                VStack {
                    HStack(alignment: .center, spacing: 0) {
                        Text("Settings")
                            .overusedFont(weight: .semiBold, size: .h1Big)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                        //            if let currUser = mainVM.currUser, currUser.fitcheck {
                        //                Text("🔥\(mainVM.currUser?.streak ?? 0)")
                        //                    .clash(type: .semibold, size: .h3p1)
                        //                    .foregroundColor(Color(.white))
                        //                    .padding(.leading, 12)
                        //            }

                        Spacer()
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(.white))
                            .onTapGesture {
                                withAnimation {
                                    Analytics.shared.log(event: "ProfileScreen: Tapped Profile")
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                    mainVM.showProfile.toggle()
                                    profileVM.showSettings = false
                                }
                            }
                    }.padding(.horizontal, 28)
                    .padding(.top, 24)
                    // Subscribe CTA
//                    VStack(alignment: .leading, spacing: 4) {
//                         Text("Subscription")
//                             .font(.headline)
//                             .fontWeight(.bold)
//                             .foregroundColor(.white)
//
//                         HStack(spacing: 4) {
//                             Image(systemName: "bolt.fill")
//                                 .foregroundColor(.purple)
//                             Text("Subscribed to Opal Pro (Trial)")
//                                 .font(.subheadline)
//                                 .foregroundColor(.blue)
//                         }
//
//                         Text("Renews on 17 Jan 2023")
//                             .font(.caption)
//                             .foregroundColor(.gray)
//                     }
//                     .padding(.leading)
//                     .frame(width: width * 0.8, alignment: .leading)
//                     .padding()
//                     .background(Color.secondaryBackground)
//                     .cornerRadius(12)
//                     .shadow(radius: 5)
                    // Achievements
//                    VStack(alignment: .leading, spacing: 20) {
//                           Text("Your Milestones")
//                               .font(.title)
//                               .fontWeight(.bold)
//                               .foregroundColor(.white)
//                               .padding(.leading)
//
//                           LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
//                               BadgeView(title: "First Gem", subtitle: "You Installed Opal", color: .purple)
//                               BadgeView(title: "Unwavering Gem", subtitle: "Get Opal Pro", color: .blue)
//                               BadgeView(title: "Original Gem", subtitle: "Early Adopter", color: .indigo)
//                               BadgeView(title: "Motivated Gem", subtitle: "Use Opal for 2 Days", color: .mint)
//                           }
//                           .padding(.horizontal, 24)
//                       }
                    List {
                        Section("Your Settings") {
                            if !mainVM.currUser.isPro {
                                HStack {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.blue)
                                    Text("Unlock Seed Pro")
                                    Spacer()
                                }.onTapGesture {
                                    Analytics.shared.log(event: "PricingScreen: From Settings")
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation {
                                        profileVM.showSettings = false
                                        Superwall.shared.register(event: "feature_locked", params: ["screen": "settings"], handler: mainVM.handler) {}
                                        // fetch sober intervals and save to userDefaults
                                    }
                                }
                            }

                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("Rate the App")
                                Spacer()
                            }
                            .onTapGesture {
                                Analytics.shared.log(event: "SettingsScreen: Tapped Rate")
                                requestReview()
                            }
                      
//                            HStack {
//                           
//                                Text("💸")
//                                    .sfFont(weight: .bold, size: .h2)
//                                Text("Become a Seed Ambassador")
//                                Spacer()
//                            }
//                            .onTapGesture {
//                                Analytics.shared.log(event: "SettingsScreen: Tapped Ambassador")
//                                if let url = URL(string: "https://forms.gle/HDJ8w9kyxPBKSH167") {
//                                    UIApplication.shared.open(url)
//                                }
//                            }
                            //MARK: - TODO
//                            HStack {
//                                Image(systemName: "ticket.fill")
//                                    .foregroundColor(.red)
//                                Text("support@tryseed.app")
//                                Spacer()
//                            }
//                            .onTapGesture {
//                                Analytics.shared.log(event: "SettingsScreen: Tapped Referral")
//                                profileVM.showSettings = false
//                                profileVM.showReferral = true
//                            }
                            HStack {
                                Image(systemName: "book.fill")
                                    .foregroundColor(.primaryPurple)
                                Text("Religion: \(mainVM.currUser.religion)")
                                Spacer()
                            }
                            .onTapGesture {
                                Analytics.shared.log(event: "SettingsScreen: Tapped Religion")
                                showReligion = true
                            }
//                            HStack {
//                                Image(systemName: "lock.fill")
//                                    .foregroundColor(.red)
//                                Text("Blocked Apps")
//                                Spacer()
//                            }
//                            .onTapGesture {
//                                Analytics.shared.log(event: "SettingsScreen: Tapped Blocked Apps")
//                                showActivityPicker = true
//                            }
//                            
                            HStack {
                                Image(systemName: "timer.circle.fill")
                                    .foregroundColor(.red)
                                Text("Blocked Timer: \(UserDefaults.standard.string(forKey: "savedTime") ?? "3 mins")")
                                Spacer()
                            }
                            .onTapGesture {
                                Analytics.shared.log(event: "SettingsScreen: Tapped Blocked Timer")
                                showTimeSheet = true
                            }


                            HStack {
                                Image(systemName: "ticket.fill")
                                    .foregroundColor(.red)
                                Text("Referral Code")
                                Spacer()
                            }
                            .onTapGesture {
                                Analytics.shared.log(event: "SettingsScreen: Tapped Referral")
                                profileVM.showSettings = false
                                profileVM.showReferral = true
                            }
                            HStack {
                                Image(systemName: "bell")
                                Text("Notifications")
                                Spacer()
                                Toggle("", isOn: $notificationsEnabled)
                                    .labelsHidden()
                                    .onChange(of: notificationsEnabled) { newValue in
                                        handleNotificationToggle(newValue)
                                    }
                            }
                            .onAppear {
                                checkNotificationStatus()
                            }
//                            HStack {
//                                Image(.discordicon)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 24)
//                            }

                            HStack {
                                Image(systemName: "gift.fill")
                                Text("Invite a friend")
                            }.onTapGesture {
                                showActivityView = true

                            }.sheet(isPresented: $showActivityView) {
                                let content = "I'm inviting you to download and install the Seed app https://apps.apple.com/us/app/protect-your-seed-quit-porn/id6636516894"
                                ActivityView(activityItems: [content])
                            }
                            HStack {
                                Image(systemName: "arrow.circlepath")
                                Text("Customer Support Center")
                            }.onTapGesture {
                                Analytics.shared.log(event: "")
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation {
                                    showCustomerCenter = true
                                }
                            }
                            
                            HStack {
                                Image(systemName: "cloud.fill")
                                Text("Resync cloud data \(syncedData ? "✅ Synced" : "")")
                            }.onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation {
                                    resyncData()
                                }
                            }




//                            HStack {
//                                Image(systemName: "ladybug.fill")
//                                Text("Submit Bug Report or Question")
//                            }.onTapGesture {
//                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                if let url = URL(string: "https://imported-periodical-608.notion.site/130ca98e4f9980899fb8c9909db04c87?pvs=105") {
//                                    UIApplication.shared.open(url)
//                                }
//                            }

//                            HStack {
//                                Image(systemName: "hand.raised.fill")
//                                Text("Submit feature request!")
//                            }.onTapGesture {
//                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                if let url = URL(string: "https://discord.gg/qyWWzgkpJF") {
//                                    UIApplication.shared.open(url)
//                                }
//                            }
                            
                            if isSignedIn {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.forward.fill")
                                    Text("Sign Out")
                                }.foregroundColor(Color.red)
                                    .onTapGesture {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation {
                                            do {
                                                mainVM.onboardingScreen = .first
                                                mainVM.currentPage = .onboarding
                                                try FirebaseService.shared.signOut()
                                            } catch {
                                                print(error.localizedDescription, "signing out")
                                            }
                                        }
                                    }
                            } else {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.forward.fill")
                                    Text("Sign In With Apple")
                                }.foregroundColor(Color.white)
                                .onTapGesture {
                                    Analytics.shared.log(event: "SettingsScreen: Tapped Sign in")
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation {
                                        signInWithApple = true
                                    }
                                }
                            }
                            
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete my Account")
                            }.foregroundColor(Color.red)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    let domain = Bundle.main.bundleIdentifier!
                                    UserDefaults.standard.removePersistentDomain(forName: domain)
                                    UserDefaults.standard.synchronize()

                                    do {
                                        mainVM.onboardingScreen = .first
                                        mainVM.currentPage = .onboarding
                                        try FirebaseService.shared.signOut()
                                        Task {
                                            if let userId = UserDefaults.standard.string(forKey: Constants.userId) {
                                                try await FirebaseService.shared.deleteDocument(collection: .users, documentId: userId)
                                            }
                                        }

                                    } catch {
                                        print(error.localizedDescription, "signing out")
                                    }
                                }
//                            ShieldView()
//                                .environmentObject(manager)
//                                .task(id: "requestAuthorizationTaskID") {
//                                    await manager.requestAuthorization()
//                                }
                        }
                        if mainVM.currUser.appleToken.isEmpty {
                            Text(mainVM.currUser.appleToken)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    UIPasteboard.general.string = mainVM.currUser.appleToken
                                }
                        }
                    
                        
                        if !mainVM.currUser.email.isEmpty {
                            Text(mainVM.currUser.email)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    UIPasteboard.general.string = mainVM.currUser.email
                                }
                        }
                  
                        Text(UserDefaults.standard.string(forKey: Constants.userId) ?? "")
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                UIPasteboard.general.string = UserDefaults.standard.string(forKey: Constants.userId) ?? ""
                            }
                        if mainVM.currUser.id != UserDefaults.standard.string(forKey: Constants.userId) ?? "" {
                            Text(mainVM.currUser.id)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    UIPasteboard.general.string = mainVM.currUser.id
                                }
                        }
                    }.colorScheme(.dark)
                }
            }.onAppear {
                syncedData = false
                if let user = Auth.auth().currentUser {
                    isSignedIn = true
                    print("signed in boy")
                } else {
                    isSignedIn = false
                    print("not signed in boy")

                }
            }
            .familyActivityPicker(
                isPresented: $showActivityPicker,
                selection: $manager.familyActivitySelection
            )
            .sheet(isPresented: $showReligion) {
                ReligionScreen()
                    .environmentObject(mainVM)
            }
            .sheet(isPresented: $showCustomerCenter) {
                CustomerCenterView()
            }
            
            .sheet(isPresented: $showTimeSheet) {
                VStack {
                    // Animate the Picker
                    Group {
                        Picker("Select an option", selection: $selectedOption) {
                            ForEach(checkInOptions, id: \.self) { option in
                                Text(option)
                                    .tag(option)
                                    .overusedFont(weight: .medium, size: .h2)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .foregroundColor(.white)
                        .colorScheme(.dark)
                        
                    }.padding(.top, 32)
                    SharedComponents.PrimaryButton(title: "Save") {
                        Analytics.shared.log(event: "SettingsScreen: Saved Time")
                        showTimeSheet = false
                        UserDefaults.standard.setValue(selectedOption, forKey: "savedTime")
                    }.padding(.vertical)
                }.padding(.horizontal)
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $signInWithApple) {
                ZStack {
                    Image(.justBackground)
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                    SignInWithAppleButton { request in
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        authVM.handleSignInWithAppleRequest(request)
                    } onCompletion: { result in
                        authVM.handleSignInWithAppleCompletion(result, mainVM)
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 56)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.4), lineWidth: 2)
                    )
                    .padding()
                }
                .presentationDetents([.height(100)])
            }
        }
//        .onAppear {
//            shieldVM.reloadSavedSelection()
//        }
//        .familyActivityPicker(
//            isPresented: $showActivityPicker,
//            selection: $shieldVM.familyActivitySelection
//        )
    }

    func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = (settings.authorizationStatus == .authorized)
            }
        }
    }

    func handleNotificationToggle(_ newValue: Bool) {
        if newValue {
            requestNotificationPermission()

        } else {
            showNotificationAlert = true
        }
    }
    
    func resyncData() {
        if isSignedIn {
            if let firstUser = user.first {
                Task {
                    print(firstUser.name, "bro what are u doing")
                    if let fbUser = await mainVM.fetchUser(id: firstUser.id), let user = user.first {
                        print("fetched from firebase", fbUser.name)
                        if !fbUser.name.isEmpty && user.name.isEmpty {
                            mainVM.currUser = fbUser
                            user.updateFromFirebase(fbUser: fbUser)
                            DataManager.shared.saveContext(context: modelContext)
                            syncedData = true
                        }
                    }
                    
                    var fbSoberIntervals: [SoberInterval] = []
                    FirebaseService.getIntervals(for: firstUser.id) { result in
                        switch result {
                        case let .success(intervals):
                            fbSoberIntervals = intervals
                            syncedData = true
                            // If local has more intervals than Firebase, upload the new ones
                            if sessionHistory.count > fbSoberIntervals.count {
                                let newIntervals = sessionHistory.filter { localInterval in
                                    !fbSoberIntervals.contains { fbInterval in
                                        fbInterval.id == localInterval.id
                                    }
                                }
                                
                                // Upload new intervals to Firebase
                                Task {
                                    for interval in newIntervals {
                                        FirebaseService.shared.addDocument(interval, collection: "intervals") { str in
                                        }
                                    }
                                }
                            } else {
                                // Firebase has more/equal intervals, update local SwiftData
                                for interval in fbSoberIntervals {
                                    if let existingIndex = sessionHistory.firstIndex(where: { $0.id == interval.id }) {                                                     
                                        sessionHistory[existingIndex].startDate = interval.startDate
                                        sessionHistory[existingIndex].endDate = interval.endDate
                                        sessionHistory[existingIndex].seed = interval.seed
                                        sessionHistory[existingIndex].seedTXP = interval.seedTXP
                                        sessionHistory[existingIndex].lastCheckInDate = interval.lastCheckInDate
                                        sessionHistory[existingIndex].reasonsForLapsing = interval.reasonsForLapsing
                                        sessionHistory[existingIndex].lapseNotes = interval.lapseNotes
                                        sessionHistory[existingIndex].motivationalNotes = interval.motivationalNotes
                                        sessionHistory[existingIndex].thoughtNotes = interval.thoughtNotes
                                    } else {
                                        // Add new interval
                                        modelContext.insert(interval)
                                    }
                                }
                                DataManager.shared.saveContext(context: modelContext)
                            }
                            
                        case let .failure(error):
                            print("Error fetching intervals: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    notificationsEnabled = true
                    NotificationManager.scheduleFallenNotification(mainVM: mainVM)
                } else {
                    notificationsEnabled = false
                    showNotificationAlert = true
                }
            }
        }
    }

    func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

#Preview {
    ProfileScreen()
        .environmentObject(MainViewModel())
}

struct BadgeView: View {
    let title: String
    let subtitle: String
    let color: Color
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.clear)
                .frame(height: 100)
                .overlay(
                    Circle()
                        .frame(width: 50, height: 50)
                        .blur(radius: 20)
                )

            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)

            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.darkGray).opacity(0.3))
        .cornerRadius(15)
    }
}
