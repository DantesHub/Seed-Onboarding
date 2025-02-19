//
//  HomeViewModel.swift
//  NoFap
//
//  Created by Dante Kim on 7/10/24.
//

import FirebaseAuth
import Foundation
import SwiftUI
import WidgetKit

enum CheckInPage {
    case mood
    case first
}

class HomeViewModel: ObservableObject {
    @Published var selectedOrb = (Orb.originalSeed, OrbSize.full)
    @Published var showEvolution = false
    @Published var tappedRelapse = false
    @Published var showCheckIn = false
    @Published var numDaysSinceLastCheckIn = 2
    @Published var selected = 1
    @Published var lastRelapsed: String = ""
    @Published var currentScreen: CheckInPage = .mood
    @Published var showRelapse = false
    @Published var showChat = false
    @Published var showNote = false
    @AppStorage("startDate", store: UserDefaults(suiteName:"group.io.nora.nofap.widgetFun")) var startDate = ""
    @AppStorage("seed", store: UserDefaults(suiteName: "group.io.nora.nofap.widgetFun")) var seed = ""

    @Published var showWidgetModal = false
    @Published var showSignUpModal = false
    @Published var showNNNTimer = false

    func lastCheckIn(lastCheckInDate: Date, mainVM: MainViewModel) { //
        if UserDefaults.standard.bool(forKey: "showNNNTimer") {
            showNNNTimer = true
        }

        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: lastCheckInDate)
        let endDate = calendar.startOfDay(for: Date())

        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        numDaysSinceLastCheckIn = components.day ?? 0

//        currentScreen = .welcome
//        showCheckIn = true

