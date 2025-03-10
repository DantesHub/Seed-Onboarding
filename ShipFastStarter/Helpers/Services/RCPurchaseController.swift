

import Foundation
import Mixpanel
import RevenueCat
import StoreKit
import SuperwallKit
import UIKit

final class RCPurchaseController: PurchaseController, ObservableObject {
    static let shared = RCPurchaseController()
    @Published var wentPro = false
    @Published var mainVM: MainViewModel?

    // Private initializer to prevent creating instances directly
    init() {}

    // MARK: Sync Subscription Status

    /// Makes sure that Superwall knows the customers subscription status by
    /// changing `Superwall.shared.subscriptionStatus`
    func syncSubscriptionStatus() {
        assert(Purchases.isConfigured, "You must configure RevenueCat before calling this method.")
        Task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                // Gets called whenever new CustomerInfo is available
                let hasActiveSubscription = !customerInfo.entitlements.active.isEmpty
                if hasActiveSubscription {
                    print("revenuecat has an active")
                    Superwall.shared.subscriptionStatus = .active
                } else {
                    print("revenuecat has no active")
                    Superwall.shared.subscriptionStatus = .inactive
                }
            }
        }
    }

    // MARK: Handle Purchases

    /// Makes a purchase with RevenueCat and returns its result. This gets called when
    /// someone tries to purchase a product on one of your paywalls.
    func purchase(product: SKProduct) async -> PurchaseResult {
        do {
            // This must be initialized before initiating the purchase.
            let purchaseDate = Date()
            let storeProduct = RevenueCat.StoreProduct(sk1Product: product)
            let revenueCatResult = try await Purchases.shared.purchase(product: storeProduct)
            mainVM?.loadingText = "got it"
            mainVM?.showToast = true
            if revenueCatResult.userCancelled {
                print("user cancelled inside superwall")
                Analytics.shared.logActual(event: "SubPricingView: Cancelled \(product.productIdentifier)", parameters: [
                    "price": product.price,
                    "cancelled": product.productIdentifier,
                ])
                mainVM?.showHalfOff = true
                UserDefaults.standard.setValue(true, forKey: "pricingClickX")
                return .cancelled
            } else {
                if let transaction = revenueCatResult.transaction,
                   purchaseDate > transaction.purchaseDate
                {
                    return .restored
                } else {
                    print("purchased")

                    let userProperties: [String: Any] = [
                        "isPro": true,
                        // Add other properties as needed
                    ]

                    let userId = UserDefaults.standard.string(forKey: Constants.userId) ?? ""
                    Mixpanel.mainInstance().people.set(properties: [
                        "isPro": true,
                        // Add other properties as needed
                    ])
                    
                    SubscriptionManager.shared.isSubscribed = true

                    Analytics.shared.logActual(event: "SubPricingView: Successfully Unlocked", parameters: ["product": product.productIdentifier, "price": product.price])

                    Mixpanel.mainInstance().people.increment(property: "Total Revenue", by: Double(truncating: product.price))
                    Analytics.shared.logActual(event: "SubPricingView: Succesfully Unlocked", parameters: [
                        "price": product.price,
                        "product": product.productIdentifier,
                    ])

                    return .purchased
                }
            }
        } catch let error as ErrorCode {
            if error == .paymentPendingError {
                return .pending
            } else {
                return .failed(error)
            }
        } catch {
            return .failed(error)
        }
    }

    // MARK: Handle Restores

    /// Makes a restore with RevenueCat and returns `.restored`, unless an error is thrown.
    /// This gets called when someone tries to restore purchases on one of your paywalls.
    func restorePurchases() async -> RestorationResult {
        do {
            _ = try await Purchases.shared.restorePurchases()
            return .restored
        } catch {
            return .failed(error)
        }
    }
}
