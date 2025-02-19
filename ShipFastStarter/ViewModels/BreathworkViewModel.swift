//
//  BreathworkViewModel.swift
//  Resolved
//
//  Created by Dante Kim on 8/13/24.
//

import Foundation

class BreathworkViewModel: ObservableObject {
    @Published var selectedBreath: Breathwork = .breathworks.first!
    @Published var showMiddle = false
}
