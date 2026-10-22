# Moyasar Integration Guide

## 1. Configuration

### iOS (`ios/Runner/Info.plist`)
Add the following keys to your `Info.plist` to support Apple Pay (if enabled) and network requests.

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

If you plan to use Apple Pay with Moyasar SDK in the future:
```xml
<key>com.apple.developer.in-app-payments</key>
<array>
    <string>merchant.com.yourdomain.app</string>
</array>
```

### Android (`android/app/src/main/AndroidManifest.xml`)
Ensure you have internet permission (usually already there).

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## 2. Usage

To navigate to the checkout screen, use the following code:

```dart
Get.to(
  () => const CheckoutScreen(),
  arguments: {
    'amount': 100.0, // Amount in SAR
    'description': 'Booking #123',
  },
);
```

## 3. Implementation Details

- **Service**: `lib/base/api/services/moyasar_payment_service.dart`
  - Handles the backend API call to `/payments`.
- **Controller**: `lib/views/checkout/controller/checkout_controller.dart`
  - Handles form validation.
  - Tokenizes card data directly via Moyasar API (`https://api.moyasar.com/v1/tokens`).
  - Initiates payment on backend.
  - Handles 3DS redirection via WebView.
- **UI**: `lib/views/checkout/checkout_screen.dart`
  - Custom credit card form using `PrimaryInputWidget`.
  - Validated using `form_builder_validators`.

## 4. Notes

- The implementation uses direct API calls for tokenization to ensure full control and compatibility with the "Tokenize Only" requirement.
- Ensure your backend is running and accessible at the configured URL.
- The `publishableKey` is hardcoded in `CheckoutController`. Consider moving it to a config file or environment variable.
