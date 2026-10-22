# Wallet Feature Implementation

Complete wallet functionality with top-up, balance tracking, transactions, and booking payment integration.

## 📁 Files Created

### Models
- `lib/models/wallet_balance.dart` - Wallet balance model with currency support
- `lib/models/wallet_transaction.dart` - Transaction model with enums for type/status

### Services
- `lib/services/wallet_service.dart` - API service for wallet operations (balance, transactions, top-up, charge)

### Controllers
- `lib/controllers/wallet_controller.dart` - GetX controller with reactive state, optimistic updates, polling

### Views
- `lib/views/wallet/wallet_screen.dart` - Complete wallet UI with balance cards, transaction list, top-up dialog

### Helpers
- `lib/helpers/wallet_payment_helper.dart` - Integration helper for booking payments (full/partial wallet)

### Storage
- `lib/base/storage/secure_storage_helper.dart` - Secure token storage wrapper using flutter_secure_storage

### API
- Updated `lib/base/api/endpoint/api_endpoint.dart` - Added wallet endpoint enums

### Localization
- Updated `lib/l10n/app_en.arb` - Added 38 wallet-related string keys

### Tests
- `test/wallet_service_test.dart` - Unit tests for WalletService (12 tests)
- `test/wallet_controller_test.dart` - Unit tests for WalletController (13 tests)
- `test/wallet_screen_test.dart` - Widget tests for WalletScreen (10 tests)

## 🚀 Features Implemented

### ✅ Wallet Balance
- Multi-currency support (SAR, USD, EGP)
- Real-time balance display with horizontal scrollable cards
- Optimistic UI updates with pending indicators
- Pull-to-refresh and auto-sync on app resume

### ✅ Transactions
- Paginated transaction history
- Transaction types: top-up, debit, refund (wallet/card)
- Status badges: pending, completed, failed, cancelled
- Infinite scroll with load more
- Formatted dates and amounts

### ✅ Top-Up Flow
1. User taps "Top Up" button
2. Enters amount and selects currency
3. App generates idempotency key (UUID v4)
4. Server returns PayTabs payment URL
5. App opens payment in webview/browser
6. After redirect, app polls transaction status (exponential backoff, max 10 attempts)
7. Wallet credited on webhook confirmation
8. UI updated with success/failure notification

### ✅ Booking Payment Integration
- `WalletPaymentHelper.checkWalletForBooking()` - Check if wallet can cover amount
- `WalletPaymentHelper.processBookingPayment()` - Full or partial wallet payment
- Optimistic balance deduction with auto-revert on error
- Fallback to PayTabs for insufficient balance
- Partial payment: use wallet + card for remainder

### ✅ Security
- Secure token storage via `flutter_secure_storage`
- Backward compatibility with GetStorage
- Automatic migration on first launch
- Encrypted shared preferences (Android) / Keychain (iOS)

### ✅ Error Handling
- Network error detection (SocketException, TimeoutException)
- User-friendly error messages
- Retry mechanisms with idempotency
- Snackbar notifications for all operations

### ✅ Testing
- **35 total tests** across service, controller, and widget layers
- Mock HTTP client for service tests
- Controller state verification
- UI rendering and interaction tests
- Edge cases: network errors, insufficient balance, pagination

## 📋 API Integration

All endpoints align with backend spec (see `WALLET_FRONTEND_API.md`):

```dart
GET  /api/v1/wallet/balance
GET  /api/v1/wallet/transactions
POST /api/v1/wallet/top-up
POST /api/v1/wallet/charge
POST /api/v1/wallet/refund-to-wallet
POST /api/v1/wallet/refund-to-card
POST /api/v1/wallet/paytabs/webhook
GET  /api/v1/wallet/paytabs/return
```

### Request Format
```json
{
  "amount": "100.00",
  "currency": "SAR",
  "idempotency_key": "uuid-v4",
  "description": "Top up wallet"
}
```

### Response Format
```json
{
  "success": true,
  "data": {
    "payment_url": "https://paytabs.com/pay/token",
    "wallet_transaction_id": 123,
    "status": "pending"
  }
}
```

