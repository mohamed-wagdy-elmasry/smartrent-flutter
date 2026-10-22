part of '../screen/otp_login_screen.dart';

class MobileInputWidget extends GetView<OtpLoginController> {
  const MobileInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: CustomColor.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            TextWidget(
              Strings.mobileNumber,
              fontWeight: FontWeight.w600,
              typographyStyle: TypographyStyle.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Phone input
        PrimaryInputWidget(
          controller: controller.mobileController,
          hintText: Strings.enterMobileNumber,
          textInputType: TextInputType.phone,
          showBorderSide: true,
          prefixIcon: CountryCodePicker(
            onChanged: (country) {
              controller.mobileCode.value = country.dialCode ?? '+966';
            },
            initialSelection: 'SA',
            favorite: const ['+966', '+20', '+971', '+1'],
            showCountryOnly: false,
            showOnlyCountryWhenClosed: false,
            alignLeft: false,
            padding: EdgeInsets.zero,
          ),
          suffixIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: controller.isMobileValid.value
                ? Container(
                    key: const ValueKey('valid'),
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _C.successGreen.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded, color: _C.successGreen, size: 18),
                  )
                : const SizedBox.shrink(key: ValueKey('invalid')),
          ),
        ),
        const SizedBox(height: 20),
      ],
    ));
  }
}
