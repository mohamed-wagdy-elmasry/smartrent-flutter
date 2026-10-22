import 'package:carbo/views/booking/controller/booking_controller.dart';
import 'package:carbo/controllers/wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:carbo/generated/l10n/app_localizations.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import '../../../base/widgets/dynamic_image_widget.dart';
import '../../../base/widgets/app_cached_image.dart';
import '../../../routes/routes.dart';
import '../controller/preview_controller.dart';
import '../model/manual_input_model.dart';
part 'preview_tablet_screen.dart';
part 'preview_mobile_screen.dart';
part '../widget/preview_section_card.dart';
part '../widget/get_manual_dynamic_input_field.dart';

class PreviewScreen extends GetView<PreviewController> {
  const PreviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: PreviewMobileScreen(),
      tablet: PreviewTabletScreen(),
    );
  }
}
