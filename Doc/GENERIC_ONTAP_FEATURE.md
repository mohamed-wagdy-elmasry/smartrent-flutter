# Generic Notification On-Tap Feature

## Overview

The notification service now provides a **generic, type-based routing system** for handling notification taps. Any notification type can be routed to a custom handler without writing boilerplate code.

## Key Features

✅ **Type-Based Routing** - Route based on `type` field in payload  
✅ **Built-in Default Handlers** - Auto-handling for booking, trip, support, payment  
✅ **Custom Handlers** - Register handlers for custom notification types  
✅ **Easy Integration** - Simple API with fallback support  
✅ **Flexible Payloads** - Support any payload structure  

## Architecture

```
Notification Tapped
       ↓
onActionReceivedMethod()
       ↓
_routeNotificationTap()
       ↓
┌─────────────────────────────────────┐
│ Type in _typeHandlers map? → Use it │
├─────────────────────────────────────┤
│ booking/trip/support/payment? → Default Handler
├─────────────────────────────────────┤
│ Unhandled? → Fallback Handler
└─────────────────────────────────────┘
       ↓
Navigate / Execute Handler
```

## Default Handlers

### 1. Booking Notifications
**Types**: `booking`, `booking_accepted`, `booking_rejected`, `booking_update`

**Payload**:
```dart
{
  'type': 'booking_accepted',
  'booking_id': '123',  // or 'history_id'
  'title': 'Booking Accepted',
  'body': 'Your booking is confirmed',
}
```

**Action**: Automatically navigates to History Detail screen

### 2. Trip Notifications
**Types**: `trip`, `trip_update`, `pickup`, `dropoff`

**Payload**:
```dart
{
  'type': 'trip_update',
  'trip_id': '456',
  'status': 'on_the_way',
}
```

**Action**: Calls fallback handler (if registered)

### 3. Support Notifications
**Types**: `support`, `support_message`, `chat`

**Payload**:
```dart
{
  'type': 'support_message',
  'conversation_id': '789',
  'message': 'New support message',
}
```

**Action**: Calls fallback handler (if registered)

### 4. Payment Notifications
**Types**: `payment`, `payment_status`

**Payload**:
```dart
{
  'type': 'payment_status',
  'transaction_id': 'TXN123',
  'status': 'completed',
}
```

**Action**: Calls fallback handler (if registered)

## Usage Examples

### Example 1: Show Booking Notification (Auto-Handles Tap)
```dart
// Show notification
await NotificationService.showBookingNotification(
  title: 'Booking Accepted',
  body: 'Your booking #42 is confirmed',
  bookingId: 42,
);

// When user taps → Automatically goes to History Detail for booking #42
```

### Example 2: Register Custom Handler for Specific Type
```dart
// In app initialization
NotificationService.registerTypeHandler(
  'custom_promotion',
  (payload) async {
    final promotionId = payload['promotion_id'];
    Get.toNamed(Routes.promotionDetail, arguments: {'id': promotionId});
  },
);

// Then show notification
await NotificationService.show(
  title: 'Special Offer',
  body: 'Get 20% discount on your next booking',
  channel: CarNotificationChannel.generalUpdates,
  payload: {
    'type': 'custom_promotion',
    'promotion_id': '99',
  },
);

// When tapped → Calls your custom handler
```

### Example 3: Register Multiple Handlers
```dart
NotificationService.registerTypeHandlers({
  'event_invitation': (payload) async {
    final eventId = payload['event_id'];
    Get.toNamed(Routes.eventDetail, arguments: {'id': eventId});
  },
  'feedback_request': (payload) async {
    Get.toNamed(Routes.feedbackForm);
  },
  'promo_code': (payload) async {
    final code = payload['code'];
    Clipboard.setData(ClipboardData(text: code));
    Get.snackbar('Success', 'Promo code copied: $code');
  },
});
```

### Example 4: Fallback Handler for Unhandled Types
```dart
// Set fallback for any unhandled notification type
NotificationService.setNotificationTapHandler((payload) async {
  final type = payload['type'] ?? 'unknown';
  final message = payload['message'] ?? 'Notification received';
  
  // Generic handling
  Get.toNamed(Routes.notificationScreen);
  
  // Or log for debugging
  log.i('Unhandled notification type: $type - $message');
});
```

### Example 5: Pusher Integration (Auto-Routing)
```dart
// Listen to Pusher events
final channel = pusher.subscribe('user-123');

channel.bind('booking-accepted', (data) async {
  // Automatically routes to History Detail
  await NotificationService.showFromPusherEvent(data);
});

channel.bind('trip-update', (data) async {
  // Routes to trip handler or fallback
  await NotificationService.showFromPusherEvent(data);
});

channel.bind('custom-event', (data) async {
  // Routes to registered custom handler
  await NotificationService.showFromPusherEvent({
    ...data,
    'type': 'custom_event',
  });
});
```

