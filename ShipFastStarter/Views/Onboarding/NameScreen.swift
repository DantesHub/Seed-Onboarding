//
//  NameScreen.swift
//  Resolved
//
//  Created by Dante Kim on 7/19/24.
//

import FirebaseAuth
import SwiftData
import SwiftUI

struct NameScreen: View {
    @State private var firstName = ""
    @State private var isNameValid = false
    @State private var showAlert = false
    @State private var showPlaceholder = true
    @Query private var user: [User]
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var mainVM: MainViewModel
    @FocusState private var isTextFieldFocused: Bool

    @State private var animateContent = false // State variable for animations

    var body: some View {
        ZStack {
            Image(.justBackground)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .edgesIgnoringSafeArea(.all)
                .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
            GeometryReader { _ in
                VStack(alignment: .leading, spacing: 12) {
                    Spacer()

                    // Title Text
                    Text("Finally, what's your name?")
                        .foregroundStyle(Color.white)
                        .sfFont(weight: .bold, size: .h1)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal)
                        .padding(.top, 24)
                        .padding(.horizontal, 16)
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        .animation(Animation.easeOut(duration: 0.5).delay(0.1), value: animateContent)

                    // Text Field
                    ZStack(alignment: .leading) {
                        TextField("", text: $firstName)
                            .modifier(CustomTextFieldStyle())
                            .foregroundColor(Color.white)
                            .focused($isTextFieldFocused)
                            .autocorrectionDisabled()
                            .onAppear {
                                isTextFieldFocused = true
                            }
                            .onChange(of: firstName) {
                                showPlaceholder = false
                                isNameValid = !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            }
                            .onTapGesture {
                                showPlaceholder = false
                            }
                            .padding(.top, 28)
                            .padding(.horizontal, 6)
                            .autocorrectionDisabled()

                        if showPlaceholder {
                            Text("")
                                .foregroundColor(.primaryForeground)
                                .sfFont(weight: .medium, size: .h1)
                                .padding(.horizontal, 42)
                        }
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(Animation.easeOut(duration: 0.5).delay(0.3), value: animateContent)

                    // Continue Button
                    SharedComponents.PrimaryButton(title: "Continue") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        Analytics.shared.log(event: "NameScreen: Tapped Continue")

                        if let user = user.first {
                            user.name = firstName
                        }
                        mainVM.currUser.name = firstName
                        mainVM.onboardingScreen = .loadingIllusion
                        DataManager.shared.saveContext(context: modelContext)
                    }
                    .padding(.bottom)
                    .padding(.horizontal)
                    .disabled(firstName.isEmpty)
                    .opacity(firstName.isEmpty ? 0.5 : 1)
                    .padding(.top, 36)
                    .padding(.bottom, 48)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(Animation.easeOut(duration: 0.5).delay(0.5), value: animateContent)
                    Spacer()
                    Spacer()
                }
            }
        }
        .onAppear {
            animateContent = true // Trigger animations when view appears
            if let user = Auth.auth().currentUser {
                print("derrick rose")
            } else {
                print("carlos boozer")
            }
        }
        .onAppearAnalytics(event: "NameScreen: Screenload")
    }
}

#Preview {
    NameScreen()
}

struct CustomTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 48)
            .font(.system(size: 32))
            .padding(16)
            .padding(.leading, 12)
            .background(Color.secondaryBackground)
            .cornerRadius(16)
            .padding(.horizontal)
    }
}
