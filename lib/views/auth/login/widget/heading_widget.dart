part of '../screen/login_screen.dart';

class HeadingWidget extends StatelessWidget {
  const HeadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.verticalSize),
      child: Column(
        crossAxisAlignment: crossStart,
        children: [
          FittedBox(
            child: TextWidget(
              padding: EdgeInsets.only(bottom: Dimensions.verticalSize * 0.1),
              textAlign: TextAlign.center,
              Strings.logInTitleText,
              fontWeight: FontWeight.bold,
              typographyStyle: TypographyStyle.titleLarge,
            ),
          ),
          TextWidget(
            maxLines: 3,
            Strings.logInDescriptionText,
            fontWeight: FontWeight.w400,
            typographyStyle: TypographyStyle.labelLarge,
            colorShade: ColorShade.mediumForty,
          ),
        ],
      ),
    );
  }
}
