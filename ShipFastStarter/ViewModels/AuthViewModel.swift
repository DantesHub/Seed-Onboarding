//
//  AuthViewModel.swift
//  Resolved
//
//  Created by Dante Kim on 9/30/24.
//

import AppsFlyerLib
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import Foundation
import Mixpanel
import OneSignalFramework
import RevenueCat
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var errorString = ""
    private var currentNonce: String?
    @Published var errorMessage = ""
    @Published var loading = false
    @Published var signInSuccessful = false
    @Published var showError = false
    @Published var isLoggingIn: Bool = false
    @Published var soberIntervals: [SoberInterval] = []
    @Published var signUpSuccessful = false
    @Published var inProcessOfSigningIn = false

}

private extension AuthViewModel {
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    /// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }

            for random in randoms {
                if remainingLength == 0 {
                    continue
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
}

// MARK: - Public Methods

extension AuthViewModel {
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        withAnimation {
            loading = true
        }
    }

    @MainActor
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>, _ mainVM: MainViewModel) {
        mainVM.loading = true
        if case let .failure(failure) = result {
            errorMessage = failure.localizedDescription
            errorString = "An error has occurred. Try Again."
            //                  try? FirebaseService.signOut()
            //                  print("Error authenticating: \(error.localizedDescription)")
            withAnimation {
                loading = false
                showError = true
            }
            return
        } else if case let .success(authorization) = result {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: a login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token.")
                    errorMessage = ""
                    errorString = "An error has occurred. Try Again."
                    try? FirebaseService.signOut()
                    withAnimation {
                        loading = false
                        showError = true
                    }
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
                    errorMessage = ""
                    errorString = "An error has occurred. Try Again."
                    try? FirebaseService.signOut()
                    withAnimation {
                        loading = false
                        showError = true
                    }
                    return
                }

                let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                               rawNonce: nonce,
                                                               fullName: appleIDCredential.fullName)

