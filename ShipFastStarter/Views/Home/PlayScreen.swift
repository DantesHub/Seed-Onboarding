//
//  PlayScreen.swift
//  NoFap
//
//  Created by Dante Kim on 7/6/24.
//

import SwiftUI

struct PlayScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {}
            .padding(32)
            .frame(width: 345, alignment: .topLeading)
//        .background(Constants)
            .cornerRadius(32)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .inset(by: 0.5)
//            .stroke(Constants.DarkWhite10, lineWidth: 1)
            )
    }
}

#Preview {
    PlayScreen()
}