## 🎨 UI Components

### Balance Card
- Gradient background (primary color)
- Currency badge
- Available balance in large font
- Pending indicator (amber icon) for optimistic changes

### Transaction Item
- Type icon (colored circle avatar)
- Title and description
- Date formatted with intl (MMM dd, yyyy • HH:mm)
- Amount with +/- prefix (green/red)
- Status badge (colored, uppercase)

### Top-Up Dialog
- Amount input (numeric keyboard)
- Currency dropdown (SAR/USD/EGP)
- Cancel and Continue buttons
- Validation: non-empty, valid decimal

### States
- Loading: CircularProgressIndicator
- Empty: Icon + "No transactions yet"
- Error: Icon + message + Retry button
- Refreshing: Small spinner in header

## 🔧 Usage Examples

### Navigate to Wallet
```dart
Get.toNamed('/wallet'); // Add to routes
```

### Check Wallet Balance
```dart
final controller = Get.find<WalletController>();
final sarBalance = controller.getBalanceForCurrency('SAR');
```

### Charge Wallet for Booking
```dart
final success = await controller.chargeWalletForBooking(
  amount: '50.00',
  currency: 'SAR',
  bookingReference: 'BK12345',
);

if (success) {
  // Proceed with booking confirmation
} else {
  // Show error or redirect to PayTabs
}
```

### Partial Payment Flow
```dart
final result = await WalletPaymentHelper.processBookingPayment(
  amount: '100.00',
  currency: 'SAR',
  bookingReference: 'BK12345',
);

// If wallet covers partial, result indicates wallet charged
// Caller handles PayTabs for shortfall
```

### Refresh Wallet Data
```dart
await controller.refresh(); // Fetches balance + transactions
```

## 🧪 Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/wallet_service_test.dart
flutter test test/wallet_controller_test.dart
flutter test test/wallet_screen_test.dart

# Run with coverage
flutter test --coverage
```

### Expected Test Results
- ✅ 12 tests in `wallet_service_test.dart`
- ✅ 13 tests in `wallet_controller_test.dart`
- ✅ 10 tests in `wallet_screen_test.dart`
- **Total: 35 passing tests**

## 🔐 Platform Configuration

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<!-- Already handled by flutter_secure_storage plugin -->
<!-- Uses EncryptedSharedPreferences by default -->
```

### iOS (`ios/Runner/Info.plist`)
```xml
<!-- Keychain access automatically configured -->
<!-- No additional setup required -->
```

## 📱 Manual QA Checklist

### Balance & Transactions
- [ ] Open wallet screen - balance cards visible
- [ ] Multiple currencies display correctly
- [ ] Pull-to-refresh updates data
- [ ] Transaction list scrolls and loads more
- [ ] Empty state shows when no transactions
- [ ] Error state shows on network failure with retry button

### Top-Up Flow
- [ ] Tap "Top Up" - dialog opens
- [ ] Enter invalid amount - validation error
- [ ] Enter valid amount - continues to PayTabs
- [ ] Complete payment - polling starts
- [ ] Return to app - balance updates within 20s
- [ ] Cancel payment - transaction shows as pending/failed
- [ ] Test duplicate request (same idempotency key) - same transaction returned

### Booking Payment
- [ ] Sufficient balance - wallet charged, booking proceeds
- [ ] Insufficient balance - error shown, prompted to top up
- [ ] Partial balance - dialog offers wallet + card payment
- [ ] Optimistic update - balance decrements immediately
- [ ] Network error - balance reverts, error shown
- [ ] Success - balance and transaction list refresh

### Edge Cases
- [ ] Airplane mode - appropriate error messages
- [ ] Token expired - 401 handled, redirect to login
- [ ] Server error (500) - retry option shown
- [ ] Rapid taps on top-up - no duplicate transactions
- [ ] App backgrounded during polling - resumes on return
- [ ] App killed during payment - transaction queryable on next launch

### Localization
- [ ] All strings use localization keys (no hardcoded English)
- [ ] RTL support tested (Arabic)
- [ ] Date formats respect locale

