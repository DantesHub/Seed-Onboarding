//
//  RatingScreen.swift
//  Resolved
//
//  Created by Dante Kim on 2/1/25.
//


import SwiftUI
import RevenueCat
import StoreKit

struct RatingScreen: View {
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
                Text("We're a small team, so a rating goes a long way 💜")
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
                LottieView(loopMode: .playOnce, animation: "stars", isVisible: .constant(true))
                    .offset(y: -48)
                Spacer()
                VStack {
                    VStack(spacing: -12) {
                        Image(.discord3)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(24)
                            .shadow(color: Color.primaryBlue.opacity(0.6), radius: 12)
                            .rotationEffect(.degrees(4))
                        Image(.discord2)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(24)
                            .shadow(color: Color.primaryBlue.opacity(0.6), radius: 12)
                            .rotationEffect(.degrees(2))
                    }.offset(y: -32)
                    SharedComponents.PrimaryButton(title: "Leave a rating") {
                        Analytics.shared.log(event: "RatingScreen: Tapped Leave")
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: scene)
                        }
                        
                    }.padding()
                    Text("Ok, I Rated 👍")
                        .sfFont(weight: .medium, size: .p2)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            Analytics.shared.log(event: "ReviewScreen: Click I Left a Rating")
                            withAnimation {
                                mainVM.onboardingScreen = .typing
                            }
                        }.foregroundColor(.gray)
                        .padding(.bottom)
                }.offset(y: -96)
              
              
            }
        }.onAppearAnalytics(event: "RatingScreen: Screenload")
            .onAppear {
                animateContent = true
            }
    }
}
