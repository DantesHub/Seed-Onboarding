//
//  NotificationScreen.swift
//  Resolved
//
//  Created by Dante Kim on 10/12/24.
//

import SwiftUI
import RevenueCat

struct NotificationScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel

    // Animation state variable
    @State private var animateContent = false

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Title Text
                Text("increase your willpower with some notification buffs")
                    .overusedFont(weight: .bold, size: .h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding(.horizontal, 36)
                    // Animation modifiers
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.0), value: animateContent)
                    .padding(.top)

                Spacer()

                // Notification Prompt
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Text("Seed Would Like to Send You Notifications")
                            .font(.system(size: 18, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                            .frame(height: 65)
                            .foregroundColor(.white)
                        Text("Notifications may include alerts, sounds, and icon badges. These can be configured in Settings.")
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .frame(height: 65)
                            .foregroundColor(.white)
                    }
                    .frame(height: 120)
                    .padding(.top, 4)
                    .padding(.bottom)
                    Divider()

                    HStack(alignment: .center, spacing: 0) {
                        Button(action: {
                            // Handle Don’t Allow action
                            Analytics.shared.log(event: "Notifications: Tapped Don't Allow")
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                mainVM.onboardingScreen = .rating
                                homeVM.showWidgetModal = true
                            }
                        }) {
                            Text("Don’t Allow")
                                .font(.system(size: 18))
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .cornerRadius(10, corners: [.bottomLeft])

                        Divider()

                        Button(action: {
                            Analytics.shared.log(event: "Notifications: Tapped Allow")
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            requestNotificationPermission()
                        }) {
                            Text("Allow")
                                .font(.system(size: 18))
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .cornerRadius(10, corners: [.bottomRight])
                    }
                    .frame(height: 40, alignment: .center)
                    .padding(.top, 4)
                }
                .frame(height: 200)
                .background(Color(.black).opacity(0.8))
                .cornerRadius(16)
                .shadow(radius: 10)
                .padding(.horizontal, 52)
                .offset(y: -32)
                .colorScheme(.light)
                // Animation modifiers for the notification prompt
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: animateContent)

                Spacer()

                // Notification Image
                Image(.notification)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 125)
                    .padding(.bottom, 96)
                    // Animation modifiers
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: animateContent)

                Spacer()
            }
        }
        .onAppear {
            UserDefaults.standard.setValue(true, forKey: "sawReferral")
            UserDefaults.standard.setValue(true, forKey: "sawNotification")
            mainVM.currUser.joinDate = Date().toString()
            animateContent = true // Trigger animations when view appears
        }
        .onAppearAnalytics(event: "NotificationScreen: Screenload")
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                    if granted {
                    Task {
                        await mainVM.fetchCheckInDay(daysSince: -1)
                    }

                    Analytics.shared.log(event: "Notifications: Granted Permission")
                    NotificationManager.scheduleFallenNotification(mainVM: mainVM)
                } else {
                    print("Notification permission denied.")
                    Analytics.shared.log(event: "Notifications: Denied Permission")
                }

                // Move to the next screen only if the app is in the foreground
                withAnimation {
                    mainVM.onboardingScreen = .rating
                }

                Task {
                    do {
                        try await FirebaseService.shared.updateDocument(collection: .users, object: mainVM.currUser)
                        Analytics.shared.log(event: "NotificationScreen: Updated User")
                    } catch {
                        print(error.localizedDescription, "can't update user document")
                    }
                }
            }
        }
    }
}

#Preview {
    NotificationScreen()
        .environmentObject(MainViewModel())
        .environmentObject(HomeViewModel())
}
