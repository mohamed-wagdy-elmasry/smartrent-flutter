import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../base/api/services/auth_services.dart';
import '../../../../base/utils/phone_validator.dart';

class RegisterController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailAddressController = TextEditingController();
  final passwordController = TextEditingController();

  RxBool agree = false.obs;
  RxString mobileCode = '+966'.obs;

  get onRegistration => registrationProcess();
  get onPrivacyPolicy => '';

  RxBool isFormValid = false.obs;
  RxBool isMobileValid = false.obs;

  String? get cleanMobile => PhoneValidator.getNsn(
        rawInput: mobileController.text,
        dialCode: mobileCode.value,
      );

  @override
  void onInit() {
    mobileController.addListener(_updateFormValidity);
    passwordController.addListener(_updateFormValidity);
    firstNameController.addListener(_updateFormValidity);
    lastNameController.addListener(_updateFormValidity);
    mobileController.addListener(_validateMobile);
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
      firstNameController.removeListener(_updateFormValidity);
      lastNameController.removeListener(_updateFormValidity);
    } catch (_) {}
    mobileController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailAddressController.dispose();
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
        passwordController.text.isNotEmpty &&
        firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        isMobileValid.value;
  }

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  registrationProcess() async {
    return AuthServices.registrationProcess(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      mobileCode: mobileCode.value,
      mobile: cleanMobile ?? mobileController.text, // ← cleaned
      email: emailAddressController.text.isEmpty
          ? null
          : emailAddressController.text,
      password: passwordController.text,
      country: 'Saudi Arabia',
      isLoading: _isLoading,
    );
  }
}