part of 'new_password_screen.dart';

class NewPasswordMobileScreen extends GetView<NewPasswordController> {
  const NewPasswordMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: CustomAppBar(''), body: _bodyWidget(context));
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize,
        ),
        child: ListView(
          children: [TextHeadline(), NewPassInputFields(), ConfirmButton()],
        ),
      ),
    );
  }
}
