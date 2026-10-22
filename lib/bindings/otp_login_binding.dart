import 'package:get/get.dart';
import '../views/auth/otp_login/controller/otp_login_controller.dart';

class OtpLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OtpLoginController());
  }
}
