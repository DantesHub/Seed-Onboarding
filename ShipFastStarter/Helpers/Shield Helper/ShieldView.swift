//
//  ShieldView.swift
//  Resolved
//
//  Created by Gursewak Singh on 27/09/24.
//
import DeviceActivity
import Foundation
import SwiftUI

struct ShieldView: View {
    @EnvironmentObject private var manager: ShieldViewModel
    @State private var showActivityPicker = false

    var body: some View {
        HStack {
            Image(systemName: "globe.europe.africa.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24)
                .padding(.trailing)

            Text("Block sites and apps")
                .sfFont(weight: .medium, size: .h3p1)
            Spacer()
            // Reduced size to match the image
            Image(systemName: "chevron.right")
                .foregroundColor(Color.primaryForeground)
        }
        .padding(.horizontal, 16) // Add horizontal padding inside the HStack
        .frame(height: 48) // Reduce height to match the image
        .background(Color.secondaryBackground)
        .cornerRadius(12) // Apply corner radius to the background
        .foregroundColor(.primaryForeground)
        .onTapGesture {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    showActivityPicker = true
                } else if let error {
                    print(error.localizedDescription)
                }
            }
        }

  
    }

    func setupDeviceActivitySchedule() -> DeviceActivitySchedule {
        // Define start and end time for shielding apps
        let startComponents = DateComponents(hour: 23, minute: 12) // Start at 9 AM
        let endComponents = DateComponents(hour: 23, minute: 13) // End at 9:05 AM (5 minutes)

        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents, repeats: false
        )

        return schedule
    }
}
