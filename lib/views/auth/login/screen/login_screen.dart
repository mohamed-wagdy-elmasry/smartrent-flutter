import 'package:cached_network_image/cached_network_image.dart';
import 'package:carbo/base/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../base/api/services/basic_services.dart';
import '../../../../base/themes/token.dart';
import '../../../../base/utils/dimensions.dart';
import '../../../../base/utils/responsive_layout.dart';
import '../../../../base/utils/size.dart';
import '../../../../base/widgets/custom_app_bar.dart';
import '../../../../base/widgets/primary_button.dart';
import '../../../../base/widgets/primary_input_widget.dart';
import '../../../../base/widgets/text_widget.dart';
import '../../../../languages/strings.dart';
import '../../../../routes/routes.dart';
import '../controller/login_controller.dart';
part 'login_tablet_screen.dart';
part 'login_mobile_screen.dart';
part '../widget/brand_logo.dart';
part '../widget/heading_widget.dart';
part '../widget/input_widget.dart';
part '../widget/login_button.dart';
part '../widget/do_not_have_an_account.dart';
part '../widget/otp_login_link.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: LoginMobileScreen(),
      tablet: LoginTabletScreen(),
    );
  }
}
