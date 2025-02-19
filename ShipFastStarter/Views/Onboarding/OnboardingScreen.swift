//
//  OnboardingScreen.swift
//  ShipFastStarter
//
//  Created by Dante Kim on 6/20/24.
//

import AppTrackingTransparency
import AuthenticationServices
import AVKit
import SuperwallKit
import SwiftData
import SwiftUI

struct OnboardingScreen: View {
    @State private var index = -1
    @State private var timer: Timer?
    @State private var orbOffset: CGFloat = UIScreen.main.bounds.height
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Query private var user: [User]
    @State private var showLogin = false
    @State private var animateTopics = false // New state variable for animation
    @Environment(\.modelContext) var modelContext

    var body: some View {
        ZStack {
            Image(.genderBg)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                // Orb Image
                Image(.nafsOrb)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width)
                    .offset(y: orbOffset)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0.8), value: orbOffset)

                // Login Text
                if index == 2 {
                    Text("login")
                        .overusedFont(weight: .medium, size: .h3p1)
                        .foregroundColor(.gray)
                        .underline()
                        .onTapGesture {

                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                showLogin = true
                            }
                        }
                        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 128)
                }

                // Main VStack with animated topics
                VStack(alignment: .center, spacing: 20) {
                    Spacer()
                        .frame(height: 60)

                    ForEach(0 ..< topics.count, id: \.self) { idx in
                        if idx == 2 {
                            Spacer()
                                .frame(height: 4)
                            SharedComponents.OnboardingButton(title: "Start my journey", font: FontManager.overUsedGrotesk(type: .medium, size: .p2), buttonAction: {
                                Analytics.shared.log(event: "OnboardingScreen: Tapped Continue")
                                if UIDevice.hasNotch {
                                    mainVM.onboardingScreen = .community
                                    mainVM.onboardingProgress = 0.05
                                } else {
                                    mainVM.onboardingScreen = .lastRelapse
                                }

                            })
                            .opacity(index >= idx ? 1 : 0)
                            .offset(y: index >= idx ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(Double(idx) * 0.3), value: index)
                            .onAppear {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                        } else {
                            topics[idx]
                                .opacity(index >= idx ? 1 : 0)
                                .offset(y: index >= idx ? 0 : 20)
                                .animation(.easeOut(duration: 0.5).delay(Double(idx) * 0.3), value: index)
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .sheet(isPresented: $showLogin) {
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
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in })
                }

                UserDefaults.standard.setValue(true, forKey: Constants.showMusic)
                UserDefaults.standard.setValue(true, forKey: Constants.displayTimer)
                animateOrb()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    startTimer()
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    requestTrackingAuthorization()
                }

                if !UserDefaults.standard.bool(forKey: Constants.completedOnboarding) {
                    if !UserDefaults.standard.bool(forKey: "sawReferral") {
                        if let userId = UserDefaults.standard.string(forKey: Constants.userId) {
                            mainVM.currUser.id = userId
                            modelContext.insert(mainVM.currUser)
                        }
                    }
                } else {
                    if let user = user.first {
                        mainVM.currUser = user
                    }
                }
            }
            .onAppearAnalytics(event: "OnboardingScreen: Screenload")
        }
        .onDisappear {
            timer?.invalidate()
        }

        .navigationBarHidden(true)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: true) { _ in
            if index < topics.count - 1 {
                index += 1
                if !UserDefaults.standard.bool(forKey: Constants.completedOnboarding) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            } else {
                if !UserDefaults.standard.bool(forKey: Constants.completedOnboarding) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                timer?.invalidate()
            }
        }
    }

    private func animateOrb() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0.8)) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            orbOffset = UIScreen.main.bounds.height * 0.35
        }
    }

    private var topics: [AnyView] {
        [
            AnyView(
                SharedComponents.CustomBoldTitleText(title: "Welcome\nto Seed", color: .white)
            ),
            AnyView(
                SharedComponents.CustomMediumText(title: "Unleash your Potential.\nLeave Porn Behind.", color: .white)
            ),
            AnyView(
                SharedComponents.CustomMediumText(title: "A science-backed approach to\nquitting porn.", color: .white)
            ),
        ]
    }

    private func requestTrackingAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                Analytics.shared.log(event: "Authorized ATT")
                print("ATT: User authorized tracking")
            case .denied:
                Analytics.shared.log(event: "Denied ATT")
                print("ATT: User denied tracking")
            case .restricted:
                Analytics.shared.log(event: "Denied ATT")
                print("ATT: Tracking is restricted")
            case .notDetermined:
                print("ATT: Tracking status not determined")
            @unknown default:
                print("ATT: Unknown tracking status")
            }
        }
    }
}
