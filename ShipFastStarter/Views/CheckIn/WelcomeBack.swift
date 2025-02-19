//
//  WelcomeBack.swift
//  Resolved
//
//  Created by Dante Kim on 10/7/24.
//

import StoreKit
import SwiftData
import SwiftUI

struct WelcomeBack: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @State private var progress = ""
    @Query var sessionHistory: [SoberInterval]
    @State private var minsSaved = 0
    @State private var animateContent = false // State variable for animations

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .cornerRadius(32)
            VStack(alignment: .leading, spacing: 0) {
                // Animated Emoji
                Text("🫡")
                    .overusedFont(weight: .bold, size: .h1Big)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5), value: animateContent)

                // Animated Texts
                Text("Salute to the \(mainVM.yesterdayCheckInDay.failed) soldiers that folded \(mainVM.yesterdayCheckInDay.date)")
                    .multilineTextAlignment(.leading)
                    .overusedFont(weight: .semiBold, size: .h1Medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: animateContent)

                Text("\(mainVM.yesterdayCheckInDay.succeeded)")
                    .multilineTextAlignment(.leading)
                    .overusedFont(weight: .semiBold, size: .statNumber)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: animateContent)

                Text("are still going strong")
                    .multilineTextAlignment(.leading)
                    .overusedFont(weight: .semiBold, size: .p2)
                    .foregroundColor(.primaryBlue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: animateContent)

                // Animated Button
                SharedComponents.PrimaryButton(title: "Complete today's check-in") {
                    // Button action here
//                    homeVM.currentScreen = .foldedBack
                }
                .padding(.vertical)
                .padding()
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: animateContent)
            }
            .offset(y: -12)
            .cornerRadius(24)
            .padding()
            .onAppear {
                mainVM.checkInDay = CheckInDay.exCheckInDay
                animateContent = true // Trigger animations when view appears
            }
        }.onAppearAnalytics(event: "Welcomebcak: Screenload")
    }
}

struct FoldedBackScreeen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @Binding var didFold: Bool
    @State private var streak = ""
    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .cornerRadius(32)
            VStack(alignment: .leading, spacing: 0) {
                Text("🫡")
                    .overusedFont(weight: .bold, size: .h1Big)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                Text("Did you fold?")
                    .multilineTextAlignment(.leading)
                    .overusedFont(weight: .semiBold, size: .h1Big)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                Text("\(mainVM.yesterdayCheckInDay.succeeded)")
                    .multilineTextAlignment(.leading)
                    .overusedFont(weight: .semiBold, size: .statNumber)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                Text("are still going strong")
                    .multilineTextAlignment(.leading)
                    .overusedFont(weight: .semiBold, size: .p2)
                    .foregroundColor(.primaryBlue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                Text("please be honest for the commmunity.")
                    .multilineTextAlignment(.leading)
                    .overusedFont(weight: .semiBold, size: .p2)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.vertical)

                SharedComponents.PrimaryButton(title: "No still going strong 💪") {
                    Analytics.shared.logActual(event: "FoldedBack: Tapped No", parameters: ["timeSaved": mainVM.currUser.minsSavedPerDay, "streak": streak])
                    didFold = false
                    homeVM.currentScreen = .mood
                    mainVM.checkInDay.succeeded += 1
                    // save last check in to firebase
                }.padding()

                SharedComponents.HomeRelapsedButton(title: "Yes, I relapsed", action: {
                    didFold = true
                    Analytics.shared.logActual(event: "FoldedBack: Tapped Yes", parameters: ["streak": streak])
                    homeVM.currentScreen = .first
                    mainVM.checkInDay.failed += 1
                }, color: [Color(red: 0.4, green: 0.13, blue: 0.13), Color(red: 0.2, green: 0.03, blue: 0.03)], height: 72)
                    .padding(.horizontal)
                    .padding(.bottom)
            }.offset(y: -12)
                .cornerRadius(32)
                .padding()
        }
        .onAppearAnalytics(event: "FoldedBack: Screenload")
        .onAppear {
            streak = "\(Date.timeDifference(date1: mainVM.currentInterval.startDate, date2: mainVM.currentInterval.endDate).1) \(Date.timeDifference(date1: mainVM.currentInterval.startDate, date2: mainVM.currentInterval.endDate).0)"
        }
    }
}

