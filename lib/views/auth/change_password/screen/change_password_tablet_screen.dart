part of 'change_password_screen.dart';

class ChangePasswordTabletScreen extends GetView<ChangePasswordController> {
  const ChangePasswordTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('ChangePassword Tablet Screen'),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return const SafeArea(child: Column(children: []));
  }
}
