import 'package:carbo/base/widgets/text_widget.dart';
import 'package:flutter/material.dart';

import '../themes/token.dart';
import '../utils/dimensions.dart';
import '../utils/size.dart';

class DoubleSideTextWidget extends StatelessWidget {
  DoubleSideTextWidget({
    required this.keys,
    required this.value,
    this.rightWidget,
    this.image = '',
    this.keyStyle = TypographyStyle.labelSmall,
    this.valueStyle = TypographyStyle.labelSmall,
    this.fontWeight,
  });
  final String keys, value;
  final TypographyStyle keyStyle;
  final TypographyStyle valueStyle;
  final FontWeight? fontWeight;
  final String image;
  final Widget? rightWidget;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.verticalSize * 0.16),
      child: Row(
        children: [
          if (image != '')
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Dimensions.paddingSize * 0.45),
                  decoration: BoxDecoration(
                    color: CustomColor.background,
                    shape: BoxShape.circle,
                    image: DecorationImage(image: NetworkImage(image)),
                  ),
                ),
                Sizes.width.v5,
              ],
            ),
          Expanded(
            child: TextWidget(
              keys,
              typographyStyle: keyStyle,
              fontWeight: fontWeight,
            ),
          ),
          rightWidget ??
              Expanded(
                child: TextWidget(
                  value,
                  typographyStyle: valueStyle,
                  fontWeight: fontWeight,
                  textAlign: TextAlign.end,
                ),
              ),
        ],
      ),
    );
  }
}
