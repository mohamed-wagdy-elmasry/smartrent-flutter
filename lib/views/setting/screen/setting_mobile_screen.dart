part of 'setting_screen.dart';

class SettingMobileScreen extends GetView<SettingController> {
  const SettingMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: BackButtonWidget(
          onTap: () {
            Get.offAllNamed(Routes.dashboardScreen);
          },
        ),
        centerTitle: false,
        Strings.setting,
      ),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: Column(children: [Sizes.height.v20, LanguageChangeWidget()]),
    );
  }
}
