//
//  ProfileViewModel.swift
//  Resolved
//
//  Created by Dante Kim on 10/10/24.
//
import FirebaseAuth
import Foundation
import UserNotifications

class ProfileViewModel: ObservableObject {
    @Published var selectedChallenge: Challenge = .winterArc
    @Published var presentChallenge = false
    @Published var allChallenges: [Challenge] = [.winterArc, .noNutNovember]
    @Published var userJoinedChallenges: [String: String] = [:]
    @Published var showUserStatsForChallenge: Bool = false
    @Published var sessionHistory: [SoberInterval]?
    @Published var currUser: User?
    @Published var showTimer = false
    @Published var showMilestones = false
    @Published var showSettings = false
    @Published var showReferral = false
    @Published var selectedMilestone = Orb.originalSeed
    @Published var presentOrb = false

    @MainActor
    func fetchChallenge() async {
            Task {
                do {
                    self.selectedChallenge = try await FirebaseService.shared.getDocument(collection: FirebaseCollection.challenges, documentId: "Winter Arc Challenge")
                    print(selectedChallenge.challengers, "bom")
                    // replaced selectedChallenge with winter arc challenge inside allChallenges
                    allChallenges = allChallenges.map { $0.title == selectedChallenge.title ? selectedChallenge : $0 }
                    print(allChallenges[0].challengers, "blue miobme")
                } catch {
                    FirebaseService.shared.addDocument(selectedChallenge, collection: FirebaseCollection.challenges.rawValue) { str in
                        print("successfully created winter arc challenge")
                    }
                }
            }
        }

    func setChallengeStatus(for challenge: Challenge) -> Challenge {
        var updatedChallenge = challenge
        
        if !userJoinedChallenges.keys.contains(challenge.title) && Date() < challenge.endDate {
            updatedChallenge.currentStatus = "Join Challenge"
        } else {
            if let intervals = sessionHistory {
                for interval in intervals.reversed() {
                    if let joinDate = Date.fromString(userJoinedChallenges[challenge.title] ?? "", format: "dd-MM-yyyy") {
                        let endDate = Date.fromString(interval.endDate) ?? Date()
                        if endDate < joinDate && endDate < challenge.endDate {
                            updatedChallenge.currentStatus = "challenge incomplete"
                            return updatedChallenge
                        }
                    }
                }
            }
            
            let now = Date()
            if challenge.startDate < now && now < challenge.endDate {
                updatedChallenge.currentStatus = "in progress"
            } else if challenge.startDate > now {
                updatedChallenge.currentStatus = "(joined) starts soon.."
            } else {
                updatedChallenge.currentStatus = "challenge completed"
            }            
        }
        
        return updatedChallenge
    }


    func scheduleNotification(forDay day: Int, participantsLost: Int) {
        Analytics.shared.log(event: "CheckIn: Schedule Next Notification")
        let content = UNMutableNotificationContent()
        content.title = "NNN Challenge Update"
        content.body = "Salute to the \(participantsLost) soldiers that have fallen today."
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = 20 // 8 PM
        dateComponents.minute = 0
        dateComponents.day = day
        dateComponents.month = 11 // November
        dateComponents.year = Calendar.current.component(.year, from: Date())

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "NNN_Day_\(day)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
                self.scheduleAllNotifications()
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }

    func scheduleAllNotifications() {
        // Remove all pending notifications first
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        // Schedule notifications for each day of November
        for day in 1 ... 30 {
            let decreasePercentage: Double
            switch day {
            case 1 ... 7: decreasePercentage = 0.10
            case 8 ... 14: decreasePercentage = 0.07
            case 15 ... 21: decreasePercentage = 0.05
            default: decreasePercentage = 0.03
            }
            let participantsLost = Int(Double(selectedChallenge.challengers) * decreasePercentage)
            scheduleNotification(forDay: day, participantsLost: participantsLost)
        }
    }

    // Call this function when the app starts or when the user joins the challenge
    func initializeChallenge() {
        setupNotifications()
    }

    func joinChallenge() {}

    func failChallenge() {}
}