struct SummaryScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var reflectVM: ReflectionsViewModel
    @Environment(\.modelContext) private var modelContext

    @Binding var didFold: Bool
    @Binding var mood: String

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .cornerRadius(32)
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24)
                        .foregroundColor(.white)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                homeVM.currentScreen = .mood
                            }
                        }
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24)
                        .foregroundColor(.white)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                Analytics.shared.log(event: "CheckIn: tapped final x")
                                homeVM.showCheckIn = false
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                    Analytics.shared.log(event: "WelcomeBack: Triggered Review")
                                    SKStoreReviewController.requestReview(in: windowScene)
                                }
                            }
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 12)

                Text("\(mood == "😊" ? "That's great to hear. Keep it pushing king 👑" : "Attitude is everything. Keep your head up king 👑")")
                    .multilineTextAlignment(.leading)
                    .overusedFont(weight: .semiBold, size: .h1Medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                VStack(alignment: .leading) {
                    HStack {
                        Text("😊")
                        Text("\(mainVM.yesterdayCheckInDay.moods["😊"] ?? 1) others")
                    }
                    HStack {
                        Text("😐")
                        Text("\(mainVM.yesterdayCheckInDay.moods["😐"] ?? 1) others")
                    }
                    HStack {
                        Text("😔")
                        Text("\(mainVM.yesterdayCheckInDay.moods["😔"] ?? 1) others")
                    }
                }
                .multilineTextAlignment(.leading)
                .overusedFont(weight: .semiBold, size: .title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)

                Text("This shit is hard but believe in yourself. And you’re not alone.")
                    .multilineTextAlignment(.leading)
                    .overusedFont(weight: .semiBold, size: .p2)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.vertical)
                HStack {
                    SharedComponents.PrimaryButton(title: "Reflect") {
                        Analytics.shared.log(event: "SummaryScreen: Tapped Reflect")
                        homeVM.showCheckIn = false
                        reflectVM.showWriteReflection = true
                    }
                    if mainVM.currUser.religion == "Muslim" && didFold {
                        SharedComponents.PrimaryButton(title: "Dhikr") {
                            Analytics.shared.log(event: "SummaryScreen: Tapped Dhikr")
                            homeVM.showCheckIn = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    mainVM.startDhikr = true
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }.offset(y: -12)
                .cornerRadius(32)
                .padding()
        }.onAppear {
  
        }.onAppearAnalytics(event: "SummaryCheckIn: Screenload")
    }
}

struct MoodScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @Binding var folded: Bool
    @Binding var mood: String

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .cornerRadius(32)
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24)
                        .foregroundColor(.white)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                if folded {
//                                    homeVM.currentScreen = .first
                                } else {
//                                    homeVM.currentScreen = .foldedBack
                                }
                            }
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 12)

                Text("\(folded ? "All good." : "Good shit.") How are you feeling?")
                    .multilineTextAlignment(.leading)
                    .overusedFont(weight: .semiBold, size: .h1Medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                    .padding(.bottom)
                VStack(spacing: 16) {
                    SharedComponents.HomeRelapsedButton(title: "😊", action: {
                        // Button action here
                        Analytics.shared.log(event: "MoodScreen: Tapped Happy")
//                        homeVM.currentScreen = .summary
                        mainVM.checkInDay.moods["😊"]! += 1
                        Task {
                            await mainVM.fetchToday()
                        }
                    }, color: [Color(red: 0.21, green: 1, blue: 0.4), Color(red: 0.05, green: 0.34, blue: 0.12)], height: 100)
                        .padding(.horizontal, 16)
                    SharedComponents.HomeRelapsedButton(title: "😐", action: {
                        // Button action here
                        Analytics.shared.log(event: "MoodScreen: Tapped Mid")
                        mainVM.checkInDay.moods["😐"]! += 1

                        homeVM.currentScreen = .summary
                        Task {
                            await mainVM.fetchToday()
                        }
                    }, color: [Color(red: 1, green: 0.96, blue: 0.21), Color(red: 0.39, green: 0.3, blue: 0.07)], height: 100)
                        .padding(.horizontal, 16)

                    SharedComponents.HomeRelapsedButton(title: "😔", action: {
                        // Button action here
                        Analytics.shared.log(event: "MoodScreen: Tapped Sad")
                        mainVM.checkInDay.moods["😔"]! += 1
                        homeVM.currentScreen = .summary
                        Task {
                            await mainVM.fetchToday()
                        }
                    }, color: [Color(red: 0.4, green: 0.13, blue: 0.13), Color(red: 0.2, green: 0.03, blue: 0.03)], height: 100)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 48)
                }

            }.offset(y: -12)
                .cornerRadius(32)
                .padding()
        }
    }
}

#Preview {
    WelcomeBack()
        .environmentObject(MainViewModel())
}
