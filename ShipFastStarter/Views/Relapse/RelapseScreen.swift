//
//  RelapseScreen.swift
//  Resolved
//
//  Created by Dante Kim on 10/13/24.
//

import SwiftData
import SwiftUI

struct RelapseScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var timerVM: TimerViewModel
    @Binding var didFold: Bool
    @State private var randNum = 0
    @State var streak = ""
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SoberInterval.startDate, order: .reverse) private var sessionHistory: [SoberInterval]

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 12) {
                Spacer()
                if homeVM.showRelapse {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.primaryForeground)
                            .frame(width: 32)
                            .onTapGesture {
                                withAnimation {
                                    Analytics.shared.log(event: homeVM.tappedRelapse ? "RelapseScreen: Tapped X" : "CheckInScreen: Tapped X")
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    homeVM.showRelapse = false
                                    homeVM.showCheckIn = false
                                }
                            }
                        Spacer()
                    }
                    .padding()
                    .padding(.top)
                }
                Spacer()

                Image("originalSeed")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 156)
                VStack {
                    Text("Hey. It's completely okay.")
                        .overusedFont(weight: .bold, size: .h1Big)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)

                    VStack(spacing: 12) {
                        Text("You made it \(streak). Don't let one bad moment wash away the hard work you've put in.")
                            .overusedFont(weight: .semiBold, size: .h3p1)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                        Text("\(randNum) people have restarted their journey today. Join them and come back stronger. You got this.")
                            .overusedFont(weight: .semiBold, size: .h3p1)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                    }
                    Spacer()
                    SharedComponents.HomeRelapsedButton(title: "Restart Milestone", action: {
//                        updateData()
                        Analytics.shared.log(event: "ItsOkay: Tapped Restart Milestone")
                        withAnimation {
                            didFold = true
                            homeVM.currentScreen = .first
                        }
                    }, color: [Color(red: 0.52, green: 0.14, blue: 0.9), Color(red: 0.11, green: 0, blue: 0.21)], height: 72)
                        .padding()
                        .padding(.bottom, 48)
                        .offset(y: -48)
                }
            }.padding(.horizontal, 24)
        }.onAppear {
            randNum = Int.random(in: 232 ... 476)
            streak = "\(Date.timeDifference(date1: mainVM.currentInterval.startDate, date2: Date().toString()).1) \(Date.timeDifference(date1: mainVM.currentInterval.startDate, date2: Date().toString()).0)"
        }
        .onAppearAnalytics(event: "ItsOkay: Screenload")
    }

    func updateData() {
        mainVM.currentInterval.endDate = Date().toString()
        DataManager.shared.saveContext(context: modelContext)

        let newInterval = SoberInterval.createSoberInterval()

        newInterval.seed = "originalSeed"

        let startDate = Date.newStartDate(relapseDate: homeVM.lastRelapsed).toString()
        newInterval.startDate = startDate
        modelContext.insert(newInterval)

        if let date = Date.fromString(startDate) {
            mainVM.currentInterval = newInterval
            homeVM.shouldEvolve(startDate: date, currentOrb: "originalSeed")
            newInterval.seed = homeVM.selectedOrb.0.name()
            timerVM.startDate = date
            timerVM.startTimer(isInit: false)
            DataManager.shared.saveContext(context: modelContext)
        }
    }
}

#Preview {
    RelapseScreen(didFold: .constant(false))
        .environmentObject(MainViewModel())
}
