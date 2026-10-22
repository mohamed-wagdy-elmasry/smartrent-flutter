part of '../screen/login_screen.dart';

class InputWidget extends GetView<LoginController> {
  const InputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mobile Number Input with Country Code Prefix
          PrimaryInputWidget(
            controller: controller.mobileController,
            label: Strings.mobileNumber,
            hintText: Strings.enterMobileNumber,
            textInputType: TextInputType.phone,
            showBorderSide: true,
            prefixIcon: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.mobileCode.value,
                  isDense: true,
                  items: [
                    DropdownMenuItem(value: '+966', child: Text('+966')),
                    DropdownMenuItem(value: '+20', child: Text('+20')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.mobileCode.value = value;
                    }
                  },
                ),
              ),
            ),
            suffixIcon: controller.isMobileValid.value
                ? Icon(Icons.check_circle, color: Colors.green)
                : null,
          ),
          Sizes.height.betweenInputBox,

          // OTP removed: password always shown
          PrimaryInputWidget(
            controller: controller.passwordController,
            label: Strings.password,
            hintText: Strings.password,
            isPasswordField: true,
            textInputType: TextInputType.text,
          ),
          _forgotPasswordWidget(context),

          // OTP removed: mode toggle removed

          Sizes.height.v30,
        ],
      ),
    );
  }

  _forgotPasswordWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: Dimensions.heightSize * 0.66),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () => Get.toNamed(Routes.reset_passwordScreen),
            child: TextWidget(
              Strings.forgotPassword,
              fontWeight: FontWeight.w400,
              color: CustomColor.primary,
              typographyStyle: TypographyStyle.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}
