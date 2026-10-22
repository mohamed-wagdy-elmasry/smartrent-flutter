import '../../../base/localization/dynamic_language_shim.dart';
import 'package:flutter/material.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/utils/local_storage.dart';
import '../../../base/widgets/app_cached_image.dart';
import '../../../routes/routes.dart';
import '../../auth/login/controller/login_controller.dart';
import '../../common/html_screen.dart';
import '../../dashboard/controller/dashboard_controller.dart';
import '../../update_profile/widget/delete_pop.dart';
part 'drawer_tablet_screen.dart';
part 'drawer_mobile_screen.dart';
part '../widget/log_out_popup.dart';
part '../widget/items_list.dart';
part '../widget/profile_image_box.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: DrawerMobileScreen(),
      tablet: DrawerTabletScreen(),
    );
  }
}
