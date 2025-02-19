//
//  StatsViewModel.swift
//  NoFap
//
//  Created by Dante Kim on 7/10/24.
//

import Foundation
import SwiftUI

enum SoberStatus {
    case failed
    case success
    case incomplete
    case today

    var symbolName: String {
        switch self {
        case .failed: "xmark"
        case .success: "checkmark"
        case .incomplete: "circle.dashed"
        case .today: "circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .failed: Color.red
        case .success: Color.green
        case .incomplete: Color.clear
        case .today: Color.primaryBlue
        }
    }
}

class StatsViewModel: ObservableObject {
    @Published var monthlySoberStatus: [SoberStatus] = []
    @Published var currentStreak = 0
    @Published var weeklySoberStatus: [SoberStatus] = Array(repeating: .incomplete, count: 7)
    @Published var thisWeekStatus = [false, true, false, false, true, true, true]
    @Published var startOfWeek = Date()
    @Published var endOfWeek = Date()
    @Published var startOfMonth = Date()
    @Published var endOfMonth = Date()
    @Published var selectedDate = Date()
    @Published var weekTitle = "This Week"
    @Published var selectedMonth = Date()
    @Published var monthTitle = "This Month"
    @Published var timeSaved = 0.0
    @Published var minsSavedPerDay = 0.0
    @Published var improvementPercent = 0.0

    init() {
        monthlySoberStatus = Array(repeating: .incomplete, count: 31)
    }

