import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

/// Secure storage wrapper that migrates from GetStorage to FlutterSecureStorage
/// for sensitive data while maintaining backward compatibility
class SecureStorageHelper {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static final GetStorage _localStorage = GetStorage();

  // Keys
  static const String tokenKey = 'secure_token';
  static const String temporaryTokenKey = 'secure_temporary_token';

  /// Migrate token from GetStorage to SecureStorage
  static Future<void> migrateTokens() async {
    try {
      // Check if migration already done
      final hasSecureToken = await _secureStorage.read(key: tokenKey);
      if (hasSecureToken != null) return;

      // Migrate existing token from GetStorage
      final oldToken = _localStorage.read('token') as String?;
      if (oldToken != null && oldToken.isNotEmpty) {
        await _secureStorage.write(key: tokenKey, value: oldToken);
      }

      final oldTempToken = _localStorage.read('temporaryToken') as String?;
      if (oldTempToken != null && oldTempToken.isNotEmpty) {
        await _secureStorage.write(key: temporaryTokenKey, value: oldTempToken);
      }
    } catch (e) {
      // Migration failed, continue with GetStorage
      print('Token migration failed: $e');
    }
  }

  /// Save token securely
  static Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: tokenKey, value: token);
      // Also save to GetStorage for backward compatibility
      await _localStorage.write('token', token);
    } catch (e) {
      print('Error saving token: $e');
      // Fallback to GetStorage only
      await _localStorage.write('token', token);
    }
  }

  /// Get token from secure storage
  static Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: tokenKey);
      if (token != null && token.isNotEmpty) return token;

      // Fallback to GetStorage
      return _localStorage.read('token') as String?;
    } catch (e) {
      print('Error reading token: $e');
      // Fallback to GetStorage
      return _localStorage.read('token') as String?;
    }
  }

  /// Save temporary token
  static Future<void> saveTemporaryToken(String token) async {
    try {
      await _secureStorage.write(key: temporaryTokenKey, value: token);
      await _localStorage.write('temporaryToken', token);
    } catch (e) {
      print('Error saving temporary token: $e');
      await _localStorage.write('temporaryToken', token);
    }
  }

  /// Get temporary token
  static Future<String?> getTemporaryToken() async {
    try {
      final token = await _secureStorage.read(key: temporaryTokenKey);
      if (token != null && token.isNotEmpty) return token;

      return _localStorage.read('temporaryToken') as String?;
    } catch (e) {
      print('Error reading temporary token: $e');
      return _localStorage.read('temporaryToken') as String?;
    }
  }

  /// Clear all tokens
  static Future<void> clearTokens() async {
    try {
      await _secureStorage.delete(key: tokenKey);
      await _secureStorage.delete(key: temporaryTokenKey);
    } catch (e) {
      print('Error clearing secure tokens: $e');
    }
    
    // Also clear from GetStorage
    await _localStorage.remove('token');
    await _localStorage.remove('temporaryToken');
  }

  /// Clear all secure storage
  static Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      print('Error clearing secure storage: $e');
    }
  }
}
