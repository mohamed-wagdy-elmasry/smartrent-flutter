import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../base/themes/token.dart';
import '../../../../base/utils/dimensions.dart';
import '../../../../base/utils/responsive_layout.dart';
import '../../../../base/utils/size.dart';
import '../../../../base/widgets/custom_app_bar.dart';
import '../../../../base/widgets/primary_button.dart';
import '../../../../base/widgets/primary_input_widget.dart';
import '../../../../base/widgets/text_widget.dart';
import '../../../../languages/strings.dart';
import '../controller/new_password_controller.dart';
part 'new_password_tablet_screen.dart';
part 'new_password_mobile_screen.dart';
part '../widget/new_pass_input_fields.dart';
part '../widget/confirm_button.dart';
part '../widget/text_headline.dart';

class NewPasswordScreen extends GetView<NewPasswordController> {
  const NewPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: NewPasswordMobileScreen(),
      tablet: NewPasswordTabletScreen(),
    );
  }
}
