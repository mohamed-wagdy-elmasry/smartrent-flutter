import 'package:get/get.dart';

import '../model/congratulations_model.dart';

class CongratulationsController extends GetxController {
  late Rx<Congratulation> congratulationDetails;
  late RxString route;
  late RxString buttonText;
  
  @override
  void onInit() {
    super.onInit();
    // Safely get arguments with fallback
    final args = Get.arguments;
    if (args != null && args is Congratulation) {
      congratulationDetails = args.obs;
      route = args.route.obs;
      buttonText = args.buttonText.obs;
    } else {
      // Fallback values
      congratulationDetails = Congratulation(
        details: 'Operation completed successfully',
        route: '/dashboardScreen',
        buttonText: 'Go to Home',
        type: 'success',
      ).obs;
      route = '/dashboardScreen'.obs;
      buttonText = 'Go to Home'.obs;
    }
  }
}
