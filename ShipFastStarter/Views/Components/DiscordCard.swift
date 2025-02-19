//
//  DiscordCard.swift
//  Resolved
//
//  Created by Dante Kim on 10/23/24.
//

import SuperwallKit
import SwiftUI

struct DiscordCard: View {
    @EnvironmentObject var mainVM: MainViewModel

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack {
                    
                        Image(.discord)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 72)
                        //                                                .shadow(color: Color.primaryBlue, radius: 12)
                    }
                    
                    VStack {
                        HStack {
                            //
                            Text("You're not alone")
                            
                                .overusedFont(weight: .bold, size: .h2)
                                .foregroundColor(Color(hex: "#64A2FF"))
                                .padding(.top)
                                .padding(.leading, 12)
                            Spacer()
                            
                        }
                        
                        
                        Text("Find an accoutability partner & share your wins with other pro users")
                            .overusedFont(weight: .medium, size: .p2)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .transition(.opacity) // Use transition for fading
                            .truncationMode(.tail)
                            .padding(.leading, 12)
                            .padding(.trailing, 4)
                            .padding(.bottom)
                            .cornerRadius(10)
                    }
                }.padding(.horizontal, 8)
                VStack(spacing: -12) {
                    Image(.discord2)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(24)
                        .shadow(color: Color.primaryBlue.opacity(0.6), radius: 12)
                        .rotationEffect(.degrees(4))
                    Image(.discord1)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(24)
                        .shadow(color: Color.primaryBlue.opacity(0.6), radius: 12)
                        .rotationEffect(.degrees(2))
                }
                SharedComponents.OnboardVoteOption(title: "Join the Community", height: 64)
                    .padding(.top, 32)
                    .onTapGesture {
                        withAnimation {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            UserDefaults.standard.setValue(true, forKey: "tappedCommunity")
                            Analytics.shared.logActual(event: "\(mainVM.currentPage.rawValue)Screen: Tapped Join Community", parameters: ["isPro": false])
                            if let url = URL(string: "https://discord.gg/qyWWzgkpJF") {
                                UIApplication.shared.open(url)
                                
                            }
                            //                        if mainVM.currUser.isPro {
                            //
                            //                        } else {
                            //                            Superwall.shared.register(event: "feature_locked", params: ["screen":"Discord"], handler: mainVM.handler) {
                            //
                            //                            }
                            //                        }
                        }
                    }
            }
        }.padding(.bottom)
            .padding(.horizontal)
            .background(
                Color(hex: "#1E2045")
                    .overlay(RoundedRectangle(cornerRadius: 24)
                        .fill(Color(hex: "#1E2045")))
                    .cornerRadius(24)
            )
            .padding()
    }
}
