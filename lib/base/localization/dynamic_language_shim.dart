import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/services/language_service.dart';
import 'i18n_service.dart';

export 'i18n_service.dart' show LanguageModel;

/// Compatibility shim that provides the same API as the external dynamic_languages package.
/// Now backed by our custom I18n implementation.
class DynamicLanguageController extends GetxController {
  final I18nService _i18n = I18n;
  
  // Reactive selected language (stored so listeners observe the same Rx)
  final RxString selectedLanguage = ''.obs;
  
  // Loading state
  bool get isLoading {
    try {
      return _i18n.isLoading;
    } catch (e) {
      debugPrint('DynamicLanguage.isLoading getter error: $e');
      return true;
    }
  }
  
  // Loading state as observable (for stream listeners)
  Rx<bool> get isLoadingValue => _i18n.isLoadingValue;
  
  // Available languages
  List<LanguageModel> get languages => _i18n.languages;
  
  // Current text direction
  TextDirection get languageDirection => _i18n.languageDirection;
  
  /// Initialize the language system
  Future<void> init({required String url}) async {
    await _i18n.init(url: url);
    try {
      selectedLanguage.value = _i18n.currentLocale.languageCode;
      // Fetch user's saved language from backend
      await fetchUserLanguage();
    } catch (e) {
      // ignore
    }
  }
  
  /// Get translation for a key
  String key(String translationKey) {
    return _i18n.key(translationKey);
  }
  
  /// Fetch user's language preference from backend
  Future<void> fetchUserLanguage() async {
    try {
      final userLanguage = await LanguageService.getUserLanguage();
      if (userLanguage != null && userLanguage.isNotEmpty) {
        // Update language if different from current
        if (_i18n.currentLocale.languageCode != userLanguage) {
          await _i18n.changeLanguage(userLanguage);
          selectedLanguage.value = userLanguage;
        }
      }
    } catch (e) {
      debugPrint('Error fetching user language: $e');
    }
  }
  
  /// Sync language preference to backend
  Future<bool> syncLanguageToBackend(String languageCode) async {
    try {
      return await LanguageService.updateUserLanguage(languageCode);
    } catch (e) {
      debugPrint('Error syncing language to backend: $e');
      return false;
    }
  }
  
  /// Change the current language
  Future<void> changeLanguage(String languageCode) async {
    await _i18n.changeLanguage(languageCode);
    try {
      selectedLanguage.value = languageCode;
      // Sync to backend (fire and forget - don't block UI)
      syncLanguageToBackend(languageCode);
    } catch (_) {}
  }
}

/// Global singleton instance
final DynamicLanguage = Get.put(DynamicLanguageController(), permanent: true);
