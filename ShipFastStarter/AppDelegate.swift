import BackgroundTasks
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerBackgroundTasks()
        return true
    }

    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "io.nora.bedrock.shieldExpiration", using: nil) { task in
            ShieldViewModel.handleBackgroundTask(task)
        }
    }

    // ... other AppDelegate methods ...
}
