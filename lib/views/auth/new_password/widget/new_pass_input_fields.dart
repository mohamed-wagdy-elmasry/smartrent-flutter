part of '../screen/new_password_screen.dart';

class NewPassInputFields extends GetView<NewPasswordController> {
  const NewPassInputFields({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: EdgeInsets.only(bottom: Dimensions.verticalSize),
        child: Column(
          children: [
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
