import 'package:get/get.dart';
import '../views/vendor_cars/controller/vendor_cars_controller.dart';

/// Binding for VendorCarsScreen
/// Registers the VendorCarsController with GetX dependency injection
class VendorCarsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VendorCarsController());
  }
}
