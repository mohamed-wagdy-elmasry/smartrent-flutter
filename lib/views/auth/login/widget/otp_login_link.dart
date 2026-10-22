part of '../screen/login_screen.dart';

class LoginWithOtpWidget extends StatelessWidget {
  const LoginWithOtpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.verticalSize),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 1,
            width: 50,
            color: Colors.grey.shade300,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: TextWidget(
              'OR',
              colorShade: ColorShade.mediumForty,
              typographyStyle: TypographyStyle.bodySmall,
            ),
          ),
          Container(
            height: 1,
            width: 50,
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}

class OtpLoginLinkWidget extends StatelessWidget {
  const OtpLoginLinkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () {
          Get.toNamed(Routes.otpLoginScreen);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.horizontalSize,
            vertical: Dimensions.verticalSize * 0.5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sms_outlined, color: CustomColor.primary, size: 20),
              SizedBox(width: 8),
              TextWidget(
                Strings.loginWithOtp,
                color: CustomColor.primary,
                fontWeight: FontWeight.w600,
                typographyStyle: TypographyStyle.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
