import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import '../../../base/utils/dimensions.dart';
import '../../../base/widgets/dynamic_image_widget.dart';
import '../../../base/widgets/primary_input_widget.dart';
import '../../../base/widgets/text_widget.dart';
import '../../preview/model/manual_input_model.dart';

void getManualReDynamicInputField({
  required List<InputField> data,
  required List<TextEditingController> inputFieldControllers,
  required RxList<dynamic> inputFields,
  required RxList<dynamic> inputFileFields,
  required RxBool hasFile,
  required RxString selectType,
}) {
  for (int item = 0; item < data.length; item++) {
    var textEditingController = TextEditingController();
    inputFieldControllers.add(textEditingController);

    if (data[item].type.contains('file')) {
      hasFile.value = true;
      inputFileFields.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(data[item].label),
            SizedBox(height: Dimensions.spaceBetweenInputTitleAndBox),
            DynamicImageWidget(
              labelName: data[item].label,
              fieldName: data[item].name,
            ),
          ],
        ),
      );
    } else if (data[item].type.contains('text')) {
      inputFields.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Dimensions.spaceBetweenInputTitleAndBox),
            PrimaryInputWidget(
              controller: textEditingController,
              hintText: '${data[item].label}',
              label: data[item].label,
            ),
          ],
        ),
      );
    }
  }
}
