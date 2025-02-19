//
//  ContentView.swift
//  ShipFastStarter
//
//  Created by Dante Kim on 6/20/24.
//

import AlertToast
import AuthenticationServices
import OneSignalFramework
import RevenueCat
import SuperwallKit
import SwiftData
import SwiftUI
import WidgetKit
import FirebaseAuth

struct MainView: View {
    @State private var showActivityView = false

    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var timerVM: TimerViewModel
    @EnvironmentObject var reflectVM: ReflectionsViewModel

    @Environment(\.modelContext) private var modelContext
    @Query private var user: [User]
    @Query private var sessionHistory: [SoberInterval]

    @StateObject var historyVM: HistoryViewModel = .init()
    @StateObject var shieldVM: ShieldViewModel = .init()
    @StateObject var profileVM: ProfileViewModel = .init()
    @StateObject var educationVM: EducationViewModel = .init()
    @StateObject var statsVM: StatsViewModel = .init()
    @StateObject var authVM: AuthViewModel = .init()
    @StateObject var breathVM: BreathworkViewModel = .init()
    @StateObject var chatVM: ChatViewModel = .init()
    @StateObject var dhikrVM: DhikrViewModel = .init()
    @StateObject var homeVM: HomeViewModel = .init()
    @StateObject var appState = AppState.shared
    @StateObject var qaManager = QuickActionsManager.instance
    @State private var signInWithApple = false
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("isPro", store: UserDefaults(suiteName: "group.io.nora.nofap.widgetFun")) var isPro = false

    let handler = PaywallPresentationHandler()

