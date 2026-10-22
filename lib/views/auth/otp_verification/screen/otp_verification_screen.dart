import 'package:carbo/base/extensions/extensions.dart';
import 'package:carbo/base/utils/size.dart';
import 'package:carbo/views/auth/reset_password/controller/reset_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../base/themes/token.dart';
import '../../../../base/utils/dimensions.dart';
import '../../../../base/utils/responsive_layout.dart';
import '../../../../base/widgets/custom_app_bar.dart';
import '../../../../base/widgets/otp_input_field.dart';
import '../../../../base/widgets/primary_button.dart';
import '../../../../base/widgets/text_widget.dart';
import '../../../../base/widgets/timer_widget.dart';
import '../../../../languages/strings.dart';
import '../controller/otp_verification_controller.dart';
part 'otp_verification_tablet_screen.dart';
part 'otp_verification_mobile_screen.dart';
part '../widget/header_text.dart';
part '../widget/submit_button.dart';
part '../widget/resend_text.dart';

class OtpVerificationScreen extends GetView<OtpVerificationController> {
  const OtpVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: OtpVerificationMobileScreen(),
      tablet: OtpVerificationTabletScreen(),
    );
  }
}
