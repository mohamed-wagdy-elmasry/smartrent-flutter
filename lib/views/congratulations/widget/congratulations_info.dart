import 'package:carbo/base/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../base/utils/dimensions.dart';
import '../../../base/widgets/title_sub_title_widget.dart';
import '../controller/congratulations_controller.dart';

class CongratulationsInfo extends StatelessWidget {
  const CongratulationsInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Dimensions.horizontalSize.edgeHorizontal,
      child: TitleSubTitleWidget(
        title: Get.find<CongratulationsController>()
            .congratulationDetails
            .value
            .type,
        subTitle:
            '${Get.find<CongratulationsController>().congratulationDetails.value.details}',
        isCenterText: true,
      ),
    );
  }
}
