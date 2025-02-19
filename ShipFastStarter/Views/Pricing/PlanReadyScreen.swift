//
//  PricingScreen.swift
//  Resolved
//
//  Created by Dante Kim on 10/5/24.
//

import AlertToast
import RevenueCat
import SuperwallKit
import SwiftData
import SwiftUI

struct PlanReadyScreen: View {
    var options: [String] = [
        "Boost your confidence",
        "Sharpen your focus and mental clarity",
        "Increase dopamine the healthy way",
        "Improve sleep quality",
        "Enhanced memory and cognitive function",
        "Reclaim time and boost productivity",
        "Heighten motivation and sense of purpose",
        "Increased self-discipline",
        "Reduced anxiety and stress",
    ]
    @EnvironmentObject var mainVM: MainViewModel
    @State private var showPricingModal = false
    @State private var selectedOption: String = "Yearly" // Default selection
    @Query private var user: [User]

    // New variables for RevenueCat offerings and packages
    @State private var isLoading = false
    @State private var showReferral = false
    @Environment(\.modelContext) private var modelContext

    // State variable for animations
    @State private var animateContent = false

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                // .scaleEffect(x: 1, y: -1, anchor: .center)
                .edgesIgnoringSafeArea(.all)
                .opacity(1)

            ScrollView(showsIndicators: false) {
                ZStack {
                    Image(.nafsBackground)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.screenHeight)
                        .scaledToFit()
                        .scaleEffect(x: 1, y: -1, anchor: .center)
                        .edgesIgnoringSafeArea(.all)
                        .offset(y: -350)
                    VStack {
                        Spacer()
                            .frame(height: 32)
                        // Centered text and options
                        VStack(spacing: 32) {
                            // Main Title and Subtitle
                            VStack(spacing: 12) {
                                SharedComponents.CustomText(
                                    title: "\(mainVM.currUser.name), your custom plan is ready.",
                                    font: FontManager.overUsedGrotesk(type: .bold, size: .h1Big),
                                    color: Color.white
                                )
                                .shadow(radius: 20)
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.5).delay(0.1), value: animateContent)

                                SharedComponents.CustomText(
                                    title: "You'll rewire your brain and quit porn by",
                                    font: FontManager.overUsedGrotesk(type: .semiBold, size: .h2),
                                    color: Color.white
                                )
                                .padding(.leading, 12)
                                .padding(.trailing, 12)
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.5).delay(0.2), value: animateContent)

                                Text(getFiftyDaysFromNow(), style: .date)
                                    .overusedFont(weight: .bold, size: .huge)
                                    .foregroundColor(.primaryBlue)
                                    .multilineTextAlignment(.center)
                                    .transition(.opacity)
                                    .opacity(animateContent ? 1 : 0)
                                    .offset(y: animateContent ? 0 : 20)
                                    .animation(.easeOut(duration: 0.5).delay(0.3), value: animateContent)
                            }
                            .padding(.top, 32)
                            .offset(y: 48)

                            // Pro users text
                            Text("You'll begin to experience these benefits")
                                .foregroundColor(.white)
                                .overusedFont(weight: .semiBold, size: .h2)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 64)
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.5).delay(0.4), value: animateContent)

                            // Pro Features list
                            VStack(alignment: .leading, spacing: 24) {
                                ForEach(options.indices, id: \.self) { idx in
                                    HStack(spacing: 24) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 32)
                                            .foregroundColor(.blue)
                                        Text(options[idx])
                                            .sfFont(weight: .medium, size: .h2)
                                            .foregroundColor(.white)
                                    }
                                    .opacity(animateContent ? 1 : 0)
                                    .offset(y: animateContent ? 0 : 20)
                                    .animation(.easeOut(duration: 0.5).delay(0.5 + Double(idx) * 0.1), value: animateContent)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                    .padding(.bottom, 144)
                }
            }
            
            VStack {
                Spacer()
                SharedComponents.PrimaryButton(title: "Begin my journey") {
                    Analytics.shared.log(event: "CustomPlan: Tapped Start Rewiring")
                    // Show the pricing modal
                    DataManager.shared.saveContext(context: modelContext)
                    UserDefaults.standard.setValue(true, forKey: "sawPricing")
                    let fiveMinutesFromNow = Calendar.current.date(byAdding: .minute, value: 3, to: Date())
                    NotificationManager.scheduleNotification(id: "halfOff", title: "🎁 retain your seed in 2025", body: "50% off for the next 24 hours. close out & reopen the app.", date: fiveMinutesFromNow ?? Date(), deepLink: "ong://halfOff")
                    if mainVM.currUser.isPro {
                        mainVM.currentPage = .home
                    } else {
                        Superwall.shared.register(event: "soft_paywall", params: ["screen":"onboarding"], handler: mainVM.handler) {

                        }
                    }
                }
                .padding(.horizontal, 24)
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
            }
            .frame(height: 100, alignment: .top)
            .background(Color(hex: "#03041E"))
            .offset(y: UIScreen.main.bounds.height / 2 - 64)
            .animation(.easeOut(duration: 0.5).delay(0.5), value: animateContent)
        }
        .onAppearAnalytics(event: "CustomPlan: Screnload")
        .onAppear {
            if let user = user.first {
                mainVM.currUser = user
            }
            animateContent = true
        }
    }
    
    func getFiftyDaysFromNow() -> Date {
        let calendar = Calendar.current
        let daysToAdd = 50
        let currentDate = Date()
        let fiftyDaysFromNow = calendar.date(byAdding: .day, value: daysToAdd, to: currentDate)
        return fiftyDaysFromNow ?? currentDate
    }

}

extension UIScreen {
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }

    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
}
