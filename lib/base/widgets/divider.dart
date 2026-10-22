import 'package:flutter/material.dart';

import '../themes/token.dart';

class DividerWidget extends StatelessWidget {
  DividerWidget({super.key, this.padding = EdgeInsets.zero});
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Divider(
        color: CustomColor.disableColor.withValues(alpha: .4),
        thickness: 0.8,
      ),
    );
  }
}