## API Reference

### Register Handlers

```dart
// Single handler
NotificationService.registerTypeHandler(
  'my_type',
  (payload) async {
    // Handle payload
  },
);

// Multiple handlers
NotificationService.registerTypeHandlers({
  'type1': handler1,
  'type2': handler2,
  'type3': handler3,
});

// Fallback handler (for unhandled types)
NotificationService.setNotificationTapHandler((payload) async {
  // Handle any unhandled notification
});
```

### Manage Handlers

```dart
// Unregister specific type
NotificationService.unregisterTypeHandler('my_type');

// Clear all custom handlers
NotificationService.clearTypeHandlers();

// Note: Default handlers (booking, trip, support, payment) always work
```

### Show Notifications

```dart
// Booking (auto-navigates)
await NotificationService.showBookingNotification(
  title: 'Title',
  body: 'Body',
  bookingId: 123,
);

// Generic with custom type
await NotificationService.show(
  title: 'Title',
  body: 'Body',
  channel: CarNotificationChannel.generalUpdates,
  payload: {
    'type': 'my_custom_type',
    'custom_field': 'value',
  },
);

// From Pusher event (auto-detects type and booking_id)
await NotificationService.showFromPusherEvent({
  'type': 'booking_accepted',
  'title': 'Booking Accepted',
  'booking_id': '123',
});
```

## Payload Structure

### Recommended Format
```dart
{
  'type': 'notification_type',              // REQUIRED - for routing
  'title': 'Notification Title',             // For display
  'body': 'Notification Body',               // For display
  'booking_id': '123',                       // For booking notifications
  'trip_id': '456',                          // For trip notifications
  'conversation_id': '789',                  // For support notifications
  'transaction_id': 'TXN123',                // For payment notifications
  // ... any custom fields
}
```

### Booking Notification Alternatives
```dart
// Use either booking_id or history_id
{
  'type': 'booking',
  'booking_id': '123',  // Option 1
}

{
  'type': 'booking',
  'history_id': '123',  // Option 2
}
```

## Complete App Initialization Example

```dart
// In main() or AppInitializer.init()
void _setupNotifications() async {
  // Initialize
  await NotificationService.init();
  
  // Register custom handlers
  NotificationService.registerTypeHandlers({
    'event': (payload) async {
      Get.toNamed(Routes.events, arguments: {'eventId': payload['event_id']});
    },
    'promotion': (payload) async {
      Get.toNamed(Routes.promotions, arguments: {'code': payload['promo_code']});
    },
    'support': (payload) async {
      Get.toNamed(Routes.supportChat, arguments: {'id': payload['chat_id']});
    },
  });
  
  // Set fallback
  NotificationService.setNotificationTapHandler((payload) async {
    // For any unhandled notification
    Get.toNamed(Routes.notificationScreen, arguments: {'data': payload});
  });
}
```

## Testing

### Test Custom Handler
```dart
// Test button in dev screen
ElevatedButton(
  onPressed: () {
    NotificationService.show(
      title: 'Test Promo',
      body: 'Use code SAVE20',
      channel: CarNotificationChannel.generalUpdates,
      payload: {
        'type': 'promotion',
        'promo_code': 'SAVE20',
        'discount': '20%',
      },
    );
  },
  child: const Text('Show Test Promotion'),
)

// Tap the notification → Should trigger your 'promotion' handler
```

## Benefits

1. **No Boilerplate** - Simple registration, auto-routing
2. **Type-Safe** - Type field ensures correct handling
3. **Extensible** - Add new notification types easily
4. **Flexible** - Custom payloads for any data
5. **Maintainable** - Handlers in one place
6. **Scalable** - Easy to add 100+ notification types
7. **Debuggable** - Logs all routing decisions

## Migration from Old System

**Before**:
```dart
// Had to manually check type in global handler
NotificationService.setNotificationTapHandler((payload) {
  if (payload['type'] == 'booking') {
    // handle booking
  } else if (payload['type'] == 'trip') {
    // handle trip
  } else {
    // handle other
  }
});
```

**After**:
```dart
// Register specific handlers
NotificationService.registerTypeHandlers({
  'booking': bookingHandler,
  'trip': tripHandler,
  'custom': customHandler,
});
```

## Notes

- Default handlers run before custom handlers
- `booking_id` or `history_id` both work for booking notifications
- Handlers run asynchronously - use `await` for navigation
- Unhandled types call the fallback handler (if registered)
- Logs all routing for debugging
