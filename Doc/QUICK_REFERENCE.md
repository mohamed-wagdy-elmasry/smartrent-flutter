# Quick Reference - Generic Notification On-Tap

## Setup (One-Time)

```dart
// In AppInitializer.init() or main()

// Initialize
await NotificationService.init();

// Optional: Register custom handlers
NotificationService.registerTypeHandlers({
  'my_type': (payload) async {
    // Your logic here
  },
});

// Optional: Set fallback for unhandled types
NotificationService.setNotificationTapHandler((payload) async {
  Get.toNamed(Routes.notificationScreen);
});
```

## Show Notifications

### Auto-Navigate to History Detail
```dart
await NotificationService.showBookingNotification(
  title: 'Booking Accepted',
  body: 'Booking #42 confirmed',
  bookingId: 42,
);
// User taps → Navigates to History Detail for booking 42
```

### Custom Type with Registered Handler
```dart
await NotificationService.show(
  title: 'Event',
  body: 'New event invitation',
  channel: CarNotificationChannel.generalUpdates,
  payload: {'type': 'event', 'event_id': '123'},
);
// User taps → Triggers registered 'event' handler
```

### From Pusher Event
```dart
await NotificationService.showFromPusherEvent({
  'type': 'booking_accepted',
  'title': 'Accepted',
  'booking_id': '42',
});
// Auto-detects type and routes appropriately
```

## Register Handlers

### Single Handler
```dart
NotificationService.registerTypeHandler(
  'my_type',
  (payload) async {
    final id = payload['my_id'];
    Get.toNamed(Routes.myScreen, arguments: {'id': id});
  },
);
```

### Multiple Handlers
```dart
NotificationService.registerTypeHandlers({
  'type1': handler1,
  'type2': handler2,
  'type3': handler3,
});
```

### Fallback Handler
```dart
NotificationService.setNotificationTapHandler((payload) async {
  // Called for any unhandled notification type
  Get.toNamed(Routes.notificationScreen);
});
```

## Auto-Handled Types

| Type | Payload Key | Action |
|------|-------------|--------|
| `booking*` | `booking_id` | → History Detail |
| `trip*` | `trip_id` | → Fallback Handler |
| `support*` | `conversation_id` | → Fallback Handler |
| `payment*` | `transaction_id` | → Fallback Handler |

*`*` = any notification containing this word (e.g., booking_accepted, booking_rejected)

## Manage Handlers

```dart
// Remove specific handler
NotificationService.unregisterTypeHandler('my_type');

// Clear all custom handlers (keeps defaults)
NotificationService.clearTypeHandlers();
```

## Common Patterns

### Push Notification Service Integration
```dart
final channel = pusher.subscribe('notifications');
channel.bind('booking-update', (data) async {
  await NotificationService.showFromPusherEvent({
    ...data,
    'type': 'booking_accepted', // Auto-routes to booking handler
  });
});
```

### Firebase Integration
```dart
FirebaseMessaging.onMessage.listen((message) {
  final data = message.data;
  if (data['type'] == 'booking') {
    await NotificationService.showBookingNotification(
      title: data['title'] ?? 'Notification',
      body: data['body'] ?? '',
      bookingId: int.parse(data['booking_id'] ?? '0'),
    );
  }
});
```

### Test Handler
```dart
NotificationService.registerTypeHandler(
  'test',
  (payload) async {
    Get.snackbar('Test', 'Notification tapped: ${payload['message']}');
  },
);
```

## Debugging

Enable logs in `notification_service.dart`:
```
Notification tapped with payload: {type: booking, booking_id: 42}
Routed notification to type handler: booking
Navigated to history detail for booking: 42
```

---

**Full Documentation**: See `GENERIC_ONTAP_FEATURE.md`  
**Booking Setup**: See `NOTIFICATION_ONTAP_GUIDE.md`
