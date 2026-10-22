import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// Centralized phone number validation and normalization service.
///
/// Supports all countries via libphonenumber and normalizes output
/// to a single standard format: {countryCode}{nsn}
///
/// Also handles copy-paste of full numbers when a country code
/// picker is active (avoids double-prefixing) and strips the
/// trunk prefix '0' (e.g. +20010... → +2010...).
class PhoneValidator {
  PhoneValidator._();

  /// Normalize a raw phone input to standard format: {countryCode}{nsn}
  ///
  /// [rawInput] — The raw text from the input field
  ///   (may contain spaces, dashes, parentheses, or a leading +).
  /// [dialCode] — The selected country dial code from the picker
  ///   (e.g. '+966', '+20').
  ///
  /// Returns the normalized string, or `null` if the input cannot be
  /// normalized into a valid phone number.
  static String? normalize({
    required String rawInput,
    required String dialCode,
  }) {
    if (rawInput.trim().isEmpty) return null;

    try {
      final cleaned = _cleanInput(rawInput);
      final fullNumber = _buildFullNumber(cleaned, dialCode);
      final phoneNumber = PhoneNumber.parse(fullNumber);

      if (!phoneNumber.isValid()) return null;

      return '${phoneNumber.countryCode}${phoneNumber.nsn}';
    } catch (_) {
      return null;
    }
  }

  /// Validate a raw phone input.
  static bool isValid({
    required String rawInput,
    required String dialCode,
  }) {
    return normalize(rawInput: rawInput, dialCode: dialCode) != null;
  }

  /// Get the normalized phone number for API calls.
  static String? getNormalizedForApi({
    required String rawInput,
    required String dialCode,
  }) {
    return normalize(rawInput: rawInput, dialCode: dialCode);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Strip spaces, dashes, parentheses, and leading '+'.
  static String _cleanInput(String input) {
    return input.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
  }

  /// Build the full E.164-style string for [PhoneNumber.parse].
  ///
  /// Handles two paste scenarios and strips the trunk prefix '0':
  /// 1. User pastes full number with CC: "2001099613699" → "+201099613699"
  /// 2. User pastes local number only: "01099613699" → "+201099613699"
  static String _buildFullNumber(String cleanedInput, String dialCode) {
    final codeWithoutPlus = dialCode.replaceAll('+', '');

    if (cleanedInput.startsWith(codeWithoutPlus)) {
      // User pasted a full number (e.g. 2001099613699 or 201099613699)
      String afterCode = cleanedInput.substring(codeWithoutPlus.length);

      // Strip trunk prefix '0' if present right after country code
      // e.g., 20[0]1099613699 → 1099613699
      if (afterCode.startsWith('0')) {
        afterCode = afterCode.substring(1);
      }

      return '+$codeWithoutPlus$afterCode';
    }

    // User typed/pasted a local number without country code (e.g. 01099613699)
    String localNumber = cleanedInput;

    // Strip trunk prefix '0' if present at the start
    // e.g., [0]1099613699 → 1099613699
    if (localNumber.startsWith('0')) {
      localNumber = localNumber.substring(1);
    }

    return '$dialCode$localNumber';
  }


  // Add this method to lib/base/utils/phone_validator.dart
// inside the PhoneValidator class, after getNormalizedForApi

  /// Get the NSN (National Significant Number) without country code
  /// and without trunk prefix '0'.
  ///
  /// Example: "01099613699" with "+20" → "1099613699"
  /// Use this when the API expects mobile_code and mobile separately.
  static String? getNsn({
    required String rawInput,
    required String dialCode,
  }) {
    if (rawInput.trim().isEmpty) return null;

    try {
      final cleaned = _cleanInput(rawInput);
      final fullNumber = _buildFullNumber(cleaned, dialCode);
      final phoneNumber = PhoneNumber.parse(fullNumber);

      if (!phoneNumber.isValid()) return null;

      return phoneNumber.nsn;
    } catch (_) {
      return null;
    }
  }
}