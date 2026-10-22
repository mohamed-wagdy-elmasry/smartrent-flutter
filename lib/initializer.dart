import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'base/services/notification_service.dart';
import 'routes/routes.dart';

class AppInitializer {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await GetStorage.init();
    await ScreenUtil.ensureScreenSize();
    
    // Initialize local notifications
    await NotificationService.init();
    
    // Register notification tap handler (fallback for unhandled types)
    NotificationService.setNotificationTapHandler((payload) async {
      // Navigate to notification screen when user taps on notification
      Get.toNamed(Routes.notificationScreen);
    });
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