                let userToken = appleIDCredential.user
                let email = appleIDCredential.email
                print("AppleIdUserToken - \(userToken) \(email)")
                Task {
                    do {
                        let result = try await Auth.auth().signIn(with: credential)
//                        if let displayName = Auth.auth().currentUser?.displayName {
//                            let components = displayName.components(separatedBy: " ")
//                            mainVM.currUser.name = components.first ?? displayName
//                        } else {
//                            mainVM.currUser.name = ""
//                        }
                        mainVM.currUser.email = email ?? ""
                        mainVM.currUser.appleToken = userToken
                        UserDefaults.standard.setValue(userToken, forKey: Constants.token)
                        
                        OneSignal.login(mainVM.currUser.id)
                        OneSignal.User.addEmail(email ?? "")
                        
                        self.isLoggingIn = try await FirebaseService.checkIfUserExists(token: userToken)
                        
                        if isLoggingIn {
                            inProcessOfSigningIn = true
                            
                        }
                        
                        if !isLoggingIn {
                            Analytics.shared.log(event: "Onboarding: Successful Signup")
                            UserDefaults.standard.setValue(mainVM.currUser.id, forKey: "userId")
                        }
                        if !mainVM.currUser.id.isEmpty {
                            let newUser = mainVM.currUser
                            /// Init analytics user profile with new user
                            let firstName = Auth.auth().currentUser?.displayName?.components(separatedBy: " ").first ?? ""
                            let userProperties: [String: Any] = [
                                "id": newUser.id,
                                "gender": newUser.gender,
                                "dateJoined": newUser.joinDate,
                                "email": email ?? "",
                                "isPro": false,
                                "appleToken": userToken,
                                "name": Auth.auth().currentUser?.displayName ?? "",
                                "firstName": firstName,
                                // Add other properties as needed
                            ]

                            let userId = UserDefaults.standard.string(forKey: Constants.userId) ?? ""
                            print(newUser.email, email, "kimi")
                            //                            CustomerIO.shared.identify(userId: userId, traits: userProperties)
                            Analytics.shared.identifyUser(properties: userProperties)
                            #if !targetEnvironment(simulator)
                                Mixpanel.mainInstance().identify(distinctId: userId)
                                Purchases.shared.attribution.setEmail(email)
                                if let onesignalId = OneSignal.User.onesignalId {
                                    Purchases.shared.attribution.setOnesignalUserID(onesignalId)
                                    Mixpanel.mainInstance().people.set(properties: [
                                        "id": userId,
                                        "gender": newUser.gender,
                                        "age": newUser.age,
                                        "dateJoined": newUser.joinDate,
                                        "email": newUser.email,
                                        "isPro": true,
                                        "appleToken": userToken,
                                        "name": Auth.auth().currentUser?.displayName ?? "",
                                        "firstName": firstName,
                                        "$onesignal_user_id": onesignalId
                                        // Add other properties as needed
                                    ])
                                }
                             
                             
                            #endif

                            if !self.isLoggingIn {
                                mainVM.loading = false
                                /// Signing up
                                // Create the user account on firebase
                                if mainVM.onboardingScreen == .first && !(UserDefaults.standard.bool(forKey: Constants.completedOnboarding) || UserDefaults.standard.bool(forKey: "isPro")) {
                                    do {
                                        try FirebaseService.shared.signOut()
                                    } catch {
                                        print(error.localizedDescription, "signing out")
                                    }
                                    mainVM.showToast = true
                                    mainVM.loadingText = "contact support@tryseed.app"
                                    self.signUpSuccessful = false
                                } else {
                                    UserDefaults.standard.setValue(true, forKey: "signedUp")
                                    UserDefaults.standard.setValue(true, forKey: Constants.completedOnboarding)
                                    FirebaseService.createUser(user: newUser) { result in
                                        Analytics.shared.log(event: "SignUpWithApple: Created User")
                                        UserDefaults.standard.setValue(true, forKey: Constants.completedOnboarding)
                                        if let _ = result {
                                            self.signUpSuccessful = true
                                            if UserDefaults.standard.bool(forKey: Constants.completedOnboarding) {
                                                mainVM.currentPage = .home
                                            } else {}
                                            mainVM.showToast = true
                                            mainVM.loadingText = "✅ Success"
                                            self.saveIntervals()
                                            if let interval = self.soberIntervals.first {
                                                FirebaseService.shared.addDocument(interval, collection: "intervals") { _ in
                                                    print("successfully saved interval")
                                                }
                                            }
                                        }
                                    }
                                }

                            } else { // logging in
                                FirebaseService.getUser { result in
                                    switch result {
                                    case let .success(user):
                                        UserDefaults.standard.setValue(true, forKey: "isPro")
                                        UserDefaults.standard.setValue(true, forKey: Constants.completedOnboarding)
                                        UserDefaults.standard.setValue(true, forKey: "sawPricing")
                                        UserDefaults.standard.setValue(true, forKey: "sawReferral")
                                        UserDefaults.standard.setValue(true, forKey: "tappedCommunity")
                                        UserDefaults.standard.setValue(user.id, forKey: Constants.userId)
                                        // 'user' is of type 'FBUser'
                                        // Handle the successfully fetched user here

                                        // Start a new Task for asynchronous operations
                                        mainVM.currUser = user
                                        mainVM.currUser.isPro = true
                                        mainVM.loading = false
                                        print("successfully signed in", user.id, mainVM.currUser.id, mainVM.currUser.name, user.name)
                                        UserDefaults.standard.setValue(true, forKey: "signedUp")
                                        UserDefaults.standard.setValue(true, forKey: Constants.completedOnboarding)
                                        UserDefaults.standard.setValue(user.id, forKey: Constants.userId)
                                        Analytics.shared.log(event: "SignUpWithApple: Successfully Signed In")
                                        self.signUpSuccessful = true
                                        withAnimation {
                                            self.loading = false
                                            mainVM.currentPage = .home
                                        }
                                        mainVM.showToast = true
                                        mainVM.loadingText = "✅ Signed In"
                                        
                                        // fetch sober intervals and save to userDefaults
                                        FirebaseService.getIntervals(for: user.id) { result in
                                            switch result {
                                            case let .success(intervals):
                                                self.soberIntervals = intervals
                                                print("successfully fetched intervals", intervals.count)
                                            case let .failure(error):
                                                print("Error fetching intervals: \(error.localizedDescription)")
                                                self.handleError()
                                            }
                                        }

                                    case let .failure(error):
                                        // 'error' is of type 'Error'
                                        // Handle the error here
                                        do {
                                            try FirebaseService.shared.signOut()
                                        } catch {
                                            print(error.localizedDescription, "signing out")
                                        }
                                        mainVM.loading = false
                                        mainVM.showToast = true
                                        Analytics.shared.log(event: "SignUpWithApple: Error Getting User")
                                        mainVM.loadingText = "no user, go through onboarding."
                                        print("Error fetching user: \(error.localizedDescription)")
                                        self.handleError()
                                    }
                                }
                            }
                        }

                    } catch {
                        errorString = "An error has occurred. Please try again later."
                        try? FirebaseService.signOut()
                        mainVM.showToast = true
                        Analytics.shared.log(event: "SignUpWithApple: Error Authenticating")
                        mainVM.loadingText = "please go through onboarding"
                        print("Error authenticating: \(error.localizedDescription)")
                        withAnimation {
                            loading = false
                            showError = true
                        }
                        
                        if !self.isLoggingIn || UserDefaults.standard.bool(forKey: Constants.completedOnboarding) {
                            Analytics.shared.log(event: "AuthScreen: FailedSignUpSentHome")
                            signUpSuccessful = true
                            mainVM.currentPage = .home
                        }
                    }
                }
            } else {
                errorMessage = ""
                errorString = "An error has occurred. Try Again."
                //                  try? FirebaseService.signOut()
                //                  print("Error authenticating: \(error.localizedDescription)")
                withAnimation {
                    loading = false
                    showError = true
                }
                if !self.isLoggingIn || UserDefaults.standard.bool(forKey: Constants.completedOnboarding) {
                    Analytics.shared.log(event: "AuthScreen: FailedSignUpSentHome")
                    signUpSuccessful = true
                    mainVM.currentPage = .home
                }
                return
            }
        }
    }



    func saveIntervals() {
        Task {
            var batchDocuments: [(collection: FirebaseCollection, data: [String: Any])] = []

            for interval in soberIntervals {
                if let intervalData = interval.encodeToDictionary() {
                    batchDocuments.append((collection: .intervals, data: intervalData))
                }
            }

            do {
                try await FirebaseService.shared.batchSave(documents: batchDocuments)
                print("successfully saved intervals")
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func handleError() {
        errorString = "An error has occurred. Please try again later."
        try? FirebaseService.signOut()
        print("Error signing in.")
        withAnimation {
            self.loading = false
            self.showError = true
        }
    }
}
