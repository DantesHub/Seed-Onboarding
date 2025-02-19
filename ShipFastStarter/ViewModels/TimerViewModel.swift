import Combine
import Foundation
import SwiftUI

class TimerViewModel: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    @Published var timerString: String = "0 00:00:00"
    @Published var days: Int = 0
    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0

    @Published var splineUpdateTrigger = 0

    private var timer: AnyCancellable?
    var startDate: Date
    private var backgroundDate: Date?
    private var updateSubject = PassthroughSubject<Void, Never>()
    private var updateCancellable: AnyCancellable?

    @Published var nnnDays: Int = 30
    @Published var nnnHours: Int = 0
    @Published var nnnMinutes: Int = 0
    @Published var nnnSeconds: Int = 0
    @Published var nnnTimerString: String = "30 00:00:00"

    private var nnnTimer: AnyCancellable?
    private var nnnEndDate: Date?

    init() {
        startDate = Date()
        initMainTimer()
    }

    func initMainTimer() {
        if let savedDate = UserDefaults.standard.object(forKey: "startDate") as? Date {
            startDate = savedDate
        } else {
            startDate = Date()
            UserDefaults.standard.set(startDate, forKey: "startDate")
        }

        updateCancellable = updateSubject
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { [weak self] in
                withAnimation {
                    self?.updateTimeComponents()
                    self?.updateTimerString()
                }
            }

        updateTimer()
        startTimer(isInit: true)
        triggerSplineUpdate()
    }

    func initNNNTimer() {
        let calendar = Calendar.current
        let currentDate = Date()
        let currentYear = calendar.component(.year, from: currentDate)
        
        // Set start date to December 1st
        var startComponents = DateComponents()
        startComponents.year = currentYear
        startComponents.month = 12  // December
        startComponents.day = 1
        startComponents.hour = 0
        startComponents.minute = 0
        startComponents.second = 0
        
        // Set end date to February 1st of next year
        var endComponents = DateComponents()
        endComponents.year = currentYear + 1  // Next year
        endComponents.month = 2   // February
        endComponents.day = 1
        endComponents.hour = 23
        endComponents.minute = 59
        endComponents.second = 59
        
        guard let startDate = calendar.date(from: startComponents),
              let endDate = calendar.date(from: endComponents) else { return }
        
        nnnEndDate = endDate
        
        // Start the countdown timer
        startNNNCountdown()
    }

    private func startNNNCountdown() {
        nnnTimer?.cancel()
        
        nnnTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let endDate = self.nnnEndDate else { return }
                
                let now = Date()
                if now < endDate {
                    let timeRemaining = endDate.timeIntervalSince(now)
                    self.updateNNNTimeComponents(timeRemaining: timeRemaining)
                } else {
                    // Challenge has ended
                    self.updateNNNTimeComponents(timeRemaining: 0)
                    self.nnnTimer?.cancel()
                }
            }
    }

    func startTimer(isInit: Bool = false) {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer(isInit: isInit)
            }
    }

    func updateTimer(isInit: Bool = false) {
        let newElapsedTime = Date().timeIntervalSince(startDate)
        if Int(newElapsedTime) != Int(elapsedTime) && !isInit {
            elapsedTime = newElapsedTime
            updateSubject.send()
        }
    }

    private func updateTimeComponents() {
        days = Int(elapsedTime / 86400)
        hours = Int((elapsedTime.truncatingRemainder(dividingBy: 86400)) / 3600)
        minutes = Int((elapsedTime.truncatingRemainder(dividingBy: 3600)) / 60)
        seconds = Int(elapsedTime.truncatingRemainder(dividingBy: 60))
    }

    private func updateTimerString() {
        timerString = String(format: "%d %02d:%02d:%02d", days, hours, minutes, seconds)
    }

    func resetTimer() {
        startDate = Date()
        UserDefaults.standard.set(startDate, forKey: "startDate")
        updateTimer()
    }

    func appWillEnterBackground() {
        // backgroundDate = Date()
        // timer?.cancel()
    }

    func appWillEnterForeground() {
        // guard let backgroundDate = self.backgroundDate else { return }
        // let now = Date()
        // let elapsedInBackground = now.timeIntervalSince(backgroundDate)
        // self.elapsedTime += elapsedInBackground

        // updateTimeComponents()
        // updateTimerString()

        // self.backgroundDate = nil
        // self.startTimer()
    }

    // Call this method when you want to update the SplineView
    func triggerSplineUpdate() {
        splineUpdateTrigger += 1
    }

    private func updateNNNTimeComponents(timeRemaining: TimeInterval) {
        nnnDays = Int(timeRemaining / 86400)
        nnnHours = Int((timeRemaining.truncatingRemainder(dividingBy: 86400)) / 3600)
        nnnMinutes = Int((timeRemaining.truncatingRemainder(dividingBy: 3600)) / 60)
        nnnSeconds = Int(timeRemaining.truncatingRemainder(dividingBy: 60))
        updateNNNTimerString()
    }

    private func updateNNNTimerString() {
        nnnTimerString = String(format: "%d %02d:%02d:%02d", nnnDays, nnnHours, nnnMinutes, nnnSeconds)
    }
}
