//
//  LockScreen_WidgetLiveActivity.swift
//  LockScreen Widget
//
//  Created by Gursewak Singh on 20/09/24.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct LockScreen_WidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct LockScreen_WidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LockScreen_WidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

private extension LockScreen_WidgetAttributes {
    static var preview: LockScreen_WidgetAttributes {
        LockScreen_WidgetAttributes(name: "World")
    }
}

private extension LockScreen_WidgetAttributes.ContentState {
    static var smiley: LockScreen_WidgetAttributes.ContentState {
        LockScreen_WidgetAttributes.ContentState(emoji: "😀")
    }

    static var starEyes: LockScreen_WidgetAttributes.ContentState {
        LockScreen_WidgetAttributes.ContentState(emoji: "🤩")
    }
}

#Preview("Notification", as: .content, using: LockScreen_WidgetAttributes.preview) {
    LockScreen_WidgetLiveActivity()
} contentStates: {
    LockScreen_WidgetAttributes.ContentState.smiley
    LockScreen_WidgetAttributes.ContentState.starEyes
}
