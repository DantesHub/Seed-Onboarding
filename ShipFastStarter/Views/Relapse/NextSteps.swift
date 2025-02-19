//
//  NextSteps.swift
//  Resolved
//
//  Created by Dante Kim on 8/5/24.
//

import SplineRuntime
import SwiftUI

struct NextSteps: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var historyVM: HistoryViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var dhikrVM: DhikrViewModel

    @Environment(\.modelContext) private var modelContext

    @State private var url: URL?

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
//            SharedComponents.linearGradient()
//                .offset(y: 100)
            GeometryReader { _ in
                VStack(alignment: .center, spacing: -24) {
                    Text("Let's bounce back")
                        .foregroundStyle(Color.white)
                        .overusedFont(weight: .bold, size: .h1Big)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 48)
                    Text("You only fail when you quit.")
                        .foregroundStyle(Color.primaryForeground)
                        .multilineTextAlignment(.center)
                        .overusedFont(weight: .medium, size: .h3p1)
                        .padding(.horizontal)
                        .padding(.top, 32)
                    // if user has x amount of days already.
                    HStack {
                        Spacer()
                        VStack {
                            SplineView(sceneFileURL: url)
                                .frame(width: 300, height: 300)
                                .ignoresSafeArea(.all)
                                .padding()
                                .id(url)

                        }.frame(width: 300, height: 300)
                            .offset(y: 100)

                        Spacer()
                    }
                    Spacer()
                    if mainVM.currUser.religion != "Muslim" {
                        SharedComponents.PrimaryButton(title: "Begin Again") {
                            //                    DataManager.shared.saveContext(context: modelContext)
                            homeVM.showCheckIn = false
                            homeVM.showRelapse = false
//                            homeVM.currentScreen = .itsOkay
//                            DataManager.shared.batchSaveIntervals(historyVM.historyList, context: modelContext)

                        }.padding()
                            .padding(.bottom, 32)
                    } else {
                        SharedComponents.PrimaryButton(title: "Start forgiveness dhikr") {
                            //                    DataManager.shared.saveContext(context: modelContext)
                            Analytics.shared.log(event: "NextSteps: Tapped Forgiveness Dhikr")
                            dhikrVM.selectedDhikir = .dhikrs[1]
//                            homeVM.currentScreen = .dhikr
                        }.padding()
                            .padding(.top, 32)
                            .padding(.horizontal)

                        Text("Go Home")
                            .foregroundColor(.gray)
                            .underline()
                            .onTapGesture {
                                homeVM.showCheckIn = false
                                homeVM.showRelapse = false
//                                homeVM.currentScreen = .itsOkay
//                                DataManager.shared.batchSaveIntervals(historyVM.historyList, context: modelContext)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 32)
                    }
                    Spacer()
                }
            }
        }.onAppear {
            if homeVM.selectedOrb.0.rawValue.contains("https") {
                url = URL(string: homeVM.selectedOrb.0.rawValue)
            } else {
                url = Bundle.main.url(forResource: homeVM.selectedOrb.0.rawValue, withExtension: "splineswift")
            }
        }
    }
}

#Preview {
    NextSteps()
        .environmentObject(MainViewModel())
        .environmentObject(HistoryViewModel())
        .environmentObject(HomeViewModel())
}
