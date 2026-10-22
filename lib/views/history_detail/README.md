# History Detail Screen - Implementation Guide

## Overview
The History Detail Screen has been separated into its own module with responsive layouts for mobile and tablet devices. It supports navigation from both the history list and push notifications.

## File Structure
```
lib/views/history_detail/
├── screen/
│   ├── history_detail_screen.dart          # Main entry point
│   ├── history_detail_mobile_screen.dart   # Mobile layout
│   └── history_detail_tablet_screen.dart   # Tablet layout
├── widget/
│   └── (future widgets)
└── controller/
    └── (future controllers if needed)
```

## Navigation Support

### 1. From History List (existing)
```dart
// In history_card.dart
Get.toNamed(
  '/historyDetailScreen',
  arguments: {'history': historyObject},
);
```

### 2. From Push Notification
```dart
// Import the helper
import 'package:carbo/base/utils/notification_navigation.dart';

// Option A: Navigate with history ID (recommended for notifications)
NotificationNavigation.goToHistoryDetail(historyId: 123);

// Option B: Navigate with full history object
NotificationNavigation.goToHistoryDetail(history: historyObject);
```

### 3. Manual Navigation
```dart
// With history ID
Get.toNamed(
  Routes.historyDetailScreen,
  arguments: {'historyId': 123},
);

// With history object
Get.toNamed(
  Routes.historyDetailScreen,
  arguments: {'history': historyObject},
);
```

## Notification Integration Example

### Firebase Cloud Messaging (FCM)
```dart
// In your notification handler
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  final data = message.data;
  
  // Check notification type
  if (data['type'] == 'booking_accepted' || data['type'] == 'booking_status') {
    final bookingId = int.tryParse(data['booking_id'] ?? data['history_id'] ?? '');
    
    if (bookingId != null) {
      // Navigate to history detail
      NotificationNavigation.goToHistoryDetail(historyId: bookingId);
    }
  }
});
```

### Local Notifications (awesome_notifications)
```dart
// When notification is tapped
@pragma("vm:entry-point")
static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  final payload = receivedAction.payload;
  
  if (payload != null && payload['type'] == 'booking_accepted') {
    final bookingId = int.tryParse(payload['booking_id'] ?? '');
    
    if (bookingId != null) {
      NotificationNavigation.goToHistoryDetail(historyId: bookingId);
    }
  }
}
```

## How It Works

1. **With History ID (from notification)**:
   - Receives `historyId` from notification payload
   - Fetches history object from `HistoryController.historyList`
   - Displays booking details

2. **With History Object (from list)**:
   - Receives complete `History` object directly
   - Displays booking details immediately

3. **Fallback**:
   - If history not found, shows "Booking not found" message
   - User can navigate back to history list

## Features

### Mobile Layout
- Single column layout
- Scrollable sections
- Status card at top
- All booking details in expandable cards

### Tablet Layout
- Two-column layout for better space utilization
- Larger status card with icon and text side-by-side
- Car Details + Payment Details in first row
- Trip Details full width
- Contact + Message in second row
- Centered content with max-width constraint (900px)

## Data Displayed

### Status Card
- Visual status indicator (icon + color)
- Status text (Pending, Ongoing, Complete, Reject)

### Car Details
- Car Model
- Car Type
- Car Number

### Trip Details
- Pickup Location
- Destination
- Pickup Date & Time
- Return Date & Time (if applicable)
- Distance (km)
- Rental Days
- Delivery option

### Payment Details
- Amount (with currency)
- Additional Charges
- Payment Type
- Transaction ID

### Contact Details
- Phone Number
- Email Address

### Additional Information
- Custom Message/Notes
- Booking ID
- Reference/Slug
- Created/Updated timestamps
- Approval information

## Dependencies

Requires:
- `HistoryController` with `historyList` populated
- `BasicServices.baseCurCode` for currency display
- `Routes.historyDetailScreen` registered in routing

## Testing

To test notification navigation:

1. **From History List**: Tap any history card → Should navigate to detail screen
2. **From Notification**: Send test notification with `historyId` in payload
3. **Direct Navigation**: 
   ```dart
   NotificationNavigation.goToHistoryDetail(historyId: 1);
   ```

## Notes

- History list must be loaded before navigating with `historyId`
- If history not in local list, consider fetching from API
- Status colors match the history card badges
- Responsive design adapts to screen size automatically
