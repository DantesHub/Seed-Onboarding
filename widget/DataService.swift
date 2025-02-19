//
//  DataService.swift
//  Resolved
//
//  Created by Dante Kim on 8/13/24.
//

import Foundation
import SwiftUI

struct DataService {
    @AppStorage("startDate", store: UserDefaults(suiteName: "group.io.nora.nofap.widgetFun")) var startDate = ""
    @AppStorage("seed", store: UserDefaults(suiteName: "group.io.nora.nofap.widgetFun")) var seed = ""
    @AppStorage("religion", store: UserDefaults(suiteName: "group.io.nora.nofap.widgetFun")) var religion = ""
    @AppStorage("isPro", store: UserDefaults(suiteName: "group.io.nora.nofap.widgetFun")) var isPro = false

    // logic for when its 1 AM => someone logs their outfit for "today"
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }
}
