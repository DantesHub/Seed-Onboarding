import SwiftData
import SwiftUI

struct AlreadySoberScreen: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var timerVM: TimerViewModel
    @EnvironmentObject var historyVM: HistoryViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Query private var sessionHistory: [SoberInterval]

    @State private var selectedOption = "Just Now"
    @State private var animateContent = false // State variable for animations

    let checkInOptions = [
        "Just Now",
        "Today",
        "Yesterday",
        "2 days ago",
        "3 days ago",
        "4 days ago",
        "5 days ago",
        "6 days ago",
        "1 week ago",
        "8 days ago",
        "9 days ago",
        "10 days ago",
        "11 days ago",
        "12 days ago",
        "13 days ago",
        "2 weeks ago",
        "3 weeks ago",   
    ]

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            GeometryReader { _ in
                VStack(alignment: .leading, spacing: 12) {
                    VStack(spacing: 12) {
                        SharedComponents.CustomBoldHeading(title: "When was your last relapse?", color: .white)
                        SharedComponents.CustomSubtitleText(title: "Please give your best approximation", color: .white)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5), value: animateContent)

                    Spacer()

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
                        .offset(y: -48)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: animateContent)

                    if UIDevice.hasNotch {
                        Spacer()
                    }

                    // Animate the Continue Button
                    SharedComponents.PrimaryButton(title: "Continue") {
                        Analytics.shared.logActual(event: "AlreadySoberScreen: Tapped Continue", parameters: ["AlreadySoberFor": selectedOption])

                        homeVM.lastRelapsed = selectedOption

                        // Create new interval and set start date
                        let newInterval = SoberInterval.createSoberInterval()
                        newInterval.startDate = Date.newStartDate(relapseDate: homeVM.lastRelapsed).toString()
                        newInterval.userId = mainVM.currUser.id

                        if let startDate = Date.fromString(newInterval.startDate) {
                            if homeVM.shouldEvolve(startDate: startDate, currentOrb: "originalSeed") {
                                newInterval.seed = homeVM.selectedOrb.0.name()
                            }

                            NotificationManager.scheduleMilestoneNotifications(startDate: startDate)
                            // Insert the new interval without checking for existing ones
                            modelContext.insert(newInterval)

                            do {
                                mainVM.currentInterval = newInterval
                                mainVM.onboardingProgress = 1.0
                                mainVM.onboardingScreen = .name
                                timerVM.startDate = startDate
                                timerVM.startTimer(isInit: false)
                                historyVM.historyList.append(newInterval)
                                authVM.soberIntervals = [newInterval]

                                try modelContext.save()
                                // Print the current state after insertion
                                let descriptor = FetchDescriptor<SoberInterval>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
                                let currentIntervals = try modelContext.fetch(descriptor)
                                print("Current number of intervals: \(currentIntervals.count)")

                            } catch {
                                print("Error saving new interval: \(error)")
                            }
                        }
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: animateContent)

                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            animateContent = true // Trigger animations when view appears
        }
        .onAppearAnalytics(event: "AlreadySoberScreen: Screenload")
    }
}

#Preview {
    AlreadySoberScreen()
        .environmentObject(HomeViewModel())
}

// struct AlreadySoberScreen: View {
//    @Environment(\.modelContext) private var modelContext
//    @EnvironmentObject var homeVM: HomeViewModel
//    @EnvironmentObject var mainVM: MainViewModel
//    @EnvironmentObject var timerVM: TimerViewModel
////    @EnvironmentObject var historyVM: HistoryViewModel
////    @Query private var sessionHistory: [SoberInterval]
//
//
//    @State private var selectedOption = "Just Now"
//    @State private var animateContent = false  // State variable for animations
//
//    let checkInOptions = [
//                "Just Now",
//                "Today",
//                "Yesterday",
//                "2 days ago",
//                "3 days ago",
//                "4 days ago",
//                "5 days ago",
//                "6 days ago",
//                "1 week ago",
//                "8 days ago",
//                "9 days ago",
//                "10 days ago",
//                "11 days ago",
//                "12 days ago",
//                "13 days ago",
//                "2 weeks ago",
//                "3 weeks ago",
//                "4 weeks ago",
//                "5 weeks ago",
//                "6 weeks ago",
//                "7 weeks ago",
//                "2+ months ago"
//            ]
//
//        var body: some View {
//            VStack {
//
//
//
//
//                Picker("Please choose a color", selection: $selectedOption) {
//                    ForEach(checkInOptions, id: \.self) {
//                        Text($0)
//                    }
//                }
//                .pickerStyle(WheelPickerStyle())
//                .frame(height: 200)
//                Text("You selected: \(selectedOption)")
//            }
//        }
//    }
//
// struct AlreadySoberScreen: View {
//        var colors = ["Red", "Green", "Blue", "Tartan", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "16", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
//        @State private var selectedColor = "Red"
//
//        var body: some View {
//            VStack {
//
//
//
//
//                Picker("Please choose a color", selection: $selectedColor) {
//                    ForEach(colors, id: \.self) {
//                        Text($0)
//                    }
//                }
//                .pickerStyle(WheelPickerStyle())
//                Text("You selected: \(selectedColor)")
//            }
//        }
//    }
