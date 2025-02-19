//
//  ViewModifiers.swift
//  NoFap
//
//  Created by Dante Kim on 7/10/24.
//

import SwiftUI

struct CustomProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.gray.opacity(0.3))
                    .cornerRadius(6)

                Rectangle()
                    .foregroundColor(Color.primaryPurple)
                    .cornerRadius(6)
                    .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width)
            }
        }
        .frame(height: 12) // Set your desired height here
    }
}

extension UITableView {
    override open func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .black
    }
}
