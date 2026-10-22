part of '../screen/otp_login_screen.dart';

class HeadingWidget extends GetView<OtpLoginController> {
  const HeadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isOtp = controller.isOtpSent.value;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Column(
          key: ValueKey(isOtp),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              isOtp
                  ? DynamicLanguage.key(Strings.enterOtpCode)
                  : DynamicLanguage.key(Strings.login),
              fontWeight: FontWeight.bold,
              typographyStyle: TypographyStyle.headlineSmall,
            ),
            const SizedBox(height: 6),
            TextWidget(
              isOtp
                  ? DynamicLanguage.key(Strings.otpSentToPhone)
                  : DynamicLanguage.key(Strings.enterMobileForOtp),
              fontWeight: FontWeight.w400,
              typographyStyle: TypographyStyle.bodyMedium,
              colorShade: ColorShade.mediumForty,
              maxLines: 2,
            ),
          ],
        ),
      );
    });
  }
}
