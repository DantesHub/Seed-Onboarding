////
////  ShieldViewModel.swift
////  Resolved
////
////  Created by Gursewak Singh on 27/09/24.
////

import BackgroundTasks
import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings
import SwiftUI

class ShieldViewModel: ObservableObject {
    @Published var familyActivitySelection: FamilyActivitySelection {
        didSet {
            saveFamilyActivitySelection()
        }
    }

    @Published var isBlocking = false
    @Published var remainingTime: TimeInterval = 0
    @Published var formattedTime: String = ""

    private var timer: Timer?
    private let store = ManagedSettingsStore.shared
    private let userDefaults = UserDefaults.standard

    init() {
        familyActivitySelection = FamilyActivitySelection()
        loadFamilyActivitySelection()
        checkPersistedTimer()
    }

    func shieldActivities() {
        print("🛡️ Shield Activities Called")
        print("🛡️ Is Blocking: \(isBlocking)")
        print("🛡️ Selection Categories: \(familyActivitySelection.categoryTokens.count)")
        print("🛡️ Selection Apps: \(familyActivitySelection.applicationTokens.count)")
        
        // Debug: Print actual tokens for verification
        print("🛡️ Category Tokens: \(familyActivitySelection.categoryTokens)")
        
        // Verify the selection is not empty
        guard !familyActivitySelection.categoryTokens.isEmpty || !familyActivitySelection.applicationTokens.isEmpty else {
            print("🛡️ No apps or categories selected to block")
            return
        }
        
        // Check authorization status
        Task {
            do {
                let center = AuthorizationCenter.shared
                let status = center.authorizationStatus
                
                print("🛡️ Current Authorization Status: \(status)")
                
                if status != .approved {
                    print("🛡️ Requesting authorization...")
                    try await requestAuthorization()
                    
                    // Verify authorization was granted
                    if center.authorizationStatus != .approved {
                        print("🛡️ Authorization was not granted")
                        return
                    }
                }
                
                // Continue with shielding on main thread
                await MainActor.run {
                    // If already blocking, stop the current block first
                    if isBlocking {
                        print("🛡️ Stopping existing block")
                        stopBlocking()
                    }
                    
                    // Start a new block
                    print("🛡️ Starting new shield")
                    store.shield(familyActivitySelection: familyActivitySelection)
                    startBlockingTimer()
                }
            } catch {
                print("🛡️ Authorization failed: \(error)")
            }
        }
    }

