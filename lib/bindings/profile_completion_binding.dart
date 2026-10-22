import 'package:get/get.dart';
import '../views/profile_completion/controller/profile_completion_controller.dart';

class ProfileCompletionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileCompletionController());
  }
}
