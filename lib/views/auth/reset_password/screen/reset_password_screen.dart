import 'package:carbo/base/utils/basic_import.dart';
import 'package:flutter/material.dart';
import '../controller/reset_password_controller.dart';
part 'reset_password_tablet_screen.dart';
part 'reset_password_mobile_screen.dart';
part '../widget/heading_text.dart';
part '../widget/field.dart';
part '../widget/button_and_text.dart';

class ResetPasswordScreen extends GetView<ResetPasswordController> {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: ResetPasswordMobileScreen(),
      tablet: ResetPasswordTabletScreen(),
    );
  }
}
