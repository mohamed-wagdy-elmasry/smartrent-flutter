part of '../screen/reset_password_screen.dart';

class SendOtpButton extends GetView<ResetPasswordController> {
  const SendOtpButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: Dimensions.verticalSize * 0.5,
          ),
          child: Obx(
            () => PrimaryButton(
              title: Strings.sendOtp,
              disable: !controller.isFormValid.value,
              isLoading: controller.isLoading,
              onPressed: () {
                if (controller.isFormValid.value) {
                  controller.onForgotPassword;
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
