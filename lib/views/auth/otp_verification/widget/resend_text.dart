part of '../screen/otp_verification_screen.dart';

class ResendText extends GetView<OtpVerificationController> {
  const ResendText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        TextWidget(fontSize: Dimensions.titleSmall, Strings.didntGetTheCode),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          // onTap: () => Get.toNamed(Routes.registerScreen),
          child: TextWidget(
            padding: EdgeInsets.only(left: Dimensions.horizontalSize * 0.2),
            color: CustomColor.rejected,
            Strings.Resend,
            fontWeight: FontWeight.w500,
            fontSize: Dimensions.titleSmall,
          ),
        ),
      ],
    );
  }
}
