import 'package:carbo/views/auth/register/controller/register_controller.dart';
import 'package:get/get.dart';
import '../base/api/services/basic_services.dart';
import '../views/splash/controller/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    BasicServices.getBasicSettingsInfo();
    Get.put(SplashController());
    Get.lazyPut(() => RegisterController());
  }
}
