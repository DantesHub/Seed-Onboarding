//
//  MainViewModel.swift
//  ShipFastStarter
//
//  Created by Dante Kim on 6/20/24.
//

import BackgroundTasks
import Combine
import Foundation
import OneSignalFramework
import RevenueCat
import SuperwallKit
import SwiftData
import UserNotifications
import WidgetKit

class MainViewModel: ObservableObject, SuperwallDelegate {
    @Published var currentPage: Page = .onboarding
    @Published var isPro = false
    @Published var showHalfOff = false
    @Published var showProfile = false
    @Published var showEvolution = false
    @Published var currUser: User = .exUser
    @Published var tappedPanic = false
    @Published var currentInterval: SoberInterval = .createSoberInterval()
    @Published var hoursSavedPerYear = 0
    @Published var showPricing = false
    @Published var startDhikr = false
    @Published var loading = false
    @Published var checkInDay: CheckInDay = .exCheckInDay
    @Published var fetchedDay: CheckInDay = .exCheckInDay
    @Published var yesterdayCheckInDay: CheckInDay = .exCheckInDay
    @Published var showConfetti: Bool = false

    // toast
    @Published var loadingText = "loading"
    @Published var showToast = false

    // onboarding}
    @Published var onboardingScreen: OnboardingScreenType = .first
    @Published var optionType: OptionType = .symptoms
    @Published var onboardingProgress = 0.0
    @Published var cancelledFreeTrial = false
    let handler = PaywallPresentationHandler()

    func calculateTimeSaved() {
        hoursSavedPerYear = Int(calculateHoursSaved(minsSavedPerDay: currUser.minsSavedPerDay, frequency: currUser.howOften))
    }
    
