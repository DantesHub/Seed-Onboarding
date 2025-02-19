//
//  ShipFastStarterApp.swift
//  ShipFastStarter
//
//  Created by Dante Kim on 6/20/24.
//
import AdSupport // Optional: to get the IDFA
import AppsFlyerLib
import AppTrackingTransparency
import BackgroundTasks
import BranchSDK
import CioDataPipelines
import FacebookCore
import FirebaseAuth
import FirebaseCore
import Foundation
import ManagedSettings
import Mixpanel
import OneSignalFramework
import RevenueCat
import SuperwallKit
import SwiftData
import SwiftUI
import TipKit
import AdjustSdk

// import Singular

@main
struct BedrockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var mainVM: MainViewModel = .init()
    @StateObject var timerVM: TimerViewModel = .init()
    @StateObject var reflectionVM: ReflectionsViewModel = .init()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject var quickActionsManager = QuickActionsManager.instance
    @Environment(\.modelContext) private var modelContext

    init() {
        setup()
    }

    var sharedModelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: User.self, SoberInterval.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

//    @StateObject private var shieldViewModel = ShieldViewModel()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(mainVM)
                .environmentObject(timerVM)
                .environmentObject(reflectionVM)
                .onChange(of: quickActionsManager.quickAction) { newAction in
                    guard let action = newAction else { return }
                    handleQuickAction(action)
                }
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .active:
                        timerVM.appWillEnterForeground()

                    case .background:
                        timerVM.appWillEnterBackground()
                    case .inactive:
                        break
                    @unknown default:
                        break
                    }
                }
                .onAppear {
                    let isSubscribed = subscriptionManager.isSubscribed
                    print("User subscription status on new device: \(isSubscribed)")
                    mainVM.isPro = isSubscribed
                    
//                    UserDefaults.standard.setValue(true, forKey: "isPro")
//                    UserDefaults.standard.setValue(true, forKey: Constants.isCreatorKey)
                    if UserDefaults.standard.bool(forKey: "isPro") {
                        mainVM.currentPage = .home
                    } else {
                        mainVM.currentPage = .onboarding
                        if UserDefaults.standard.bool(forKey: "isPro") {
                            if UserDefaults.standard.bool(forKey: "signedUp") {
                                mainVM.currentPage = .home
                            } else {
                                mainVM.onboardingScreen = .signUp
                            }
                        } else if UserDefaults.standard.bool(forKey: "sawReferral") {
                            if UserDefaults.standard.bool(forKey: "sawReferral") {
                                Analytics.shared.log(event: "HardClosedPaywall")
                                mainVM.onboardingScreen = .pricing
                            }
                        }
                    }
                }
                .onOpenURL { url in
                    if url.scheme == "nafs" && url.host == "panic" {
                        if mainVM.currentPage == .home {
                            DispatchQueue.main.async {
                                mainVM.tappedPanic = true
                            }
                        }
                        print(url)
                    } else if url.scheme == "nafs" && url.host == "newentry" {
                        Analytics.shared.log(event: "Widget: tapped newentry")
                        mainVM.currentPage = .home
                        DispatchQueue.main.async {
                            reflectionVM.showWriteReflection = true
                        }
                    } else if url.scheme == "nafs" && url.host == "gopro" {
                        Analytics.shared.log(event: "Widget: tapped go pro")
                        DispatchQueue.main.async {
                            Superwall.shared.register(event: "feature_locked")
                        }
                    }

                    Branch.getInstance().handleDeepLink(url)
                    ApplicationDelegate.shared.application(UIApplication.shared,
                                                           open: url, sourceApplication: nil,
                                                           annotation: UIApplication.OpenURLOptionsKey.annotation)
                }
        }

        .modelContainer(sharedModelContainer)
    }

    func setup() {
        
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault),
        ])

        let secondLaunch = UserDefaults.standard.bool(forKey: "firstLaunch1")

        if !secondLaunch {
            UserDefaults.standard.setValue(true, forKey: "firstLaunch1")
            let userId = UUID().uuidString
            UserDefaults.standard.setValue(userId, forKey: Constants.userId)
            mainVM.currUser.id = userId
        }

        let userId = UserDefaults.standard.string(forKey: Constants.userId) ?? ""
//        UserDefaults.standard.setValue(false, forKey: "sawReferral")
//        UserDefaults.standard.setValue(false, forKey: Constants.completedOnboarding)
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_OkoYujoGWkewGpVNaJiWXJJpjKV", appUserID: userId)
//
        Superwall.configure(apiKey: "pk_62316de0b18ff390d2002a3cab019b2fdddb38df1c00e5b1")
        Superwall.shared.identify(userId: userId)

        //MARK: revert
