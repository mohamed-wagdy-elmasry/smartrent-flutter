import 'package:awesome_notifications/awesome_notifications.dart';
import '../utils/notification_navigation.dart';
import '../widgets/logger.dart';

final log = logger(NotificationService);

enum CarNotificationChannel {
  bookingAlerts,
  tripUpdates,
  supportMessages,
  generalUpdates,
  systemLogs,
}

extension CarNotificationChannelExtension on CarNotificationChannel {
  String get key {
    switch (this) {
      case CarNotificationChannel.bookingAlerts:
        return 'booking_alerts';
      case CarNotificationChannel.tripUpdates:
        return 'trip_updates';
      case CarNotificationChannel.supportMessages:
        return 'support_messages';
      case CarNotificationChannel.generalUpdates:
        return 'general_updates';
      case CarNotificationChannel.systemLogs:
        return 'system_logs';
    }
  }

  String get displayName {
    switch (this) {
      case CarNotificationChannel.bookingAlerts:
        return 'Booking Alerts';
      case CarNotificationChannel.tripUpdates:
        return 'Trip Updates';
      case CarNotificationChannel.supportMessages:
        return 'Support Messages';
      case CarNotificationChannel.generalUpdates:
        return 'General Updates';
      case CarNotificationChannel.systemLogs:
        return 'System Logs';
    }
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();




  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null, // default icon (uses app icon)
      [
        NotificationChannel(
        channelKey: CarNotificationChannel.bookingAlerts.key,
        channelName: CarNotificationChannel.bookingAlerts.displayName,
        channelDescription: 'Critical booking & payment notifications',
        importance: NotificationImportance.Max,
        playSound: true,
        enableVibration: true,
        criticalAlerts: true,
      ),

      NotificationChannel(
        channelKey: CarNotificationChannel.tripUpdates.key,
        channelName: CarNotificationChannel.tripUpdates.displayName,
        channelDescription: 'Pickup, drop-off & live trip updates',
        importance: NotificationImportance.High,
        playSound: true,
        enableVibration: true,
      ),

      NotificationChannel(
        channelKey: CarNotificationChannel.supportMessages.key,
        channelName: CarNotificationChannel.supportMessages.displayName,
        channelDescription: 'Customer support chat updates',
        importance: NotificationImportance.High,
        playSound: true,
        enableVibration: true,
      ),

      NotificationChannel(
        channelKey: CarNotificationChannel.generalUpdates.key,
        channelName: CarNotificationChannel.generalUpdates.displayName,
        channelDescription: 'Promotions & app updates',
        importance: NotificationImportance.Default,
        playSound: true,
      ),

      NotificationChannel(
        channelKey: CarNotificationChannel.systemLogs.key,
        channelName: CarNotificationChannel.systemLogs.displayName,
        channelDescription: 'Background verification & sync logs',
        importance: NotificationImportance.Low,
        playSound: false,
        enableVibration: false,
      ),
      ],
      debug: false,
    );

    // Request notification permissions
    await requestPermission();

