//
//  AgeExposedScreen.swift
//  Resolved
//
//  Created by Dante Kim on 7/19/24.
//

import SwiftUI

struct AgeExposedScreen: View {
    let options = ["Under 17", "18-26", "27-34", "35-45", "45-55", "55+"]

    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            GeometryReader { _ in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32)
                            .onTapGesture {
                                withAnimation {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                            }
                    }.padding(.horizontal)
                    Text("What is your age range?")
                        .foregroundStyle(Color.white)
                        .sfFont(weight: .bold, size: .h2)
                        .padding(.horizontal)
                        .padding(.top)
                    Text("The following questions will be used to personalize your experience")
                        .foregroundStyle(Color.primaryForeground)
                        .sfFont(weight: .medium, size: .h3p1)
                        .padding(.horizontal)
                    Spacer()
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {}) {
                                Text(option)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 64)
                                    .background(Color.secondaryBackground)
                                    .cornerRadius(16)
                                    .sfFont(weight: .semibold, size: .h3p1)
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
            }
        }.onAppearAnalytics(event: "RelapseReasonScreen: Screenload")
    }
}

#Preview {
    AgeExposedScreen()
}
