# Token Management - Quick Reference Card

## Current Implementation

### Token Sources
| Token | Source | Used For | Validity |
|-------|--------|----------|----------|
| **Vendor Token** | API: /cars → AllVendorsDashboard | Preview API call | Per vendor |
| **Booking Token** | API: /preview → bookingData | Confirm booking | Per session |

### Methods Updated

```dart
// 1. Preview API Call
getPreviewData() {
  final bookingToken = dashboardController.carToken.value;
  GET /user/booking/preview?token=<vendor_token>&car_id=13
}

// 2. Auto Booking
bookingProcessAuto() {
  final bookingToken = bookingData.value?['token'] ?? '';
  POST /user/booking/confirm with bookingToken
}

// 3. Manual Payment
bookingManualProcess() {
  final bookingToken = bookingData.value?['token'] ?? '';
  POST /user/booking/confirm with bookingToken
}

// 4. PayTabs Success
handlePaymentSuccess(transactionRef) {
  final bookingToken = bookingData.value?['token'] ?? '';
  POST /user/booking/confirm with bookingToken
}
```

## Key Points

✅ **Preview API**: Uses vendor token from car selection
✅ **Booking APIs**: All use booking token from preview response
✅ **Error Handling**: Validates token exists before each API call
✅ **Session Integrity**: No fallback to LocalStorage for booking operations
✅ **All Payment Methods**: Consistent token usage across Auto/Manual/PayTabs

## Quick Flow

```
Car Selection
    ↓
Vendor Token → dashboardController.carToken
    ↓
Preview API (vendor token)
    ↓
Booking Token → bookingData['token']
    ↓
Confirm Booking (booking token)
```

## Files Modified

- `lib/views/preview/controller/preview_controller.dart`

## Validation Rules

| Scenario | Token | Action |
|----------|-------|--------|
| No vendor token | Empty | Show "Select car again" → return null |
| No booking token | Empty | Show "Session expired" → return/null |
| Valid tokens | Present | Proceed with API calls |

## Error Messages

| Method | Error | Message |
|--------|-------|---------|
| getPreviewData | No vendor token | "Booking token is missing. Please select a car again." |
| bookingProcessAuto | No booking token | "Booking session expired. Please go back and refresh your booking." |
| bookingManualProcess | No booking token | "Booking session expired. Please go back and refresh your booking." |
| handlePaymentSuccess | No booking token | "Booking session expired. Please go back and try again." |

## No Changes In

- AllVendorsDashboardController (already working)
- DashboardController (already working)
- BookingController (already working)
- Car Carousel (already working)

✅ Implementation Complete and Tested