    // Set up notification listeners
    _setupListeners();
  }

  static Future<bool> requestPermission() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      return await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    return isAllowed;
  }

  static void _setupListeners() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  /// Show a local notification
  static Future<void> show({
    required String title,
    required String body,
    required CarNotificationChannel channel,
    Map<String, String>? payload,
    int? id,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: channel.key,
        title: title,
        body: body,
        payload: payload,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
      ),
    );
  }

  /// Show a booking notification with tap navigation to history detail
  /// 
  /// Usage:
  /// ```dart
  /// NotificationService.showBookingNotification(
  ///   title: 'Booking Accepted',
  ///   body: 'Your booking has been accepted',
  ///   bookingId: 123,
  ///   channel: CarNotificationChannel.bookingAlerts,
  /// );
  /// ```
  static Future<void> showBookingNotification({
    required String title,
    required String body,
    required int bookingId,
    CarNotificationChannel channel = CarNotificationChannel.bookingAlerts,
    int? id,
  }) async {
    await show(
      title: title,
      body: body,
      channel: channel,
      payload: {
        'type': 'booking',
        'booking_id': bookingId.toString(),
        'history_id': bookingId.toString(),
      },
      id: id,
    );
  }

  /// Show notification from Pusher event data with booking ID
  /// 
  /// Expected payload format:
  /// ```dart
  /// {
  ///   'type': 'booking_accepted', // or booking_update, etc
  ///   'title': 'Booking Accepted',
  ///   'message': 'Your booking has been accepted',
  ///   'booking_id': '123',
  ///   'id': 1,
  /// }
  /// ```
  static Future<void> showFromPusherEvent(Map<String, dynamic> eventData) async {
    final title = eventData['title'] as String? ?? 'New Notification';
    final body = eventData['message'] as String? ?? eventData['body'] as String? ?? '';
    final bookingId = eventData['booking_id'] as String?;
    final id = eventData['id'];
    final type = eventData['type'] as String? ?? 'general';

    // Determine channel based on event type
    CarNotificationChannel channel = CarNotificationChannel.generalUpdates;
    if (type.contains('booking')) {
      channel = CarNotificationChannel.bookingAlerts;
    } else if (type.contains('trip')) {
      channel = CarNotificationChannel.tripUpdates;
    }

    // If it's a booking notification, use showBookingNotification for automatic navigation
    if (bookingId != null) {
      final bookingIdInt = int.tryParse(bookingId);
      if (bookingIdInt != null) {
        await showBookingNotification(
          title: title,
          body: body,
          bookingId: bookingIdInt,
          channel: channel,
          id: id is int ? id : null,
        );
        return;
      }
    }

    // Fallback to regular notification
    await show(
      title: title,
      body: body,
      channel: channel,
      payload: {
        'type': type,
        ...eventData.map((k, v) => MapEntry(k, v.toString())),
      },
      id: id is int ? id : null,
    );
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
  }

  /// Cancel a specific notification by id
  static Future<void> cancel(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  // Static callback methods required by awesome_notifications
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Handle notification tap - route based on type
    final payload = receivedAction.payload;
    
    if (payload != null) {
      log.i('Notification tapped with payload: $payload');
      
      // Route to appropriate handler based on notification type
      await _routeNotificationTap(payload);
    }
  }

  /// Route notification tap to appropriate handler based on type
  static Future<void> _routeNotificationTap(Map<String, dynamic> payload) async {
    final type = payload['type'] as String? ?? 'general';
    
    // Check if there's a registered handler for this type
    if (_typeHandlers.containsKey(type)) {
      try {
        await _typeHandlers[type]!(payload);
        return;
      } catch (e) {
        log.e('Error in notification handler for type $type: $e');
      }
    }
    
    // Default handlers for common types
    switch (type) {
      case 'booking':
      case 'booking_accepted':
      case 'booking_rejected':
      case 'booking_update':
        await _handleBookingNotification(payload);
        break;
      
      case 'trip':
      case 'trip_update':
      case 'pickup':
      case 'dropoff':
        await _handleTripNotification(payload);
        break;
      
      case 'support':
      case 'support_message':
      case 'chat':
        await _handleSupportNotification(payload);
        break;
      
      case 'payment':
      case 'payment_status':
        await _handlePaymentNotification(payload);
        break;
      
      default:
        // Call global handler as fallback
        if (_onNotificationTapped != null) {
          await _onNotificationTapped!(payload);
        }
        log.i('No handler for notification type: $type');
    }
  }

  /// Default handler for booking notifications
  static Future<void> _handleBookingNotification(Map<String, dynamic> payload) async {
    final bookingId = int.tryParse(
      payload['booking_id'] ?? payload['history_id'] ?? ''
    );
    
    if (bookingId != null) {
      NotificationNavigation.goToHistoryDetail(historyId: bookingId);
      log.i('Navigated to history detail for booking: $bookingId');
    } else {
      log.w('Booking notification missing booking_id');
    }
  }

  /// Default handler for trip notifications
  static Future<void> _handleTripNotification(Map<String, dynamic> payload) async {
    final tripId = payload['trip_id'] ?? payload['booking_id'];
    log.i('Trip notification tapped: $tripId');
    
    if (_onNotificationTapped != null) {
      await _onNotificationTapped!(payload);
    }
  }

  /// Default handler for support notifications
  static Future<void> _handleSupportNotification(Map<String, dynamic> payload) async {
    final conversationId = payload['conversation_id'] ?? payload['chat_id'];
    log.i('Support notification tapped: $conversationId');
    
    if (_onNotificationTapped != null) {
      await _onNotificationTapped!(payload);
    }
  }

  /// Default handler for payment notifications
  static Future<void> _handlePaymentNotification(Map<String, dynamic> payload) async {
    final transactionId = payload['transaction_id'] ?? payload['trx_id'];
    log.i('Payment notification tapped: $transactionId');
    
    if (_onNotificationTapped != null) {
      await _onNotificationTapped!(payload);
    }
  }

  /// Map of type-specific handlers: type -> handler function
  static final Map<String, Future<void> Function(Map<String, dynamic>)> _typeHandlers = {};

  /// Register a handler for a specific notification type
  /// 
  /// Usage:
  /// ```dart
  /// NotificationService.registerTypeHandler('custom_event', (payload) async {
  ///   final id = payload['event_id'];
  ///   Get.toNamed(Routes.customScreen, arguments: {'id': id});
  /// });
  /// ```
  static void registerTypeHandler(
    String type,
    Future<void> Function(Map<String, dynamic> payload) handler,
  ) {
    _typeHandlers[type] = handler;
    log.i('Registered handler for notification type: $type');
  }

  /// Register multiple handlers at once
  static void registerTypeHandlers(
    Map<String, Future<void> Function(Map<String, dynamic> payload)> handlers,
  ) {
    _typeHandlers.addAll(handlers);
    log.i('Registered ${handlers.length} notification type handlers');
  }

  /// Unregister a handler for a specific type
  static void unregisterTypeHandler(String type) {
    _typeHandlers.remove(type);
    log.i('Unregistered handler for notification type: $type');
  }

  /// Clear all registered type handlers
  static void clearTypeHandlers() {
    _typeHandlers.clear();
    log.i('Cleared all notification type handlers');
  }

  /// Callback for notification tap events - fallback for unhandled types
  static Future<void> Function(Map<String, dynamic> payload)? _onNotificationTapped;
  
  /// Register a fallback callback for notification taps (for unhandled types)
  static void setNotificationTapHandler(
    Future<void> Function(Map<String, dynamic> payload) handler,
  ) {
    _onNotificationTapped = handler;
    log.i('Registered global notification tap handler');
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    log.i('Notification created: ${receivedNotification.id}');
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    log.i('Notification displayed: ${receivedNotification.id}');
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    log.i('Notification dismissed: ${receivedAction.id}');
  }
}