//        Superwall.shared.reset()
        Superwall.shared.delegate = mainVM

        CustomerIO.initialize(
            withConfig: SDKConfigBuilder(cdpApiKey: "863257965edb4562816c")
                .build()
        )

        AppsFlyerLib.shared().appsFlyerDevKey = "MuYPR9jvHqxu7TzZCrTNcn"
        AppsFlyerLib.shared().appleAppID = "6636516894"
        AppsFlyerLib.shared().customerUserID = userId
        AppsFlyerLib.shared().logEvent("App Started", withValues: [:])
        AppsFlyerLib.shared().isDebug = false
        AppsFlyerLib.shared().start()
        // Initialize Branch
//        Branch.getInstance().setDebug() // Remove this line for production
//        Branch.getInstance().initSession { (params, error) in
//            if error == nil {
//                // params are the deep linked params associated with the link that the user clicked -> was deep linked to
//                print("Branch initialization successful", params ?? {})
//            } else {
//                print("Branch initialization failed", error?.localizedDescription ?? "")
//            }
//        }
//        Branch.getInstance().setIdentity(userId)

        Mixpanel.initialize(token: "b09fe7bcb2f85d98f1bfdef2cd2e1ad2", trackAutomaticEvents: false)
        Mixpanel.mainInstance().track(event: "App Start")
        Mixpanel.mainInstance().identify(distinctId: userId)

        print("setup")
    }
    
    private func handleQuickAction(_ action: QuickAction) {
          switch action {
          case .search:
              // Navigate to your search screen, or set some state to show a search UI
              print("User tapped the Search quick action")
          case .home:
              // Go to the home screen
              print("User tapped the Home quick action")
          }
      }

    func handleAppRefresh(task: BGAppRefreshTask) {
        // Create an operation that performs the main part of the background task
        let operation = BlockOperation {
            // Perform your background tasks here
            // For example, update elapsed time, sync data, etc.
            print("Performing background refresh")
        }

        // Inform the system that the background task is complete
        operation.completionBlock = {
            task.setTaskCompleted(success: true)
        }

        // Start the operation
        OperationQueue.main.addOperation(operation)

        // Schedule the next refresh
    }