    var body: some View {
        GeometryReader { _ in
            ZStack {
                Color(.primaryBackground).edgesIgnoringSafeArea(.all)
                VStack {
//                    if mainVM.currentPage != .onboarding {
//                        HeaderView
//                            .frame(height: 36)
//                            .offset(y: -55)
//                    }

                    switch mainVM.currentPage {
                    case .onboarding:
                        Onboarding()
                            .environmentObject(homeVM)
                            .environmentObject(mainVM)
                            .environmentObject(timerVM)
                            .environmentObject(authVM)
                            .environmentObject(historyVM)
                            .environmentObject(profileVM)
                    case .home:
//                            CoursesScreen()
//                                .environmentObject(mainVM)
//                                .environmentObject(educationVM)
                        EmptyView()
                    case .stats:
                        EmptyView()
                    case .course:
                        EducationScreen()
                            .environmentObject(educationVM)
                            .environmentObject(reflectVM)
                            .environmentObject(homeVM)
                            .environmentObject(mainVM)
                            .environmentObject(breathVM)
                    case .profile:
                        EmptyView()
                    }
                }

                if mainVM.showConfetti {
                    LottieView(loopMode: .playOnce, animation: "confetti", isVisible: $mainVM.showConfetti)
                        .onTapGesture {
                            mainVM.showConfetti = false
                        }
                }

                if mainVM.currentPage != .onboarding {
                    // Bottom navigation bar
                    Tabbar(mainVM: mainVM)
                        .position(x: UIScreen.main.bounds.width / 2, y: (UIScreen.main.bounds.height * (UIDevice.hasNotch && !UIDevice.isProMax ? 0.875 : (UIDevice.isProMax ? 0.89 : 0.92))) + 12)
                }

//                CustomModal(isPresented: $homeVM.showCheckIn) {
//                              CheckInScreen()
//                                  .environmentObject(homeVM)
//                                  .environmentObject(historyVM)
//                                  .environmentObject(dhikrVM)
//                                  .environmentObject(educationVM)
//                                  .environmentObject(mainVM)
//                                  .frame(width: UIScreen.main.bounds.width, height: 500, alignment: .center)
//                          }
            }
        }
        .onChange(of: authVM.signUpSuccessful) {
            signInWithApple = false
        }
        .onAppear {
      
            print(mainVM.currUser.name, "shimate", UserDefaults.standard.bool(forKey: "isPro"), UserDefaults.standard.bool(forKey: Constants.completedOnboarding))
        
            if UserDefaults.standard.bool(forKey: "isPro") || UserDefaults.standard.bool(forKey: Constants.completedOnboarding) {
                if FirebaseService.isLoggedIn() {
                    
                } else { // needs to sign up or sign in
                    signInWithApple = true
                    // sync all there data
                }
            }
        }
        .sheet(isPresented: $signInWithApple) {
            ZStack {
                Image(.justBackground)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Sign up within 24 hours, or risk your data being deleted")
                        .sfFont(weight: .semibold, size: .h2)
                        .multilineTextAlignment(.center)
                        .padding()
                    SignInWithAppleButton { request in
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        authVM.handleSignInWithAppleRequest(request)
                    } onCompletion: { result in
                        authVM.handleSignInWithAppleCompletion(result, mainVM)
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 56)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.4), lineWidth: 2)
                    )
                    .padding()
                }
              
            }
            .presentationDetents([.height(300)])
            .interactiveDismissDisabled()
        }
        .toast(isPresenting: $mainVM.loading) {
            AlertToast(type: .loading, title: mainVM.loadingText)
        }
        .toast(isPresenting: $mainVM.showToast) {
            AlertToast(displayMode: .hud, type: .regular, title: mainVM.loadingText)
        }
        .fullScreenCover(isPresented: $mainVM.showProfile) {
//            ProfileScreen()
        }
        .fullScreenCover(isPresented: $mainVM.showPricing) {
            PlanReadyScreen()
                .environmentObject(mainVM)
        }
        .sheet(isPresented: $homeVM.showCheckIn) {
        
        }.fullScreenCover(isPresented: $reflectVM.showWriteReflection) {
            WriteReflectionScreen()
                .environmentObject(reflectVM)
                .environmentObject(homeVM)
        }
        .fullScreenCover(isPresented: $mainVM.startDhikr) {
            Dhikar(viewModel: dhikrVM, page: .constant(.dhikr))
                .environmentObject(mainVM)
                .environmentObject(homeVM)
        }
        .onChange(of: homeVM.selectedOrb.0) {
            print(homeVM.selectedOrb.0.name())
        }
        .onAppear {
            mainVM.handler.onDismiss { _ in
                mainVM.pricingLogic(user: user, modelContext: modelContext)
            }

            mainVM.handler.onPresent { _ in
                if UserDefaults.standard.bool(forKey: "sawReferral") {
                    Analytics.shared.logActual(event: "PricingScreen Halfoff: Screenload", parameters: ["duringOnboarding": !UserDefaults.standard.bool(forKey: Constants.completedOnboarding)])

                } else {
                    Analytics.shared.logActual(event: "PricingScreen: Screenload", parameters: ["duringOnboarding": !UserDefaults.standard.bool(forKey: Constants.completedOnboarding)])
                }
            }

            mainVM.checkSubscriptionStatus()
            Task {
                await mainVM.fetchCheckInDay()
            }
        }
        .fullScreenCover(isPresented: $mainVM.tappedPanic) {
            PanicButtonScreen()
                .environmentObject(mainVM)
                .environmentObject(breathVM)
                .environmentObject(chatVM)
                .environmentObject(dhikrVM)
        }.onChange(of: mainVM.currUser.isPro) {
            self.isPro = true
            print("reloading timelines")
              // Reload both widgets explicitly
            WidgetCenter.shared.reloadTimelines(ofKind: "smallWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "mediumWidget")
        }
        .onChange(of: authVM.soberIntervals) {
            for soberInterval in authVM.soberIntervals {
                modelContext.insert(soberInterval)
                DataManager.shared.saveContext(context: modelContext)
            }
            
            authVM.soberIntervals.sorted { inter1, inter2 in
                inter1.endDate > inter2.endDate
            }

            if let interval = authVM.soberIntervals.first {
                mainVM.currentInterval = interval
            }
        }
        .onChange(of: mainVM.currUser) {
      
        }
        .onChange(of: authVM.signUpSuccessful) {
            if let firstUser = user.first {
                
            } else { // logging in
                modelContext.insert(mainVM.currUser)
            }
            mainVM.currUser.isPro = true
            homeVM.showSignUpModal = false
            print(mainVM.currUser.name, user.first?.name ?? "", "savage")
            DataManager.shared.saveContext(context: modelContext)

            
            Task {
                await mainVM.fetchToday()
//                await profileVM.fetchChallenge()
//                if mainVM.currentPage == .home {
//                    profileVM.presentChallenge = true
//                }
            }
            resyncData()
            OneSignal.login(mainVM.currUser.id)
        }
        .sheet(isPresented: $homeVM.showSignUpModal) {
            ZStack {
                Image(.justBackground)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
            }
            .presentationDetents([.height(380)])
            .interactiveDismissDisabled(true)
            .onAppearAnalytics(event: "SignUpWithApple: Screenload")
        }
    }
    
    func resyncData() {
        if let firstUser = user.first {
            Task {
                print(firstUser.name, "bro what are u doing")
                var fbSoberIntervals: [SoberInterval] = []
                FirebaseService.getIntervals(for: firstUser.id) { result in
                    switch result {
                    case let .success(intervals):
                        fbSoberIntervals = intervals
                        // If local has more intervals than Firebase, upload the new ones
                        if sessionHistory.count > fbSoberIntervals.count {
                            let newIntervals = sessionHistory.filter { localInterval in
                                !fbSoberIntervals.contains { fbInterval in
                                    fbInterval.id == localInterval.id
                                }
                            }
                            
                            // Upload new intervals to Firebase
                            Task {
                                for interval in newIntervals {
                                    FirebaseService.shared.addDocument(interval, collection: "intervals") { str in
                                    }
                                }
                            }
                            authVM.inProcessOfSigningIn = false
                        } else {
                            // Firebase has more/equal intervals, update local SwiftData
                            for interval in fbSoberIntervals {
                                if let existingIndex = sessionHistory.firstIndex(where: { $0.id == interval.id }) {
                                    sessionHistory[existingIndex].startDate = interval.startDate
                                    sessionHistory[existingIndex].endDate = interval.endDate
                                    sessionHistory[existingIndex].seed = interval.seed
                                    sessionHistory[existingIndex].seedTXP = interval.seedTXP
                                    sessionHistory[existingIndex].lastCheckInDate = interval.lastCheckInDate
                                    sessionHistory[existingIndex].reasonsForLapsing = interval.reasonsForLapsing
                                    sessionHistory[existingIndex].lapseNotes = interval.lapseNotes
                                    sessionHistory[existingIndex].motivationalNotes = interval.motivationalNotes
                                    sessionHistory[existingIndex].thoughtNotes = interval.thoughtNotes
                                } else {
                                    // Add new interval
                                    modelContext.insert(interval)
                                }
                            }
                            DataManager.shared.saveContext(context: modelContext)
                            authVM.inProcessOfSigningIn = false
                        
                        }
                        if let last = sessionHistory.last {
                            mainVM.currentInterval = last
                            timerVM.startDate = Date.fromString(last.startDate) ?? Date()
                            timerVM.startTimer()
                        }
                     
                        
                    case let .failure(error):
                        print("Error fetching intervals: \(error.localizedDescription)")
                        authVM.inProcessOfSigningIn = false
                    }
                }
            }
        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: Item.self, inMemory: true)
        .environmentObject(MainViewModel())
}

