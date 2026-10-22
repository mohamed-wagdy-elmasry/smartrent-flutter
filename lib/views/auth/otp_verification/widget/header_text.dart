part of '../screen/otp_verification_screen.dart';

class HeaderText extends StatelessWidget {
  HeaderText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Sizes.height.v40,
        TextWidget(
          fontSize: Dimensions.titleMedium * 1.2,
          textAlign: TextAlign.center,
          padding: EdgeInsets.symmetric(
            vertical: Dimensions.verticalSize * 0.2,
          ),
          maxLines: 1,
          Strings.pleaseEnterTheCode,
          fontWeight: FontWeight.bold,
        ),
        FittedBox(
          child: Row(
            mainAxisAlignment: mainCenter,
            children: [
              TextWidget(
                textAlign: TextAlign.center,
                padding: EdgeInsets.only(bottom: Dimensions.verticalSize * 1.5),
                color: CustomColor.blackColor.withValues(alpha: 0.5),
                Strings.weSentADigitCode,
                fontSize: Dimensions.titleSmall * 0.95,
                maxLines: 3,
              ),
              Sizes.width.v5,
              TextWidget(
                textAlign: TextAlign.center,
                padding: EdgeInsets.only(bottom: Dimensions.verticalSize * 1.5),
                color: CustomColor.blackColor.withValues(alpha: 0.5),
                Get.find<ResetPasswordController>().emailAddressController.text,
                fontWeight: FontWeight.bold,
                fontSize: Dimensions.titleSmall * 0.95,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
