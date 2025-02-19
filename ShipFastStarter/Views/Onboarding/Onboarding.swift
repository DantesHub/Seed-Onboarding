//
//  Onboarding.swift
//  Resolved
//
//  Created by Dante Kim on 8/9/24.
//

import SwiftUI

struct Onboarding: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var timerVM: TimerViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var historyVM: HistoryViewModel
    @EnvironmentObject var profileVM: ProfileViewModel

    @State private var frequency: String = ""
    @State private var showStory = false
    @State var pageType: YesNoPage = .amount
    @State var ageRange: AgeQuestion = .age
    @State var frequentType: FrequencyPage = .arousal
    @State private var showSkipConfirmation = false

    var body: some View {
        NavigationView {
            ZStack {
                Image(.justBackground)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.top)
                    .frame(width: UIScreen.main.bounds.width)
                VStack {
                    if mainVM.onboardingScreen != .first && mainVM.onboardingScreen != .loadingIllusion && mainVM.onboardingScreen != .pricing && mainVM.onboardingScreen != .notification && mainVM.onboardingScreen != .community && mainVM.onboardingScreen != .quiz && mainVM.onboardingScreen != .problem && mainVM.onboardingScreen != .options && mainVM.onboardingScreen != .goodNews && mainVM.onboardingScreen != .commit && mainVM.onboardingScreen != .graphic && mainVM.onboardingScreen != .referral && mainVM.onboardingScreen != .signUp && mainVM.onboardingScreen != .typing && mainVM.onboardingScreen != .name && mainVM.onboardingScreen != .rating {
                        Spacer()
                            .frame(height: 100)
                        HStack {
                            Image(systemName: "arrow.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24)
                                .foregroundColor(Color.primaryForeground)
                                .onTapGesture {
                                    Analytics.shared.log(event: "Onboarding: tapped Back")
                                    withAnimation {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        goBack()
                                    }
                                }.padding(.leading)
                                .padding(.trailing, 4)
                                .opacity(mainVM.onboardingScreen != .gender ? 1 : 0)
                                .disabled(mainVM.onboardingScreen == .gender)

                            ProgressView(value: abs(mainVM.onboardingProgress))
                                .progressViewStyle(CustomProgressViewStyle())
                                .frame(height: 24)
                                .padding(.trailing)
                        }.padding(.top)
                            .padding(.horizontal, 8)

                    } else {
                        Spacer()
                            .frame(height: 60)
                    }

                    switch mainVM.onboardingScreen {
                    case .first: OnboardingScreen()
                    case .community: CommunityScreen()
                    case .quiz: QuizScreen()
                    case .when: WhenStartScreen(ageQuestion: $ageRange)
                    case .yesNo: YesNo(pageType: $pageType)
                    case .frequently: FrequentlyScreen(frequency: $frequentType)
                    case .gender: GenderScreen()
                    case .haveQuittingBeforeScreen: HaveQuittingBeforeScreen()
                    case .name: NameScreen()
                    case .religion: ReligionScreen()
                    case .haveBeenDuration: HowLongHaveScreen(frequency: $frequency).environmentObject(mainVM)
                    case .frequency: HowOftenScreen(frequency: $frequency).environmentObject(mainVM)
                    case .duration: HowLongScreen(frequency: $frequency).environmentObject(mainVM)
                    case .lastRelapse:
                        AlreadySoberScreen()
                            .environmentObject(homeVM)
                            .environmentObject(timerVM)
                    case .explainer: ExplainScreen()
                    case .graphic: AnimatedChartView()
                    case .loadingIllusion:
                        LoadingIllusion(showStory: $showStory)
                    case .notification: NotificationScreen()
                    case .commit: LetsCommitScreen()
                    case .rating: RatingScreen() 
                    case .problem: ProblemScreen()
                    case .referral: ReferralScreen().environmentObject(profileVM)
                    case .pricing: OldPricingScreen()
                    case .options: SelectOptionsScreen()
                    case .goodNews: GoodNews()
                    case .typing: TypingScreen()
                    case .signUp: SignUpScreen()
                    default: OnboardingScreen()
                    }
                }

                if mainVM.onboardingScreen != .first && mainVM.onboardingScreen != .explainer && mainVM.onboardingScreen != .loadingIllusion && mainVM.onboardingScreen != .pricing && mainVM.onboardingScreen != .notification && mainVM.onboardingScreen != .community && mainVM.onboardingScreen != .quiz && mainVM.onboardingScreen != .gender && mainVM.onboardingScreen != .duration && mainVM.onboardingScreen != .frequency && mainVM.onboardingScreen != .lastRelapse && mainVM.onboardingScreen != .problem && mainVM.onboardingScreen != .options && mainVM.onboardingScreen != .goodNews && mainVM.onboardingScreen != .commit && mainVM.onboardingScreen != .graphic && mainVM.onboardingScreen != .referral &&  mainVM.onboardingScreen != .name && mainVM.onboardingScreen != .religion  && mainVM.onboardingScreen != .signUp && mainVM.onboardingScreen != .lastRelapse && mainVM.onboardingScreen != .typing  && mainVM.onboardingScreen != .rating  {
                    Text("skip")
                        .overusedFont(weight: .medium, size: .p2)
                        .foregroundColor(.gray)
                        .onTapGesture {
                            showSkipConfirmation = true
                            Analytics.shared.logActual(event: "Onboarding: Tapped Skip", parameters: ["page": mainVM.onboardingScreen.rawValue])
                        }
                        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height)
                        .alert("Skip the quiz?", isPresented: $showSkipConfirmation) {
                            Button("No", role: .cancel) { }
                            Button("Yes", role: .destructive) {
                                Analytics.shared.logActual(event: "Onboarding: Tapped Skip Confirm", parameters: ["page": mainVM.onboardingScreen.rawValue])
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation {
                                    mainVM.onboardingProgress = 1.0
                                    mainVM.onboardingScreen = .lastRelapse
                                }
                            }
                        } message: {
                            Text("These questions help us tailor a plan")
                        }
                }
            }
        }
        .fullScreenCover(isPresented: $showStory) {
            OnboardingStory(showStory: $showStory)
                .environmentObject(mainVM)
        }
    }
    
    func skipQuestion() {
        switch mainVM.onboardingScreen {
        case .yesNo:
            switch pageType {
            case .amount: pageType = .explicit
            case .explicit: pageType = .spentMoney
            case .spentMoney: mainVM.onboardingScreen = .frequently
            }
        case .frequently:
            switch frequentType {
            case .arousal: frequentType = .escape
            case .escape: frequentType = .restless
            case .restless: frequentType = .preoccupied
            case .preoccupied: frequentType = .empty
            case .empty: frequentType = .promised
            case .promised: frequentType = .lied
            case .lied: frequentType = .cope
            case .cope: frequentType = .bored
            case .bored: mainVM.onboardingScreen = .haveQuittingBeforeScreen
            }
        case .when:
            switch ageRange {
            case .when: ageRange = .active
            case .active: ageRange = .age
            case .age: mainVM.onboardingScreen = .yesNo
            }
        default:
            mainVM.onboardingScreen = .lastRelapse
        }
        
//        mainVM.onboardingProgress += 0.05
    }
    
    func goBack() {
        mainVM.onboardingProgress -= 0.08
        switch mainVM.onboardingScreen {
//            case .first: mainVM.onboardingScreen = .first
//            case .explainer:  mainVM.onboardingScreen = .first
//            case .age: mainVM.onboardingScreen = .first
//            case .gender: mainVM.onboardingScreen = .age
//            case .religion: mainVM.onboardingScreen = .graphic
//            case .graphic: mainVM.onboardingScreen = .duration
//            case .frequency: mainVM.onboardingScreen = .gender
//            case .duration: mainVM.onboardingScreen = .frequency
//            default: return
        case .yesNo:
            switch pageType {
            case .amount: mainVM.onboardingScreen = .when
            case .explicit: pageType = .amount
            case .spentMoney: pageType = .explicit
            }
        case .frequently:
            switch frequentType {
            case .arousal: mainVM.onboardingScreen = .yesNo
            case .escape: frequentType = .arousal
            case .restless: frequentType = .escape
            case .preoccupied: frequentType = .restless
            case .empty: frequentType = .preoccupied
            case .promised: frequentType = .empty
            case .lied: frequentType = .promised
            case .cope: frequentType = .lied
            case .bored: frequentType = .cope
            }
        case .first: mainVM.onboardingScreen = .gender
        case .explainer: mainVM.onboardingScreen = .first
        case .when:
            switch ageRange {
            case .when:
                ageRange = .age
            case .active:
                ageRange = .when
            case .age:
                mainVM.onboardingScreen = .duration
            }
        case .haveQuittingBeforeScreen: mainVM.onboardingScreen = .frequently
        case .gender: mainVM.onboardingScreen = .first
        case .religion: mainVM.onboardingScreen = .haveQuittingBeforeScreen
        case .graphic: mainVM.onboardingScreen = .duration
        case .frequency: mainVM.onboardingScreen = .gender
        case .lastRelapse: mainVM.onboardingScreen = .haveQuittingBeforeScreen
        case .haveBeenDuration: mainVM.onboardingScreen = .frequency
        case .duration: mainVM.onboardingScreen = .frequency
        case .name: mainVM.onboardingScreen = .religion
        
        default: return
        }
    }
}

#Preview {
    Onboarding()
        .environmentObject(HomeViewModel())
}
