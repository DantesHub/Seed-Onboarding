//
//  FutureNoteScreen.swift
//  Resolved
//
//  Created by Dante Kim on 7/13/24.
//

import SwiftData
import SwiftUI

struct FutureNoteScreen: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var educationVM: EducationViewModel
    @State private var noteText: String = ""
    @Environment(\.modelContext) private var modelContext
    @Query private var sessionHistory: [SoberInterval]

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            GeometryReader { _ in
                VStack(alignment: .leading, spacing: 12) {
                    Text("Future Notes to Yourself")
                        .foregroundStyle(Color.white)
                        .overusedFont(weight: .bold, size: .h1)
                        .padding(.horizontal)
                        .padding(.top, 32)
                    Text("Write down anything that might stop you next time your triggered.")
                        .foregroundStyle(Color.primaryForeground)
                        .overusedFont(weight: .medium, size: .h3p1)
                        .padding(.horizontal)
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $noteText)
                            .foregroundColor(.white)
                            .padding()
                            .frame(height: 200)
                            .scrollContentBackground(.hidden)
                            .background(Color.secondaryBackground)
                            .cornerRadius(10)
                        //                        .overlay(
                        //                            RoundedRectangle(cornerRadius: 10)
                        //                                .stroke(Color.gray, lineWidth: 1)
                        //                        )
                        if noteText.isEmpty {
                            Text("Remember why you're doing this. Everytime you relapse you feel like shit man.")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 8)
                                .allowsHitTesting(false)
                                .padding()
                        }
                    }.padding(12)
                    Text("+ 10 EXP to your new seed, if completed")
                        .overusedFont(weight: .medium, size: .p2)
                        .foregroundColor(Color.primaryPurple)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity)

                    SharedComponents.PrimaryButton(title: "Continue") {
                        Analytics.shared.log(event: "FutureNoteScreen: Continue")
                        mainVM.currentInterval.motivationalNotes[Date().toString()] = noteText
                        if mainVM.currUser.religion == "Muslim" {
//                            homeVM.currentScreen = .nextSteps
                        } else {
                            homeVM.showRelapse = false
//                            homeVM.currentScreen = .itsOkay
                        }
                    }.disabled(noteText.count < 4)
                        .padding(.top)
                        .opacity(noteText.count >= 4 ? 1 : 0.5)
                    Text("Skip")
                        .overusedFont(weight: .medium, size: .h3p1)
                        .foregroundColor(.gray)
                        .underline()
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            Analytics.shared.log(event: "FutureNoteScreen: Skip")
                            if mainVM.currUser.religion == "Muslim" {
                                homeVM.currentScreen = .nextSteps
                            } else {
                                homeVM.showRelapse = false
                                homeVM.currentScreen = .itsOkay
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                }.padding()
                Spacer()
            }
        }.onChange(of: sessionHistory) { _, newValue in
            print("sessionHistory changed - new count:", newValue.count)
            for interval in newValue {
                print("Interval in changed sessionHistory - startDate: \(interval.startDate), id: \(interval.id)")
            }
        }
    }
}

#Preview {
    FutureNoteScreen()
        .environmentObject(HomeViewModel())
}
