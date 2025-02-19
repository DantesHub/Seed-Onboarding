//
//  EducationScreen.swift
//  Resolved
//
//  Created by Dante Kim on 8/9/24.
//

import SuperwallKit
import SwiftData
import SwiftUI

struct EducationScreen: View {
    @EnvironmentObject var viewModel: EducationViewModel
    @EnvironmentObject var breathVM: BreathworkViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var reflectVM: ReflectionsViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @Query private var sessionHistory: [SoberInterval]
    var gridItemLayout = Array(repeating: GridItem(.flexible(), spacing: 0), count: 2)
    @Environment(\.modelContext) private var modelContext
    @State private var isReflectionSelected = false
    @State private var notesCount = 0

    var body: some View {
        GeometryReader { g in
            let width = g.size.width
            let height = g.size.height

            ZStack {
                Color.primaryBackground.edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading) {
                    HStack {
                        Text("Tapes")
                            .overusedFont(weight: .semiBold, size:UIDevice.isSmall ? .h2Big : .h1)
                            .foregroundColor(!isReflectionSelected ? .white : .white.opacity(0.5))
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation {
                                    isReflectionSelected = false
                                }
                            }
                        Text("Reflections")
                            .overusedFont(weight: .semiBold, size: UIDevice.isSmall ? .h2Big : .h1)
                            .foregroundColor(isReflectionSelected ? .white : .white.opacity(0.5))
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation {
                                    isReflectionSelected = true
                                }
                            }
                            .padding(.horizontal, 12)

                        Spacer()
                        Button(action: {
                            // Menu button action
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            Analytics.shared.log(event: "ReflectionsScreen: Tapped i")
                            if isReflectionSelected {
                                withAnimation {
                                    if !mainVM.currUser.isPro, notesCount > 0 {
                                        Analytics.shared.log(event: "ReflectionsScreen: Triggered Pricing")
                                        Superwall.shared.register(event: "feature_locked", params: ["screen": "reflections"], handler: mainVM.handler)
                                    } else {
                                        reflectVM.showWriteReflection = true
                                    }
                                }
                            } else {
                                Analytics.shared.log(event: "TapeScreen: Tapped Info")
                                if let url = URL(string: "https://imported-periodical-608.notion.site/Rewire-Tapes-FAQ-12eca98e4f9980ce85ccd57515013018?pvs=4") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }) {
                            Image(systemName: isReflectionSelected ? "plus.circle.fill" : "info.circle.fill")
                                .overusedFont(weight: .semiBold, size: .h2)
                                .foregroundColor(.primaryBlue)
                        }
                    }.padding(.horizontal, 28)
                    
                    if isReflectionSelected {
                        NewReflectionsScreen()
                            .environmentObject(mainVM)
                            .environmentObject(homeVM)
                            .environmentObject(reflectVM)
                    } else {
                        CoursesScreen()
                            .environmentObject(mainVM)
                            .environmentObject(viewModel)
                    }
                 
                }
            }.frame(width: width)
        }.onAppear {
            for session in sessionHistory {
                notesCount += session.motivationalNotes.count
                notesCount += session.thoughtNotes.count
                notesCount += session.lapseNotes.count
            }
        }
    }
}

#Preview {
    EducationScreen()
        .environmentObject(EducationViewModel())
        .environmentObject(MainViewModel())
        .environmentObject(BreathworkViewModel())
}
