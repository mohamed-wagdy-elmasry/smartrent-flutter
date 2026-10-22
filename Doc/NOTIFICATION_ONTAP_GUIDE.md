# Notification On-Tap Feature Guide

## Overview
The notification service now automatically navigates to the History Detail screen when a booking notification is tapped.

## Features

### Automatic Navigation
When a notification with `booking_id` or `history_id` is tapped:
1. The payload is automatically parsed
2. User is navigated to the History Detail screen
3. The specific booking/history is loaded and displayed

### Supported Notification Types
- Booking Accepted
- Booking Rejected
- Booking Status Updates
- Trip Updates
- Cancellation Notices

## Usage

### Method 1: Using `showBookingNotification()` (Recommended)
```dart
// Simple way to show booking notifications with automatic navigation
await NotificationService.showBookingNotification(
  title: 'Booking Accepted',
  body: 'Your booking has been accepted and confirmed',
  bookingId: 123,
  channel: CarNotificationChannel.bookingAlerts,
);
```

### Method 2: Using Generic `show()` with Payload
```dart
// Manual payload method - include booking_id in payload
await NotificationService.show(
  title: 'Booking Update',
  body: 'Your booking status has changed',
  channel: CarNotificationChannel.bookingAlerts,
  payload: {
    'type': 'booking_update',
    'booking_id': '456',
    'history_id': '456',
    'status': 'confirmed',
  },
);
```

### Method 3: From Pusher Events
```dart
// Automatically handles booking_id from Pusher event
final pusherEventData = {
  'type': 'booking_accepted',
  'title': 'Booking Accepted!',
  'message': 'Your car booking has been confirmed',
  'booking_id': '789',
  'id': 1,
};

await NotificationService.showFromPusherEvent(pusherEventData);
```

## Integration Examples

### Firebase Cloud Messaging
```dart
// In your FCM message handler
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  final data = message.data;
  
  if (data['type'] == 'booking_accepted') {
    NotificationService.showBookingNotification(
      title: data['title'] ?? 'Booking Accepted',
      body: data['body'] ?? 'Your booking has been confirmed',
      bookingId: int.parse(data['booking_id'] ?? '0'),
    );
  }
});
```

### Pusher Integration
```dart
// In your Pusher channel listener
channel.bind('booking-accepted', (data) {
  NotificationService.showFromPusherEvent(data);
  // Automatically navigates to history detail when tapped
});

channel.bind('booking-status-update', (data) {
  NotificationService.showFromPusherEvent(data);
});
```

## Payload Format

### Required for Automatic Navigation
```dart
{
  'booking_id': '123',  // Required - booking ID
  // OR
  'history_id': '123',  // Alternative field name
}
```

### Full Recommended Format
```dart
{
  'type': 'booking_accepted',           // Notification type
  'booking_id': '123',                   // Required for navigation
  'history_id': '123',                   // Backup field
  'title': 'Booking Accepted',           // Shown in notification
  'message': 'Your booking is confirmed', // Notification body
  'status': 'confirmed',                 // Additional data
  'timestamp': '2024-12-13T10:30:00Z',  // Event timestamp
}
```

## How It Works

1. **Notification Created**: `showBookingNotification()` or `show()` with `booking_id` payload
2. **User Taps Notification**: `onActionReceivedMethod()` is triggered
3. **Payload Parsed**: Extracts `booking_id` or `history_id` from payload
4. **Navigation**: Automatically calls `NotificationNavigation.goToHistoryDetail(historyId: id)`
5. **History Detail Opens**: Loads and displays the booking details

## Notification Channels

Auto-select based on event type or specify manually:

```dart
// Booking events
CarNotificationChannel.bookingAlerts

// Trip & pickup/dropoff updates  
CarNotificationChannel.tripUpdates

// Support messages
CarNotificationChannel.supportMessages

// General promotions/updates
CarNotificationChannel.generalUpdates

// Background logs
CarNotificationChannel.systemLogs
```

## Custom Tap Handlers

For non-booking notifications, register a custom handler:

```dart
// In your app initialization
NotificationService.setNotificationTapHandler((payload) {
  if (payload['type'] == 'support_message') {
    Get.toNamed(Routes.supportChat, arguments: payload);
  }
});
```

## Testing

### Test Booking Notification Navigation
```dart
// In your test/dev screen
ElevatedButton(
  onPressed: () {
    NotificationService.showBookingNotification(
      title: 'Test Booking Accepted',
      body: 'Test notification for booking #42',
      bookingId: 42,
    );
  },
  child: const Text('Show Test Booking Notification'),
)
```

### Manual Test Flow
1. Show test notification
2. See notification in system tray
3. Tap notification
4. Should navigate to History Detail screen for booking ID 42
5. Booking details should load and display

## Notes

- Automatic navigation only works if `HistoryController` has the history list loaded
- If booking not found in local list, shows "Booking not found" message
- Payload keys are case-sensitive
- Both `booking_id` and `history_id` are checked (use either)
- String values in payload are automatically converted to integers where needed

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Notification not opening history detail | Check that `booking_id` or `history_id` is in payload |
| "Booking not found" message | Ensure history list is loaded before tapping notification |
| Notification not showing | Check channel importance and notification permissions |
| Wrong screen opens | Verify custom tap handler isn't overriding booking handler |

