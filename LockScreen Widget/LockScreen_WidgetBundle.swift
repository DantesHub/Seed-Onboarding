//
//  LockScreen_WidgetBundle.swift
//  LockScreen Widget
//
//  Created by Gursewak Singh on 20/09/24.
//

import SwiftUI
import WidgetKit

@main
struct LockScreen_WidgetBundle: WidgetBundle {
    var body: some Widget {
        LockScreen_Widget()
        LockScreen_WidgetLiveActivity()
    }
}
