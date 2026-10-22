part of '../screen/login_screen.dart';

class DoNotHaveAnAccount extends StatelessWidget {
  const DoNotHaveAnAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        TextWidget(
          Strings.alreadyHaveAnAccount,
          colorShade: ColorShade.mediumForty,
          typographyStyle: TypographyStyle.labelMedium,
          padding: Dimensions.horizontalSize.edgeHorizontal * 0.07,
        ),
        TextWidget(
          padding: EdgeInsets.only(left: Dimensions.horizontalSize * 0.1),
          Strings.registerNow,
          colorShade: ColorShade.mediumForty,
          typographyStyle: TypographyStyle.labelMedium,
          color: CustomColor.primary,
          fontWeight: FontWeight.w400,
          onTap: () => Get.offAllNamed(Routes.registerScreen),
        ),
      ],
    );
  }
}
