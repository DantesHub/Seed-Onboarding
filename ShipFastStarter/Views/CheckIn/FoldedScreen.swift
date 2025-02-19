//
//  FoldedScreen.swift
//  Resolved
//
//  Created by Dante Kim on 10/7/24.
//

import SwiftUI

struct FoldedScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @Binding var didFold: Bool

    var body: some View {
        ZStack {
//            Image(.justBackground)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .edgesIgnoringSafeArea(.all)
            GeometryReader { g in
                let height = g.size.height
                VStack(alignment: .leading, spacing: 16) {
                    Text("Did you fold since we last chatted?")
                        .multilineTextAlignment(.center)
                        .overusedFont(weight: .bold, size: .h1)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 24)
                    Text("Don’t worry, this is a safe space. Answer honestly and we can help you better.")
                        .multilineTextAlignment(.center)
                        .overusedFont(weight: .medium, size: .h3p1)
                        .foregroundColor(.white)
                        .opacity(0.6)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    SharedComponents.OnboardVoteOption(title: "Yes", height: height / 4)
                        .onTapGesture {
                            Analytics.shared.log(event: "FoldedScreen: Tapped Yes")
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                homeVM.currentScreen = .first
                            }
                            didFold = true
                        }
                    SharedComponents.OnboardVoteOption(title: "No", height: height / 4)
                        .onTapGesture {
                            Analytics.shared.log(event: "FoldedScreen: Tapped No")
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
//                                homeVM.currentScreen = .trigger
                            }

                            didFold = false
                        }
                        .padding(.bottom, 64)
                }
                .padding()
            }
        }
    }
}

struct BigOption: View {
    let title: String
    let height: CGFloat
    var body: some View {
        Text(title)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overusedFont(weight: .medium, size: .h3p1)
            .background(SharedComponents.Gradients.primary)
            .cornerRadius(24)
    }
}

#Preview {
    FoldedScreen(didFold: .constant(false))
        .environmentObject(MainViewModel())
}
