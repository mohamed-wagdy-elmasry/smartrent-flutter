import 'package:carbo/routes/routes.dart';
import 'package:carbo/views/auth/register/controller/register_controller.dart';
import 'package:flutter/material.dart';
import '../../../../base/utils/basic_import.dart';

class AlreadyAccountWidget extends GetView<RegisterController> {
  const AlreadyAccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        TextWidget(
          Strings.alreadyHaveAnAccount,
          colorShade: ColorShade.mediumForty,
          typographyStyle: TypographyStyle.labelMedium,
          padding: Dimensions.horizontalSize.edgeHorizontal * 0.07,
        ),
        TextWidget(
          padding: EdgeInsets.only(left: Dimensions.horizontalSize * 0.1),
          Strings.loginNow,
          colorShade: ColorShade.mediumForty,
          typographyStyle: TypographyStyle.labelMedium,
          color: CustomColor.primary,
          fontWeight: FontWeight.w400,
          onTap: () {
            Get.offAllNamed(Routes.otpLoginScreen);
            // controller.onLogIn;
          },
        ),
      ],
    );
  }
}
