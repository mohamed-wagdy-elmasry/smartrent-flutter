import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../base/utils/dimensions.dart';
import '../../../../base/utils/responsive_layout.dart';
import '../../../../base/utils/size.dart';
import '../../../../base/widgets/custom_app_bar.dart';
import '../../../../base/widgets/primary_button.dart';
import '../../../../base/widgets/primary_input_widget.dart';
import '../../../../languages/strings.dart';
import '../controller/change_password_controller.dart';
part 'change_password_tablet_screen.dart';
part 'change_password_mobile_screen.dart';
part '../widget/password_input_field.dart';

class ChangePasswordScreen extends GetView<ChangePasswordController> {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: ChangePasswordMobileScreen(),
      tablet: ChangePasswordTabletScreen(),
    );
  }
}
