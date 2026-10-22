part of '../screen/otp_login_screen.dart';

class LoginButtonWidget extends GetView<OtpLoginController> {
  const LoginButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isOtp     = controller.isOtpSent.value;
      final isEnabled = isOtp ? controller.isOtpValid.value : controller.isMobileValid.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radius * 1.2),
          gradient: isEnabled
              ? LinearGradient(
                  colors: [CustomColor.primary, _C.heroBottom],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: CustomColor.primary.withOpacity(0.32),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: PrimaryButton(
          isLoading: controller.isLoading,
          title: isOtp ? Strings.verifyAndLogin : Strings.sendOtp,
          disable: !isEnabled,
          buttonColor: Colors.transparent,
          onPressed: () {
            if (isOtp && controller.isOtpValid.value) {
              controller.onVerifyOtp;
            } else if (!isOtp && controller.isMobileValid.value) {
              controller.onSendOtp;
            }
          },
        ),
      );
    });
  }
}
