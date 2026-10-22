import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../assets/assets.dart';
import '../utils/basic_import.dart';

class CustomSnackBar {
  static success({
    required String title,
    required String message,
    void Function(GetSnackBar)? onTap,
  }) {
    return Get.showSnackbar(
      GetSnackBar(
        backgroundColor: Colors.white,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize * 0.7,
          vertical: Dimensions.verticalSize * 0.3,
        ),
        padding: EdgeInsets.all(Dimensions.paddingSize * 0.45),
        borderRadius: Dimensions.radius * 1.5,
        snackPosition: SnackPosition.BOTTOM,
        messageText: CustomSnackbarContent(
          title: title,
          message: message,
          type: 'success',
        ),
        onTap: onTap,
        boxShadows: [
          BoxShadow(
            blurRadius: 20,
            spreadRadius: 7,
            color: CustomColor.blackColor.withValues(alpha: 0.05),
          ),
        ],
        isDismissible: true,
      ),
    );
  }

  static error(String message) {
    return Get.showSnackbar(
      GetSnackBar(
        backgroundColor: Colors.white,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize * 0.7,
          vertical: Dimensions.verticalSize * 0.3,
        ),
        padding: EdgeInsets.all(Dimensions.paddingSize * 0.45),
        borderRadius: Dimensions.radius * 1.5,
        snackPosition: SnackPosition.BOTTOM,
        messageText: CustomSnackbarContent(
          title: Strings.error,
          message: message,
          type: 'error',
        ),
        boxShadows: [
          BoxShadow(
            blurRadius: 20,
            spreadRadius: 7,
            color: CustomColor.blackColor.withValues(alpha: 0.05),
          ),
        ],
        isDismissible: true,
      ),
    );
  }
}

class CustomSnackbarContent extends StatelessWidget {
  final String title, message, type;

  const CustomSnackbarContent({
    super.key,
    required this.title,
    required this.message,
    required this.type,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          type == 'success' ? Assets.icons.success : Assets.icons.reject,
          height: Dimensions.heightSize * 4.5,
        ),
        Sizes.width.v10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                title,
                fontSize: Dimensions.titleSmall * 0.8,
                fontWeight: FontWeight.w400,
              ),
              Sizes.height.v5,
              TextWidget(
                message
                    .replaceAll(RegExp(r'\['), '')
                    .replaceAll(RegExp(r'\]'), ''),
                fontSize: Dimensions.labelSmall * 0.9,
                fontWeight: FontWeight.w400,
                colorShade: ColorShade.highSeventy,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
