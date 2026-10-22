import 'package:get/get.dart';
import '../views/all_vendors_dashboard/controller/all_vendors_dashboard_controller.dart';

class AllVendorsDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AllVendorsDashboardController());
  }
}
