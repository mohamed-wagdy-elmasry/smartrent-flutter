import 'package:carbo/base/themes/token.dart';
import 'package:flutter/material.dart';

import '../../../base/widgets/text_widget.dart';
import '../../../languages/strings.dart';

class AppVersion extends StatelessWidget {
  const AppVersion({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextWidget(
          Strings.appName,
          fontWeight: FontWeight.bold,
          color: CustomColor.primary,
          typographyStyle: TypographyStyle.titleLarge,
        ),
      ],
    );
  }
}
