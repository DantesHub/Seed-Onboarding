//
//  DhikrCompletion.swift
//  Resolved
//
//  Created by Dante Kim on 8/5/24.
//

import SplineRuntime
import SwiftUI

struct DhikrCompletion: View {
    @EnvironmentObject var viewModel: DhikrViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var mainVM: MainViewModel

    @Environment(\.modelContext) private var modelContext
    @State private var url: URL?
    @Binding var page: PanicPage

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            GeometryReader { _ in
                VStack {
                    Spacer()
                    VStack {
                        Text("Dhikr Completed")
                            .foregroundColor(Color.white)
                            .overusedFont(weight: .bold, size: .h1)
                            .multilineTextAlignment(.center)
                            .offset(y: 50)
                        LottieView(loopMode: .playOnce, animation: "checkmark", isVisible: .constant(true))
                            .frame(width: 300)
                            .offset(y: -100)
                    }

                    HStack(alignment: .center) {
                        VStack {
                            Text("Total Duration")
                                .foregroundColor(Color.primaryForeground)
                                .overusedFont(weight: .medium, size: .h2)
                                .multilineTextAlignment(.center)
                            Text("\(viewModel.selectedDuration / 60) min")
                                .foregroundColor(Color.primaryPurple)
                                .overusedFont(weight: .bold, size: .title)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                        VStack {
                            Text("Total Dhikrs")
                                .foregroundColor(Color.primaryForeground)
                                .overusedFont(weight: .medium, size: .h2)
                                .multilineTextAlignment(.center)
                            Text("\(viewModel.counter)")
                                .foregroundColor(Color.primaryPurple)
                                .overusedFont(weight: .bold, size: .title)
                                .multilineTextAlignment(.center)
                        }
                    }.offset(y: -200)
                        .padding(.horizontal, 32)

                    Spacer()
                    SharedComponents.PrimaryButton(title: "Finish") {
                        Analytics.shared.logActual(event: "DhikrCompletition: Clicked Complete")
                        DataManager.shared.saveContext(context: modelContext)
                        homeVM.showCheckIn = false
                        homeVM.showRelapse = false
                        homeVM.tappedRelapse = false
                        mainVM.startDhikr = false
                        viewModel.progress = 0.0
                        viewModel.elapsedTime = 0.0
                    }
                    .padding(28)
                    .offset(y: -100)
                }.offset(y: 50)
            }
        }.onDisappear {
            viewModel.completedDhikr = false
        }
        .onAppearAnalytics(event: "DhikrCompletion: Screenload")
    }
}

#Preview {
    DhikrCompletion(page: .constant(.dhikr))
        .environmentObject(DhikrViewModel())
        .environmentObject(HomeViewModel())
}
