import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import '../../../../base/localization/dynamic_language_shim.dart';
import '../../../../base/utils/basic_import.dart';

class ChangeLanguageWidget extends StatelessWidget {
  const ChangeLanguageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.05 > 36
              ? 36
              : MediaQuery.of(context).size.height * 0.05,
          width: MediaQuery.of(context).size.width * 0.3 > 120
              ? 130
              : MediaQuery.of(context).size.width * 0.3,
          decoration: BoxDecoration(
            border: Border.all(color: CustomColor.disableColor, width: 1),
            borderRadius: BorderRadius.circular(Dimensions.radius / 0.5),
          ),
          child: DropdownButton2<String>(
            isExpanded: true,
            buttonStyleData: ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 8),
              height: 100,
            ),
            iconStyleData: IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: CustomColor.disableColor,
                size: 18,
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(color: CustomColor.background),
              maxHeight: MediaQuery.sizeOf(context).height * .25,
            ),
            value: DynamicLanguage.selectedLanguage.value,
            underline: SizedBox.shrink(),
            onChanged: (newValue) => DynamicLanguage.changeLanguage(newValue!),
            items: DynamicLanguage.languages
                .map(
                  (language) => DropdownMenuItem(
                    value: language.code,
                    child: TextWidget(
                      language.name,
                      color: CustomColor.blackColor,
                      fontSize: Dimensions.titleMedium * 0.75,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