        if !lastCheckInDate.isDateToday() {
            if lastCheckInDate.isDateYesterday() {
                // user checked in yesterday check if its after 9 PM to show him new check-in
                Analytics.shared.log(event: "LastCheckIn: Show Check in 1 day")
                if Date().isAfterNine() {
                    Task {
                        await mainVM.fetchCheckInDay(daysSince: -numDaysSinceLastCheckIn)
                    }
//                    showCheckIn = true
//                    currentScreen = .welcome
                }

                mainVM.scheduleTomorrowNotification()
            } else {
                // user hasnt checked in over 2 days
                Analytics.shared.log(event: "LastCheckIn: Show Check in > 2 days")
                Task {
                    await mainVM.fetchCheckInDay(daysSince: -numDaysSinceLastCheckIn)
                }
                showCheckIn = true

                mainVM.scheduleTomorrowNotification()
            }
        }
    }

    func shouldEvolve(startDate: Date, currentOrb: String) -> Bool {
        let elapsed = Date().timeIntervalSince(startDate)

        // here is based off number of lessons and checks in we add more "time" or aura.
        getOrb(elapsedTime: elapsed / 3600)
//        aura = (elapsed)
//        print(aura, "aura")
        if currentOrb != selectedOrb.0.name() { // evolved
            Analytics.shared.logActual(event: "OrbEvolved", parameters: ["orb": selectedOrb.0.name(), "previousOrb": currentOrb])
            updateWidget(startDate: startDate)
            return true
        } else {
            updateWidget(startDate: startDate)
            return false
        }
    }

    func updateWidget(startDate: Date) {
        self.startDate = startDate.toString()
        seed = selectedOrb.0.name()
        WidgetCenter.shared.reloadAllTimelines()
    }

    //    func getOrbName(fromDate: Date) -> String {
    //        let elapsed = Date().timeIntervalSince(fromDate)
    //        getOrb(elapsedTime: elapsed / 3600)
    //
    //    }

    func getOrb(elapsedTime: Double) {
        switch elapsedTime {
        case 0 ..< 72: // Day 1-3
            switch elapsedTime {
            case 0 ..< 14.4: selectedOrb = (Orb.originalSeed, OrbSize.extraSmall)
            case 14.4 ..< 28.8: selectedOrb = (Orb.originalSeed, OrbSize.small)
            case 28.8 ..< 43.2: selectedOrb = (Orb.originalSeed, OrbSize.medium)
            case 43.2 ..< 57.6: selectedOrb = (Orb.originalSeed, OrbSize.large)
            case 57.6 ..< 72: selectedOrb = (Orb.originalSeed, OrbSize.extraLarge)
            default: selectedOrb = (Orb.originalSeed, OrbSize.extraLarge)
            }
        case 72 ..< 168: // Day 3-7
            switch elapsedTime {
            case 72 ..< 91.2: selectedOrb = (Orb.blueOrb, OrbSize.extraSmall)
            case 91.2 ..< 110.4: selectedOrb = (Orb.blueOrb, OrbSize.small)
            case 110.4 ..< 129.6: selectedOrb = (Orb.blueOrb, OrbSize.medium)
            case 129.6 ..< 148.8: selectedOrb = (Orb.blueOrb, OrbSize.large)
            case 148.8 ..< 168: selectedOrb = (Orb.blueOrb, OrbSize.extraLarge)
            default: selectedOrb = (Orb.blueOrb, OrbSize.extraLarge)
            }
        case 168 ..< 336: // Day 7-14
            switch elapsedTime {
            case 168 ..< 201.6: selectedOrb = (Orb.fireDrop, OrbSize.extraSmall)
            case 201.6 ..< 235.2: selectedOrb = (Orb.fireDrop, OrbSize.small)
            case 235.2 ..< 268.8: selectedOrb = (Orb.fireDrop, OrbSize.medium)
            case 268.8 ..< 302.4: selectedOrb = (Orb.fireDrop, OrbSize.large)
            case 302.4 ..< 336: selectedOrb = (Orb.fireDrop, OrbSize.extraLarge)
            default: selectedOrb = (Orb.fireDrop, OrbSize.extraLarge)
            }
        case 336 ..< 504: // Day 14-21
            switch elapsedTime {
            case 336 ..< 369.6: selectedOrb = (Orb.materialBlob, OrbSize.extraSmall)
            case 369.6 ..< 403.2: selectedOrb = (Orb.materialBlob, OrbSize.small)
            case 403.2 ..< 436.8: selectedOrb = (Orb.materialBlob, OrbSize.medium)
            case 436.8 ..< 470.4: selectedOrb = (Orb.materialBlob, OrbSize.large)
            case 470.4 ..< 504: selectedOrb = (Orb.materialBlob, OrbSize.extraLarge)
            default: selectedOrb = (Orb.materialBlob, OrbSize.extraLarge)
            }
        case 504 ..< 720: // Day 21-30
            switch elapsedTime {
            case 504 ..< 558: selectedOrb = (Orb.infinityBulb, OrbSize.extraSmall)
            case 558 ..< 612: selectedOrb = (Orb.infinityBulb, OrbSize.small)
            case 612 ..< 666: selectedOrb = (Orb.infinityBulb, OrbSize.medium)
            case 666 ..< 720: selectedOrb = (Orb.infinityBulb, OrbSize.large)
            default: selectedOrb = (Orb.infinityBulb, OrbSize.extraLarge)
            }
        case 720 ..< 1080: // Day 30-45
            switch elapsedTime {
            case 720 ..< 810: selectedOrb = (Orb.spores, OrbSize.extraSmall)
            case 810 ..< 900: selectedOrb = (Orb.spores, OrbSize.small)
            case 900 ..< 990: selectedOrb = (Orb.spores, OrbSize.medium)
            case 990 ..< 1080: selectedOrb = (Orb.spores, OrbSize.large)
            default: selectedOrb = (Orb.spores, OrbSize.extraLarge)
            }
        case 1080 ..< 1440: // Day 45-60
            switch elapsedTime {
            case 1080 ..< 1170: selectedOrb = (Orb.lavalLamp, OrbSize.extraSmall)
            case 1170 ..< 1260: selectedOrb = (Orb.lavalLamp, OrbSize.small)
            case 1260 ..< 1350: selectedOrb = (Orb.lavalLamp, OrbSize.medium)
            case 1350 ..< 1440: selectedOrb = (Orb.lavalLamp, OrbSize.large)
            default: selectedOrb = (Orb.lavalLamp, OrbSize.extraLarge)
            }
        case 1440 ..< 2160: // Day 60-90
            switch elapsedTime {
            case 1440 ..< 1620: selectedOrb = (Orb.aiSphere, OrbSize.extraSmall)
            case 1620 ..< 1800: selectedOrb = (Orb.aiSphere, OrbSize.small)
            case 1800 ..< 1980: selectedOrb = (Orb.aiSphere, OrbSize.medium)
            case 1980 ..< 2160: selectedOrb = (Orb.aiSphere, OrbSize.large)
            default: selectedOrb = (Orb.aiSphere, OrbSize.extraLarge)
            }
        case 2160...: // Day 90+
            selectedOrb = (Orb.marbleDyson, OrbSize.full)
        default:
            selectedOrb = (Orb.marbleDyson, OrbSize.full)
        }
    }
}
