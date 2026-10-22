part of 'otp_verification_screen.dart';

class OtpVerificationTabletScreen extends GetView<OtpVerificationController> {
  const OtpVerificationTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('OtpVerification Tablet Screen'),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return const SafeArea(child: Column(children: []));
  }
}
