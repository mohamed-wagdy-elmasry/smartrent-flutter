import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/pusher_beams_service.dart';

/// Helper class for managing push notifications throughout the app
class PushNotificationHelper {
  /// Subscribe to user-specific notifications
  /// Call this after user logs in
  static Future<void> subscribeToUserNotifications(String userId) async {
    await PusherBeamsService.instance.addDeviceInterest('user-$userId');
  }

  /// Unsubscribe from user-specific notifications
  /// Call this when user logs out
  static Future<void> unsubscribeFromUserNotifications(String userId) async {
    await PusherBeamsService.instance.removeDeviceInterest('user-$userId');
  }

  /// Subscribe to order updates for a specific vendor
  static Future<void> subscribeToVendorOrders(String vendorId) async {
    await PusherBeamsService.instance.addDeviceInterest('vendor-$vendorId-orders');
  }

  /// Subscribe to delivery notifications
  static Future<void> subscribeToDeliveryNotifications() async {
    await PusherBeamsService.instance.addDeviceInterest('deliveries');
  }

  /// Subscribe to promotional notifications
  static Future<void> subscribeToPromotions() async {
    await PusherBeamsService.instance.addDeviceInterest('promotions');
  }

  /// Unsubscribe from promotional notifications
  static Future<void> unsubscribeFromPromotions() async {
    await PusherBeamsService.instance.removeDeviceInterest('promotions');
  }

  /// Subscribe to booking updates
  static Future<void> subscribeToBookingNotifications() async {
    await PusherBeamsService.instance.addDeviceInterest('bookings');
  }

  /// Setup notification handlers
  /// Call this in your app's initialization
  static void setupNotificationHandlers({
    required Function(RemoteMessage) onForegroundMessage,
    required Function(RemoteMessage) onNotificationTap,
  }) {
    // Handle foreground messages
    PusherBeamsService.instance.onMessageReceivedInForeground(onForegroundMessage);

    // Handle notification tap
    PusherBeamsService.instance.onMessageOpenedApp(onNotificationTap);
  }

  /// Check and handle initial notification
  /// Call this when app starts to handle notification that opened the app
  static Future<void> handleInitialNotification(
    Function(RemoteMessage) onInitialMessage,
  ) async {
    final initialMessage = await PusherBeamsService.instance.getInitialMessage();
    if (initialMessage != null) {
      onInitialMessage(initialMessage);
    }
  }

  /// Get the current FCM token
  /// Useful for debugging or sending to your backend
  static String? getFcmToken() {
    return PusherBeamsService.instance.getFcmToken();
  }
}
