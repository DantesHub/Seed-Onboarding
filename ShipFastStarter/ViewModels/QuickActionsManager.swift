//
//  QuickActionsManager.swift
//  Resolved
//
//  Created by Dante Kim on 1/9/25.
//

import SwiftUI

class QuickActionsManager: ObservableObject {
    static let instance = QuickActionsManager()
    @Published var quickAction: QuickAction? = nil

    func handleQaItem(_ item: UIApplicationShortcutItem) {
        print(item)
        if item.type == "SearchAction" {
            quickAction = .search
            print("shibal moli")
        } else if item.type == "Home" {
            quickAction = .home
            print("shibal moli2")
        }
    }
}

enum QuickAction: Hashable {
    case search
    case home
}
