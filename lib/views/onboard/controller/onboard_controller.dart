import 'package:carbo/base/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';

class OnboardController extends GetxController {
  RxInt selectedIndex = 0.obs;

  get onLogIn => Routes.otpLoginScreen.toNamed; // Default to OTP login
  get onRegistration => Routes.registerScreen.toNamed;

  final pageController = PageController();

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
