//
//  WidgetModal.swift
//  ColorMe
//
//  Created by Dante Kim on 6/17/24.
//

import CoreLocation
import Foundation
import SwiftUI

struct WidgetModal: View {
    enum WidgetStep {
        case step0
        case step1
        case step2
        case first
    }

    @State var step: WidgetStep = .first
    @Binding var showModal: Bool

    var body: some View {
        ZStack {
            Color.primaryBackground
            VStack {
                Spacer()
                if step == .step0 {
                    VStack {
                        Text("1. Touch & hold home screen \nuntil jiggle")
                            .overusedFont(weight: .semiBold, size: .h3p1)
                            .foregroundColor(Color.primaryForeground)
                            .multilineTextAlignment(.center)
                            .padding(.top)
                        Image(.widgetStep0)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300)
                            .cornerRadius(24)
                            .shadow(radius: 4)
                            .padding()
                    }
                } else if step == .step1 {
                    VStack {
                        Text("2. Press the plus in the top\nleft corner")
                            .overusedFont(weight: .semiBold, size: .h3p1)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.primaryForeground)
                            .padding(.top)
                        Image(.widgetStep1)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300)
                            .cornerRadius(24)
                            .shadow(radius: 4)
                            .padding()
                    }
                } else if step == .step2 {
                    VStack {
                        Text("3. Search Seed,\nadd to homescreen")
                            .overusedFont(weight: .semiBold, size: .h3p1)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.primaryForeground)
                            .padding(.top)
                        Image(.widgetStep2)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300)
                            .cornerRadius(24)
                            .shadow(radius: 4)
                            .padding()
                    }
                } else {
                    VStack {
                        HStack {
                            Image(systemName: "xmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color.primaryForeground)
                                .frame(width: 16)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation {
                                        Analytics.shared.log(event: "WidgetModal: Tapped X")
                                        showModal.toggle()
                                    }
                                }
                            Spacer()
                            VStack(spacing: 0) {
                                Text("users who add a widget are")
                                    .overusedFont(weight: .semiBold, size: .h3p1)
                                    .foregroundColor(Color.primaryForeground)
                                Text("37% more likely to quit!")
                                    .overusedFont(weight: .semiBold, size: .h3p1)
                                    .foregroundColor(Color.primaryBlue)
                            }

                            Spacer()
                            Image(systemName: "xmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color.primaryForeground)
                                .frame(width: 16)
                                .opacity(0)
                        }.padding(.horizontal)

                        Image(.widgetCard)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 325)
                            .cornerRadius(24)
                            .shadow(radius: 4)
                            .padding()
                    }
                }
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.primaryPurple)
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.secondaryBackground.opacity(0.5), lineWidth: 2.5)
                        )

                    HStack {
                        Text(step == .first ? "Add to my screen!" : step == .step1 ? "Final Step" : step == .step2 ? "Done" : "Next Step")
                            .overusedFont(weight: .semiBold, size: .h3p1)
                            .foregroundColor(.white)
                    }.foregroundColor(Color.white)
                        .padding(.leading, 8)
                }.onTapGesture {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation {
                        // ask for location permissions
                        if step == .step0 {
                            step = .step1
                            Analytics.shared.log(event: "WidgetModal: Step 1 -> 2")
                        } else if step == .step1 {
                            Analytics.shared.log(event: "WidgetModal: Step 2 -> 3")
                            step = .step2
                        } else if step == .step2 {
                            Analytics.shared.log(event: "WidgetModal: Click Final Step")
                            // close out modal
                            showModal.toggle()
                        } else {
                            step = .step0
                            Analytics.shared.log(event: "WidgetModal: Step 1 -> 2")
                        }
                    }
                }.padding(.bottom)
                // Add your half sheet content here
            }
        }
        .onAppearAnalytics(event: "WidgetModal: Screenload Modal")
//        .clipShape(RoundedRectangle(cornerRadius: 10))
//        .shadow(radius: 5)
    }
}

#Preview {
    WidgetModal(showModal: .constant(true))
        .frame(height: 500)
}

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var authorizationChangeHandler: ((CLAuthorizationStatus) -> Void)?

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationChangeHandler?(manager.authorizationStatus)
    }
}
