import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'i18n_service.dart';

/// Service to fetch and cache translations from remote server
class RemoteLanguageService {
  static const String _cacheKey = 'cached_translations';
  static const String _languagesKey = 'cached_languages';
  static const String _lastFetchKey = 'last_fetch_timestamp';
  static const Duration _cacheExpiry = Duration(hours: 24);
  
  final GetStorage _storage = GetStorage();
  final I18nService _i18nService;
  
  RemoteLanguageService(this._i18nService);
  
  /// Fetch languages and translations from server
  Future<void> fetchTranslations(String url) async {
    try {
      // Check if we have valid cached data
      if (_hasFreshCache()) {
        debugPrint('RemoteLanguageService: Loading from cache');
        _loadFromCache();
        return;
      }
      
      debugPrint('RemoteLanguageService: Fetching from server: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _processServerResponse(data);
      } else {
        debugPrint('RemoteLanguageService: Server error ${response.statusCode}');
        // Fallback to cache if available
        _loadFromCache();
      }
    } catch (e) {
      debugPrint('RemoteLanguageService: Fetch error: $e');
      // Fallback to cache if available
      _loadFromCache();
    }
  }
  
  /// Process server response and update I18n service
  Future<void> _processServerResponse(dynamic data) async {
    try {
      List<LanguageModel> languages = [];
      Map<String, Map<String, String>> allTranslations = {};
      
      // Expected server response format:
      // {
      //   "languages": [
      //     {
      //       "code": "en",
      //       "name": "English",
      //       "direction": "ltr",
      //       "translations": {
      //         "appLBookNow": "Book Now",
      //         ...
      //       }
      //     },
      //     ...
      //   ]
      // }
      
      if (data is Map && data.containsKey('languages')) {
        for (var langData in data['languages']) {
          final language = LanguageModel.fromJson(langData);
          languages.add(language);
          
          if (langData.containsKey('translations')) {
            final translations = Map<String, String>.from(langData['translations']);
            allTranslations[language.code] = translations;
            _i18nService.updateRuntimeTranslations(language.code, translations);
          }
        }
        
        _i18nService.updateLanguages(languages);
        
        // Cache the data
        await _cacheData(languages, allTranslations);
        
        debugPrint('RemoteLanguageService: Loaded ${languages.length} languages');
      }
    } catch (e) {
      debugPrint('RemoteLanguageService: Process error: $e');
    }
  }
  
  /// Cache data locally
  Future<void> _cacheData(
    List<LanguageModel> languages,
    Map<String, Map<String, String>> translations,
  ) async {
    try {
      await _storage.write(
        _languagesKey,
        languages.map((l) => l.toJson()).toList(),
      );
      
      await _storage.write(_cacheKey, translations);
      await _storage.write(_lastFetchKey, DateTime.now().toIso8601String());
      
      debugPrint('RemoteLanguageService: Data cached successfully');
    } catch (e) {
      debugPrint('RemoteLanguageService: Cache write error: $e');
    }
  }
  
  /// Load from cache
  void _loadFromCache() {
    try {
      final cachedLanguages = _storage.read<List>(_languagesKey);
      final cachedTranslations = _storage.read<Map>(_cacheKey);
      
      if (cachedLanguages != null && cachedTranslations != null) {
        final languages = cachedLanguages
            .map((l) => LanguageModel.fromJson(Map<String, dynamic>.from(l)))
            .toList();
        
        _i18nService.updateLanguages(languages);
        
        cachedTranslations.forEach((langCode, translations) {
          _i18nService.updateRuntimeTranslations(
            langCode,
            Map<String, String>.from(translations),
          );
        });
        
        debugPrint('RemoteLanguageService: Loaded from cache');
      }
    } catch (e) {
      debugPrint('RemoteLanguageService: Cache load error: $e');
    }
  }
  
  /// Check if cache is fresh
  bool _hasFreshCache() {
    final lastFetchStr = _storage.read<String>(_lastFetchKey);
    if (lastFetchStr == null) return false;
    
    try {
      final lastFetch = DateTime.parse(lastFetchStr);
      final now = DateTime.now();
      return now.difference(lastFetch) < _cacheExpiry;
    } catch (e) {
      return false;
    }
  }
  
  /// Clear cache (useful for debugging or forced refresh)
  Future<void> clearCache() async {
    await _storage.remove(_cacheKey);
    await _storage.remove(_languagesKey);
    await _storage.remove(_lastFetchKey);
    debugPrint('RemoteLanguageService: Cache cleared');
  }
}
