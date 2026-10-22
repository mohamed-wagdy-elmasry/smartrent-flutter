part of 'onboard_screen.dart';

class OnboardMobileScreen extends GetView<OnboardController> {
  const OnboardMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.whiteColor,
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _clipViewWidget(context),
          _otherWidget(context),
          Positioned(
            top: Dimensions.verticalSize,
            left: Dimensions.defaultHorizontalSize,
            right: Dimensions.defaultHorizontalSize,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => CachedNetworkImage(
                    imageUrl: BasicServices.appBasicLogoWhite.value,
                    placeholder: (context, url) => const Text(''),
                    errorWidget: (context, url, error) => const Text(''),
                    height: MediaQuery.of(context).size.height * 0.035,
                  ),
                ),
                ChangeLanguageWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _otherWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimensions.horizontalSize * 0.8),
      child: Column(
        mainAxisSize: mainMin,
        crossAxisAlignment: crossStart,
        children: [_contentWidget(context), _buttonWidget(context)],
      ),
    );
  }

  _clipViewWidget(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PageView.builder(
          controller: controller.pageController,
          itemCount: BasicServices.onboardScreen.length,
          itemBuilder: (BuildContext context, int index) {
            var data = BasicServices.onboardScreen[index];
            return CachedNetworkImage(
              height: MediaQuery.of(context).size.height,
              imageUrl:
                  "${BasicServices.basePath.value}/${BasicServices.pathLocation.value}/${data.image}",
              placeholder: (context, url) => Container(),
              errorWidget: (context, url, error) => Container(),
              fit: BoxFit.cover,
            );
          },
          onPageChanged: (v) {
            controller.selectedIndex.value = v;
          },
        ),
      ],
    );
  }

  _contentWidget(BuildContext context) {
    return Obx(
      () => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Dimensions.verticalSize),
          child: Column(
            crossAxisAlignment: crossCenter,
            children: [
              TextWidget(
                BasicServices
                    .onboardScreen[controller.selectedIndex.value]
                    .title,
                fontWeight: FontWeight.w700,
                fontSize: Dimensions.headlineSmall * 0.9,
              ),
              TextWidget(
                padding: EdgeInsets.only(top: Dimensions.verticalSize * 0.2),
                textAlign: TextAlign.center,
                maxLines: 2,
                BasicServices
                    .onboardScreen[controller.selectedIndex.value]
                    .subTitle!,
                fontSize: Dimensions.labelLarge * 0.9,
                colorShade: ColorShade.mediumSixty,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buttonWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.verticalSize * 1.6),
      child: Column(
        children: [
          PrimaryButton(
            title: Strings.loginNow,
            onPressed: () {
              Get.offAllNamed(Routes.otpLoginScreen);
            },
          ),
          Sizes.height.v10,
          if (BasicServices.userIsRegister.value == 1)
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                TextWidget(
                  Strings.newToCarbo,
                  colorShade: ColorShade.mediumForty,
                  typographyStyle: TypographyStyle.labelMedium,
                  padding: Dimensions.horizontalSize.edgeHorizontal * 0.07,
                ),
                TextWidget(
                  padding: EdgeInsets.only(
                    left: Dimensions.horizontalSize * 0.1,
                  ),
                  Strings.registerNow,
                  colorShade: ColorShade.mediumForty,
                  typographyStyle: TypographyStyle.labelMedium,
                  color: CustomColor.primary,
                  fontWeight: FontWeight.w400,
                  onTap: () {
                    Get.offAllNamed(Routes.registerScreen);
                    // controller.onLogIn;
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
