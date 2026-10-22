import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/local_storage.dart';
import '../../widgets/logger.dart';
import '../endpoint/api_endpoint.dart';

final log = logger(LanguageService);

class LanguageService {
  /// Fetch language data with proper UTF-8 handling
  static Future<Map<String, dynamic>> fetchLanguageData(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Ensure UTF-8 decoding
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        return decoded as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to fetch language data: ${response.statusCode}',
        );
      }
    } catch (e) {
      log.e('Error fetching language data: $e');
      rethrow;
    }
  }
  
  /// Get user's language preference from backend
  static Future<String?> getUserLanguage() async {
    try {
      final token = LocalStorage.token;
      if (token.isEmpty) {
        log.w('No token found, cannot fetch user language');
        return null;
      }

      final url = ApiEndpoint.getUserLanguage.url();
      
      log.i('GET $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      log.i('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        final language = jsonData['language'] as String?;
        log.i('User language: $language');
        return language;
      } else {
        log.e('Failed to get user language: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log.e('Error getting user language: $e');
      return null;
    }
  }
  
  /// Update user's language preference on backend
  static Future<bool> updateUserLanguage(String languageCode) async {
    try {
      final token = LocalStorage.token;
      if (token.isEmpty) {
        log.w('No token found, cannot update user language');
        return false;
      }

      final url = ApiEndpoint.updateUserLanguage.url();
      
      log.i('POST $url - Language: $languageCode');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'language': languageCode,
        }),
      );

      log.i('Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        log.i('User language updated successfully');
        return true;
      } else {
        log.e('Failed to update user language: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log.e('Error updating user language: $e');
      return false;
    }
  }
}
