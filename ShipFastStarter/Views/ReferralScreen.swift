//
//  ReferralScreen.swift
//  FitCheck
//
//  Created by Dante Kim on 1/26/24.
//

import Combine
import SuperwallKit
import SwiftData
import SwiftUI
import WidgetKit

struct ReferralScreen: View {
    // MARK: - Properties

    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode  // Add this to access presentation mode
    @State var otpCodeLength: Int = 6
    @State var textSize = CGFloat(28)
    @State private var otpCode = ""
    @State private var errorString = ""
    @Query private var user: [User]
    @AppStorage("isPro", store: UserDefaults(suiteName: "group.io.nora.nofap.widgetFun")) var isPro = false
    // Animation state variable
    @State private var animateContent = false
    let handler = PaywallPresentationHandler()

    // MARK: - Body

    init() {}

    var body: some View {
        ZStack {
            Image(.genderBg)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                HStack {
                    Text("🎟️ Have a Referral Code?")
                        .overusedFont(weight: .semiBold, size: .h1)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .foregroundColor(.white)
                // Animation modifiers for the title
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.0), value: animateContent)

                if true {
                    // Invite Code Input View
                    InviteCodeInputView(code: $otpCode, codeLength: otpCodeLength)
                        .frame(height: 100)
                        // Animation modifiers
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: animateContent)

                    // Submit Button and Skip Text
                    VStack(spacing: 30) {
                        SharedComponents.PrimaryButton(title: "Submit") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            Analytics.shared.log(event: "ReferralCode: Click Continue")
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()

                            if otpCode == "WXES4S" {
                                profileVM.showReferral = false
                                UserDefaults.standard.setValue(true, forKey: Constants.isCreatorKey)
                                UserDefaults.standard.setValue(true, forKey: "sawReferral")
                                UserDefaults.standard.setValue(true, forKey: "isPro")
                                withAnimation(.linear(duration: 0.1)) {
                                    Analytics.shared.log(event: "ReferralScreen: Creator Code Used")
                                    mainVM.onboardingScreen = .signUp
                                } completion: {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                                        mainVM.loadingText = "✅ success"
                                        mainVM.showToast = true
                                        mainVM.currUser.isPro = true
                                        SubscriptionManager.shared.isSubscribed = true
                                        UserDefaults.standard.setValue(true, forKey: Constants.completedOnboarding)
                                        DataManager.shared.saveContext(context: modelContext)
                                        WidgetCenter.shared.reloadAllTimelines()
                                        Analytics.shared.logActual(event: "ReferralScreen: Real Code", parameters: ["code": otpCode])
                                    }
                                }

                            } else if ["FARZY1", "BILAL1", "BOTHER", "YUSSUF", "GAMER1", "TIKTOK",
                                       "INSTA1", "SHALAH", "MUSLIM", "DEMONS", "MYSEED", "RETAIN",
                                       "PARAMO", "JPBRAZZ"].contains(otpCode)
                            {
                                UserDefaults.standard.setValue(true, forKey: "creatorCodeUsed")
                                mainVM.loadingText = "✅ success"
                                mainVM.showToast = true
                                profileVM.showReferral = false
                                UserDefaults.standard.setValue(true, forKey: "sawReferral")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    Superwall.shared.register(event: "better_deal", handler: mainVM.handler)
                                    Analytics.shared.logActual(event: "ReferralScreen: Real Code", parameters: ["code": otpCode])
                                }
                            } else {
                                mainVM.loadingText = "✅ success"
                                mainVM.showToast = true
                                profileVM.showReferral = false
                                UserDefaults.standard.setValue(true, forKey: "sawReferral")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    Superwall.shared.register(event: "better_deal", handler: mainVM.handler)
                                    Analytics.shared.logActual(event: "ReferralScreen: Fake Code", parameters: ["code": otpCode])
                                }
                            }
                        }
                        .opacity(otpCode.isEmpty ? 0.5 : 1)
                        .disabled(otpCode.isEmpty)
                        if profileVM.showReferral {
                            Text("Close")
                                .overusedFont(weight: .bold, size: .h2)
                                .foregroundColor(.white.opacity(0.7))
                                .underline()
                                .onTapGesture {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    withAnimation {
                                        Analytics.shared.log(event: "ReferralScreen: Tapped Close")
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        profileVM.showReferral = false
                                    }
                                }
                        } else {
                            Text("close")
                                .overusedFont(weight: .bold, size: .h2)
                                .foregroundColor(.white.opacity(0.7))
                                .underline()
                                .onTapGesture {
                                    UserDefaults.standard.setValue(true, forKey: "sawReferral")
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    
                                    withAnimation {
                                        Analytics.shared.log(event: "ReferralScreen: Tapped Skip")
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                        }
                    }
                    // Animation modifiers for the buttons
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: animateContent)
                }
                Spacer()
                Spacer()
            }
            .padding(32)
            .onAppear {
                animateContent = true // Trigger animations when view appears
                if let user = user.first {
                    mainVM.currUser = user
                } else {
                    print("fk")
                }
            }
            .onAppearAnalytics(event: "ReferralCode: Screenload")
        }
    }
}

// MARK: - InviteCodeInputView

struct InviteCodeInputView: View {
    @FocusState private var focusedField: Bool
    @Binding var code: String
    var codeLength: Int

    init(code: Binding<String>, codeLength: Int) {
        _code = code
        self.codeLength = codeLength
    }

    var body: some View {
        HStack {
            ZStack(alignment: .center) {
                Color(.clear)
                    .onTapGesture {
                        DispatchQueue.main.async {
                            self.focusedField = true
                        }
                    }
                TextField("", text: $code)
                    .frame(width: 0, height: 0)
                    .font(Font.system(size: 0))
                    .tint(.clear)
                    .foregroundStyle(.clear)
                    .multilineTextAlignment(.center)
                    .keyboardType(.default)
                    .onReceive(Just(code)) { _ in
                        if code.count > codeLength {
                            code = String(code.prefix(codeLength))
                        }
                        code = code.uppercased()
                    }
                    .focused($focusedField)
                    .padding()
                HStack {
                    ForEach(0 ..< codeLength, id: \.self) { index in
                        ZStack {
                            Text(getPin(at: index))
                                .font(Font.system(size: CGFloat(28)))
                                .fontWeight(.semibold)
                                .foregroundStyle(.primaryForeground)
                            Rectangle()
                                .frame(height: 2)
                                .foregroundStyle(.primaryForeground)
                                .padding(.horizontal, 5)
                                .opacity(code.count <= index ? 1 : 0)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .onTapGesture {
            focusedField = true
        }
        .onAppear {
            withAnimation {
                focusedField = true
            }
        }
    }

    private func getPin(at index: Int) -> String {
        guard code.count > index else {
            return ""
        }
        return String(code[code.index(code.startIndex, offsetBy: index)])
    }
}

// MARK: - Preview

#Preview {
    ReferralScreen()
        .environmentObject(MainViewModel())
}
