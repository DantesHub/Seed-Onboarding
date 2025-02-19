//
//  AppIntent.swift
//  widget
//
//  Created by Dante Kim on 8/13/24.
//

import AppIntents
import WidgetKit

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configure Widget"
    static var description = IntentDescription("Choose your favorite emoji")

    // An example configurable parameter
    @Parameter(title: "Favorite Emoji")
    var favoriteEmoji: String

    init() {
        favoriteEmoji = "😊"
    }

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
