part of '../screen/otp_login_screen.dart';

class OtpLoginTabletScreen extends GetView<OtpLoginController> {
  const OtpLoginTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.background,
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
          child: ListView(
            children: [
              BrandLogo(),
              HeadingWidget(),
              Obx(() => controller.isOtpSent.value
                  ? OtpInputWidget()
                  : MobileInputWidget()),
              LoginButtonWidget(),
              Sizes.height.v30,
            ],
          ),
        ),
      ),
    );
  }
}
