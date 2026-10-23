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

    // 2. Set UNUserNotificationCenter delegate so foreground notifications work
    UNUserNotificationCenter.current().delegate = self

    // 3. Set Firebase Messaging delegate for APNs token ↔ FCM token mapping
    Messaging.messaging().delegate = self

    // 4. Provide Google Maps API key (read from Info.plist at runtime)
    if let gmsKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !gmsKey.isEmpty {
      GMSServices.provideAPIKey(gmsKey)
    }

    // 5. Register Flutter plugins (must be last)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - APNs Registration
  // With FirebaseAppDelegateProxyEnabled = YES in Info.plist, Firebase swizzles
  // didRegisterForRemoteNotificationsWithDeviceToken to automatically map the APNs
  // token to FCM. We forward directly to super so FlutterAppDelegate dispatches to all plugins.
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

  // MARK: - UNUserNotificationCenterDelegate (foreground & background notification handling)
  /// Show notification banner even when app is in foreground.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
      @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .badge, .sound])
  }

  /// Handle tap on notification (background / terminated state).
  /// Forward to FlutterAppDelegate so firebase_messaging and flutter_local_notifications
  /// can trigger onMessageOpenedApp and getInitialMessage() for deep navigation.
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
    // FCM token refresh is observed by the firebase_messaging Flutter plugin.
    print("FCM registration token refreshed")
  }
}
