part of 'change_password_screen.dart';

class ChangePasswordMobileScreen extends GetView<ChangePasswordController> {
  const ChangePasswordMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(centerTitle: false, Strings.changePassword),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize,
        ),
        children: [
          PasswordInputField(),
          Obx(
            () => PrimaryButton(
              isLoading: controller.isLoading,
              title: Strings.changePassword,
              disable: !controller.isFormValid.value,
              onPressed: () {
                if (controller.isFormValid.value) {
                  controller.changePasswordProcess();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
