// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import '../utils/basic_import.dart';

class PrimaryButton extends StatelessWidget {
  PrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.borderColor,
    this.borderWidth = 0,
    this.height,
    this.buttonColor,
    this.buttonTextColor,
    this.shape,
    this.icon,
    this.fontSize,
    this.fontWeight,
    this.isLoading = false,
    this.primary = false,
    this.disable = false,
  });

  final String title;
  final VoidCallback onPressed;
  final Color? borderColor;
  final double borderWidth;
  final double? height;
  final Color? buttonColor;
  final Color? buttonTextColor;
  final OutlinedBorder? shape;
  final Widget? icon;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool isLoading;
  final bool primary;
  final bool disable;
  ValueNotifier<bool> isPadding = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Loader()
        : ValueListenableBuilder<bool>(
            valueListenable: isPadding,
            builder: (context, value, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  horizontal: isPadding.value ? 5 : 0,
                ),
                height: height ?? Dimensions.buttonHeight * 0.8,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: disable
                      ? null
                      : () {
                          isPadding.value = !isPadding.value;
                          Future.delayed(const Duration(milliseconds: 220), () {
                            isPadding.value = !isPadding.value;
                          });
                          onPressed();
                        },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape:
                        shape ??
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius * 1.2,
                          ),
                        ),
                    backgroundColor:
                        (disable ? CustomColor.disableColor : buttonColor) ??
                        CustomColor.primary,
                    side: BorderSide(
                      width: borderWidth,
                      color: disable
                          ? CustomColor.disableColor
                          : borderColor ?? CustomColor.primary,
                    ),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    child: TextWidget(
                      title,
                      fontSize: isPadding.value
                          ? Dimensions.titleMedium * 0.95
                          : fontSize ?? Dimensions.titleMedium,
                      fontWeight: fontWeight ?? FontWeight.w700,
                      color: primary
                          ? CustomColor.primary
                          : buttonTextColor ?? Colors.white,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          );
  }
}
