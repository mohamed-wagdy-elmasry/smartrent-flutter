import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../assets/assets.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import '../../../base/utils/basic_import.dart';
import '../../../routes/routes.dart';
import '../controller/congratulations_controller.dart';

part 'congratulations_mobile_screen.dart';
part 'congratulations_tablet_screen.dart';

class CongratulationsScreen extends StatelessWidget {
  CongratulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const CongratulationsMobileScreen(),
      tablet: const CongratulationsTabletScreen(),
    );
  }
}
