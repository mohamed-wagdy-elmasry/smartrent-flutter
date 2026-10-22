import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../base/api/services/auth_services.dart';

class NewPasswordController extends GetxController {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  get onResetPasswordSubmit => resetPasswordProcess();

  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  resetPasswordProcess() async {
    return AuthServices.resetPasswordProcess(
      password: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
      isLoading: _isLoading,
    );
  }
}
