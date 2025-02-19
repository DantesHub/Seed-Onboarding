////
////  HomeScreen.swift
////  ShipFastStarter
////
////  Created by Dante Kim on 6/20/24.
//
//
// import SplineRuntime
// import SwiftUI
// import SwiftData
//
// struct HomeScreen: View {
//    @ObservedObject var homeVM: HomeViewModel
//    @EnvironmentObject var timerVM: TimerViewModel
//    @EnvironmentObject var educationVM: EducationViewModel
//    @EnvironmentObject var mainVM: MainViewModel
//    @EnvironmentObject var chatVM: ChatViewModel
//    @State  var currentOrbURL: String = ""
//    @State  var url: URL?
//    @State  var urlChangeToken = UUID()
//    @Query  var sessionHistory: [SoberInterval]
//    @Query  var user: [User]
//    @Environment(\.modelContext)  var modelContext
//    @State  var showWidgetModal = false
//    @State  var showPanicTutorial = false
//    @State  var tutorialStep = 0
//    @State  var isPanicFlashing = false
//    @State  var isRelapseFlashing = false
//
//    @State private var isAnimating: Bool = true
//    @State private var isVisible: Bool = true
//
//    @State private var lastUpdateTime: TimeInterval = 0
//
//    var body: some View {
//        GeometryReader { g in
//            Color.primaryBackground.edgesIgnoringSafeArea(.all)
//            let height = g.size.height
//            let width = g.size.width
//            SharedComponents.linearGradient()
//            ZStack {
//                VStack {
//                    ZStack {
//                        Color.primaryBackground
//                        VStack(spacing: 24) {
//                            if !mainVM.currUser.completedLessons.contains(educationVM.selectedLesson.id) {
//                                // Milestone rectangle
//                                VStack(alignment: .leading, spacing: 10) {
//                                    HStack {
//                                        VStack(alignment: .leading) {
//                                            Text("Lesson \(educationVM.selectedLesson.id)")
//                                                .sfFont(weight: .semibold, size: .h2)
//                                                .foregroundColor(Color.white)
//                                                .opacity(0.8)
//                                            Text( "\(educationVM.selectedLesson.title)")
//                                                .sfFont(weight: .regular, size: .p2)
//                                                .foregroundColor(Color.white)
//                                                .opacity(0.6)
//                                        }
//                                        Spacer()
//                                        educationVM.selectedLesson.img
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                            .foregroundColor(.yellow)
//                                    }
//
//                                    //                                ProgressView(value: Double(educationVM.currentSlide) / Double(educationVM.selectedLesson.slides.count))
//                                    //                                    .progressViewStyle(CustomProgressViewStyle())
//                                    //                                    .frame(height: 24)
//                                    //                                    .padding(.top)
//                                }
//                                .frame(height: height * 0.125)
//                                .padding(24)
//                                .background(Color.secondaryBackground)
//                                .cornerRadius(15)
//                                .onTapGesture {
//                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                    Analytics.shared.log(event: "HomeScreen: Tapped Lesson")
//                                    withAnimation {
//                                        if Double(educationVM.currentSlide) / Double(educationVM.selectedLesson.slides.count) == 1.0 {
//                                            educationVM.currentSlide = 0
//                                        }
//                                        educationVM.showEducation = true
//                                    }
//                                }
//                                .opacity( Double(educationVM.currentSlide) / Double(educationVM.selectedLesson.slides.count) == 1.0 ? 0.5 : 1)
//                            } else {
//                                VStack(alignment: .leading, spacing: 10) {
//                                    HStack {
//                                        VStack(alignment: .leading) {
//                                            Text("Notes to Yourself")
//                                                .sfFont(weight: .semibold, size: .h2)
//                                                .foregroundColor(Color.white)
//                                                .opacity(0.8)
//                                            Text("Reminders & Motivation")
//                                                .sfFont(weight: .regular, size: .p2)
//                                                .foregroundColor(Color.white)
//                                                .opacity(0.6)
//                                        }
//                                        .offset(y: -16)
//                                        Spacer()
//                                        Image(systemName: "note.text")
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                            .frame(width: 32, height: 32)
//                                            .padding(.trailing, 12)
//                                            .offset(y: 16)
//                                            .foregroundColor(Color.white)
//                                            .opacity(0.65)
//                                    }
//                                }
//                                .frame(height: height * 0.125)
//                                .padding(24)
//                                .background(Color.secondaryBackground)
//                                .cornerRadius(15)
//                                .onTapGesture {
//                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                    Analytics.shared.log(event: "HomeScreen: Tapped Notes")
//                                    withAnimation {
//                                        homeVM.showNote = true
//                                    }
//                                }
//                            }
//                            // Time Saved and Relapsed rectangles
//                            HStack(spacing: 16) {
//                                VStack(alignment: .leading){
//                                    Text("Panic")
//                                        .sfFont(weight: .semibold, size: .h3p1)
//                                        .foregroundColor(Color.white)
//                                        .padding(.leading, 4)
//                                    Text("0x times")
//                                        .sfFont(weight: .regular, size: .p2)
//                                        .foregroundColor(Color.white)
//                                        .padding(.leading, 4)
//                                    Spacer()
//                                    HStack {
//                                        Spacer()
//                                        Image(systemName: "exclamationmark.triangle.fill")
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                            .frame(width: 36)
//                                            .foregroundColor(Color.white)
//                                            .opacity(0.65)
//                                            .padding(.trailing, 4)
//                                    }
//                                    Spacer()
//                                }
//                                .padding(.horizontal)
//                                .frame(width: width * 0.41, height: width * 0.3)
//                                .padding(.vertical, 20)
//                                .background(Color.yellow.opacity(0.6))
//                                .cornerRadius(24)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 24)
//                                        .stroke(Color.white, lineWidth: 3)
//                                        .opacity(isPanicFlashing ? 1 : 0)
//                                )
//                                .animation(isPanicFlashing ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : nil, value: isPanicFlashing)
//                                .onTapGesture {
//                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                    Analytics.shared.log(event: "Homescreen: Tapped Panic")
//                                    withAnimation {
//                                        mainVM.tappedPanic = true
//                                        isPanicFlashing = false
//                                    }
//                                }
//                                VStack(alignment: .leading){
//                                    Text("Relapse")
//                                        .sfFont(weight: .medium, size: .h3p1)
//                                        .foregroundColor(Color.white)
//                                    Text("2 days ago")
//                                        .sfFont(weight: .regular, size: .p2)
//                                        .foregroundColor(Color.white)
//                                    Spacer()
//                                    HStack {
//                                        Spacer()
//                                        Image(systemName: "arrow.uturn.backward.circle.fill")
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                            .frame(width: 36)
//                                            .foregroundColor(Color.white)
//                                            .opacity(0.65)
//                                            .padding(.trailing, 4)
//                                    }
//                                    Spacer()
//                                }
//                                .padding(.horizontal)
//                                .frame(width: width * 0.41, height: width * 0.3)
//                                .padding(.vertical, 20)
//                                .background(Color.red.opacity(0.6))
//                                .cornerRadius(24)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 24)
//                                        .stroke(Color.white, lineWidth: 3)
//                                        .opacity(isRelapseFlashing ? 1 : 0)
//                                )
//                                .animation(isRelapseFlashing ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: isRelapseFlashing)
//                                .onTapGesture {
//                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                    Analytics.shared.log(event: "Homescreen: Tapped Relapse")
//                                    withAnimation {
//                                        homeVM.showCheckIn = true
//                                        homeVM.tappedRelapse = true
//                                        isRelapseFlashing = false
//                                    }
//                                }
//                                .onAppear {
//                                    withAnimation(.easeInOut(duration: 0.5)) {
//                                        if !UserDefaults.standard.bool(forKey: "completedPanicTutorial") {
//                                            isPanicFlashing = true
//                                        }
//                                    }
//                                }
//                            }
//                            Spacer()
//                        }
//                        .padding(28)
//                    }
//                    .frame(height: height * 0.6)
//                    .cornerRadius(32)
//                }
//                if showPanicTutorial {
//                    PanicTutorialOverlay(showTutorial: $showPanicTutorial, tutorialStep: $tutorialStep, screenSize: g.size)
//                        .zIndex(1)
//                        .onChange(of: tutorialStep) {
//                            if tutorialStep == 0 {
//                                isPanicFlashing = true
//                                isRelapseFlashing = false
//
//                            } else if tutorialStep == 1 {
//                                isPanicFlashing = false
//                                isRelapseFlashing = true
//                            }
//                        }
//                }
//
//                if showWidgetModal {
//                    Color.black
//                        .opacity(0.5)
//                        .edgesIgnoringSafeArea(.all)
//                        .blur(radius: 10)
//
//                }
//            }
//
//        }.sheet(isPresented: $homeVM.showEvolution) {
//            EvolutionScreen(showEvolution: $homeVM.showEvolution)
//                .environmentObject(mainVM)
//                .environmentObject(homeVM)
//                .onDisappear {
//                    if !UserDefaults.standard.bool(forKey: "showedWidget") {
//                        UserDefaults.standard.setValue(true, forKey: "showedWidget")
//                        showWidgetModal = true
//                    }
//                }
//        }
//        .onAppear {
//            timerVM.triggerSplineUpdate()
//            setData()
//            updateURL()
//        }
////        .onChange(of: homeVM.show)
//        .sheet(isPresented: $homeVM.showNote) {
//            NoteScreen()
//                .environmentObject(mainVM)
//                .environmentObject(homeVM)
//        }
//        .sheet(isPresented: $showWidgetModal) {
//            WidgetModal(showModal: $showWidgetModal)
//                .presentationDragIndicator(.visible)
//                .presentationDetents([.height(450)])
//                .background(Color.primaryBackground)
//        }
//        .onChange(of: mainVM.currentInterval) {
//            setData()
//            updateURL()
//        }
//        .onChange(of: tutorialStep) {
//            withAnimation {
//                isPanicFlashing = (tutorialStep == 0)
//                isRelapseFlashing = (tutorialStep == 1)
//            }
//        }
//        .onChange(of: mainVM.tappedPanic) {
//            if  mainVM.tappedPanic && tutorialStep == 0 && !UserDefaults.standard.bool(forKey: "completedPanicTutorial") {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    tutorialStep = 1
//                }
//            }
//        }
//        .onChange(of: homeVM.tappedRelapse) {
//            if homeVM.tappedRelapse && tutorialStep == 1 {
//                showPanicTutorial = false
//                UserDefaults.standard.set(true, forKey: "completedPanicTutorial")
//                isPanicFlashing = false
//                isRelapseFlashing = false
//            }
//        }
//
//        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
//                isAnimating = false
//                isVisible = false
//        }
//        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
//                isVisible = true
//                    isAnimating = true
//        }
//
//    }
//
// }
//
// #Preview {
//    HomeScreen(homeVM: HomeViewModel())
//        .environmentObject(TimerViewModel())
// }
//
//
//
//
//
//
