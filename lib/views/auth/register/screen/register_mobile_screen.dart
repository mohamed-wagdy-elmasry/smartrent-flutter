part of 'register_screen.dart';

class RegisterMobileScreen extends GetView<RegisterController> {
  const RegisterMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _bodyWidget(context));
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize,
        ),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              BrandLogo(),
              HeadingTextHeader(),
              RegisterInputFields(),
              CustomCheckboxWidget(),
              RegisterButton(),
              AlreadyAccountWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
