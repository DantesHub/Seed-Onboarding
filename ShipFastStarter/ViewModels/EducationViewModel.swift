//
//  EducationViewModel.swift
//  Resolved
//
//  Created by Dante Kim on 8/9/24.
//

import Foundation

class EducationViewModel: ObservableObject {
    @Published var showTapes = false
    @Published var selectedTape: RewireTape = RewireTape.tapes.first ?? RewireTape.tapes[0]
    @Published var completedTapes: [Int] = []
    @Published var showEducation = false
    @Published var showAudioDetails = false
    @Published var completedLessons: [Int] = []
    @Published var currentSlide = 0
    @Published var lastCompletionDate: Date?

    init() {
        loadState()
    }

    func canStartNextTape() -> Bool {
        guard let lastCompletion = lastCompletionDate else { return true }
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.compare(lastCompletion, to: today, toGranularity: .day) == .orderedAscending
    }

    func calculateNumberCompleted() {
        let completedTapes = RewireTape.tapes.filter { tape in
            self.completedTapes.contains(tape.id)
        }
        print(completedTapes.count, "completed tapes")
    }

    func isTapeAvailable(_ tape: RewireTape) -> Bool {
        // First tape is always available
        if tape.id == 1 { return true }

        // For other tapes, check if previous tape is completed and if enough time has passed
        if tape.id == 2 {
            return completedTapes.contains(tape.id - 1)
        } else {
            return completedTapes.contains(tape.id - 1) && canStartNextTape() || completedTapes.contains(tape.id)
        }
    }

    func completeTape(_ tapeId: Int) {
        if !completedTapes.contains(tapeId) {
            completedTapes.append(tapeId)
            lastCompletionDate = Date()
            saveState()
        }
    }

    func saveState() {
        UserDefaults.standard.set(completedTapes, forKey: "completedTapes")
        UserDefaults.standard.set(lastCompletionDate, forKey: "lastCompletionDate")
    }

    func loadState() {
        completedTapes = UserDefaults.standard.array(forKey: "completedTapes") as? [Int] ?? []
        lastCompletionDate = UserDefaults.standard.object(forKey: "lastCompletionDate") as? Date
    }

    func willBeTapeAvailableTomorrow(_ tape: RewireTape) -> Bool {
        // Only the next sequential tape can be available tomorrow
        let previousTapeId = tape.id - 1

        // Check if this is the next tape in sequence
        guard completedTapes.contains(previousTapeId) && !completedTapes.contains(tape.id) else {
            return false
        }

        // Check if the previous tape was completed today
        guard let lastCompletion = lastCompletionDate else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let completionDay = calendar.startOfDay(for: lastCompletion)

        return completionDay == today && previousTapeId == completedTapes.max()
    }

    func getNextAvailableTape() -> RewireTape? {
        return RewireTape.tapes.first { tape in
            !completedTapes.contains(tape.id) && isTapeAvailable(tape)
        }
    }

    func isTapeCompleted(_ tape: RewireTape) -> Bool {
        return completedTapes.contains(tape.id)
    }

    func getAllCompletedTapes() -> [RewireTape] {
        return RewireTape.tapes.filter { tape in
            completedTapes.contains(tape.id)
        }
    }

    func getProgress() -> Double {
        return Double(completedTapes.count) / Double(RewireTape.tapes.count)
    }
}