extension MainView {
    var HeaderView: some View {
        HStack(alignment: .center, spacing: 0) {
            if historyVM.showDetailedView {
                Image(systemName: "arrow.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        withAnimation {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            historyVM.showDetailedView = false
                        }
                    }.foregroundColor(Color.white)
                    .padding(.trailing)
                Spacer()
                Text(historyVM.title)
                    .sfFont(weight: .semibold, size: .h3p1)
                    .foregroundColor(Color(.white))
                Spacer()
                Image(systemName: "arrow.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .opacity(0)
            } else {
                Text(mainVM.currentPage.rawValue)
                    .sfFont(weight: .semibold, size: .h2)
                    .foregroundColor(Color(.white))
                Spacer()
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundColor(Color(.white))
                    .onTapGesture {
                        withAnimation {
                            Analytics.shared.log(event: "Header: Tapped Profile")
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            mainVM.showProfile.toggle()
                        }
                    }
            }

//            if let currUser = mainVM.currUser, currUser.fitcheck {
//                Text("🔥\(mainVM.currUser?.streak ?? 0)")
//                    .clash(type: .semibold, size: .h3p1)
//                    .foregroundColor(Color(.white))
//                    .padding(.leading, 12)
//            }
        }
        .frame(width: UIScreen.main.bounds.width / 1.175)
        .padding()
        .position(x: UIScreen.main.bounds.width / 2, y: 68)
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}

import SwiftUI

struct CustomModal<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content

    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        _isPresented = isPresented
        self.content = content()
    }

    var body: some View {
        if isPresented {
            ZStack {
                // Background overlay
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }

                // Modal content
                VStack {
                    Spacer()
                    content
                        .background(Color.white)
                        .cornerRadius(32)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: -5)
                        .padding()
                }
                .transition(.move(edge: .bottom))
            }
            .animation(.easeInOut, value: isPresented)
        }
    }
}
