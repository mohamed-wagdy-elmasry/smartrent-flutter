import 'package:flutter/material.dart';
import '../../../../base/utils/basic_import.dart';
import 'card_type_widget.dart';
import 'language_dropdown.dart';

class LanguageChangeWidget extends StatelessWidget {
  const LanguageChangeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
      ),
      child: CardTypeWidget(
        title: Strings.language,
        description: '',
        icon: Icons.g_translate,
        onTap: () {},
        child: ChangeLanguageWidget(),
      ),
    );
  }
}
