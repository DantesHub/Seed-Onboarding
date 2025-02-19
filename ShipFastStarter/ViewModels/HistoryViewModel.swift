//
//  HistoryViewModel.swift
//  NoFap
//
//  Created by Dante Kim on 7/10/24.
//

import Foundation

class HistoryViewModel: ObservableObject {
    @Published var historyList: [SoberInterval] = []
    @Published var selectedInterval: SoberInterval = .createSoberInterval()
    @Published var showDetailedView = false

    var title: String {
        let startDate = Date.changeDateFormat(dateString: selectedInterval.startDate, fromFormat: "dd-MM-yyyy HH:mm:ss", toFormat: "MMMM dd")
        let endDate = Date.changeDateFormat(dateString: selectedInterval.endDate, fromFormat: "dd-MM-yyyy HH:mm:ss", toFormat: "MMMM dd")
        if endDate.isEmpty {
            return "\(startDate): IN PROGRESS"
        } else {
            return "\(startDate) - \(endDate)"
        }
    }
}
