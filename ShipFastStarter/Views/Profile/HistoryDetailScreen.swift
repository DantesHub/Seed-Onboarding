//
//  HistoryDetailScreen.swift
//  NoFap
//
//  Created by Dante Kim on 7/10/24.
//

import SwiftUI

struct HistoryDetailScreen: View {
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    let statuses = [false, true, false, false, true, true, true]
    @State private var currentDate = Date()
    @State private var offset: CGSize = .zero
    @EnvironmentObject var historyVM: HistoryViewModel

    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            VStack {
            }
        }
    }
}

#Preview {
    HistoryDetailScreen()
        .environmentObject(HistoryViewModel())
}
