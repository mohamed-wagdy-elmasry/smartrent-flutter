# Pusher Beams Implementation with Firebase Cloud Messaging

This implementation uses Firebase Cloud Messaging (FCM) to provide push notification functionality compatible with Pusher Beams.

## Overview

Due to dependency conflicts with the official `pusher_beams` package (uuid version mismatch), we've implemented a custom FCM-based solution that integrates with Pusher Beams' infrastructure.

## Architecture

- **Firebase Cloud Messaging**: Handles the actual push notification delivery
- **Pusher Beams API**: Backend service for managing device registration and targeting
- **PusherBeamsService**: Flutter service class that bridges FCM and Pusher Beams

## Configuration

### 1. Firebase Setup

Ensure you have `google-services.json` in `android/app/` directory with your Firebase project configuration.

### 2. Android Configuration

The following is already configured:

**android/app/build.gradle**:
```gradle
plugins {
    id "com.google.gms.google-services"
}

dependencies {
    implementation platform("com.google.firebase:firebase-bom:34.7.0")
    implementation "com.google.firebase:firebase-analytics"
    implementation "com.google.firebase:firebase-messaging"
}
```

**android/build.gradle**:
```gradle
plugins {
    id "com.google.gms.google-services" version "4.4.4" apply false
}
```

### 3. Pusher Beams Instance

Instance ID: `e2aaf506-f2b9-43fe-81b6-0d26c5fe5596`

Configure this in your Pusher Beams dashboard to use FCM as the provider.

## Usage

### Initialization

The service is automatically initialized in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize Pusher Beams
  await PusherBeamsService.instance.initialize();
  await PusherBeamsService.instance.setDeviceInterests(['hello']);
  
  runApp(const MyApp());
}
```

### Subscribe to Topics/Interests

```dart
// Subscribe to a single interest
await PusherBeamsService.instance.addDeviceInterest('orders');

// Subscribe to multiple interests
await PusherBeamsService.instance.setDeviceInterests(['orders', 'updates', 'promotions']);

// Unsubscribe from an interest
await PusherBeamsService.instance.removeDeviceInterest('promotions');
```

### Handle Notifications

#### Foreground Messages

```dart
PusherBeamsService.instance.onMessageReceivedInForeground((message) {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
});
```

#### Background/Terminated Messages

```dart
// When user taps notification
PusherBeamsService.instance.onMessageOpenedApp((message) {
  // Handle navigation or action
  print('User tapped notification: ${message.data}');
});

// Get initial message if app was opened from notification
RemoteMessage? initialMessage = await PusherBeamsService.instance.getInitialMessage();
if (initialMessage != null) {
  // Handle the initial message
}
```

### Get FCM Token

```dart
String? token = PusherBeamsService.instance.getFcmToken();
print('FCM Token: $token');
```

## Sending Notifications

### Using Pusher Beams API

Send notifications using Pusher Beams REST API:

```bash
curl -X POST https://e2aaf506-f2b9-43fe-81b6-0d26c5fe5596.pushnotifications.pusher.com/publish_api/v1/instances/e2aaf506-f2b9-43fe-81b6-0d26c5fe5596/publishes \
  -H "Authorization: Bearer YOUR_SECRET_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "interests": ["hello"],
    "fcm": {
      "notification": {
        "title": "Hello",
        "body": "Hello, world!"
      }
    }
  }'
```

### From Laravel Backend

```php
use Pusher\PushNotifications\PushNotifications;

$beamsClient = new PushNotifications([
    'instanceId' => 'e2aaf506-f2b9-43fe-81b6-0d26c5fe5596',
    'secretKey' => 'YOUR_SECRET_KEY',
]);

$publishResponse = $beamsClient->publishToInterests(
    ['hello'],
    [
        'fcm' => [
            'notification' => [
                'title' => 'Hello',
                'body' => 'Hello, world!',
            ],
        ],
    ]
);
```

## Features

✅ Device registration with Pusher Beams  
✅ Subscribe/unsubscribe to interests (topics)  
✅ Foreground notification handling  
✅ Background notification handling  
✅ Notification tap handling  
✅ FCM token management  
✅ Token refresh handling  
✅ iOS permission requests  
✅ Android notification support  

## Dependencies

```yaml
firebase_core: ^3.10.0
firebase_messaging: ^15.1.6
```

## Notes

- The service automatically requests notification permissions on iOS
- FCM tokens are automatically refreshed and re-registered with Pusher Beams
- Background message handling requires the handler to be a top-level function
- The service uses FCM topics (interests) which are compatible with Pusher Beams targeting

## Troubleshooting

### No notifications received

1. Check Firebase Console for your project configuration
2. Verify `google-services.json` is in the correct location
3. Ensure the device has internet connectivity
4. Check that the app has notification permissions
5. Verify the FCM token is being generated (check logs)

### Token not registering with Pusher Beams

1. Verify your Pusher Beams instance ID is correct
2. Check the Pusher Beams dashboard for device registration
3. Ensure your Firebase project is linked to Pusher Beams

### iOS notifications not working

1. Enable Push Notifications capability in Xcode
2. Configure APNs in Firebase Console
3. Ensure proper provisioning profile is used
4. Check that the app requests notification permissions

## References

- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Pusher Beams Documentation](https://pusher.com/docs/beams)
- [Firebase Flutter Setup](https://firebase.flutter.dev/docs/overview)
