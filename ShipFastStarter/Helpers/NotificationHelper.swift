//
//  NotificationHelper.swift
//  Resolved
//
//  Created by Dante Kim on 10/19/24.
//

import Foundation
import UserNotifications

enum NotificationManager {
    static func scheduleFallenNotification(mainVM: MainViewModel) {
        let tomorrow = GetDate.tomorrow().formatted(format: .firebaseFormat)

        // Check if notification for tomorrow already exists
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let isAlreadyScheduled = requests.contains { $0.identifier == tomorrow }

            if !isAlreadyScheduled {
                let tomorrow9PM = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date().addingTimeInterval(86400))!
                var fallenSoldiers = 0

                if mainVM.yesterdayCheckInDay.failed < 1000 {
                    fallenSoldiers = Int.random(in: 800 ... 1000)
                } else if mainVM.yesterdayCheckInDay.failed < 1800 {
                    fallenSoldiers = Int.random(in: 1100 ... 2000)
                } else if mainVM.yesterdayCheckInDay.failed < 4000 {
                    fallenSoldiers = Int.random(in: 2500 ... 4000)
                } else {
                    fallenSoldiers = Int.random(in: mainVM.yesterdayCheckInDay.failed ... (mainVM.yesterdayCheckInDay.failed + 25))
                }

                NotificationManager.scheduleNotification(
                    id: tomorrow,
                    title: "Salute to the \(fallenSoldiers) fallen soldiers.",
                    body: "are you staying strong? check-in now.",
                    date: tomorrow9PM
                )
            } else {
                print("Notification for tomorrow is already scheduled")
            }
        }
    }

    // for when the countdown ends
    static func scheduleNotification(id: String, title: String, body: String, date: Date, deepLink: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Add deep link URL if provided
        if let deepLink = deepLink {
            content.userInfo = ["url": deepLink]
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully for \(date) \(id)")
            }
        }
    }

    static func scheduleMilestoneNotifications(startDate: Date) {
        let currentDate = Date()
        let calendar = Calendar.current
        let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: currentDate).day ?? 0

        let milestones: [Orb] = [.blueOrb, .fireDrop, .materialBlob, .infinityBulb, .spores, .lavalLamp, .aiSphere, .marbleDyson]

        // Remove only pending milestone notifications
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let milestoneIdentifiers = requests.filter { $0.identifier.starts(with: "milestone_") }.map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: milestoneIdentifiers)
        }

        for orb in milestones {
            if orb.daysCount() > daysSinceStart {
                let notificationDate = calendar.date(byAdding: .day, value: orb.daysCount(), to: startDate)!
                let title = "Your seed has evolved!"
                let subtitle = "Congratulations on \(orb.daysCount()) days!"

                scheduleNotification(
                    id: "milestone_\(orb.daysCount())",
                    title: title,
                    body: subtitle,
                    date: notificationDate
                )
            }
        }
    }

    static func clearNotification(withId id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        print("Cleared notification with ID: \(id)")
    }

    static func clearNotification(withId id: String, completion: @escaping () -> Void) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        print("Cleared notification with ID: \(id)")
        completion()
    }
}
