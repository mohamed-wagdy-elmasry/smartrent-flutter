import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/dynamic_language_shim.dart';
import '../utils/basic_import.dart';

/// >>> Border Side Style
enum BSS {
  enabledBorder,
  b,
  disableBorder,
  focusedBorder,
  errorBorder,
  focusedErrorBorder,
}

enum BorderStyle { outline, underline, none }

class PrimaryInputWidget extends StatefulWidget {
  final String hintText, phoneCode;
  final String? label;
  final String? optionalText;
  final String? prefixIconPath;
  final int maxLines;
  final bool isValidator;
  final bool isPasswordField;
  final bool autoFocus;
  final bool readOnly;
  final bool isFilled;
  final bool showBorderSide;
  final bool validator;
  final bool showShape;
  final bool skipEnterText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? padding;
  final double? radius;
  final double borderWidth;
  final Color? fillColor;
  final Color? shadowColor;
  final Function(String)? onChanged;
  final Decoration? customShapeDecoration;
  final EdgeInsetsGeometry? customPadding;
  final TextEditingController controller;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final AlignmentGeometry? alignment;
  final EdgeInsets? suffixIconPadding;
  final BorderStyle borderStyle;
  final String? Function(String?)? validatorFunction;

  const PrimaryInputWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIconPath = "",
    this.phoneCode = "",
    this.isValidator = true,
    this.isPasswordField = false,
    this.isFilled = false,
    this.validator = false,
    this.autoFocus = false,
    this.readOnly = false,
    this.skipEnterText = false,
    this.showShape = true,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.borderWidth = 1,
    this.radius,
    this.customPadding,
    this.padding,
    this.label,
    this.optionalText,
    this.textInputType,
    this.inputFormatters,
    this.alignment,
    this.shadowColor,
    this.borderStyle = BorderStyle.outline,
    this.fillColor,
    this.validatorFunction,
    this.showBorderSide = true,
    this.customShapeDecoration,
    this.onChanged,
    this.suffixIconPadding,
  });

  @override
  State<PrimaryInputWidget> createState() => _PrimaryInputWidgetState();
}

class _PrimaryInputWidgetState extends State<PrimaryInputWidget> {
  FocusNode? focusNode;
  bool isVisibility = true;
  @override
  Widget build(BuildContext context) {
    // Guard: Obx in parent may trigger rebuild after controller is disposed
    // during navigation (e.g. back button while async operation completes)
    try {
      widget.controller.text;
    } catch (_) {
      return const SizedBox.shrink();
    }

    return widget.alignment != null
        ? Align(
            alignment: widget.alignment ?? Alignment.center,
            child: _buildTextFormFieldWidget(context),
          )
        : _buildTextFormFieldWidget(context);
  }