### Accessibility
- [ ] Screen reader announces balance amounts
- [ ] Transaction items readable by TalkBack/VoiceOver
- [ ] Buttons have semantic labels
- [ ] Touch targets ≥48dp

## 📊 Analytics & Monitoring Suggestions

### Events to Track
```dart
// Top-up initiated
analytics.logEvent(
  name: 'wallet_topup_initiated',
  parameters: {'amount': amount, 'currency': currency},
);

// Top-up completed
analytics.logEvent(
  name: 'wallet_topup_completed',
  parameters: {'transaction_id': id, 'amount': amount},
);

// Booking payment via wallet
analytics.logEvent(
  name: 'booking_wallet_payment',
  parameters: {'booking_ref': ref, 'amount': amount},
);

// Errors
analytics.logEvent(
  name: 'wallet_error',
  parameters: {'error_type': type, 'operation': op},
);
```

### Crashlytics
```dart
try {
  // Wallet operation
} catch (e, stack) {
  FirebaseCrashlytics.instance.recordError(e, stack);
  log.e('Wallet error: $e');
}
```

### Performance Monitoring
```dart
final trace = FirebasePerformance.instance.newTrace('wallet_top_up_flow');
await trace.start();
// ... top-up flow
await trace.stop();
```

## 🐛 Known Issues & Future Enhancements

### Current Limitations
1. **Polling vs Webhooks**: Polling used for payment confirmation; future: WebSocket or push notifications
2. **Currency Conversion**: No automatic conversion; user must top up in booking currency
3. **Transaction Filtering**: UI doesn't expose type/currency filters (API supports it)
4. **Offline Mode**: No local caching of transactions for offline viewing

### Planned Enhancements
1. **Wallet Binding**: Create `WalletBinding` for route-based dependency injection
2. **Receipt Generation**: PDF receipt for transactions
3. **Scheduled Top-Ups**: Auto top-up when balance falls below threshold
4. **Multi-Step Top-Up**: Support for split payments (wallet + multiple cards)
5. **Transaction Search**: Search by date range, amount, or description
6. **Export Transactions**: CSV/PDF export for accounting

## 🔗 Integration Points

### Add Wallet Route
```dart
// In routes file
GetPage(
  name: '/wallet',
  page: () => const WalletScreen(),
  binding: BindingsBuilder(() {
    Get.lazyPut(() => WalletController());
  }),
),
```

### Add Navigation from Dashboard
```dart
IconButton(
  icon: const Icon(Icons.account_balance_wallet),
  onPressed: () => Get.toNamed('/wallet'),
)
```

### Booking Flow Integration
```dart
// In booking preview/confirmation controller
import 'package:carbo/helpers/wallet_payment_helper.dart';

// Check wallet before proceeding
final check = await WalletPaymentHelper.checkWalletForBooking(
  amount: totalAmount.toString(),
  currency: 'SAR',
);

if (check['canCover']) {
  // Use wallet payment
  final success = await WalletPaymentHelper.processBookingPayment(
    amount: totalAmount.toString(),
    currency: 'SAR',
    bookingReference: bookingId,
  );
  
  if (success) {
    // Confirm booking
  }
} else {
  // Show shortfall, offer to top up or use card
  final shortfall = check['shortfall'];
  // Show dialog or redirect to PayTabs
}
```

## 📞 Support & Troubleshooting

### Common Issues

**Q: Balance not updating after payment**  
A: Check webhook logs on server. If webhook failed, transaction stays pending. Manual reconciliation via admin dashboard required.

**Q: Duplicate transactions appearing**  
A: Verify idempotency key is being sent correctly. Check server logs for duplicate key handling.

**Q: PayTabs redirect not working on iOS**  
A: Ensure URL scheme is registered in Info.plist. Consider using external browser instead of WKWebView.

**Q: Token migration fails**  
A: Migration is optional; app falls back to GetStorage. Check device keychain access permissions.

---

**Implementation Date**: November 20, 2025  
**Flutter Version**: 3.32.8  
**Dart SDK**: >=3.8.1 <4.4.0  
**GetX Version**: 4.7.2
