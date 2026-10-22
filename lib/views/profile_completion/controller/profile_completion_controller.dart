import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../base/api/services/profile_kyc_service.dart';
import '../../../base/utils/next_action_guard.dart';
import '../../../base/widgets/custom_snackbar.dart';

class ProfileCompletionController extends GetxController {
  final formKey = GlobalKey<FormState>();
  
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();

  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> submitProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final response = await ProfileKycService.completeProfile(
        firstname: firstnameController.text.trim(),
        lastname: lastnameController.text.trim(),
        email: emailController.text.trim(),
      );

      isLoading.value = false;

      if (response != null && response.success && response.data != null) {
        CustomSnackBar.success(
          title: 'Success',
          message: response.message,
        );

        // Use guard to navigate to next step
        await NextActionGuard.handleAfterProfileComplete(response.data!);
      } else {
        CustomSnackBar.error(
          response?.message ?? 'Failed to complete profile. Please try again.',
        );
      }
    } catch (e) {
      isLoading.value = false;
      CustomSnackBar.error('An error occurred. Please try again.');
    }
  }
}
