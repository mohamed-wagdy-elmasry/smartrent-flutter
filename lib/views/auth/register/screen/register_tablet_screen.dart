part of 'register_screen.dart';

class RegisterTabletScreen extends GetView<RegisterController> {
  const RegisterTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('Register Tablet Screen'),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return const SafeArea(child: Column(children: []));
  }
}
