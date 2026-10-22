part of 'new_password_screen.dart';

class NewPasswordTabletScreen extends GetView<NewPasswordController> {
  const NewPasswordTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('NewPassword Tablet Screen'),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return const SafeArea(child: Column(children: []));
  }
}
