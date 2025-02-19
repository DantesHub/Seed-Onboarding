//
//  ReflectionsScreen.swift
//  Resolved
//
//  Created by Gursewak Singh on 03/10/24.
//

import SwiftUI

struct ReflectionsScreen: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var mainVM: MainViewModel

    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: "gender_bg")!)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            // Centered text and options
            VStack(spacing: 32) {
                Text("Reflections.")
                    .foregroundColor(Color(hex: "#444FFF"))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
                    .sfFont(weight: .bold, size: .h1Big)
                VStack {
                    Text("You’re on a")
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .sfFont(weight: .bold, size: .h1Big)

                    Text("5 day streak.")
                        .foregroundColor(Color(hex: "#444FFF"))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .sfFont(weight: .bold, size: .h1Big)
                }
                Spacer()
                VStack(spacing: 12) {
                    Text("You haven’t reflected in 8 days.")
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .sfFont(weight: .regular, size: .p3)
                    Button(action: {}) {
                        Text("Reflect")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "#6F73FF"), Color(hex: "#1A20CE")]), // Normal colors
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .cornerRadius(12)
                            )
                    }
                    Text("Maybe later")
                        .underline()
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .sfFont(weight: .regular, size: .p3)
                        .padding()
                }
                // Gender options buttons
            }
            .safeAreaPadding()
            .padding()

            Spacer() // Pushes content up to center it
        }
        .onAppearAnalytics(event: "RelapseReasonScreen: Screenload")
        .navigationBarHidden(true)
    }
}

#Preview {
    ReflectionsScreen()
}