    func fetchUser(id: String) async -> User? {
        return await withCheckedContinuation { continuation in
            FirebaseService.getUser { [weak self] result in
                guard let self else {
                    continuation.resume(returning: nil)
                    return
                }
                
                switch result {
                case .success(let user):
                    continuation.resume(returning: user)
                case .failure(let error):
                    print("Error fetching user:", error.localizedDescription)
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { purchaserInfo, error in
            if let error = error {
                // Handle any errors that occurred
                print("Error checking subscription status: \(error.localizedDescription)")
                return
            }

            // Check if the user has an active pro subscription
            if let entitlements = purchaserInfo?.entitlements {
                if let subscription = entitlements["isPro"] {
                    
                    if subscription.isActive {
                        UserDefaults.standard.setValue(true, forKey: "isPro")
                        self.currUser.isPro = subscription.isActive == true
                        if subscription.willRenew {
                            print("subscription will renew")
                            Analytics.shared.logActual(event: "User: Will Renewal", parameters: ["product": purchaserInfo?.entitlements["isPro"]?.productIdentifier ?? ""])
                        } else {
                            if UserDefaults.standard.bool(forKey: "renewalOff") {
                                Analytics.shared.logActual(event: "User: Turned Of Renewal", parameters: ["product": purchaserInfo?.entitlements["isPro"]?.productIdentifier ?? ""])
                                UserDefaults.standard.setValue(true, forKey: "renewalOff")
                            }

                            print("subscription is not active cancelled or expired")
                            if UserDefaults.standard.bool(forKey: "expired") {
                                Analytics.shared.logActual(event: "User: Subscription Expired", parameters: ["product": purchaserInfo?.entitlements["isPro"]?.productIdentifier ?? ""])
                                UserDefaults.standard.setValue(true, forKey: "expired")
                            }
                        }
                    } else {                       
                        self.currUser.isPro = false
                        if UserDefaults.standard.bool(forKey: Constants.completedOnboarding) {
                            if !UserDefaults.standard.bool(forKey: Constants.isCreatorKey) {
                                Analytics.shared.log(event: "trial over: show paywall")
                            }
                        }
                    }
                } else {
                    print("no active subscription")
                    self.currUser.isPro = false
                    
                    if !UserDefaults.standard.bool(forKey: "isPro") {
                        if UserDefaults.standard.bool(forKey: Constants.completedOnboarding) {
                            if let halfOffDate = UserDefaults.standard.object(forKey: "halfOffDate") as? Date {
                                self.onboardingScreen = .pricing
                                if Date() > halfOffDate { // show free trial
                                    Analytics.shared.log(event: "HardClosed: Came back saw free")
                                    Superwall.shared.register(event: "freeTrial", handler: self.handler)
                                    UserDefaults.standard.setValue(true, forKey: "sawFreeTrial")
                                } else {
                                    Analytics.shared.log(event: "HardClosed: Came back saw half again")
                                    Superwall.shared.register(event: "halfOffBack", handler: self.handler)
                                }
                            } else if !UserDefaults.standard.bool(forKey: "sawHalfOff") {
                                self.onboardingScreen = .pricing
                                Analytics.shared.log(event: "HardClosed: Came back saw half")
                                Superwall.shared.register(event: "halfOffBack", handler: self.handler)
                                
                                let sixHoursFromNow = Calendar.current.date(byAdding: .hour, value: 6, to: Date())
                                let oneDayFromNow = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                                NotificationManager.scheduleNotification(id: "halfOffFinal", title: "🎁 SEED 50% one last chance.", body: "make 2025 the year u finally win.", date: sixHoursFromNow ?? Date(), deepLink: "ong://halfOff")
                                
                                NotificationManager.scheduleNotification(id: "free trial", title: "🎁 get seed pro for free", body: "we really want u to retain in 2025. close out and reopen the app to try seed for free", date: oneDayFromNow ?? Date(), deepLink: "ong://halfOff")
                                
                                UserDefaults.standard.setValue(oneDayFromNow, forKey: "halfOffDate")
                                UserDefaults.standard.setValue(true, forKey: "sawHalfOff")
                            }
                        }
                    }
                }
            }

            if UserDefaults.standard.bool(forKey: Constants.isCreatorKey) {
                self.currUser.isPro = true
            }

            print("is UserPro \(self.isPro)")
        }
    }

    func calculateHoursSaved(minsSavedPerDay: Double, frequency: String) -> Double {
        let frequencyMultiplier: Double

        switch frequency {
        case "3+ times a day":
            frequencyMultiplier = 3.5 // Assuming an average of 3.5 times a day
        case "Twice a day":
            frequencyMultiplier = 2.0
        case "Once a day":
            frequencyMultiplier = 1.0
        case "A few times a week":
            frequencyMultiplier = 0.5 // Assuming 3.5 times a week
        case "Less than once a week":
            frequencyMultiplier = 0.1 // Assuming once every 10 days
        default:
            frequencyMultiplier = 0.0
        }

        let totalMinsSavedPerWeek = minsSavedPerDay * frequencyMultiplier * 365
        let hoursSavedPerWeek = totalMinsSavedPerWeek / 60

        return hoursSavedPerWeek
    }

    @MainActor
    func fetchCheckInDay(daysSince: Int = -1) async {

        let yesterday = GetDate.yesterday().formatted(format: .firebaseFormat)
        print(yesterday, "shibal muyah")
        // day does not exist yet create it
        yesterdayCheckInDay.id = yesterday
        yesterdayCheckInDay.date = yesterday

        do {
            yesterdayCheckInDay = try await FirebaseService.shared.getDocument(collection: .dailySummaries, documentId: yesterday)
            
            if yesterdayCheckInDay.succeeded < 1000 {
                setRandomNumber(for: yesterdayCheckInDay)
            }
        } catch let error {
            setRandomNumber(for: yesterdayCheckInDay)
            if (error as NSError).code == 401 {
                return
            }
    
            if FirebaseService.isLoggedIn() {
                FirebaseService.shared.addDocument(yesterdayCheckInDay, collection: "daily_summaries") { _ in
                    print("successfully created summary for days past")
                }
            }
            
            
        }
        
    }
    
    func setRandomNumber(for day: CheckInDay) {
        // Generate random values for failed and succeeded
        day.failed = Int.random(in: 1500...2500)
        day.succeeded = Int.random(in: 10000...14000)

        // Calculate the total number of events
        let total = day.succeeded + day.failed

        // Determine the number of moods
        let moodCount = Int.random(in: 1...3)
        let mood = ["😊", "😐", "😔"]

        // Clear existing moods
        day.moods.removeAll()

        // Calculate the minimum count per mood
        let minMoodCount = max(10, total / (10 * moodCount))

        // Add random moods with associated counts
        var remainingCount = total - (minMoodCount * moodCount)
        var moodKeys = Array(mood)
        for i in 0..<moodCount {
            let randomMood = moodKeys[i]
            let moodCount = minMoodCount + Int.random(in: 0..<(remainingCount / (moodCount - day.moods.count)))
            day.moods[randomMood] = moodCount
            remainingCount -= moodCount
        }

        // Assign remaining count to the last mood
        if let lastMoodKey = moodKeys.last {
            day.moods[lastMoodKey] = (day.moods[lastMoodKey] ?? 0) + remainingCount
            // Ensure no mood count is less than 10% of the total
            let totalMoodCount = day.moods.values.reduce(0, +)
            for (_, count) in day.moods {
                if count < max(10, totalMoodCount / (10 * moodCount)) {
                    day.moods[lastMoodKey] = (day.moods[lastMoodKey] ?? 0) + (max(10, totalMoodCount / (10 * moodCount)) - count)
                }
            }
        }
       
    }



    @MainActor
    func fetchToday() async {
        let today = Date().formatted(format: .firebaseFormat)
        do {
            fetchedDay = try await FirebaseService.shared.getDocument(collection: .dailySummaries, documentId: today)
            await updateTomorrowDocument()
        } catch let error {
            if (error as NSError).code == 401 {
                return
            }
            // day does not exist yet create it
            fetchedDay.id = today
            fetchedDay.date = today
            FirebaseService.shared.addDocument(fetchedDay, collection: "daily_summaries") { [weak self] _ in
                guard let self else { return }
                print("successfully created summary for today")
                Task {
                    self.setRandomNumber(for: self.fetchedDay)
                    await self.updateTomorrowDocument()
                }
            }
        }
    }

    func updateTomorrowDocument() async {
        if checkInDay.succeeded >= 1 {
            fetchedDay.succeeded += 1
        } else {
            fetchedDay.failed += 1
        }

        if checkInDay.moods["😊"]! >= 1 {
            fetchedDay.moods["😊"]! += 1
        } else if checkInDay.moods["😐"]! >= 1 {
            fetchedDay.moods["😐"]! += 1
        } else {
            fetchedDay.moods["😔"]! += 1
        }

        do {
            try await FirebaseService.shared.updateDocument(collection: .dailySummaries, object: fetchedDay)
            scheduleTomorrowNotification()

            // remove any notifications that were scheduled today if user checked in early
            let center = UNUserNotificationCenter.current()
            center.getPendingNotificationRequests { requests in
                let identifier = Date().formatted(format: .firebaseFormat)
                let isAlreadyScheduled = requests.contains { $0.identifier == identifier }
                if isAlreadyScheduled {
                    center.removePendingNotificationRequests(withIdentifiers: [identifier])
                    center.removeDeliveredNotifications(withIdentifiers: [identifier])
                }
                
            }
        } catch {
            print(error.localizedDescription, "daily summaries not working")
        }
    }

    func scheduleTomorrowNotification() {
        let tomorrow9PM = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date().addingTimeInterval(86400))!
        var fallenSoldiers = 0

        fallenSoldiers = Int.random(in: 700...1000)

        let tomorrow = GetDate.tomorrow().formatted(format: .firebaseFormat)

        // Check if a notification with this ID is already scheduled
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let isAlreadyScheduled = requests.contains { $0.identifier == tomorrow }

            if !isAlreadyScheduled {
                Analytics.shared.log(event: "CheckIn: Scheduling Notification Tomorrow")
                NotificationManager.scheduleNotification(id: tomorrow, title: "Salute to the \(fallenSoldiers) fallen soldiers.", body: "are you staying strong? check-in now.", date: tomorrow9PM)
            } else {
                print("Notification for tomorrow is already scheduled.")
            }
        }
    }

    func pricingLogic(user: [User], modelContext: ModelContext) {
        print("pricing logic called")
        switch Superwall.shared.subscriptionStatus {
        case .unknown:
            if !Superwall.shared.isPaywallPresented {
                Analytics.shared.log(event: "PricingScreen: Tapped X Unknown")
            } else {
                Analytics.shared.logActual(event: "PricingScreen: Screenload Unknown", parameters: ["duringOnboarding": !UserDefaults.standard.bool(forKey: Constants.completedOnboarding)])
            }
            print("Subscription status is unknown.")
            return
        case .active:
            UserDefaults.standard.setValue(true, forKey: Constants.completedOnboarding)
            NotificationManager.clearNotification(withId: "halfOff")
            NotificationManager.clearNotification(withId: "freeTrial")
            UserDefaults.standard.setValue(true, forKey: "isPro")
            loadingText = "inside active "
            showToast = true
            if !Superwall.shared.isPaywallPresented {
                loadingText = "🤝 invested in yourself "
                showToast = true
                Purchases.shared.getCustomerInfo { purchaserInfo, error in
                    if let error = error {
                        print("Error checking subscription status: \(error.localizedDescription)")
                        return
                    }
                    UserDefaults.standard.setValue(true, forKey: "isPro")
                    self.isPro = true
                    WidgetCenter.shared.reloadAllTimelines()
                    Analytics.shared.logActual(event: "PricingScreen: Subscribed General", parameters: ["duringOnboarding": !UserDefaults.standard.bool(forKey: Constants.completedOnboarding), "page": self.currentPage.rawValue])
                    if let entitlements = purchaserInfo?.entitlements {
                        if let subscription = entitlements["isPro"] {
                            let product = subscription.productIdentifier
                            Analytics.shared.logActual(event: "PricingScreen: Subscribed General", parameters: ["duringOnboarding": !UserDefaults.standard.bool(forKey: Constants.completedOnboarding), "product": product])
                            if product == "nafs_1y_3999" {
                                Analytics.shared.logActual(event: "PricingScreen: Started Free Trial", parameters: ["duringOnboarding": !UserDefaults.standard.bool(forKey: Constants.completedOnboarding), "product": product])
                            } else {
                                Analytics.shared.logActual(event: "PricingScreen: Subscribed", parameters: ["duringOnboarding": !UserDefaults.standard.bool(forKey: Constants.completedOnboarding), "product": product])
                            }
                        }
                    }
                }
           
                currUser.isPro = true
                SubscriptionManager.shared.isSubscribed = true
                if UserDefaults.standard.bool(forKey: "sawHalfOff") {
                    Analytics.shared.logActual(event: "PricingScreen: Subscribed Halfoff", parameters: ["duringOnboarding": !UserDefaults.standard.bool(forKey: Constants.completedOnboarding)])

                } else {
                    Analytics.shared.logActual(event: "PricingScreen: Subscribed Main", parameters: ["duringOnboarding": !UserDefaults.standard.bool(forKey: Constants.completedOnboarding), "page": currentPage.rawValue])

                }
                //MARK: revert
                onboardingScreen = .signUp
            }
        case .inactive:
            if !Superwall.shared.isPaywallPresented {
                Analytics.shared.logActual(event: "PricingScreen: Tapped X", parameters: ["duringOnboarding": !UserDefaults.standard.bool(forKey: Constants.completedOnboarding)])
            } else {
                Analytics.shared.logActual(event: "PricingScreen: Screenload", parameters: ["duringOnboarding": !UserDefaults.standard.bool(forKey: Constants.completedOnboarding)])
            }
            return
        }

        if !Superwall.shared.isPaywallPresented {
            if user.isEmpty {
                currUser.id = UserDefaults.standard.string(forKey: Constants.userId) ?? ""
                modelContext.insert(currUser)
            } else {
                if let usr = user.first {
                    currUser = usr
                }
            }
            
            DataManager.shared.saveContext(context: modelContext)
       

            if currUser.isPro {
                showConfetti = true
            }
        }
    }
}

enum OnboardingScreenType: String {
    case first
    case community
    case quiz
    case age
    case when
    case yesNo
    case frequently
    case gender
    case lastRelapse
    case graphic
    case name
    case explainer
    case religion
    case loadingIllusion
    case already
    case frequency
    case problem
    case duration
    case haveBeenDuration
    case haveQuittingBeforeScreen
    case notification
    case rating
    case pricing
    case typing
    case options
    case goodNews
    case commit
    case referral
    case signUp
}

enum Page: String {
    case home = "Home"
    case onboarding = "Onboarding"
    case stats = "Statistics"
    case course = "Courses"
    case profile = "Profile"
}
