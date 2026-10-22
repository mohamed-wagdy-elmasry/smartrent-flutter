import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../base/api/services/profile_kyc_service.dart';
import '../../../base/api/model/kyc_model.dart';
import '../../../base/utils/next_action_guard.dart';
import '../../../base/widgets/custom_snackbar.dart';

class KycSubmissionController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingFields = true.obs;
  final RxList<KycField> kycFields = <KycField>[].obs;

  // Store text field controllers
  final Map<String, TextEditingController> textControllers = {};

  // Store selected values for dropdowns
  final RxMap<String, String> selectedValues = <String, String>{}.obs;

  // Store selected files
  final RxMap<String, File> selectedFiles = <String, File>{}.obs;
  final RxMap<String, String> fileNames = <String, String>{}.obs;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _fetchKycFields();
  }

  @override
  void onClose() {
    // Dispose all text controllers
    textControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.onClose();
  }

  Future<void> _fetchKycFields() async {
    isLoadingFields.value = true;

    try {
      final response = await ProfileKycService.getKycFields();

      if (response != null && response.success && response.fields != null) {
        kycFields.value = response.fields!;

        // Initialize controllers for text fields
        for (var field in kycFields) {
          if (field.type == KycFieldType.text ||
              field.type == KycFieldType.textarea ||
              field.type == KycFieldType.number ||
              field.type == KycFieldType.date) {
            textControllers[field.name] = TextEditingController();
          }
        }
      } else {
        CustomSnackBar.error(
          response?.message ?? 'Failed to load KYC fields',
        );
      }
    } catch (e) {
      CustomSnackBar.error('An error occurred while loading KYC fields');
    } finally {
      isLoadingFields.value = false;
    }
  }

  Future<void> pickFile(String fieldName) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        selectedFiles[fieldName] = File(result.files.single.path!);
        fileNames[fieldName] = result.files.single.name;
        selectedFiles.refresh();
        fileNames.refresh();
      }
    } catch (e) {
      CustomSnackBar.error('Failed to pick file');
    }
  }

  Future<void> pickImage(String fieldName) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (image != null) {
        selectedFiles[fieldName] = File(image.path);
        fileNames[fieldName] = image.name;
        selectedFiles.refresh();
        fileNames.refresh();
      }
    } catch (e) {
      CustomSnackBar.error('Failed to pick image');
    }
  }

  void removeFile(String fieldName) {
    selectedFiles.remove(fieldName);
    fileNames.remove(fieldName);
    selectedFiles.refresh();
    fileNames.refresh();
  }

  void selectDropdownValue(String fieldName, String value) {
    selectedValues[fieldName] = value;
    selectedValues.refresh();
  }

  Future<void> submitKyc() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Validate required files
    for (var field in kycFields) {
      if (field.required && field.type == KycFieldType.file) {
        if (!selectedFiles.containsKey(field.name)) {
          CustomSnackBar.error('${field.label} is required');
          return;
        }
      }
    }

    isLoading.value = true;

    try {
      // Prepare text fields
      final Map<String, String> fields = {};
      textControllers.forEach((key, controller) {
        fields[key] = controller.text.trim();
      });

      // Add dropdown selections
      selectedValues.forEach((key, value) {
        fields[key] = value;
      });

      // Prepare file paths
      final Map<String, String> filePaths = {};
      selectedFiles.forEach((key, file) {
        filePaths[key] = file.path;
      });

      final response = await ProfileKycService.submitKyc(
        fields: fields,
        filePaths: filePaths,
      );

      isLoading.value = false;

      if (response != null && response.success && response.data != null) {
        // Use guard to navigate to next step
        await NextActionGuard.handleAfterKycSubmit(response.data!);
      } else {
        CustomSnackBar.error(
          response?.message ?? 'Failed to submit KYC. Please try again.',
        );
      }
    } catch (e) {
      isLoading.value = false;
      CustomSnackBar.error('An error occurred. Please try again.');
    }
  }
}
