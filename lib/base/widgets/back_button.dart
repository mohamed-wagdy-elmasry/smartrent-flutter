import 'package:carbo/base/utils/basic_import.dart';
import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({
    super.key,
    required this.onTap,
    this.isWhite = false,
  });

  final VoidCallback onTap;
  final bool isWhite;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(Dimensions.paddingSize * 0.25),
        decoration: BoxDecoration(
          color: CustomColor.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back_ios_new,
            size: Dimensions.iconSizeLarge * 0.65,
            color: CustomColor.whiteColor,
          ),
        ),
      ),
    );
  }
}
