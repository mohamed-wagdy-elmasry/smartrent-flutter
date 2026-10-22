import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../base/api/services/auth_services.dart';

class ResetPasswordController extends GetxController {
  final emailAddressController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  RxBool isFormValid = false.obs;
  var userInputMail = ''.obs;

  void onInit() {
    emailAddressController.addListener(_updateFormValidity);
    super.onInit();
  }

  void _updateFormValidity() {
    isFormValid.value = emailAddressController.text.isNotEmpty;
  }

  @override
  void onClose() {
    try {
      emailAddressController.removeListener(_updateFormValidity);
    } catch (_) {}
    emailAddressController.dispose();
    super.onClose();
  }

  // Route
  get onForgotPassword => forgotPasswordProcess();
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  forgotPasswordProcess() {
    return AuthServices.forgotPasswordProcess(
      credentials: emailAddressController.text,
      isLoading: _isLoading,
    );
  }
}
