//
//  SplineGestureView.swift
//  Resolved
//
//  Created by Dante Kim on 10/16/24.
//

import SplineRuntime
import SuperwallKit
import SwiftUI
import DeviceActivity

struct SplineViewWithGesture: UIViewRepresentable {
    let sceneFileURL: URL?
    var onDragChanged: ((CGPoint) -> Void)? // Closure to handle drag updates

    func makeUIView(context: Context) -> UIView {
        // Create the SplineView
        let splineView = SplineView(sceneFileURL: sceneFileURL)

        // Embed SplineView in a UIHostingController
        let hostingController = UIHostingController(rootView: splineView)
        let view = hostingController.view!
        view.backgroundColor = .clear

        // Add pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePan(_:)))
        panGesture.cancelsTouchesInView = false
        panGesture.delegate = context.coordinator // Set the delegate
        view.addGestureRecognizer(panGesture)

        return view
    }

    func updateUIView(_: UIView, context _: Context) {
        // Update the view if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onDragChanged: onDragChanged)
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var onDragChanged: ((CGPoint) -> Void)?
        private var lastLocation: CGPoint?

        init(onDragChanged: ((CGPoint) -> Void)?) {
            self.onDragChanged = onDragChanged
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            let location = gesture.location(in: gesture.view)

            switch gesture.state {
            case .began:
                // Store the initial location when the gesture begins
                lastLocation = location
            case .changed:
                if let lastLocation = lastLocation {
                    // Calculate the movement distance
                    let deltaX = location.x - lastLocation.x
                    let deltaY = location.y - lastLocation.y
                    let movementDistance = sqrt(deltaX * deltaX + deltaY * deltaY)

                    // Define a movement threshold
                    let movementThreshold: CGFloat = 5.0 // Adjust this value as needed

                    if movementDistance > movementThreshold {
                        // Trigger haptic feedback
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        // Update the last location
                        self.lastLocation = location
                    }
                } else {
                    // If lastLocation is nil, set it to the current location
                    lastLocation = location
                }

                // Call the closure with the updated location
                onDragChanged?(location)
            case .ended, .cancelled, .failed:
                // Reset the lastLocation when the gesture ends
                lastLocation = nil
            default:
                break
            }
        }

        // Allow simultaneous gesture recognition
        func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
            return true
        }
    }
}

protocol BottomPopDelegate {
    func didSelectDhikr()
}

import SwiftData

struct bottomPop: View {
    var delegate: BottomPopDelegate?
    @EnvironmentObject private var manager: ShieldViewModel
    @State private var showActivityPicker = false
    @Binding var isPresented: Bool
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var reflectionVM: ReflectionsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel

    @State private var notesCount = 0
    @Query private var sessionHistory: [SoberInterval]
    @State private var showPanicScreen = false
    @State private var showAlertModal = false
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                        SharedComponents.HomeRelapsedButton(title: manager.remainingTime > 0 ? "\(manager.formattedTime) deep breath, lock-in." : "Panic", action: {
//                        isPresented = false
//                        UserDefaults.standard.setValue(false, forKey: "sawPanicModal")
                         showPanicScreen = true
                      
                    }, color: [Color(red: 0.63, green: 0.11, blue: 0.11), Color(red: 0.32, green: 0.12, blue: 0.12).opacity(0.14)])
                    .alert("Lockdown Mode (2 minutes)", isPresented: $showAlertModal) {
                        Button("Settings", role: .cancel) {
                            Analytics.shared.log(event: "Panic Modal: Tapped Settings")
                            mainVM.currentPage = .profile
                            profileVM.showSettings = true
                        }
                        Button("Start", role: .destructive) {
                            Analytics.shared.logActual(event: "Panic Modal: Tapped Start", parameters: ["page": mainVM.onboardingScreen.rawValue])
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                blockApps()
                            }
                        }
                    } message: {
                        Text("You can edit duration & blocked apps in settings")
                    }
                    if mainVM.currUser.religion == "Muslim" {
                        SharedComponents.HomeDankherButton(title: "dhikr", action: {
                            withAnimation {
                                Analytics.shared.log(event: "HomeScreen: Tapped Dhikr")
                                isPresented = false
                                mainVM.startDhikr = true
                            }
                        }, color: [Color(red: 0.9, green: 0.8, blue: 0.14), Color(red: 0.66, green: 0.38, blue: 0.08).opacity(0.14)])
                    }
                    SharedComponents.HomeRelapsedButton(title: "AI Coach", action: {
                        isPresented = false
                        Analytics.shared.log(event: "HomeScreen: Tapped AI Coach")
                        isPresented = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            homeVM.showChat = true
                        }

                    }, color: [Color(red: 0.14, green: 0.9, blue: 0.73), Color(red: 0.08, green: 0.31, blue: 0.26).opacity(0.14)])

                    SharedComponents.HomeRelapsedButton(title: "I relapsed", action: {
                        isPresented = false
                        Analytics.shared.log(event: "HomeScreen: Tapped Relapsed")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                            homeVM.currentScreen = .itsOkay
                            homeVM.showRelapse = true
                        }
                    }, color: [Color(red: 0.52, green: 0.14, blue: 0.9), Color(red: 0.11, green: 0, blue: 0.21)])

                    SharedComponents.HomeRelapsedButton(title: "I wanna reflect", action: {
                        isPresented = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            Analytics.shared.log(event: "HomeScreen: Tapped Reflect")
                            reflectionVM.showWriteReflection = true
                        }
                    }, color: [Color(red: 0.44, green: 0.45, blue: 1), Color(red: 0.1, green: 0.13, blue: 0.81)])
                }
                .padding()
                .frame(minHeight: geometry.size.height)
                .familyActivityPicker(
                    isPresented: $showActivityPicker,
                    selection: $manager.familyActivitySelection
                )
                .onChange(of: manager.familyActivitySelection) {
                    
                    manager.shieldActivities()
                    showPanicScreen = true
        //            setupDeviceActivitySchedule()
        //            startScheduledShielding()
                }
            }.fullScreenCover(isPresented: $showPanicScreen) {
                PanicTypingScreen(showPanicScreen: $showPanicScreen, showPlusModal: $isPresented)
                    .environmentObject(mainVM)
                    .environmentObject(homeVM)
                    .environmentObject(reflectionVM)
                    .environmentObject(manager)
            }
        
        }
        .background(Color.black)
        .onAppear {
            for session in sessionHistory {
                notesCount += session.motivationalNotes.count
                notesCount += session.thoughtNotes.count
                notesCount += session.lapseNotes.count
            }
        }
    }
    
    private func blockApps() {
        Task {
            do {
                try await manager.requestAuthorization()
            }
        }
        Analytics.shared.log(event: "HomeScreen: Tapped Panic")
        if manager.remainingTime > 0 {
            // display list of activities to do.
        } else {
            if manager.familyActivitySelection.categoryTokens.count > 0 || manager.familyActivitySelection.applicationTokens.count > 0  {
                manager.shieldActivities()
                showPanicScreen = true
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            showActivityPicker = true
                        } else if let error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
}
