import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../base/api/services/auth_services.dart';
import '../../../../base/utils/phone_validator.dart';

class LoginController extends GetxController {
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  RxBool isFormValid = false.obs;
  RxString mobileCode = '+966'.obs;
  RxBool isMobileValid = false.obs;

  String? get normalizedMobile => PhoneValidator.getNormalizedForApi(
        rawInput: mobileController.text,
        dialCode: mobileCode.value,
      );

  get onLogInProcess => logInProcess();

  @override
  void onInit() {
    mobileController.addListener(_updateFormValidity);
    mobileController.addListener(_validateMobile);
    passwordController.addListener(_updateFormValidity);
    super.onInit();
  }

  @override
  void onClose() {
    try {
      mobileController.removeListener(_updateFormValidity);
      mobileController.removeListener(_validateMobile);
    } catch (_) {}
    try {
      passwordController.removeListener(_updateFormValidity);
    } catch (_) {}
    mobileController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void _validateMobile() {
    isMobileValid.value = PhoneValidator.isValid(
      rawInput: mobileController.text,
      dialCode: mobileCode.value,
    );
  }

  void _updateFormValidity() {
    isFormValid.value =
        mobileController.text.isNotEmpty &&
        isMobileValid.value &&
        passwordController.text.isNotEmpty;
  }

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  logInProcess() async {
    // Send full normalized number as credentials
    final credentials = normalizedMobile ??
        '${mobileCode.value}${mobileController.text}';

    return AuthServices.logInService(
      credentials: credentials,
      password: passwordController.text,
      isLoading: _isLoading,
    ).then((value) {
      mobileController.clear();
      passwordController.clear();
    });
  }

  logOutProcess() async {
    return AuthServices.logOutService(isLoading: _isLoading);
  }

  Future<bool> deleteAccountProcess() async {
    final result =
        await AuthServices.deleteAccountServices(isLoading: _isLoading);
    return result != null;
  }
}