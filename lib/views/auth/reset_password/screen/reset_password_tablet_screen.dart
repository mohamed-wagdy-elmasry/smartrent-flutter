part of 'reset_password_screen.dart';

class ResetPasswordTabletScreen extends GetView<ResetPasswordController> {
  const ResetPasswordTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('ResetPassword Tablet Screen'),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return const SafeArea(child: Column(children: []));
  }
}