  @override
  void dispose() {
    focusNode!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  _buildDecoration() {
    return InputDecoration(
      hintText: DynamicLanguage.isLoading
          ? ''
          : widget.skipEnterText
          ? DynamicLanguage.key(widget.hintText)
          : "${DynamicLanguage.key(Strings.enter)} ${DynamicLanguage.key(widget.hintText)}",
      hintStyle: CustomStyle.bodyMedium.copyWith(
        fontWeight: FontWeight.w400,
        color: Colors.grey,
      ),
      border: _setBorderStyle(BSS.b),
      enabledBorder: _setBorderStyle(BSS.enabledBorder),
      focusedBorder: _setBorderStyle(BSS.focusedBorder),
      disabledBorder: _setBorderStyle(BSS.disableBorder),
      errorBorder: _setBorderStyle(BSS.errorBorder),
      focusedErrorBorder: _setBorderStyle(BSS.focusedErrorBorder),
      prefixIcon: _setPrefixIcon(),
      fillColor: _setFillColor(context),
      filled: _setFilled(),
      isDense: true,
      contentPadding: _setPadding(),
      suffixIcon: _setSuffixIcon(),
    );
  }

  _buildTextFormFieldWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: crossStart,
      children: [
        _buildTitle(),
        TextSelectionTheme(
          data: TextSelectionThemeData(
            selectionHandleColor: CustomColor.primary,
          ),
          child: TextFormField(
            readOnly: widget.readOnly,
            controller: widget.controller,
            focusNode: focusNode,
            autofocus: widget.autoFocus,
            style: _setFontStyle(),
            inputFormatters: widget.inputFormatters,
            obscureText: widget.isPasswordField ? isVisibility : false,
            textInputAction: TextInputAction.next,
            keyboardType: widget.textInputType,
            maxLines: widget.maxLines,
            decoration: _buildDecoration(),
            validator: widget.validatorFunction ?? _setValidator(),
            cursorColor: CustomColor.blackColor,
            onChanged: widget.onChanged,
            onTap: () {
              if (!widget.readOnly) {
                setState(() {
                  focusNode!.unfocus();
                  focusNode!.requestFocus();
                });
              }
            },
            onFieldSubmitted: (value) {
              if (!widget.readOnly) {
                setState(() {
                  focusNode!.unfocus();
                });
              }
            },
            onEditingComplete: () {
              if (!widget.readOnly) {
                setState(() {
                  focusNode!.unfocus();
                });
              }
            },
            onTapOutside: (value) {
              if (!widget.readOnly) {
                setState(() {
                  focusNode!.unfocus();
                });
              }
            },
          ),
        ),
      ],
    );
  }

  _buildTitle() {
    return widget.label != null
        ? Padding(
            padding: EdgeInsets.only(
              bottom: Dimensions.spaceBetweenInputTitleAndBox * 0.8,
            ),
            child: Row(
              mainAxisSize: mainMin,
              children: [
                TextWidget(
                  fontSize: Dimensions.titleMedium * 0.9,
                  widget.label!,
                  style: CustomStyle.labelSmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  color: Color(0xfff1D1D1D),
                ),
                if (widget.optionalText != '' && widget.optionalText != null)
                  Row(
                    children: [
                      Sizes.width.v5,
                      TextWidget(
                        widget.optionalText ?? '',
                        style: CustomStyle.labelSmall.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                        fontSize: Dimensions.titleMedium * 0.9,
                        color: CustomColor.primary,
                      ),
                    ],
                  ),
              ],
            ),
          )
        : Container();
  }

  _setBorderSide(borderSideStyle) {
    switch (borderSideStyle) {
      case BSS.enabledBorder:
        return BorderSide(width: widget.borderWidth, color: Colors.grey);
      case BSS.b:
        return BorderSide(width: widget.borderWidth, color: Colors.transparent);
      case BSS.disableBorder:
        return BorderSide(width: widget.borderWidth, color: Colors.transparent);
      case BSS.focusedBorder:
        return BorderSide(
          width: widget.borderWidth,
          color: CustomColor.primary,
        );
      case BSS.errorBorder:
        return BorderSide(width: widget.borderWidth, color: Colors.red);
      case BSS.focusedErrorBorder:
        return BorderSide(width: widget.borderWidth, color: Colors.red);
      default:
        return BorderSide(width: widget.borderWidth, color: Colors.transparent);
    }
  }

  _setBorderStyle(borderSideStyle) {
    switch (widget.borderStyle) {
      case BorderStyle.outline:
        return OutlineInputBorder(
          borderRadius: _setOutlineBorderRadius(),
          borderSide: widget.showBorderSide
              ? _setBorderSide(borderSideStyle)
              : BorderSide.none,
        );
      case BorderStyle.underline:
        return UnderlineInputBorder(
          borderRadius: _setOutlineBorderRadius(),
          borderSide: widget.showBorderSide
              ? _setBorderSide(borderSideStyle)
              : BorderSide.none,
        );

      case BorderStyle.none:
        return InputBorder.none;
    }
  }

  _setFillColor(BuildContext context) {
    return widget.fillColor ?? Theme.of(context).colorScheme.tertiary;
  }

  _setFilled() {
    return widget.isFilled;
  }

  _setFontStyle() {
    return CustomStyle.bodyLarge;
  }

  _setOutlineBorderRadius() {
    return BorderRadius.circular(widget.radius ?? Dimensions.radius * 0.5);
  }

  _setPadding() {
    return EdgeInsets.symmetric(
      horizontal: Dimensions.horizontalSize * 0.6,
      vertical: Dimensions.verticalSize * 0.5,
    );
  }

  _setPrefixIcon() {
    bool controllerHasText() {
      try {
        return widget.controller.text.isNotEmpty;
      } catch (_) {
        return false;
      }
    }

    return widget.prefixIcon ??
        (widget.prefixIconPath != ''
            ? Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSize * 0.4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomImageWidget(
                      path: widget.prefixIconPath!,
                      color: focusNode!.hasFocus || controllerHasText()
                          ? CustomColor.typography
                          : Get.isDarkMode
                              ? Colors.white
                              : CustomColor.disableColor,
                    ),
                    Visibility(
                      visible: widget.phoneCode != '',
                      child: Row(
                        children: [
                          Text(
                            widget.phoneCode,
                            style: TextStyle(
                              fontSize: Dimensions.headlineSmall,
                              fontWeight: FontWeight.w500,
                              color: focusNode!.hasFocus
                                  ? CustomColor.primary
                                  : CustomColor.typography.withValues(
                                      alpha: 0.2,
                                    ),
                            ),
                          ).marginOnly(left: Dimensions.horizontalSize * 0.3),
                          Container(
                            margin: EdgeInsets.only(
                              left: Dimensions.horizontalSize * 0.3,
                            ),
                            height: Dimensions.heightSize * 1.5,
                            width: 1,
                            color: focusNode!.hasFocus
                                ? CustomColor.primary
                                : CustomColor.typography.withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : null);
  }

  _setSuffixIcon() {
    return widget.isPasswordField
        ? IconButton(
            icon: Icon(
              isVisibility
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: focusNode!.hasFocus
                  ? CustomColor.typography
                  : Get.isDarkMode
                  ? CustomColor.typographyDark.withValues(alpha: 0.50)
                  : CustomColor.disableColor,
              size: Dimensions.iconSizeDefault,
            ),
            onPressed: () {
              setState(() {
                isVisibility = !isVisibility;
              });
            },
          )
        : widget.suffixIcon;
  }

  _setValidator() {
    return widget.isValidator == false
        ? null
        : (String? value) {
            if (value!.isEmpty) {
              return DynamicLanguage.key(Strings.pleaseFillOutTheField);
            } else {
              return null;
            }
          };
  }

  _buildShapeDecoration(BuildContext context) {
    return focusNode!.hasFocus
        ? widget.customShapeDecoration ??
              BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border.all(width: 1, color: CustomColor.blackColor),
                borderRadius: BorderRadius.circular(Dimensions.radius * 1.1),
              )
        : BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(width: 1, color: Color(0xffE8E8E8)),
            borderRadius: BorderRadius.circular(Dimensions.radius * 1.2),
          );
  }
}
