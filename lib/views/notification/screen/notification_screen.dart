import 'package:flutter/material.dart';
import '../../../base/utils/basic_import.dart';
import '../controller/notification_controller.dart';
import 'notification_mobile_screen.dart';
import 'notification_tablet_screen.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: NotificationMobileScreen(),
      tablet: NotificationTabletScreen(),
    );
  }
}
