part of '../screen/register_screen.dart';

class HeadingTextHeader extends GetView<RegisterController> {
  const HeadingTextHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.verticalSize),
      child: Column(
        children: [
          FittedBox(
            child: TextWidget(
              padding: EdgeInsets.only(bottom: Dimensions.verticalSize * 0.1),
              Strings.logInTitleText,
              fontWeight: FontWeight.bold,
              typographyStyle: TypographyStyle.headlineSmall,
            ),
          ),
          TextWidget(
            Strings.logInDescriptionText,
            textAlign: TextAlign.start,
            maxLines: 3,
            fontWeight: FontWeight.w400,
            typographyStyle: TypographyStyle.labelLarge,
            colorShade: ColorShade.mediumForty,
            padding: EdgeInsets.only(right: Dimensions.horizontalSize * 0.1),
          ),
        ],
      ),
    );
  }
}
