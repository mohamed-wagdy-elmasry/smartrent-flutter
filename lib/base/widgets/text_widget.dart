import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../themes/model.dart';
import '../themes/token.dart';
import '../utils/custom_style.dart';
import '../localization/dynamic_language_shim.dart';

class TextWidget extends StatelessWidget {
  const TextWidget(
    this.text, {
    super.key,
    this.textAlign,
    this.textOverflow,
    this.padding = paddingValue,
    this.opacity = 1.0,
    this.maxLines,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.style,
    this.onTap,
    this.colorShade = ColorShade.full,
    this.typographyStyle = TypographyStyle.titleMedium,
  });

  final String text;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;
  final EdgeInsetsGeometry padding;
  final double opacity;
  final int? maxLines;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextStyle? style;
  final TypographyStyle typographyStyle;
  final ColorShade colorShade;
  final VoidCallback? onTap;
  static const paddingValue = EdgeInsets.all(0.0);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = DynamicLanguage.isLoading;
      DynamicLanguage.selectedLanguage.value;

      final displayText = isLoading ? '' : DynamicLanguage.key(text);

      return InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Opacity(
          opacity: opacity,
          child: Padding(
            padding: padding,
            child: Text(
              displayText,
              style: style != null
                  ? style!.copyWith(
                      color: color ?? _color(colorShade),
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                    )
                  : style ??
                        _style(typographyStyle).copyWith(
                          color: color ?? _color(colorShade),
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                        ),
              textAlign: textAlign,
              overflow: textOverflow,
              maxLines: maxLines,
              textScaler: TextScaler.linear(ScreenUtil().textScaleFactor),
            ),
          ),
        ),
      );
    });
  }
}

TextStyle _style(TypographyStyle typographyStyle) {
  switch (typographyStyle) {
    case TypographyStyle.displayLarge:
      return CustomStyle.displayLarge;
    case TypographyStyle.displayMedium:
      return CustomStyle.displayMedium;
    case TypographyStyle.displaySmall:
      return CustomStyle.displaySmall;

    case TypographyStyle.headlineLarge:
      return CustomStyle.headlineLarge;
    case TypographyStyle.headlineMedium:
      return CustomStyle.headlineMedium;
    case TypographyStyle.headlineSmall:
      return CustomStyle.headlineSmall;

    case TypographyStyle.titleLarge:
      return CustomStyle.titleLarge;
    case TypographyStyle.titleMedium:
      return CustomStyle.titleMedium;
    case TypographyStyle.titleSmall:
      return CustomStyle.titleSmall;

    case TypographyStyle.bodyLarge:
      return CustomStyle.bodyLarge;
    case TypographyStyle.bodyMedium:
      return CustomStyle.bodyMedium;
    case TypographyStyle.bodySmall:
      return CustomStyle.bodySmall;

    case TypographyStyle.labelLarge:
      return CustomStyle.labelLarge;
    case TypographyStyle.labelMedium:
      return CustomStyle.labelMedium;
    case TypographyStyle.labelSmall:
      return CustomStyle.labelSmall;
  }
}

Color? _color(ColorShade colorShade) {
  CSM shade = Get.isDarkMode
      ? CustomColor.typographyDarkShade
      : CustomColor.typographyShade;

  switch (colorShade) {
    case ColorShade.full:
      return shade.full;
    case ColorShade.highEighty:
      return shade.highEighty;
    case ColorShade.highSeventy:
      return shade.highSeventy;
    case ColorShade.mediumSixty:
      return shade.mediumSixty;
    case ColorShade.mediumFifty:
      return shade.mediumFifty;
    case ColorShade.mediumForty:
      return shade.mediumForty;
    case ColorShade.lowThirty:
      return shade.lowThirty;
    case ColorShade.lowTwenty:
      return shade.lowTwenty;
    case ColorShade.lowTen:
      return shade.lowTen;
    case ColorShade.zero:
      return shade.zero;

    default:
      return shade.full;
  }
}

enum TypographyStyle {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}

enum ColorShade {
  full,
  highNinety,
  highEighty,
  highSeventy,
  mediumSixty,
  mediumFifty,
  mediumForty,
  lowThirty,
  lowTwenty,
  lowTen,
  lowFive,
  zero,
}
