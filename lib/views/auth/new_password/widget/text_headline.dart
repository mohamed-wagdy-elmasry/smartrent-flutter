part of '../screen/new_password_screen.dart';

class TextHeadline extends GetView<NewPasswordController> {
  const TextHeadline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Sizes.height.v40,
        TextWidget(
          fontSize: Dimensions.titleMedium * 1.2,
          textAlign: TextAlign.center,
          padding: EdgeInsets.symmetric(
            vertical: Dimensions.verticalSize * 0.2,
          ),
          maxLines: 1,
          Strings.resetPasswordTile,
          fontWeight: FontWeight.bold,
        ),
        TextWidget(
          textAlign: TextAlign.center,
          padding: EdgeInsets.only(bottom: Dimensions.verticalSize * 1.5),
          color: CustomColor.blackColor.withValues(alpha: 0.5),
          Strings.resetPasswordDes,
          fontSize: Dimensions.titleSmall * 0.95,
          maxLines: 3,
        ),
      ],
    );
  }
}
