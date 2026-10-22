import 'dart:convert';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../api/endpoint/api_endpoint.dart';
import '../utils/local_storage.dart';
import '../widgets/logger.dart';
import 'notification_service.dart';

final log = logger(RealtimeService);

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  PusherChannelsFlutter? _pusher;
  bool _isConnected = false;
  bool _isDisposed = false;

  // Pusher configuration
  static const String _pusherKey = 'fad63cca4d52a3b0235f';
  static const String _pusherCluster = 'ap2';

  // Laravel broadcasting auth endpoint
  static String get _authEndpoint =>
      '${ApiConfig.mainDomain}/broadcasting/auth';

  bool get isConnected => _isConnected;

  /// Initialize and connect to Pusher
  Future<void> init() async {
    if (_pusher != null) {
      log.i('[RealtimeService] Pusher already initialized.');
      return;
    }

    try {
      _pusher = PusherChannelsFlutter.getInstance();

      // Get auth token for private channels
      // final token = LocalStorage.token;
      
      // Initialize Pusher with callbacks
      await _pusher!.init(
        apiKey: _pusherKey,
        cluster: _pusherCluster,
        onConnectionStateChange: _onConnectionStateChange,
        onError: _onError,
        onSubscriptionSucceeded: _onSubscriptionSucceeded,
        onEvent: _onEvent,
        onSubscriptionError: _onSubscriptionError,
       
      );

   
      log.i('[RealtimeService] Pusher initialized and connecting...');
    } catch (e) {
      log.e('[RealtimeService] Init error: $e');
    }
  }
 


  /// subscribe to a specific channel
  Future<void> subscribeToChannel(String channelName) async {
    try {
      await _pusher?.subscribe(channelName: channelName);
      log.i('[RealtimeService] Subscribed to $channelName');
    } catch (e) {
      log.e('[RealtimeService] Subscription error: $e');
    }
  }


  // Connect to Pusher
  Future<void> connect() async {
    try {
      await _pusher?.connect();
      log.i('[RealtimeService] Connected to Pusher');
    } catch (e) {
      log.e('[RealtimeService] Connect error: $e');
    }
  }

  /// Disconnect from Pusher
  Future<void> disconnect() async {
    try {
      _isDisposed = true;
      await _pusher?.disconnect();
      _isConnected = false;
      log.i('[RealtimeService] Disconnected from Pusher');
    } catch (e) {
      log.e('[RealtimeService] Disconnect error: $e');
    }
  }

  /// Unsubscribe from all channels
  Future<void> unsubscribeAll() async {
    try {
      await _pusher?.unsubscribe(channelName: 'all-users');
      final userId = LocalStorage.userId;
      await _pusher?.unsubscribe(
        channelName: 'user-notification-$userId',
      );
          log.i('[RealtimeService] Unsubscribed from all channels');
    } catch (e) {
      log.e('[RealtimeService] Unsubscribe error: $e');
    }
  }

  // Connection state change callback
  void _onConnectionStateChange(dynamic currentState, dynamic previousState) {
    if (_isDisposed) return; // Prevent reconnection after disconnect
    log.i('[RealtimeService] Connection state: $previousState -> $currentState');
    _isConnected = currentState == 'CONNECTED';
  }

  // Error callback
  void _onError(String message, int? code, dynamic e) {
    if (_isDisposed) return; // Suppress errors after disconnect
    log.e('[RealtimeService] Error: $message (code: $code) - $e');
  }

  // Subscription succeeded callback
  void _onSubscriptionSucceeded(String channelName, dynamic data) {
    log.i('[RealtimeService] Successfully subscribed to $channelName');
  }

  // Subscription error callback
  void _onSubscriptionError(String message, dynamic e) {
    log.e('[RealtimeService] Subscription error: $message - $e');
  }

  // Event callback
  void _onEvent(PusherEvent event) {
    try {
      log.i('[RealtimeService] Event received: ${event.eventName} on ${event.channelName}');
      log.i('[RealtimeService] Event raw data: ${event.data}');
      final decoded = event.data is String
          ? jsonDecode(event.data as String) as Map<String, dynamic>
          : Map<String, dynamic>.from(event.data as Map);
      final notification = decoded['notification'];
      if (notification == null) {
        log.w('[RealtimeService] No notification key in event data, skipping.');
        return;
      }
      final data = Map<String, dynamic>.from(notification as Map);
      final title = data['title'] as String?;
      final body = data['message'] as String?;
      final type = data['type'];
      
      // Convert payload to Map<String, String>
      Map<String, String>? payload;
      if (data['data'] != null) {
        final rawPayload = data['data'] as Map<String, dynamic>?;
        if (rawPayload != null) {
          payload = rawPayload.map(
            (key, value) => MapEntry(key, value.toString()),
          );
        }
      }

      log.i('[RealtimeService] Event data: ${event.data}');
      log.i('[RealtimeService] Title: $title');
      log.i('[RealtimeService] Body: $body');
      log.i('[RealtimeService] Type: $type');
      log.i('[RealtimeService] Data: $payload');

      NotificationService.show(
        title: title ?? 'Notification',
        body: body ?? '',
        channel: CarNotificationChannel.bookingAlerts,
        payload: payload,
      );
    } catch (e) {
      log.e('[RealtimeService] Event handling error: $e');
      log.e('[RealtimeService] Event data: ${event.data}');
    }
  }
}