    private func saveFamilyActivitySelection() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(familyActivitySelection)
            userDefaults.set(data, forKey: "savedFamilyActivitySelection")
        } catch {
            print("Failed to save family activity selection: \(error)")
        }
    }

    private func loadFamilyActivitySelection() {
        if let savedData = userDefaults.data(forKey: "savedFamilyActivitySelection") {
            do {
                let decoder = JSONDecoder()
                let loadedSelection = try decoder.decode(FamilyActivitySelection.self, from: savedData)
                print("🛡️ Loaded Selection - Categories: \(loadedSelection.categoryTokens.count), Apps: \(loadedSelection.applicationTokens.count)")
                self.familyActivitySelection = loadedSelection
            } catch {
                print("🛡️ Failed to load family activity selection: \(error)")
            }
        } else {
            print("🛡️ No saved selection found")
        }
    }

    func reloadSavedSelection() {
        loadFamilyActivitySelection()
    }
    func convertTimeToSeconds(_ timeString: String) -> Int {
        let components = timeString.components(separatedBy: " ")
        let timeValue = Double(components.first ?? "0") ?? 0
        let timeUnit = components.last ?? ""
        
        switch timeUnit {
        case "seconds", "second":
            return Int(timeValue)
        case "mins", "min", "minutes", "minute":
            return Int(timeValue * 60)
        case "hours", "hour":
            return Int(timeValue * 3600)
        case "days", "day":
            return Int(timeValue * 86400)
        default:
            return 0
        }
    }
    private func startBlockingTimer() {
        print("🛡️ Start Blocking Timer Called")
        isBlocking = true
        let savedTime = UserDefaults.standard.string(forKey: "savedTime") ?? "3 mins"
        print("🛡️ Saved Time: \(savedTime)")
        var totalTime = convertTimeToSeconds(savedTime)
        let endTime = Date().addingTimeInterval(Double(totalTime))
        userDefaults.set(endTime, forKey: "shieldEndTime")

        updateRemainingTime()
        // Remove background task scheduling as it's failing
        // scheduleTimerExpiration()

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateRemainingTime()
        }
        
        // Add a one-time timer to ensure we stop blocking after the duration
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(totalTime)) { [weak self] in
            self?.stopBlocking()
        }
        
        print("🛡️ Timer Started")
    }

    private func updateRemainingTime() {
        guard let endTime = userDefaults.object(forKey: "shieldEndTime") as? Date else {
            stopBlocking()
            return
        }

        let currentTime = Date()
        if currentTime >= endTime {
            stopBlocking()
        } else {
            remainingTime = endTime.timeIntervalSince(currentTime)
            let minutes = Int(remainingTime) / 60
            let seconds = Int(remainingTime) % 60
            formattedTime = String(format: "%02d:%02d", minutes, seconds)
        }
    }

    private func stopBlocking() {
        print("🛡️ Stop Blocking Called")
        isBlocking = false
        remainingTime = 0
        timer?.invalidate()
        timer = nil
        userDefaults.removeObject(forKey: "shieldEndTime")
        store.clearAllSettings()
        store.shield.webDomains = nil
        
        // Ensure we're on the main thread when updating published properties
        DispatchQueue.main.async { [weak self] in
            self?.formattedTime = ""
        }
        
        print("🛡️ Blocking Stopped")
    }

    func checkPersistedTimer() {
        if let endTime = userDefaults.object(forKey: "shieldEndTime") as? Date {
            let currentTime = Date()
            if currentTime < endTime {
                isBlocking = true
                store.shield(familyActivitySelection: familyActivitySelection)
                updateRemainingTime()
                // scheduleTimerExpiration()

                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                    self?.updateRemainingTime()
                }
            } else {
                stopBlocking()
            }
        }
    }

    private func scheduleTimerExpiration() {
        let request = BGProcessingTaskRequest(identifier: "io.nora.bedrock.shieldExpiration")
        request.earliestBeginDate = userDefaults.object(forKey: "shieldEndTime") as? Date

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule shield expiration: \(error)")
        }
    }

    func handleShieldExpiration(task: BGProcessingTask) {
        stopBlocking()
        task.setTaskCompleted(success: true)
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "io.nora.bedrock.refresh")
        // Fetch no earlier than 15 minutes from now.
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }

//    func schedule() {
//        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "io.nora.nofap.backgroundTask")
//
//        BGTaskScheduler.shared.getPendingTaskRequests { [self] requests in
//            print(requests.count, "bg task pending -----")
//            guard requests.isEmpty else { return }
//            do {
//                let newtask = BGAppRefreshTaskRequest(identifier: "io.nora.nofap.backgroundTask")
//
//                newtask.earliestBeginDate = Date().addingTimeInterval(60)
//                try BGTaskScheduler.shared.submit(newtask)
//                print("Task is scheduled")
//                UIApplication.shared.beginBackgroundTask()
//
//            }catch (let error) {
//
//                print("Failed to schedule", error)
//            }
//        }
//    }

    func handleAppRefresh(task: BGAppRefreshTask) {
        let store = ManagedSettingsStore.shared
        store.clearAllSettings()
        // Complete the task
        task.setTaskCompleted(success: true)
    }

    func requestAuthorization() async throws {
        print("🛡️ Requesting FamilyControls authorization")
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        print("🛡️ Authorization request completed")
    }

