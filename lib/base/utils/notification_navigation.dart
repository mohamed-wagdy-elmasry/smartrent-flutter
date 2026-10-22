import 'package:carbo/routes/routes.dart';
import 'package:get/get.dart';

/// Helper class to handle notification navigation
/// 
/// Usage in notification handler:
/// ```dart
/// // When booking is accepted notification is tapped
/// NotificationNavigation.goToHistoryDetail(bookingId: 123);
/// 
/// // Or if you have the full history object
/// NotificationNavigation.goToHistoryDetail(history: historyObject);
/// ```
class NotificationNavigation {
  /// Navigate to history detail screen from notification
  /// 
  /// Can accept either [historyId] or [history] object
  /// - [historyId]: The booking/history ID from notification data
  /// - [history]: The full History object (if already fetched)
  static void goToHistoryDetail({
    int? historyId,
    dynamic history,
  }) {
    if (historyId != null) {
      Get.toNamed(
        Routes.historyDetailScreen,
        arguments: {'historyId': historyId},
      );
    } else if (history != null) {
      Get.toNamed(
        Routes.historyDetailScreen,
        arguments: {'history': history},
      );
    }
  }

  /// Navigate to history list screen
  static void goToHistory() {
    Get.toNamed(Routes.historyScreen);
  }
}
