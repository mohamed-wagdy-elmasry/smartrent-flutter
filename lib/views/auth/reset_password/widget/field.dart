part of '../screen/reset_password_screen.dart';

class Field extends GetView<ResetPasswordController> {
  const Field({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.verticalSize * 0.5),
      child: PrimaryInputWidget(
        key: controller.formKey,
        validator: true,
        label: Strings.emailAddress,
        controller: controller.emailAddressController,
        hintText: Strings.emailAddress,
      ),
    );
  }
}
