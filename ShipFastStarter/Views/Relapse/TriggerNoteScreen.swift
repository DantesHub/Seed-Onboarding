//
//  TriggerNoteScreen.swift
//  Resolved
//
//  Created by Dante Kim on 7/13/24.
//

import SwiftUI

struct TriggerNoteScreen: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @State private var noteText: String = ""
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            GeometryReader { _ in
                VStack(alignment: .leading, spacing: 12) {
                    (Text("What were some of the ")
                        .foregroundStyle(Color.white)
                        + Text("triggers?")
                        .foregroundStyle(Color.secondaryPurple)
                    )
                    .overusedFont(weight: .bold, size: .h1)
                    .padding(.horizontal)
                    .padding(.top, 32)
                    Text("Really reflect and think. Awareness is the 1st step to change. Be really specific.")
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
                        if noteText.isEmpty {
                            Text("I was alone in my room,  after 9 PM and i had  no  energy, i should hop on a discord call with friends")
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
                        withAnimation {
                            mainVM.currentInterval.lapseNotes[Date().toString()] = noteText
                            DataManager.shared.saveContext(context: modelContext)
//                            homeVM.currentScreen = .future
                        }
                    }.disabled(noteText.count < 4)
                        .opacity(noteText.count >= 4 ? 1 : 0.5)
                        .padding(.top)
                    Text("Skip")
                        .overusedFont(weight: .medium, size: .h3p1)
                        .foregroundColor(.gray)
                        .underline()
                        .onTapGesture {
                            withAnimation {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                homeVM.currentScreen = .future
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                    Spacer()
                }.padding()
            }
        }
    }
}

#Preview {
    TriggerNoteScreen()
        .environmentObject(HomeViewModel())
}
