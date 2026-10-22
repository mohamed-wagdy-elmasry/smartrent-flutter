import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

import '../../../base/utils/local_storage.dart';
import '../../../base/utils/navigator_plug.dart';
import '../../../base/services/realtime_service.dart';
import '../../../base/services/pusher_beams_service.dart';
import '../../../base/widgets/logger.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import '../../../routes/routes.dart';
import '../../../../debug/print_auth_token.dart';

// Logger instance
final log = logger(SplashController);

class SplashController extends GetxController {
  final navigatorPlug = NavigatorPlug();

  @override
  void onReady() {
    super.onReady();
    // In debug builds, print whether auth tokens exist when splash is shown.
    if (kDebugMode) {
      // Fire-and-forget; don't block splash navigation.
      printAuthTokenDebug(revealRaw: true);
    }

    navigatorPlug.startListening(
      seconds: 3,
      onChanged: () {
        _checkUserAndNavigate();
      },
    );
  }

  void _checkUserAndNavigate() {
      _reconnectRealtimeService();
      _syncUserLanguage();
      
      // Initialize Pusher Beams for push notifications if user is logged in
      if (LocalStorage.isLoggedIn) {
        _initializePusherBeamsOnRestart();
      }

    if (LocalStorage.isLoggedIn) {
      // Reconnect to realtime service if user is logged in
      // User exists, navigate to dashboard
      Get.offAndToNamed(Routes.dashboardScreen);
    } else {
      // User doesn't exist, navigate to dashboard screen
      Get.offAndToNamed(Routes.dashboardScreen);
    }
  }

  /// Initialize Pusher Beams on app restart when user is already logged in
  Future<void> _initializePusherBeamsOnRestart() async {
    final userId = LocalStorage.userId;
    if (userId > 0) {
      try {
        log.i('[SplashController] 🚀 Initializing Pusher Beams on app restart for userId: $userId');
        await PusherBeamsService.instance.initialize(userId: userId.toString());
        await PusherBeamsService.instance.setDeviceInterests(['debug-hello', 'user-$userId']);
        log.i('[SplashController] ✅ Pusher Beams initialized on restart with authenticated user');
      } catch (e) {
        log.e('[SplashController] ❌ Failed to initialize Pusher Beams: $e');
      }
    }
  }

  /// Sync user's language preference from backend
  Future<void> _syncUserLanguage() async {
    if (LocalStorage.isLoggedIn) {
      try {
        await DynamicLanguage.fetchUserLanguage();
        log.i('[SplashController] Language synced from backend');
      } catch (e) {
        log.e('[SplashController] Failed to sync language: $e');
      }
    }
  }

  /// Reconnect to Pusher realtime service on app restart
  Future<void> _reconnectRealtimeService() async {
    final userId = LocalStorage.userId;
    final realtime = RealtimeService();
    await realtime.init();
    await realtime.subscribeToChannel('all-users');
    if ( userId > 0) {
      try {
        await realtime.subscribeToChannel('user-notification-$userId');

        // await realtime.subscribeToUserChannel(userId);
        log.i('[SplashController] Reconnected realtime for userId: $userId');
      } catch (e) {
        log.e('[SplashController] Failed to reconnect realtime: $e');
      }
    } else {
      log.w('[SplashController] Invalid userId: $userId');
    }
        await realtime.connect();

  }

  @override
  void onClose() {
    navigatorPlug.stopListening();
    super.onClose();
  }
}
