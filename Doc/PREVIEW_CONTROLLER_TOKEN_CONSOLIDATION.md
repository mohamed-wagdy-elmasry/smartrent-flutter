# Preview Controller Token Consolidation

## Overview
Consolidated the preview controller to use a single booking token flow instead of mixing vendor car token with booking token.

## Changes Made

### Token Flow Update

**Before**: Mixed usage of two different tokens
- `dashboardController.carToken.value` for preview API (vendor cars token)
- `bookingData.value?['token']` for confirm booking (booking token from preview response)
- Fallbacks to `LocalStorage.token` if missing

**After**: Single unified token flow
- Use `dashboardController.carToken.value` (vendor cars token) for preview API call
- Use `bookingData.value?['token']` (booking token from preview response) for all confirm booking operations
- No fallback to `LocalStorage.token` (maintains session integrity)

## Updated Methods

### 1. getPreviewData() - Line 179-198
**Change**: Extracted `bookingToken` variable with validation before API call

```dart
// Get booking token from dashboard controller (vendor cars token)
final String bookingToken = dashboardController.carToken.value;
if (bookingToken.isEmpty) {
  // Show error snackbar
  Future.delayed(Duration.zero, () {
    Get.snackbar(
      'Error',
      'Booking token is missing. Please select a car again.',
      snackPosition: SnackPosition.BOTTOM,
    );
  });
  return null;
}

// Await the request with booking token
BookingPreviewModel? result = await RequestProcess().request<BookingPreviewModel>(
  queryParams: {
    'token': bookingToken,  // Use extracted variable
    'car_id': dashboardController.selectedCarId.value,
  },
  // ... rest of request
);
```

**Purpose**: Early validation and clear intent - we're using the vendor cars token for preview

### 2. bookingProcessAuto() - Line 464-499
**Change**: Simplified token extraction for auto booking

```dart
// Get token from bookingData (from preview API response)
final String bookingToken = bookingData.value?['token'] ?? '';

if (bookingToken.isEmpty) {
  Get.snackbar(
    'Error',
    'Booking session expired. Please go back and refresh your booking.',
    snackPosition: SnackPosition.BOTTOM,
  );
  return null;
}
```

**Purpose**: Use booking-specific token from preview API response, no local storage fallback

### 3. bookingManualProcess() - Line 604-639
**Change**: Same token extraction pattern as bookingProcessAuto()

```dart
// Get token from bookingData (from preview API response)
final String bookingToken = bookingData.value?['token'] ?? '';

if (bookingToken.isEmpty) {
  Get.snackbar(
    'Error',
    'Booking session expired. Please go back and refresh your booking.',
    snackPosition: SnackPosition.BOTTOM,
  );
  return null;
}
```

**Purpose**: Consistent token handling across payment methods

### 4. handlePaymentSuccess() - Line 925-940
**Change**: Simplified token extraction for PayTabs success

```dart
// Get token from bookingData (from preview API response)
final String bookingToken = bookingData.value?['token'] ?? '';

if (bookingToken.isEmpty) {
  Get.snackbar(
    'Error',
    'Booking session expired. Please go back and try again.',
    snackPosition: SnackPosition.BOTTOM,
  );
  return;
}
```

**Purpose**: Use booking-specific token after PayTabs payment success

## Token Flow Diagram

```
┌──────────────────────────────────────────────────────────┐
│ Step 1: Car Selection (from AllVendors Dashboard)        │
├──────────────────────────────────────────────────────────┤
│ Vendor Cars API Response:                                │
│ {                                                        │
│   "data": {                                              │
│     "token": "U5cOjXHRck3szMr3B338",  ← Vendor Token    │
│     "cars": [...]                                        │
│   }                                                      │
│ }                                                        │
│                                                          │
│ Stored in: dashboardController.carToken.value           │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│ Step 2: Preview Booking API Call                         │
├──────────────────────────────────────────────────────────┤
│ GET /user/booking/preview                                │
│ Parameters:                                              │
│   - token: dashboardController.carToken.value ← VENDOR   │
│   - car_id: 13                                           │
│                                                          │
│ Uses: Vendor-specific token for accurate preview data    │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│ Step 3: Preview API Response                             │
├──────────────────────────────────────────────────────────┤
│ Response contains:                                       │
│ {                                                        │
│   "data": {                                              │
│     "token": "different_booking_token_123",              │
│     "car": {...},                                        │
│     "pricing": {...}                                     │
│   }                                                      │
│ }                                                        │
│                                                          │
│ Stored in: bookingData.value['token']                    │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│ Step 4: Confirm Booking API Call                         │
├──────────────────────────────────────────────────────────┤
│ POST /user/booking/confirm                               │
│ Body:                                                    │
│   - token: bookingData.value['token'] ← BOOKING SESSION  │
│   - car_id: 13                                           │
│   - payment_method: ...                                  │
│   - etc.                                                 │
│                                                          │
│ Uses: Booking-specific token from preview response       │
└──────────────────────────────────────────────────────────┘
```

## Key Improvements

✅ **Clear Token Purpose**: Each token is used for its intended API endpoint
  - Vendor token: for getting preview data
  - Booking token: for confirming the booking

✅ **Simplified Logic**: Removed unnecessary fallback to LocalStorage.token
  - If booking token is missing, session is invalid anyway
  - Cleaner validation with empty string check

✅ **Consistent Error Messages**: Updated all error messages to be more specific
  - "Booking token is missing. Please select a car again." (preview)
  - "Booking session expired. Please go back and refresh your booking." (confirm)

✅ **Type Safety**: All token variables are `String` with proper null coalescing
  - Explicit validation before use
  - Consistent error handling

✅ **Backward Compatibility**: All payment methods updated consistently
  - bookingProcessAuto (online payment)
  - bookingManualProcess (manual payment)
  - handlePaymentSuccess (PayTabs payment)

## Files Modified

- `lib/views/preview/controller/preview_controller.dart`
  - getPreviewData() method
  - bookingProcessAuto() method
  - bookingManualProcess() method
  - handlePaymentSuccess() method

## Testing Checklist

- [x] Preview API call uses vendor cars token
- [x] Booking data captures token from preview response
- [x] Auto booking uses preview response token
- [x] Manual payment uses preview response token
- [x] PayTabs success uses preview response token
- [x] Proper validation of token before API calls
- [x] Error messages are clear and actionable
- [x] No compilation errors

## Summary

The preview controller now follows a clean token flow:

1. **Vendor Cars Token** → Used to fetch booking preview
2. **Booking Token** (from preview) → Used to confirm booking

This ensures proper session management and accurate booking data throughout the entire flow. The booking token from the preview API response contains the necessary information for completing the booking, making it the single source of truth for all subsequent booking operations.
