import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../assets/assets.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/widgets/divider.dart';
import '../../../base/widgets/double_side_text_widget.dart';
import '../controller/congratulations_controller.dart';
import 'congratulations_info.dart';

class CongratulationsMain extends StatelessWidget {
  const CongratulationsMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildStatusIcon(), const CongratulationsInfo()]);
  }

  Widget _buildDivider() {
    return DividerWidget(
      padding: EdgeInsets.symmetric(vertical: Dimensions.verticalSize * 0.2),
    );
  }

  Widget _buildInfoRow(String key, String value) {
    return DoubleSideTextWidget(
      keys: key,
      value: value,
      valueStyle: TypographyStyle.bodyMedium,
    );
  }

  Widget _buildStatusIcon() {
    final controller = Get.find<CongratulationsController>();
    final isSuccess = controller.congratulationDetails.value.type.toLowerCase().contains('success') ||
                      controller.congratulationDetails.value.type.toLowerCase().contains('payment') ||
                      controller.congratulationDetails.value.type.toLowerCase().contains('confirm');
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.verticalSize * 0.6),
      child: SvgPicture.asset(
        isSuccess ? Assets.icons.success : Assets.icons.reject,
        height: Dimensions.heightSize * 12,
      ),
    );
  }
}
