import 'package:carbo/base/utils/basic_import.dart';
import 'package:carbo/base/widgets/empty_data_widget.dart';
import 'package:flutter/material.dart';
import '../controller/notification_controller.dart';
import '../widget/logo_widget.dart';

class NotificationMobileScreen extends GetView<NotificationController> {
  const NotificationMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(centerTitle: false, Strings.notification),
      body: Obx(() => controller.isLoading ? Loader() : _bodyWidget(context)),
    );
  }

  _bodyWidget(BuildContext context) {
    // Handle error state
    if (controller.hasError) {
      return SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Failed to load notifications'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.getNotificationInfo(),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Handle null or empty data
    if (controller.notificationModel == null || !controller.hasNotifications) {
      return SafeArea(
        child: EmptyDataWidget(massage: Strings.noNotification),
      );
    }

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.only(
          left: Dimensions.defaultHorizontalSize * 0.8,
          right: Dimensions.defaultHorizontalSize * 0.8,
          top: Dimensions.verticalSize * 0.5,
        ),
        children: List.generate(
          controller.notificationModel!.data.notification.length,
          (index) => LogoWidget(index),
        ),
      ),
    );
  }
}
