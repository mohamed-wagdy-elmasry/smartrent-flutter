import 'package:carbo/base/api/services/basic_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../base/themes/token.dart';
import '../../../../base/utils/dimensions.dart';
import '../../../../base/utils/responsive_layout.dart';
import '../../../../base/utils/size.dart';
import '../../../../base/widgets/custom_app_bar.dart';
import '../../../../base/widgets/custom_snackbar.dart';
import '../../../../base/widgets/primary_button.dart';
import '../../../../base/widgets/primary_input_widget.dart';
import '../../../../base/widgets/text_widget.dart';
import '../../../../languages/strings.dart';
import '../../login/screen/login_screen.dart';
import '../controller/register_controller.dart';
import '../widget/already_account.dart';
import '../widget/web_screen.dart';
part 'register_tablet_screen.dart';
part 'register_mobile_screen.dart';
part '../widget/heading_text_header.dart';
part '../widget/register_input_fields.dart';
part '../widget/check_box_widget.dart';
part '../widget/register_button.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: RegisterMobileScreen(),
      tablet: RegisterTabletScreen(),
    );
  }
}
