//
//  WelcomeScreen.swift
//  Resolved
//
//  Created by Gursewak Singh on 03/10/24.
//

import SwiftUI

struct WelcomeScreen: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var mainVM: MainViewModel
    @State private var isWriteReflectionActive = false

    var body: some View {
        NavigationStack {
            ZStack {
                Image(uiImage: UIImage(named: "gender_bg")!)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                // Centered text and options
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 40)
                    SharedComponents.CustomExtraBoldHeading(title: "Welcome back,\nDante.", color: .white)

                    VStack {
                        SharedComponents.CustomBoldHeading(title: "You’re on a", color: .white)
                        SharedComponents.CustomBoldHeading(title: "5 day streak.", color: Color(hex: "#444FFF"))
                    }
                    Spacer()
                    VStack(spacing: 8) {
                        SharedComponents.CustomLightText(title: "You haven’t reflected in 8 days.", color: Color(.white.opacity(0.5)))

                        SharedComponents.PrimaryButton(title: "Reflect", action: {
                            isWriteReflectionActive = true

                        }).padding(.leading, 20)
                            .padding(.trailing, 20)
                            .navigationDestination(isPresented: $isWriteReflectionActive) {
                                WriteReflectionScreen()
                            }
                        SharedComponents.CustomLightText(title: "Maybe later", color: Color(.white)).underline()
                    }
                    // Gender options buttons
                    Spacer()
                        .frame(height: 20)
                }

                Spacer() // Pushes content up to center it
            }
            .onAppearAnalytics(event: "RelapseReasonScreen: Screenload")
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    WelcomeScreen()
}
