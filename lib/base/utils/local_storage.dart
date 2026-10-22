import 'package:get_storage/get_storage.dart';

import 'local_storage_model.dart';

class LocalStorage {
  // Create a single instance of GetStorage
  static final GetStorage _storage = GetStorage();

  // Keys for storage -- FIRST
  static const String tokenKey = 'token';
  static const String temporaryTokenKey = 'temporaryToken';
  static const String mobileCodeKey = 'mobileCode';
  static const String onboardSaveKey = 'onboardSave';
  static const String waitTimeKey = 'waitTime';
  static const String isLoggedInKey = 'isLoggedIn';
  static const String isEmailVerifiedKey = 'isEmailVerified';
  static const String isKycVerifiedKey = 'isKycVerified';
  static const String kycStatusKey = 'isKycStatus';
  static const String isSmsVerifiedKey = 'isSmsVerified';
  static const String emailKey = 'email';
  static const String userNumberKey = 'number';
  static const String userIdKey = 'userId';

  // FOR TEST -------------------------
  static const String exampleKey = 'example';
  static const String userCountryCodeKey = 'userCountryCode';

  // Save data to local storage (supports individual properties) 2ND
  static Future<void> save({
    String? token,
    // FOR TEST-------------------------
    String? example,
    String? userCountryCode,
    String? temporaryToken,
    String? mobileCode,
    String? waitTime,
    bool? onboardSave,
    bool? isLoggedIn,
    bool? isEmailVerified,
    bool? isKycVerified,
    bool? isSmsVerified,
    String? email,
    String? number,
    int? kycStatus,
    int? userId,
  }) async {
    // FOR TEST  --------------------------------------
    if (example != null) await _storage.write(exampleKey, example);
    if (userCountryCode != null)
      await _storage.write(userCountryCodeKey, userCountryCode);

    if (token != null) await _storage.write(tokenKey, token);
    if (temporaryToken != null)
      await _storage.write(temporaryTokenKey, temporaryToken);
    if (mobileCode != null) await _storage.write(mobileCode, mobileCode);
    if (onboardSave != null) await _storage.write(onboardSaveKey, onboardSave);
    if (isLoggedIn != null) await _storage.write(isLoggedInKey, isLoggedIn);
    if (isEmailVerified != null)
      await _storage.write(isEmailVerifiedKey, isEmailVerified);
    if (isKycVerified != null)
      await _storage.write(isKycVerifiedKey, isKycVerified);
    if (isSmsVerified != null)
      await _storage.write(isSmsVerifiedKey, isSmsVerified);
    if (waitTime != null) await _storage.write(waitTimeKey, waitTime);
    if (email != null) await _storage.write(emailKey, email);

    if (number != null) await _storage.write(userNumberKey, number);

    if (kycStatus != null) await _storage.write(kycStatusKey, kycStatus);
    if (userId != null) await _storage.write(userIdKey, userId);
  }

  // Read entire model
  static LocalStorageModel get model {
    return LocalStorageModel(
      _storage.read(tokenKey) ?? '',
      _storage.read(onboardSaveKey) ?? false,
      _storage.read(waitTimeKey) ?? '01:00',
      _storage.read(isLoggedInKey) ?? false,
      _storage.read(isEmailVerifiedKey) ?? false,
      _storage.read(isKycVerifiedKey) ?? false,
      _storage.read(isSmsVerifiedKey) ?? false,
      _storage.read(kycStatusKey) ?? 0,
      temporaryToken: _storage.read(temporaryTokenKey) ?? '',
      mobileCode: _storage.read(mobileCodeKey) ?? '',
    );
  }

  // Read individual properties
  static String get token => _storage.read(tokenKey) ?? '';

  // FOR TEST --------------------------------------------
  static String get example => _storage.read(exampleKey) ?? '';
  static String get userCountryCode => _storage.read(userCountryCodeKey) ?? '';

  static String get temporaryToken => _storage.read(temporaryTokenKey) ?? '';

  static String get userMobileCode => _storage.read(mobileCodeKey) ?? '';

  static String get waitTime => _storage.read(waitTimeKey) ?? '01:00';

  static bool get onboardSave => _storage.read(onboardSaveKey) ?? false;

  static bool get isLoggedIn => _storage.read(isLoggedInKey) ?? false;

  static bool get isEmailVerified => _storage.read(isEmailVerifiedKey) ?? false;

  static bool get isKycVerified => _storage.read(isKycVerifiedKey) ?? false;

  static bool get isSmsVerified => _storage.read(isSmsVerifiedKey) ?? false;

  static String get email => _storage.read(emailKey) ?? '';

  static String get number => _storage.read(userNumberKey) ?? '';

  static int get userId => _storage.read(userIdKey) ?? 0;

  /// Convenience alias for `number` to make intent clearer in calling code.
  static String get mobile => number;

  /// Returns true when an email value exists in storage (non-empty after trim).
  static bool get hasEmail => email.toString().trim().isNotEmpty;

  /// Returns true when a mobile/number value exists in storage (non-empty after trim).
  static bool get hasMobile => mobile.toString().trim().isNotEmpty;

  /// Simple email format validator. Not exhaustive but sufficient for quick checks.
  static bool isValidEmail(String? e) {
    if (e == null) return false;
    final emailStr = e.trim();
    if (emailStr.isEmpty) return false;
    // Basic regex: local@domain.tld (does not cover all edge cases).
    final regExp = RegExp(r"^[\w\-\.]+@[\w\-]+(\.[\w\-]+)+$");
    return regExp.hasMatch(emailStr);
  }

  static int get kycStatus => _storage.read(kycStatusKey) ?? 0;

  // Clear all stored data
  static Future<void> clear() async {
    await _storage.erase();
  }
}
