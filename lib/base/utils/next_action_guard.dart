import 'package:get/get.dart';
import '../api/model/next_action_response.dart';
import '../api/model/kyc_model.dart';
import '../api/services/profile_kyc_service.dart';
import '../../routes/routes.dart';
import 'local_storage.dart';
import '../widgets/custom_snackbar.dart';

class NextActionGuard {
  /// Handle routing after OTP verification
  static Future<void> handlePostAuth(OtpVerifyData authData) async {
    // Save token first
    await LocalStorage.save(
      token: authData.token,
      isLoggedIn: true,
      kycStatus: authData.kycStatus,
    );

    // Check if there is a pending resume route from guest booking flow
    final args = Get.arguments;
    if (args != null && args is Map) {
      final resumeRoute = args['resumeRoute'] as String?;
      final resumeArgs = args['resumeArgs'];
      if (resumeRoute != null && resumeRoute.isNotEmpty) {
        Get.offAllNamed(resumeRoute, arguments: resumeArgs);
        return;
      }
    }

    // Route based on next_action
    _routeByNextAction(authData.nextAction);
  }

  /// Handle routing on app launch (when user already has token)
  static Future<void> handleOnLaunch() async {
    final token = LocalStorage.token;

    if (token.isEmpty) {
      // No token, go to login
      Get.offAllNamed(Routes.otpLoginScreen);
      return;
    }

    // Fetch current profile status from API
    final profileStatus = await ProfileKycService.getProfileStatus();

    if (profileStatus == null || profileStatus.data == null) {
      // API failed, clear storage and go to login
      await LocalStorage.clear();
      Get.offAllNamed(Routes.otpLoginScreen);
      return;
    }

    // Route based on next_action
    _routeByNextAction(profileStatus.data!.nextAction);
  }

  /// Centralized routing logic based on next_action
  static void _routeByNextAction(NextAction nextAction) {
    switch (nextAction) {
      case NextAction.completeProfile:
        Get.offAllNamed(Routes.profileCompletionScreen);
        break;

      case NextAction.submitKyc:
        // KYC is optional - route to dashboard instead of forcing KYC submission
        Get.offAllNamed(Routes.dashboardScreen);
        break;

      case NextAction.none:
        Get.offAllNamed(Routes.dashboardScreen);
        break;
    }
  }

  /// After profile completion, check next action and route
  static Future<void> handleAfterProfileComplete(ProfileCompleteData data) async {
    // Update local storage
    await LocalStorage.save(kycStatus: data.kycStatus);

    _routeByNextAction(data.nextAction);
  }

  /// After KYC submission, check next action and route
  static Future<void> handleAfterKycSubmit(KycSubmitData data) async {
    // Update local storage
    await LocalStorage.save(
      isKycVerified: data.kycStatus == 1,
      kycStatus: data.kycStatus,
    );

    // Show success message based on KYC status
    if (data.kycStatus == 2) {
      CustomSnackBar.success(
        title: 'Pending',
        message: 'Your KYC is pending review. We will notify you once it is verified.',
      );
    }

    // Route to dashboard
    Get.offAllNamed(Routes.dashboardScreen);
  }
}
