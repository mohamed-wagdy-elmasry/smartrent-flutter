import 'package:get/get.dart';

import '../../../../base/api/services/auth_services.dart';

class OtpVerificationController extends GetxController {
  // reactive otp value instead of a shared TextEditingController
  RxString otp = ''.obs;
  RxBool isFormValid = false.obs;

  @override
  void onInit() {
    // keep validity in sync
    ever<String>(otp, (val) => isFormValid.value = val.length == 6);
    super.onInit();
  }

  // routing getters
  get onResendOtp => onResendOtpProcess();
  get onOtpSubmit => otpVerifyProcess();

  final _isResendLoading = false.obs;

  bool get isResendLoading => _isResendLoading.value;

  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  onResendOtpProcess() {
    return AuthServices.resendForgotOtpCode(isResendLoading: _isResendLoading);
  }

  otpVerifyProcess() async {
    // call loginViaOtp service

    return AuthServices.otpVerifyProcess(
      code: otp.value,
      isLoading: _isLoading,
    );
  }
}
