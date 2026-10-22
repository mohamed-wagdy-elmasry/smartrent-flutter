part of '../screen/register_screen.dart';

class RegisterButton extends GetView<RegisterController> {
  const RegisterButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.verticalSize * 0.5),
      child: Obx(
        () => PrimaryButton(
          disable: !controller.isFormValid.value,
          title: Strings.registerNow,
          isLoading: controller.isLoading,
          onPressed: () {
            if (controller.isFormValid.value) {
              if (BasicServices.agreePolicy.value == 1) {
                if (controller.agree.value) {
                  controller.onRegistration;
                } else {
                  CustomSnackBar.error(Strings.agreeToTerms);
                }
              } else {
                controller.onRegistration;
              }
            }
          },
        ),
      ),
    );
  }
}
