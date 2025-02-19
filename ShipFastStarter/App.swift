import BackgroundTasks
import SwiftUI

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerBackgroundTasks()
        return true
    }

    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "io.nora.bedrock.shieldExpiration", using: nil) { task in
            ShieldViewModel.handleBackgroundTask(task)
        }
    }

    func application(_: UIApplication, handleEventsForBackgroundURLSession _: String, completionHandler _: @escaping () -> Void) {
        // This method is not needed for BGTask, so we can leave it empty
    }
}
