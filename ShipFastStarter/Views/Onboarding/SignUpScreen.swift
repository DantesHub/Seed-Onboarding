//
//  SignUpScreen.swift
//  Resolved
//
//  Created by Dante Kim on 12/7/24.
//

import SwiftUI
import AuthenticationServices
import SplineRuntime
import OneSignalFramework

struct SignUpScreen: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var index = -1
    @State private var timer: Timer?
    @Environment(\.modelContext) private var modelContext
    @State private var navigateToReligionScreen = false // To trigger navigation
    
    @State private var animateContent = false // State variable for animations
    
    var body: some View {
        ZStack {
            Image(.genderBg)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Finally, Save Your Progress")
                    .overusedFont(weight: .semiBold, size: .h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 32)
                Text("Join 231,234 other seedlings around the world.")
                    .overusedFont(weight: .semiBold, size: .h3p1)
                    .foregroundColor(.primaryBlue)
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
                    .padding(.horizontal)
                VStack {
                    SplineViewWithGesture(sceneFileURL: URL(string: Orb.earth.rawValue)) { _ in
                        // Handle drag updates here
                    }
                    .frame(width: 500, height: UIDevice.isSmall ? 250 : 400, alignment: .center)
                    .ignoresSafeArea(.all)
                    .padding()
                    .shadow(color: Color.primaryBlue, radius: 120)
                    .shadow(color: .black.opacity(0.25), radius: 2.74199, x: 0, y: 5.48398)
                }.frame(width: 175, height: UIDevice.isSmall ? 150 : 350, alignment: .center)
                    .offset(x: 25, y: 0)
//                                    .background(Color.red)
                    .offset(y: 48)
                
                Text("all your data is encrypted.")
                    .overusedFont(weight: .medium, size: .h3p1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
                    .padding(.horizontal)
                    .padding(.top, 64)
                SignInWithAppleButton { request in
                 
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    Analytics.shared.log(event: "SignUpWithApple: Started Sign In")
                    authVM.handleSignInWithAppleRequest(request)
                } onCompletion: { result in
                    authVM.handleSignInWithAppleCompletion(result, mainVM)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 56)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.45), lineWidth: 2)
                )
                .padding()
                Spacer()
            }
        }
        .onChange(of: authVM.signUpSuccessful) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                homeVM.showWidgetModal = true
                mainVM.currentPage = .home
                Analytics.shared.log(event: "SignUpScreen: Successful")                
            }
        }
        .onAppearAnalytics(event: "SignUpScreen: Screenload")
        .onAppear {
            UserDefaults.standard.setValue(true, forKey: Constants.completedOnboarding)
        }
    }
    
}
