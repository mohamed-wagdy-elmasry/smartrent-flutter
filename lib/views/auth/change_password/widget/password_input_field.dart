part of '../screen/change_password_screen.dart';

class PasswordInputField extends GetView<ChangePasswordController> {
  const PasswordInputField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: EdgeInsets.only(bottom: Dimensions.verticalSize),
        child: Column(
          children: [
            Sizes.height.v30,
            PrimaryInputWidget(
              controller: controller.oldPasswordController,
              label: Strings.oldPassword,
              hintText: Strings.oldPassword,
              isPasswordField: true,
            ),
            Sizes.height.betweenInputBox,

            PrimaryInputWidget(
              controller: controller.newPasswordController,
              label: Strings.newPassword,
              hintText: Strings.newPassword,
              isPasswordField: true,
            ),
            Sizes.height.betweenInputBox,
            PrimaryInputWidget(
              controller: controller.confirmPasswordController,
              label: Strings.confirmPassword,
              hintText: Strings.confirmPassword,
              isPasswordField: true,
            ),
          ],
        ),
      ),
    );
  }
}
