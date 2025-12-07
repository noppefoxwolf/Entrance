import SwiftUI
import UserNotifications
import UIKit

@main
struct App: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// UIApplicationDelegate to demonstrate launch from local notification.
final class AppDelegate: NSObject, UIApplicationDelegate, @MainActor UNUserNotificationCenterDelegate {
    static private(set) weak var instance: AppDelegate?
    static var shared: AppDelegate? { instance }

    var launchedFromNotification = false

    override init() {
        super.init()
        AppDelegate.instance = self
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        // Note: `.localNotification` launch option is deprecated since iOS 10.
        // For local notifications, rely on UNUserNotificationCenterDelegate callbacks
        // such as `userNotificationCenter(_:didReceive:withCompletionHandler:)`.
        if launchOptions?[.remoteNotification] != nil {
            launchedFromNotification = true
        }
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        launchedFromNotification = true
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .demoNotificationLaunch, object: nil)
        }
        completionHandler()
    }
}
