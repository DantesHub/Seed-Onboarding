//
//  SubscriptionManagerHelper.swift
//  Resolved
//
//  Created by Gaganjot Singh on 10/11/24.
//

import Foundation

class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    private let subscriptionKey = "isSubscribed"
    
    // Private initializer to ensure only one instance is created
    private init() {
        // Observe changes in iCloud data
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(icloudDataDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default
        )
    }
    
    // Retrieve and store the subscription status in iCloud
    var isSubscribed: Bool {
        get {
            let value = NSUbiquitousKeyValueStore.default.bool(forKey: subscriptionKey)
            print("Retrieved isSubscribed from iCloud: \(value)")
            return value
        }
        set {
            print("Saving isSubscribed to iCloud with value: \(newValue)")
            NSUbiquitousKeyValueStore.default.set(newValue, forKey: subscriptionKey)
            let success = NSUbiquitousKeyValueStore.default.synchronize()
            print("Sync status: \(success)")
        }
    }
    
    // Handle updates from iCloud when data changes
    @objc private func icloudDataDidChange(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        if let reasonForChange = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int,
           reasonForChange == NSUbiquitousKeyValueStoreServerChange {
            print("iCloud data changed. New subscription status: \(isSubscribed)")
            // Notify the UI or update as needed
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
