import 'package:carbo/routes/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../base/api/endpoint/api_endpoint.dart';
import '../../../../base/api/method/request_process.dart';
import '../../../../base/api/model/common_success_model.dart';

class ChangePasswordController extends GetxController {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  RxBool isFormValid = false.obs;

  @override
  void onInit() {
    oldPasswordController.addListener(_updateFormValidity);
    newPasswordController.addListener(_updateFormValidity);
    confirmPasswordController.addListener(_updateFormValidity);
    super.onInit();
  }

  @override
  void onClose() {
    try {
      oldPasswordController.removeListener(_updateFormValidity);
    } catch (_) {}
    try {
      newPasswordController.removeListener(_updateFormValidity);
    } catch (_) {}
    try {
      confirmPasswordController.removeListener(_updateFormValidity);
    } catch (_) {}

    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void _updateFormValidity() {
    isFormValid.value =
        oldPasswordController.text.isNotEmpty &&
        newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty;
  }

  // Change password process
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  late CommonSuccessModel _commonSuccessModel;

  CommonSuccessModel get commonSuccessModel => _commonSuccessModel;

  Future<CommonSuccessModel?> changePasswordProcess() async {
    Map<String, dynamic> inputBody = {
      'current_password': oldPasswordController.text,
      'password': newPasswordController.text,
      'password_confirmation': confirmPasswordController.text,
    };

    return RequestProcess().request<CommonSuccessModel>(
      fromJson: CommonSuccessModel.fromJson,
      apiEndpoint: ApiEndpoint.updatePassword,
      isLoading: _isLoading,
      method: HttpMethod.POST,
      body: inputBody,
      showSuccessMessage: true,
      onSuccess: (value) {
        _commonSuccessModel = value!;
        _clearInputField();
        Get.offAllNamed(Routes.dashboardScreen);
      },
    );
  }

  _clearInputField() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }
}