//    func startScheduledShielding() {
//        let deviceActivityCenter = DeviceActivityCenter()
//        let activityName = DeviceActivityName("lunchBreak")
//
//        let now = Date()
//        let components: Set<Calendar.Component> = [.hour, .minute, .second]
//        let calendar = Calendar.current
//        let startDate = calendar.date(bySettingHour: 23, minute: 40, second: 0, of: now)!
//        let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: now)!
//        let intervalStart = calendar.dateComponents(components, from: startDate)
//        let intervalEnd = calendar.dateComponents(components, from: endDate)
//
//        let schedule = DeviceActivitySchedule(intervalStart: intervalStart, intervalEnd: intervalEnd, repeats: true)
//        // you can also provide a warningTime to DeviceActivitySchedule.
//
//        let thresholdDate = calendar.date(bySettingHour: 0, minute: 10, second: 0, of: now)!
//        let thresholdTime = calendar.dateComponents(components, from: thresholdDate)
//        let event = DeviceActivityEvent(threshold: thresholdTime)
//        let eventName = DeviceActivityEvent.Name("lunchBreakEvent")
//        do {
//            try deviceActivityCenter.startMonitoring(activityName, during: schedule, events: [eventName: event])
//        }catch(let error) {
//            print(error.localizedDescription)
//        }
//    }
    func startScheduledShielding() {
        let deviceActivityCenter = DeviceActivityCenter()
        let activityName = DeviceActivityName("userTriggeredShield")

        let now = Date()
        let calendar = Calendar.current
        let components: Set<Calendar.Component> = [.hour, .minute, .second]

        // Schedule for now and end 10 minutes later
        let endDate = calendar.date(byAdding: .minute, value: 15, to: now)!
        let intervalStart = calendar.dateComponents(components, from: now)
        let intervalEnd = calendar.dateComponents(components, from: endDate)

        let schedule = DeviceActivitySchedule(intervalStart: intervalStart, intervalEnd: intervalEnd, repeats: false)

        // Event is optional,s can be used for alerts before the activity ends
        let thresholdDate = calendar.date(byAdding: .minute, value: 14, to: now)! // 1 minute before end
        let thresholdTime = calendar.dateComponents(components, from: thresholdDate)
        let event = DeviceActivityEvent(threshold: thresholdTime)
        let eventName = DeviceActivityEvent.Name("shieldWillEnd")

        do {
            try deviceActivityCenter.startMonitoring(activityName, during: schedule, events: [eventName: event])

            // Trigger app shielding logic here (add your shield apps functionality)
            print("Apps are now shielded")
        } catch {
            print(error.localizedDescription)
        }
    }

    // Logic for unshielding apps (to run after 10 minutes)
    func stopMonitoring() {
        let deviceActivityCenter = DeviceActivityCenter()
        let activityName = DeviceActivityName("userTriggeredShield")

        deviceActivityCenter.stopMonitoring([activityName])

        // Trigger app unshielding logic here (add your unshield apps functionality)
        print("Apps are now unshielded")
    }

    static func handleBackgroundTask(_ task: BGTask) {
        guard let task = task as? BGProcessingTask else { return }

        let viewModel = ShieldViewModel()
        viewModel.handleShieldExpiration(task: task)
    }
}

extension ManagedSettingsStore {
    static var shared = ManagedSettingsStore()

    func shield(familyActivitySelection: FamilyActivitySelection) {
        print("🛡️ Setting up shield with selection")
        
        // Clear to reset previous settings
        clearAllSettings()
        print("🛡️ Cleared previous settings")

        let applicationTokens = familyActivitySelection.applicationTokens
        let categoryTokens = familyActivitySelection.categoryTokens

        print("🛡️ Apps to block: \(applicationTokens.count)")
        print("🛡️ Categories to block: \(categoryTokens.count)")

        // Set application restrictions
        if !applicationTokens.isEmpty {
            shield.applications = applicationTokens
            print("🛡️ Set application shields")
        }

        // Set category restrictions (both for apps and web)
        if !categoryTokens.isEmpty {
            shield.applicationCategories = .specific(categoryTokens)
            shield.webDomainCategories = .specific(categoryTokens)
            print("🛡️ Set category shields")
            
            // Debug: Print the actual shield settings
            print("🛡️ Applied Categories: \(shield.applicationCategories)")
            print("🛡️ Applied Web Categories: \(shield.webDomainCategories)")
        }

        // Block web access only if we have categories or apps to block
        if !categoryTokens.isEmpty || !applicationTokens.isEmpty {
            shield.webDomains = Set<WebDomainToken>()
            print("🛡️ Set web domain shields")
        }
        
        print("🛡️ Shield setup complete")
        
        // Verify shield settings were applied
        print("🛡️ Final Shield State:")
        print("🛡️ - Applications: \(shield.applications != nil)")
        print("🛡️ - App Categories: \(shield.applicationCategories != nil)")
        print("🛡️ - Web Categories: \(shield.webDomainCategories != nil)")
        print("🛡️ - Web Domains: \(shield.webDomains != nil)")
    }
}
