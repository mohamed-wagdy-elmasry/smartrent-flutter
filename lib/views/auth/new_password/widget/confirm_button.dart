part of '../screen/new_password_screen.dart';

class ConfirmButton extends GetView<NewPasswordController> {
  const ConfirmButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PrimaryButton(
        title: Strings.submit,
        isLoading: controller.isLoading,
        onPressed: () {
          controller.onResetPasswordSubmit;
        },
      ),
    );
  }
}
