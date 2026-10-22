part of 'splash_screen.dart';

class SplashMobileScreen extends GetView<SplashController> {
  const SplashMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _bodyWidget(context));
  }

  _bodyWidget(BuildContext context) {
    return Obx(
      () => BasicServices.isLoading
          ? Loader()
          : SafeArea(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [Positioned.fill(child: SplashImage())],
              ),
            ),
    );
  }
}
