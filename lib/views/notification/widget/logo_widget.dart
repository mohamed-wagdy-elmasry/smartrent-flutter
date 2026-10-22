import 'package:carbo/base/themes/token.dart';
import 'package:carbo/base/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../base/utils/dimensions.dart';
import '../../../base/utils/size.dart';
import '../../../base/widgets/text_widget.dart';
import '../controller/notification_controller.dart';

class LogoWidget extends GetView<NotificationController> {
  LogoWidget(this.index, {Key? key}) : super(key: key);
  final index;

  @override
  Widget build(BuildContext context) {
    if (controller.notificationModel == null) {
      return const SizedBox.shrink();
    }
    final notification = controller.notificationModel!.data.notification[index];
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(Dimensions.paddingSize * 0.5),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSize * 0.7,
                vertical: Dimensions.paddingSize * 0.1,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius),
                color: Colors.grey[100],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextWidget(
                    DateFormat('d').format(notification.createdAt),
                    typographyStyle: TypographyStyle.headlineSmall,
                    fontWeight: FontWeight.bold,
                    color: CustomColor.primary,
                  ),
                  TextWidget(
                    DateFormat('MMM').format(notification.createdAt),
                    typographyStyle: TypographyStyle.labelSmall,
                    color: CustomColor.primary,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.horizontalSize * 0.3,
                ),
                child: Column(
                  crossAxisAlignment: crossStart,
                  children: [
                    TextWidget(
                      notification.message.title,
                      typographyStyle: TypographyStyle.bodyLarge,
                      fontWeight: FontWeight.bold,
                    ),
                    Sizes.height.v5,
                    TextWidget(
                      notification.message.message,
                      typographyStyle: TypographyStyle.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
            if (notification.message.title.contains('Payment Rejected')) ...[
              Obx(
                () => controller.isRepaymentLoading
                    ? Loader()
                    : IconButton(
                        onPressed: () {
                          controller.rePaymentManualInsert();
                        },
                        icon: Icon(Icons.payment, color: CustomColor.rejected),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
