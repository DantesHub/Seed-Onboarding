//
//  widgetEntry.swift
//  ColorMe
//
//  Created by Dante Kim on 6/17/24.
//

import WidgetKit

struct SimpleEntry: TimelineEntry {
    let date: Date
    let startDate: String
    let seed: String
    let remainingTime: TimeInterval
    let quote: String
    let isSmallWidget: Bool
}