    func getWeeksAgoString(earlierDate: Date, laterDate: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekOfYear], from: earlierDate, to: laterDate)

        guard let weeksDifference = components.weekOfYear else {
            weekTitle = "This Week"
            return
        }

        let weekDiffence = abs(weeksDifference)
        switch weekDiffence {
        case 0:
            // Check if it's the same week
            if calendar.isDate(earlierDate, equalTo: laterDate, toGranularity: .weekOfYear) {
                weekTitle = "This Week"
            } else {
                weekTitle = "Last Week"
            }
        case 1:
            weekTitle = "Last Week"
        default:
            weekTitle = "\(weekDiffence) weeks ago"
        }
    }

    func calculateIntervals() {
        // Implementation here if needed
    }

    func calculateWeek(intervals: [SoberInterval]) {
        timeSaved = 0
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday as first day of week
//        calendar.timeZone = TimeZone(identifier: "Asia/Kuala_Lumpur")!

        getWeekBoundaries() // Ensure week boundaries are set

        weeklySoberStatus = Array(repeating: .incomplete, count: 7)

        let today = calendar.startOfDay(for: Date()) // Get today's date without time components
        var dailyStatus: [SoberStatus] = Array(repeating: .incomplete, count: 7)

        for dayOffset in 0 ..< 7 {
            let currentDay = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
            if calendar.isDate(currentDay, inSameDayAs: today) {
                dailyStatus[dayOffset] = .today
            } else if currentDay < today {
                dailyStatus[dayOffset] = calculateStatusForDay(date: currentDay, intervals: intervals, today: today)
                if dailyStatus[dayOffset] == .success {
                    timeSaved += minsSavedPerDay
                }
            } else {
                dailyStatus[dayOffset] = .incomplete
            }
        }

        weeklySoberStatus = dailyStatus
    }

    func calculateImprovement() {}

    private func calculateStatusForDay(date: Date, intervals: [SoberInterval], today: Date) -> SoberStatus {
        let calendar = Calendar.current
        for interval in intervals {
            guard let startDate = Date.fromString(interval.startDate) else { continue }
            let endDate = interval.endDate.isEmpty ? nil : Date.fromString(interval.endDate)

            if startDate <= date && (endDate == nil || endDate! >= date) {
                if endDate != nil && calendar.isDate(date, inSameDayAs: endDate!) {
                    return .failed
                } else if endDate == nil {
                    // Only mark as success if it's not today
                    if calendar.isDate(date, inSameDayAs: today) {
                        return .incomplete
                    } else {
                        return .success
                    }
                } else if endDate != nil && endDate! >= date {
                    return .success
                }
            }
        }
        return .incomplete
    }

    func calculateMonth(intervals: [SoberInterval]) {
        let calendar = Calendar.current

        // Update the month boundaries
        getMonthBoundaries(for: selectedMonth)

        // Calculate the number of days in the month
        let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: selectedMonth)!.count

        // Adjust the `monthlySoberStatus` array to match the number of days in the month
        if monthlySoberStatus.count != numberOfDaysInMonth {
            monthlySoberStatus = Array(repeating: .incomplete, count: numberOfDaysInMonth)
        }

        let today = calendar.startOfDay(for: Date()) // Get today's date without time components
        var dailyStatus: [SoberStatus] = Array(repeating: .incomplete, count: numberOfDaysInMonth)

        // Iterate over each day of the current month
        for dayOffset in 0 ..< numberOfDaysInMonth {
            let currentDay = calendar.date(byAdding: .day, value: dayOffset, to: startOfMonth)!
            if calendar.isDate(currentDay, inSameDayAs: today) {
                dailyStatus[dayOffset] = .today
            } else if currentDay <= today {
                dailyStatus[dayOffset] = calculateStatusForDay(date: currentDay, intervals: intervals, today: today)
            } else {
                dailyStatus[dayOffset] = .incomplete
            }
        }

        // Update the `monthlySoberStatus` array with the correct status for each day
        monthlySoberStatus = dailyStatus
    }

    func getWeekBoundaries() {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday as the first day of the week
//        calendar.timeZone = TimeZone(identifier: "Asia/Kuala_Lumpur")!
        let today = selectedDate

        let weekday = calendar.component(.weekday, from: today)
        let daysToSubtract = (weekday + 5) % 7 // Adjust to make Monday the first day

        guard let startWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: today),
              let endWeek = calendar.date(byAdding: .day, value: 6 - daysToSubtract, to: today)
        else {
            fatalError("Failed to calculate week boundaries")
        }

        startOfWeek = calendar.startOfDay(for: startWeek)
        endOfWeek = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endWeek)!
    }

    func calendarGrid(for date: Date) -> some View {
        let days = daysInMonth(date)
        let firstWeekday = firstWeekdayOfMonth(date)
        let numberOfRows = 6 // Always use 6 rows to accommodate all possible month layouts

        return VStack(alignment: .center, spacing: 8) {
            Spacer().frame(height: 20) // Add more padding at the top
            ForEach(0 ..< numberOfRows, id: \.self) { row in
                self.calendarRow(row: row, days: days, firstWeekday: firstWeekday)
            }
        }
    }

    func calendarRow(row: Int, days: Int, firstWeekday: Int) -> some View {
        HStack(spacing: 12) {
            ForEach(1 ... 7, id: \.self) { column in
                self.calendarCell(row: row, column: column, days: days, firstWeekday: firstWeekday)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    func calendarCell(row: Int, column: Int, days: Int, firstWeekday: Int) -> some View {
        let day = (row * 7 + column) - firstWeekday + 1
        let cellSize: CGFloat = UIDevice.isProMax ? 45 : 40

        return Group {
            if day > 0 && day <= days {
                ZStack {
                    if day - 1 < monthlySoberStatus.count {
                        if monthlySoberStatus[day - 1] == .incomplete {
                            Circle()
                                .fill(Color.clear)
                                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [2]))
                                .frame(width: cellSize, height: cellSize)
                        } else {
                            Circle()
                                .fill(monthlySoberStatus[day - 1].color)
                                .frame(width: cellSize, height: cellSize)
                        }
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: cellSize, height: cellSize)
                    }

                    Text("\(day)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            } else {
                Color.clear
                    .frame(width: cellSize, height: cellSize)
            }
        }
    }

    func firstWeekdayOfMonth(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        let firstDayOfMonth = calendar.date(from: components)!

        // Adjust to make Monday the first day of the week (1) and Sunday the last (7)
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        return (weekday + 5) % 7 + 1
    }

    func daysInMonth(_ date: Date) -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }

    func getMonthBoundaries(for date: Date) {
        var calendar = Calendar.current

        // Get the start and end of the month
        let components = calendar.dateComponents([.year, .month], from: date)
        startOfMonth = calendar.date(from: components)!
        endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!

        startOfMonth = calendar.startOfDay(for: startOfMonth)
        endOfMonth = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endOfMonth)!
    }

    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    func nextMonth() -> Date {
        Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth)!
    }

    func previousMonth() -> Date {
        Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth)!
    }

    var isProMax: Bool {
        UIDevice.isProMax
    }
}
