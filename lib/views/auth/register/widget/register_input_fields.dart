part of '../screen/register_screen.dart';

class RegisterInputFields extends GetView<RegisterController> {
  const RegisterInputFields({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: PrimaryInputWidget(
                  skipEnterText: true,
                  label: Strings.firstName,
                  controller: controller.firstNameController,
                  hintText: Strings.firstName,
                ),
              ),
              Sizes.width.v10,
              Expanded(
                child: PrimaryInputWidget(
                  skipEnterText: true,
                  label: Strings.lastName,
                  controller: controller.lastNameController,
                  hintText: Strings.lastName,
                ),
              ),
            ],
          ),
          Sizes.height.v10,

          // Mobile Number Input with Country Code Prefix
          PrimaryInputWidget(
            controller: controller.mobileController,
            label: Strings.mobileNumber,
            hintText: Strings.enterMobileNumber,
            textInputType: TextInputType.phone,
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

          // OTP removed: verification badge/button removed
          Sizes.height.v10,
          PrimaryInputWidget(
            label: '${Strings.emailAddress} (${Strings.optional})',
            controller: controller.emailAddressController,
            hintText: Strings.emailAddress,
            textInputType: TextInputType.emailAddress,
          ),
          Sizes.height.v10,
          PrimaryInputWidget(
            isPasswordField: true,
            label: Strings.password,
            controller: controller.passwordController,
            hintText: Strings.password,
          ),
        ],
      ),
    );
  }
}
