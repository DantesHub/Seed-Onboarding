////
////  RelapseEducationScreen.swift
////  Resolved
////
////  Created by Dante Kim on 8/28/24.
////
//
// import Foundation
// import SwiftUI
//
// struct RelapseEducationScreen: View {
//    @EnvironmentObject var mainVM: MainViewModel
//    @EnvironmentObject var homeVM: HomeViewModel
//
//    @EnvironmentObject var educationVM: EducationViewModel
//
//
//    var body: some View {
//        ZStack {
//            Color.primaryBackground.edgesIgnoringSafeArea(.all)
//            VStack {
//                Spacer()
//                Text("Rewire your brain")
//                    .foregroundColor(.white)
//                    .sfFont(weight: .bold, size: .h1)
//                    .padding()
//                LottieView(loopMode: .loop, animation: "studying", isVisible: .constant(true))
//                    .frame(width: 300, height: 300)
//                Text("Now is the perfect time to start a relapse lesson")
//                    .foregroundColor(.primaryForeground)
//                    .sfFont(weight: .semibold, size: .h3p1)
//                    .padding()
//                    .multilineTextAlignment(.center)
//
//                Spacer()
//                SharedComponents.PrimaryButton(title: "Start Lesson (1 min)") {
//                    if let nextLesson = educationVM.getNextAvailableRelapseLesson() {
//                        homeVM.showCheckIn = false
//                        educationVM.selectedLesson = nextLesson
//                        educationVM.showEducation = true
//                    }
//                }
//                .padding()
//                .padding(.bottom)
//
//            }
//        }.onAppearAnalytics(event: "RelapseLesson: Screenload")
//    }
// }
//
// #Preview {
//    RelapseEducationScreen()
//        .environmentObject(MainViewModel())
//        .environmentObject(EducationViewModel())
// }
