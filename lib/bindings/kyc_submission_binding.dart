import 'package:get/get.dart';
import '../views/kyc_submission/controller/kyc_submission_controller.dart';

class KycSubmissionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => KycSubmissionController());
  }
}
