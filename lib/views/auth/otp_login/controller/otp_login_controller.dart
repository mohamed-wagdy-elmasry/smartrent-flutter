import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../base/api/services/auth_services.dart';
import '../../../../base/api/services/profile_kyc_service.dart';
import '../../../../base/services/realtime_service.dart';
import '../../../../base/utils/local_storage.dart';
import '../../../../base/utils/next_action_guard.dart';
import '../../../../base/utils/phone_validator.dart';
import '../../../../base/widgets/custom_snackbar.dart';
import '../../../../base/widgets/logger.dart';
import '../../../../languages/strings.dart';

class OtpLoginController extends GetxController {
  final log = logger(OtpLoginController);
  final mobileController = TextEditingController();
  final otpController = TextEditingController();

  RxString mobileCode = '+966'.obs;
  RxBool isMobileValid = false.obs;
  RxBool isOtpSent = false.obs;
  RxBool isOtpDisabled = false.obs;
  RxString otp = ''.obs;
  RxBool isOtpValid = false.obs;
  RxInt expiresInMinutes = 10.obs;

  /// Clean NSN for API calls (no trunk prefix 0).
  /// "01099613699" → "1099613699"
  String? get cleanMobile => PhoneValidator.getNsn(
        rawInput: mobileController.text,
        dialCode: mobileCode.value,
      );

  /// Full normalized format: 201099613699
  String? get normalizedMobile => PhoneValidator.getNormalizedForApi(
        rawInput: mobileController.text,
        dialCode: mobileCode.value,
      );

  get onSendOtp => sendOtpProcess();
  get onVerifyOtp => verifyOtpProcess();

  @override
  void onInit() {
    mobileController.addListener(_validateMobile);
    ever<String>(otp, (val) => isOtpValid.value = val.length == 6);
    super.onInit();
  }

  @override
  void onClose() {
    try {
      mobileController.removeListener(_validateMobile);
    } catch (_) {}
    mobileController.dispose();
    otpController.dispose();
    super.onClose();
  }

  void _validateMobile() {
    isMobileValid.value = PhoneValidator.isValid(
      rawInput: mobileController.text,
      dialCode: mobileCode.value,
    );
  }

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _isResending = false.obs;
  bool get isResending => _isResending.value;

  sendOtpProcess() async {
    if (!isMobileValid.value) {
      Get.snackbar(
        Strings.invalidPhoneNumber,
        Strings.pleaseEnterValidPhone,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _isLoading.value = true;

    final result = await AuthServices.sendUserOtp(
      mobileCode: mobileCode.value,
      mobile: cleanMobile ?? mobileController.text, // ← cleaned
      isLoading: _isLoading,
    );

    if (result != null) {
      expiresInMinutes.value = result.expiresInMinutes;

      if (result.otpDisabled) {
        log.i('OTP is disabled, proceeding with direct login...');
        isOtpDisabled.value = true;
        await _loginDirectWithoutOtp();
      } else {
        log.i('OTP is enabled, waiting for user to enter OTP...');
        isOtpDisabled.value = false;
        isOtpSent.value = true;
        _isLoading.value = false;
        Get.snackbar(
          Strings.otpSent,
          Strings.checkMobileForOtp,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      _isLoading.value = false;
    }
  }

  Future<void> _loginDirectWithoutOtp() async {
    final phone = normalizedMobile ??
        '${mobileCode.value}${mobileController.text}';

    log.i('Attempting direct login without OTP for mobile: $phone');

    final loginResult = await AuthServices.loginViaMobileWithoutOtp(
      mobileCode: mobileCode.value,
      mobile: cleanMobile ?? mobileController.text, // ← cleaned
      isLoading: _isLoading,
    );

    _isLoading.value = false;

    if (loginResult != null) {
      log.i('Direct login successful!');
      mobileController.clear();
      otpController.clear();
      otp.value = '';
      isOtpSent.value = false;
      isOtpDisabled.value = false;
    } else {
      log.e('Direct login failed');
      CustomSnackBar.error('Failed to login. Please try again.');
    }
  }

  resendOtpProcess() async {
    if (!isMobileValid.value) return;

    _isResending.value = true;

    final result = await AuthServices.sendUserOtp(
      mobileCode: mobileCode.value,
      mobile: cleanMobile ?? mobileController.text, // ← cleaned
      isLoading: _isResending,
    );

    _isResending.value = false;

    if (result != null) {
      if (result.otpDisabled) {
        log.i('OTP disabled during resend, attempting direct login...');
        isOtpDisabled.value = true;
        _isLoading.value = true;
        await _loginDirectWithoutOtp();
        return;
      }

      otp.value = '';
      otpController.clear();
      expiresInMinutes.value = result.expiresInMinutes;
      Get.snackbar(
        Strings.otpSent,
        Strings.checkMobileForOtp,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  verifyOtpProcess() async {
    if (otp.value.length != 6) {
      Get.snackbar(
        Strings.invalidOtp,
        Strings.enterSixDigitOtp,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _isLoading.value = true;

    final response = await ProfileKycService.verifyOtpWithNextAction(
      mobileCode: mobileCode.value,
      mobile: cleanMobile ?? mobileController.text, // ← cleaned
      otpCode: otp.value,
    );

    _isLoading.value = false;

    if (response != null && response.success && response.data != null) {
      final data = response.data!;

      await LocalStorage.save(
        userId: data.userInfo?.id ?? 0,
        token: data.token,
        kycStatus: data.kycStatus,
        isLoggedIn: true,
      );

      log.i(
        '[OtpLoginController] User logged in via OTP: ${data.userInfo!.id}',
      );

      try {
        final realtime = RealtimeService();
        await realtime.init();
        await realtime.subscribeToChannel('all-users');
        if (data.userInfo != null && data.userInfo!.id > 0) {
          await realtime.subscribeToChannel(
            'user-notification-${data.userInfo!.id}',
          );
          log.i(
            '[OtpLoginController] Connected to realtime service for user ${data.userInfo!.id}',
          );
        }
        await realtime.connect();
      } catch (e) {
        log.e(
          '[OtpLoginController] Failed to connect realtime service: $e',
        );
      }

      mobileController.clear();
      otpController.clear();
      otp.value = '';
      isOtpSent.value = false;

      await NextActionGuard.handlePostAuth(data);
    } else {
      CustomSnackBar.error(
        response?.message ?? 'Failed to verify OTP. Please try again.',
      );
    }
  }
}