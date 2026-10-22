import 'package:cached_network_image/cached_network_image.dart';
import 'package:carbo/base/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../../../../base/api/services/basic_services.dart';
import '../../../../base/themes/token.dart';
import '../../../../base/utils/dimensions.dart';
import '../../../../base/utils/responsive_layout.dart';
import '../../../../base/utils/size.dart';
import '../../../../base/widgets/primary_button.dart';
import '../../../../base/widgets/primary_input_widget.dart';
import '../../../../base/widgets/text_widget.dart';
import '../../../../base/localization/dynamic_language_shim.dart';
import '../../../../languages/strings.dart';
import '../controller/otp_login_controller.dart';

part 'otp_login_tablet_screen.dart';
part 'otp_login_mobile_screen.dart';
part '../widget/brand_logo.dart';
part '../widget/heading_widget.dart';
part '../widget/mobile_input_widget.dart';
part '../widget/otp_input_widget.dart';
part '../widget/login_button.dart';
part '../widget/have_account_widget.dart';

class OtpLoginScreen extends GetView<OtpLoginController> {
  const OtpLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: OtpLoginMobileScreen(),
      tablet: OtpLoginTabletScreen(),
    );
  }
}
