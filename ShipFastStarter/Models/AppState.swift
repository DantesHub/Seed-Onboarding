//
//  AppState.swift
//  Resolved
//
//  Created by Gaganjot Singh on 07/11/24.
//

import Foundation

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var showEvolution: Bool = false
}
