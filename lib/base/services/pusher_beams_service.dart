import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../api/endpoint/api_endpoint.dart';
import '../utils/local_storage.dart';

/// Pusher Beams Service using Firebase Cloud Messaging with Pusher Beams API
/// Official Pusher Beams SDK has dependency conflicts, so we use REST API directly
class PusherBeamsService {
  PusherBeamsService._();
  static final PusherBeamsService instance = PusherBeamsService._();

  final Logger _logger = Logger();
  
  // Your Pusher Beams instance ID
  static const String instanceId = 'e2aaf506-f2b9-43fe-81b6-0d26c5fe5596';
  
  // Pusher Beams API endpoints
  static const String _baseUrl = 'https://$instanceId.pushnotifications.pusher.com';
  
  FirebaseMessaging? _messaging;
  String? _deviceId;
  String? _fcmToken;
  String? _beamsAuthToken;
  bool _isInitialized = false;
  Set<String> _localInterests = {};

  /// Fetch Pusher Beams authentication token from backend
  Future<String?> _fetchBeamsAuthToken() async {
    try {
      final authToken = LocalStorage.token;
      _logger.i('🔍 Fetching Beams auth token. Token available: ${authToken.isNotEmpty}');
      
      if (authToken.isEmpty) {
        _logger.w('❌ No authentication token available');
        return null;
      }

      // Use the special endpoint URL (not under /api/v1)
      final endpointUrl = ApiEndpoint.getPusherBeamsAuthUrl();
      _logger.i('📍 Endpoint: $endpointUrl');

      final response = await http.get(
        Uri.parse(endpointUrl),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        },
      );

      _logger.i('📊 Response Status: ${response.statusCode}');
      _logger.i('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _logger.i('✅ JSON Parsed: ${data.keys.toList()}');
        
        _beamsAuthToken = data['token'] ?? data['beams_token'];
        if (_beamsAuthToken != null && _beamsAuthToken!.isNotEmpty) {
          _logger.i('✅ Beams auth token fetched successfully');
          return _beamsAuthToken;
        } else {
          _logger.e('❌ No token in response. Keys: ${data.keys.toList()}');
          return null;
        }
      } else {
        _logger.e('❌ Failed to get Beams token: ${response.statusCode}');
        _logger.e('Response: ${response.body}');
        return null;
      }
    } catch (e, st) {
      _logger.e('❌ Error fetching Beams auth token: $e');
      _logger.e('StackTrace: $st');
      return null;
    }
  }

  /// Initialize Firebase Messaging and register with Pusher Beams
  /// @param userId - The user ID to associate with this device for authenticated notifications
  Future<void> initialize({String? userId}) async {
    try {
      _logger.i('🚀 Starting Pusher Beams initialization...');
      
      if (_isInitialized) {
        _logger.i('ℹ️ Pusher Beams already initialized');
        
        // If user ID is provided and device is registered, set user ID
        if (userId != null && _deviceId != null) {
          await setUserId(userId);
        }
        return;
      }

      // Fetch Beams authentication token from backend
      _logger.i('🔑 Fetching Beams auth token...');
      final beamsToken = await _fetchBeamsAuthToken();
      
      if (beamsToken == null) {
        _logger.w('❌ Failed to fetch Beams auth token, skipping initialization');
        return;
      }

      _logger.i('✅ Beams Token received: ${beamsToken.substring(0, 20)}...');

      // Initialize Firebase Messaging
      _messaging = FirebaseMessaging.instance;

      // Request permission for iOS
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.i('User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        _logger.i('User granted provisional permission');
      } else {
        _logger.w('User declined or has not accepted permission');
        return;
      }

      // Get FCM token
      _fcmToken = await _messaging!.getToken();
      if (_fcmToken != null) {
        _logger.i('FCM Token obtained');
        await _registerDevice(_fcmToken!);
        
        // Set user ID for authenticated notifications if provided
        if (userId != null && _deviceId != null) {
          await setUserId(userId);
        }
      }

      // Listen to token refresh
      _messaging!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _logger.i('FCM Token refreshed');
        _registerDevice(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.i('Notification received in foreground');
        _logger.i('Data: ${message.data}');
        if (message.notification != null) {
          _logger.i('Title: ${message.notification!.title}');
          _logger.i('Body: ${message.notification!.body}');
        }
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logger.i('Notification opened app from background');
        _logger.i('Data: ${message.data}');
      });

      _isInitialized = true;
      _logger.i('Pusher Beams initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Pusher Beams: $e');
      rethrow;
    }
  }

  /// Register device with Pusher Beams using authenticated user ID
  Future<void> _registerDevice(String fcmToken) async {
    try {
      if (_beamsAuthToken == null || _beamsAuthToken!.isEmpty) {
        _logger.e('❌ Cannot register device: Beams auth token is missing');
        return;
      }

      final platform = Platform.isAndroid ? 'FCM' : 'APNS';
      
      _logger.i('📱 Registering device with Pusher Beams (authenticated)...');
      
      // Register device with authentication token
      final response = await http.post(
        Uri.parse('$_baseUrl/device_api/v1/instances/$instanceId/devices/${platform.toLowerCase()}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_beamsAuthToken', // Use Beams auth token
        },
        body: json.encode({
          'token': fcmToken,
        }),
      );

      _logger.i('📊 Device registration response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _deviceId = data['id'];
        _logger.i('✅ Device registered with Pusher Beams. Device ID: $_deviceId');
      } else {
        _logger.e('❌ Failed to register device: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _logger.e('❌ Error registering device with Pusher: $e');
    }
  }

  /// Set user ID for authenticated push notifications
  /// This associates the device with a specific user using the Beams auth token
  Future<void> setUserId(String userId) async {
    try {
      if (_beamsAuthToken == null || _beamsAuthToken!.isEmpty) {
        _logger.e('❌ Cannot set user ID: Beams auth token is missing');
        return;
      }

      if (_deviceId == null) {
        _logger.w('⚠️ Device not registered yet. User ID will be set after registration.');
        return;
      }

      final platform = Platform.isAndroid ? 'fcm' : 'apns';
      final beamsUserId = 'user-$userId'; // IMPORTANT: must match backend user ID format
      
      _logger.i('👤 Setting Pusher Beams user ID: $beamsUserId');

      // Set user ID with authentication
      final response = await http.put(
        Uri.parse('$_baseUrl/device_api/v1/instances/$instanceId/devices/$platform/$_deviceId/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_beamsAuthToken', // Use Beams auth token
        },
        body: json.encode({
          'user': beamsUserId,
        }),
      );

      _logger.i('📊 Set user ID response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        _logger.i('✅ User ID set successfully for authenticated notifications');
      } else {
        _logger.e('❌ Failed to set user ID: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _logger.e('❌ Error setting user ID: $e');
    }
  }

  /// Add a device interest (subscribe to topic)
  Future<void> addDeviceInterest(String interest) async {
    try {
      if (!_isInitialized) {
        _logger.w('Pusher Beams not initialized. Call initialize() first.');
        return;
      }

      if (_deviceId == null) {
        _logger.w('Device not registered yet. Waiting for registration...');
        // Store locally and will be synced after registration
        _localInterests.add(interest);
        return;
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/device_api/v1/instances/$instanceId/devices/fcm/$_deviceId/interests/$interest'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        _localInterests.add(interest);
        _logger.i('Added device interest: $interest');
      } else {
        _logger.e('Failed to add interest: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _logger.e('Failed to add device interest: $e');
    }
  }

  /// Remove a device interest (unsubscribe from topic)
  Future<void> removeDeviceInterest(String interest) async {
    try {
      if (!_isInitialized || _deviceId == null) {
        _logger.w('Pusher Beams not initialized or device not registered.');
        return;
      }
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/device_api/v1/instances/$instanceId/devices/fcm/$_deviceId/interests/$interest'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        _localInterests.remove(interest);
        _logger.i('Removed device interest: $interest');
      } else {
        _logger.e('Failed to remove interest: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _logger.e('Failed to remove device interest: $e');
    }
  }

  /// Set device interests (replaces all current interests)
  Future<void> setDeviceInterests(List<String> interests) async {
    try {
      if (!_isInitialized || _deviceId == null) {
        _logger.w('Pusher Beams not initialized or device not registered.');
        // Store locally
        _localInterests = interests.toSet();
        return;
      }
      
      final response = await http.put(
        Uri.parse('$_baseUrl/device_api/v1/instances/$instanceId/devices/fcm/$_deviceId/interests'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'interests': interests,
        }),
      );

      if (response.statusCode == 200) {
        _localInterests = interests.toSet();
        _logger.i('Set device interests: $interests');
      } else {
        _logger.e('Failed to set interests: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _logger.e('Failed to set device interests: $e');
    }
  }

  /// Get all current device interests
  Future<List<String>> getDeviceInterests() async {
    try {
      if (!_isInitialized || _deviceId == null) {
        _logger.w('Pusher Beams not initialized or device not registered.');
        return _localInterests.toList();
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/device_api/v1/instances/$instanceId/devices/fcm/$_deviceId/interests'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final interests = List<String>.from(data['interests'] ?? []);
        _localInterests = interests.toSet();
        _logger.i('Current device interests: $interests');
        return interests;
      } else {
        _logger.e('Failed to get interests: ${response.statusCode} - ${response.body}');
        return _localInterests.toList();
      }
    } catch (e) {
      _logger.e('Failed to get device interests: $e');
      return _localInterests.toList();
    }
  }

  /// Clear all device interests
  Future<void> clearDeviceInterests() async {
    try {
      await setDeviceInterests([]);
      _logger.i('Cleared all device interests');
    } catch (e) {
      _logger.e('Failed to clear device interests: $e');
    }
  }

  /// Get FCM token
  String? getFcmToken() => _fcmToken;

  /// Get device ID
  String? getDeviceId() => _deviceId;

  /// Setup notification handlers for custom actions
  void onMessageReceivedInForeground(Function(RemoteMessage) callback) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.i('Custom foreground handler triggered');
      callback(message);
    });
  }

  /// Handle when user taps on notification
  void onMessageOpenedApp(Function(RemoteMessage) callback) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.i('Custom notification opened handler triggered');
      callback(message);
    });
  }

  /// Get initial message if app was opened from notification
  Future<RemoteMessage?> getInitialMessage() async {
    return await _messaging?.getInitialMessage();
  }

  /// Stop and clear all state
  Future<void> clearAllState() async {
    try {
      await clearDeviceInterests();
      if (_messaging != null) {
        await _messaging!.deleteToken();
      }
      _deviceId = null;
      _fcmToken = null;
      _isInitialized = false;
      _localInterests.clear();
      _logger.i('Cleared all Pusher Beams state');
    } catch (e) {
      _logger.e('Failed to clear state: $e');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  Logger().i('Background message: ${message.messageId}');
}

