part of '../screen/otp_verification_screen.dart';

class SubmitButton extends GetView<OtpVerificationController> {
  const SubmitButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Dimensions.verticalSize),
      child: Obx(
        () => PrimaryButton(
          title: Strings.submit,
          disable: !controller.isFormValid.value,
          isLoading: controller.isLoading,
          onPressed: () {
            if (controller.isFormValid.value) {
              controller.onOtpSubmit;
            }
          },
        ),
      ),
    );
  }
}
