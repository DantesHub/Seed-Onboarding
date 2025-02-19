//
//  AgeScreen.swift
//  Resolved
//
//  Created by Dante Kim on 7/19/24.
//
import SwiftUI

struct ReligionScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    let options = ["Muslim", "Christian", "Spiritual", "Hindu", "Agnostic", "Buddhist", "Not Religious", "Other"]
    @Environment(\.presentationMode) var presentationMode  // Add this to access presentation mode
    @AppStorage("religion", store: UserDefaults(suiteName:"group.io.nora.nofap.widgetFun")) var widgetReligion = ""

    @Environment(\.modelContext) private var modelContext
    @State private var animateContent = false

    var body: some View {
        ZStack {
            Image(.genderBg)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Centered text and options
                if UserDefaults.standard.bool(forKey: Constants.completedOnboarding) {
                    HStack {
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20)
                                .overusedFont(weight: .semiBold, size: .h1Big)
                                .foregroundColor(.white)
                        }
                        Spacer()
                      
                    }.padding(.horizontal, 28)
                    .padding(.top, 72)
                }
                VStack(spacing: 32) {
                  
                    VStack(spacing: 12) {
                        SharedComponents.CustomBoldHeading(title: "Are you religious?", color: .white)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5), value: animateContent)
                        SharedComponents.CustomSubtitleText(title: "This helps us personalize your experience.", color: .white)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.5).delay(0.1), value: animateContent)
                            .multilineTextAlignment(.center)
                    }

                    // Gender options buttons
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(options, id: \.self) { option in
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    Analytics.shared.logActual(event: "ReligionScreen: Tapped Continue", parameters: ["religion": option])
                                    print(mainVM.currUser.name, "woahhh")
                                    mainVM.currUser.religion = option
                                    widgetReligion = option
                                    DataManager.shared.saveContext(context: modelContext)
                                    UserDefaults.standard.setValue(option, forKey: "religion")
                                    withAnimation {
                                        mainVM.onboardingProgress += 0.08
                                        mainVM.onboardingScreen = .lastRelapse
                                    }
                                    if UserDefaults.standard.bool(forKey: Constants.completedOnboarding) {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }) {
                                    SharedComponents.OnboardVoteOption(title: option, height: 64)
                                }
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.5).delay(0.2 + 0.1 * Double(options.firstIndex(of: option)!)), value: animateContent)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer() // Pushes content up to center it
            }
            .onAppear {
                animateContent = true
            }
            .onAppearAnalytics(event: "ReligionScreen: Screenload")
        }
    }
}

#Preview {
    ReligionScreen()
        .environmentObject(MainViewModel())
}

//
// struct ReligionScreen: View {
//    @EnvironmentObject var mainVM: MainViewModel
//    let options = ["Muslim", "Christian", "Buddhist", "Hindu", "Jewish", "Agnostic", "None", "Other"]
//    @Environment(\.modelContext) private var modelContext
//
//    var body: some View {
//        ZStack {
//            Color.primaryBackground.edgesIgnoringSafeArea(.all)
//            GeometryReader { g in
//                VStack(alignment: .leading, spacing: 12) {
//                    HStack {
//                        Image(systemName: "arrow.left")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 32)
//                            .onTapGesture {
//                                withAnimation {
//                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
//
//                                }
//                            }
//                    }.padding(.horizontal)
//                    Text("Are you religious?")
//                        .foregroundStyle(Color.white)
//                        .sfFont(weight: .bold, size: .h2)
//                        .padding(.bottom)
//                    VStack(alignment: .leading, spacing: 24) {
//                        ForEach(options, id: \.self) { option in
//                            Button(action: {
//                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                Analytics.shared.logActual(event: "ReligionScreen: Tapped Continue", parameters: ["religion":option])
//                                mainVM.currUser.religion = option
//                                DataManager.shared.saveContext(context: modelContext)
//                                withAnimation {
//                                    mainVM.onboardingProgress += 0.15
//                                    mainVM.onboardingScreen = .age
//                                }
//
//                            }) {
//                                Text(option)
//                                    .foregroundColor(.white)
//                                    .frame(maxWidth: .infinity)
//                                    .frame(height: g.size.height / 12)
//                                    .background(Color.secondaryBackground)
//                                    .cornerRadius(16)
//                                    .sfFont(weight: .semibold, size: .h3p1)
//                            }
//                        }
//                    }
//
//                            Spacer()
//                }
//                .padding(.horizontal)
//            }
//        }.onAppearAnalytics(event: "RelapseReasonScreen: Screenload")
//
//    }
// }
//
// #Preview {
//    ReligionScreen()
//        .environmentObject(MainViewModel())
// }
