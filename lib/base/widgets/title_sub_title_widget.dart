import 'package:flutter/material.dart';

import '../utils/basic_import.dart';

class TitleSubTitleWidget extends StatelessWidget {
  const TitleSubTitleWidget({
    super.key,
    required this.title,
    required this.subTitle,
    this.titleFontSize, // Added parameter
    this.subTitleFontSize,
    this.titleColor,
    this.subTitleColor,
    this.isCenterText = false,
  });
  final String title, subTitle;
  final double? titleFontSize; // Added parameter
  final double? subTitleFontSize;
  final Color? titleColor, subTitleColor;
  final bool isCenterText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isCenterText ? crossCenter : crossStart,
      mainAxisAlignment: isCenterText ? mainCenter : mainCenter,
      children: [
        TextWidget(
          title,
          color: CustomColor.primary,
          fontWeight: FontWeight.w500,
          fontSize: titleFontSize, // Use the new parameter
          textAlign: isCenterText ? TextAlign.center : TextAlign.start,
          typographyStyle: TypographyStyle.headlineSmall,
        ),
        Sizes.height.btnInputTitleAndBox,
        Visibility(
          visible: subTitle != '',
          child: TextWidget(
            subTitle,
            color: CustomColor.blackColor.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
            textAlign: isCenterText ? TextAlign.center : TextAlign.start,
            fontSize: Dimensions.titleSmall,
          ),
        ),
      ],
    );
  }
}
