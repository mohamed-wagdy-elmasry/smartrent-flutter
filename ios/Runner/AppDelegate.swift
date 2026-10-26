import Flutter
import UIKit
import GoogleMaps
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // 1. Configure Firebase FIRST (before any other Firebase call)
    FirebaseApp.configure()

    // 2. Provide Google Maps API key (read from Info.plist at runtime)
    if let gmsKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !gmsKey.isEmpty {
      GMSServices.provideAPIKey(gmsKey)
    }

    // 3. Set Firebase Messaging delegate for APNs token ↔ FCM token mapping
    Messaging.messaging().delegate = self

    // 4. Register Flutter plugins
    //    NOTE: With UIScene lifecycle (iOS 26+ / Xcode 26), FlutterAppDelegate
    //    delegates window/engine creation to FlutterSceneDelegate.
    //    GeneratedPluginRegistrant.register(with: self) still works here because
    //    FlutterAppDelegate conforms to both UIApplicationDelegate and the
    //    FlutterPluginRegistry protocol. Plugin channels are wired to the engine
    //    automatically when the scene initialises.
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - APNs Registration
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("APNs registration failed: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  // MARK: - UNUserNotificationCenterDelegate (foreground & background)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
      @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .badge, .sound])
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }
}

// MARK: - MessagingDelegate (FCM token refresh)
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("FCM registration token refreshed")
  }
}
