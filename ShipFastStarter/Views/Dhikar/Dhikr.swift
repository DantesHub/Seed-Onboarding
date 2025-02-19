//
//  Dhikr.swift
//  Resolved
//
//  Created by Dante Kim on 8/22/24.
//

import Foundation
import SwiftUI

struct Dhikar: View {
    @ObservedObject var viewModel: DhikrViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel

    @Binding var page: PanicPage

    var body: some View {
        ZStack(alignment: .top) {
            if viewModel.completedDhikr {
                DhikrCompletion(page: $page)
                    .environmentObject(viewModel)
                    .environmentObject(mainVM)
                    .environmentObject(homeVM)

            } else {
                DhikarPlay(viewModel: viewModel, page: $page)
                    .environmentObject(mainVM)
                    .environmentObject(homeVM)
            }
        }
    }
}