//        func requestTrackingPermission() {
//            // Check if the ATT is supported
//            if #available(iOS 14, *) {
//
//                ATTrackingManager.requestTrackingAuthorization { status in
//                    switch status {
//                    case .authorized:
//                        print("Tracking authorized")
//                    case .denied:
//                        print("Tracking denied")
//                    case .notDetermined:
//                        print("Tracking not determined")
//                    case .restricted:
//                        print("Tracking restricted")
//                    @unknown default:
//                        break
//                    }
//                }
//            } else {
//                // Fallback on earlier versions
//                print("ATT not supported")
//            }
//        }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(
      _ application: UIApplication,
      performActionFor shortcutItem: UIApplicationShortcutItem,
      completionHandler: @escaping (Bool) -> Void
    ) {
        // Forward this to your QuickActionsManager
        QuickActionsManager.instance.handleQaItem(shortcutItem)
        print("bazinga")
        // Let the system know the shortcut was handled
        completionHandler(true)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        print("finish launching")
        // Handle any initialization that needs to happen at app launch
        print("launching be enough")

        UNUserNotificationCenter.current().delegate = self
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        #if DEBUG
            let branchKey = Bundle.main.object(forInfoDictionaryKey: "branch_key_test") as? String
        #else
            let branchKey = Bundle.main.object(forInfoDictionaryKey: "branch_key_live") as? String
        #endif
        Branch.setBranchKey(branchKey!)
        Branch.getInstance().resetUserSession()
        Branch.getInstance().initSession { params, error in
            if error == nil {
                // params are the deep linked params associated with the link that the user clicked -> was deep linked to
                print("Branch initialization successful", params ?? {})
            } else {
                print("Branch initialization failed", error?.localizedDescription ?? "")
            }
        }
        
        Branch.getInstance().enableLogging()
        let userId = UserDefaults.standard.string(forKey: Constants.userId) ?? ""
        Branch.getInstance().setIdentity(userId)

        BranchEvent.customEvent(withName: "App_Open").logEvent()

//        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "io.nora.bedrock.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
      // OneSignal initialization
        if UserDefaults.standard.bool(forKey: "isPro") {
            OneSignal.Debug.setLogLevel(.LL_VERBOSE)
          OneSignal.initialize("c0fbef9f-99ca-4865-9c3d-8ab70800f015", withLaunchOptions: launchOptions)
        }
     
//        let userId = UserDefaults.standard.string(forKey: Constants.userId) ?? ""
        FirebaseApp.configure()

   
//        UserDefaults.standard.setValue(false, forKey: "sawReferral")
        // Add this for Branch
//        Branch.getInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
//        setupAdjustSDK()

        return true
    }
    
    func setupAdjustSDK() {
        let yourAppToken = "kf3n4uebmups"
        let environment = ADJEnvironmentProduction
        let adjustConfig = ADJConfig(
            appToken: yourAppToken,
            environment: environment,
            suppressLogLevel: true)
        adjustConfig?.logLevel = ADJLogLevel.verbose
        adjustConfig?.delegate = self
        //...
        Adjust.initSdk(adjustConfig)

    }
    
    

    func application(_: UIApplication, performFetchWithCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void) {
        let stor = ManagedSettingsStore()
        stor.clearAllSettings()
    }

    func handleAppRefresh(task: BGAppRefreshTask) {
        let operation = BlockOperation {
            // For example, update elapsed time, sync data, etc.
            let store = ManagedSettingsStore()
            store.clearAllSettings()
            print("Performing background refresh")
        }

        operation.completionBlock = {
            let store = ManagedSettingsStore()
            store.clearAllSettings()

            task.setTaskCompleted(success: true)
        }
        let store = ManagedSettingsStore()
        store.clearAllSettings()

        OperationQueue.main.addOperation(operation)

        // Schedule a new refresh task.
//       scheduleAppRefresh()

        // Create an operation that performs the main part of the background task.
//       let operation = RefreshAppContentsOperation()
//
//       // Provide the background task with an expiration handler that cancels the operation.
//       task.expirationHandler = {
//          operation.cancel()
//       }
//
//
//       // Inform the system that the background task is complete
//       // when the operation completes.
//       operation.completionBlock = {
//          task.setTaskCompleted(success: !operation.isCancelled)
//       }
//

        // Start the operation.
//       operationQueue.addOperation(operation)
    }

    func application(_: UIApplication, didReceiveRemoteNotification _: [AnyHashable: Any], fetchCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void) {}

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler(.alert)
    }

//       func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//           // Handle foreground presentation options
//
//           completionHandler([.alert, .sound, .badge])
//       }
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        let identifier = response.notification.request.identifier

        if identifier == "milestone_\(Orb.blueOrb.daysCount())" {
            AppState.shared.showEvolution = true
        }
        completionHandler()
    }

    func application(_: UIApplication, handleEventsForBackgroundURLSession _: String, completionHandler _: @escaping () -> Void) {
        // Handle background URL session events if needed
//        completionHandler()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("URL received: \(url.absoluteString)") // Log the URL received
        Branch.getInstance().application(app, open: url, options: options)

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        // Check if the URL scheme and host match
        if url.scheme == "shipfast" && url.host == "panic" {
            print("Panic button tapped!")
            // Trigger your panic action here
            return true // Indicate that the URL was handled
        }

        return false // Return false if the URL wasn't handled
    }

    func applicationDidBecomeActive(_: UIApplication) {
        requestDataPermission()
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        Adjust.trackSubsessionEnd()
    }

    func requestDataPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown
                    // and we are authorized
                    print("Authorized")
                    Adjust.trackSubsessionStart()
                case .denied:
                    // Tracking authorization dialog was
                    // shown and permission is denied
                    print("Denied")
                case .notDetermined:
                    // Tracking authorization dialog has not been shown
                    print("Not Determined")
                case .restricted:
                    print("Restricted")
                @unknown default:
                    print("Unknown")
                }
            })
        } else {
            // you got permission to track, iOS 14 is not yet installed
        }
    }

    // Add these methods for Branch deep linking
    func application(_: UIApplication, continue userActivity: NSUserActivity, restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return Branch.getInstance().continue(userActivity)
    }
//
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        return Branch.getInstance().application(app, open: url, options: options)
//    }
}

extension AppDelegate: AdjustDelegate {
    func adjustDeeplinkResponse(_ deeplink: URL?) -> Bool {
        guard let url = deeplink else { return false }
        // Handle the URL, e.g., navigate to a specific screen
        return true
    }
}

