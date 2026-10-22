# Booking Data Flow: From Booking to Preview to Confirmation

## Overview

This document describes how booking data (including car ID and slug) flows from the BookingController through the PreviewController to the final booking confirmation API.

## Data Flow Architecture

```
Booking Screen (BookingController)
    ↓
    └─→ getBookingData() [returns Map with car_id, total, pricing, etc]
        ↓
    Get.toNamed(Routes.PREVIEW, arguments: bookingData)
        ↓
PreviewController.onInit()
    ├─→ Extracts car_id from bookingData
    ├─→ Initializes Id.value (RxString)
    ├─→ Initializes totalPayable.value
    └─→ Calls getPreviewData()
        ↓
getPreviewData() [API call to fetch preview details]
    ├─→ Gets slug from API response (Car object)
    ├─→ Initializes slug.value (RxString)
    ├─→ Loads payment gateways
    └─→ Fallback if API fails
        ↓
PreviewScreen [displays car, payment options, confirm button]
    ↓
User clicks "Confirm Booking" → handlePaymentProcess()
    ├─→ Validates Id and slug are set
    ├─→ Calls processPayTabsPayment()
        ↓
processPayTabsPayment()
    ├─→ Creates PayTabs payment with cart details
    ├─→ Passes car_id and slug in userDefined data
    └─→ Returns payment URL
        ↓
PayTabsPaymentScreen [WebView with payment form]
    ↓
User completes payment → handlePaymentSuccess(transactionRef)
    ├─→ Validates booking data exists
    ├─→ Validates car_id and slug are set
    ├─→ Builds confirmation body with all data
    └─→ Submits to API.bookingConfirm endpoint
        ↓
API Response
    └─→ Success: Navigate to confirmation screen
    └─→ Failure: Show error message
```

## Data Structure

### BookingController.getBookingData()

Returns a `Map<String, dynamic>` with the following structure:

```dart
{
  'email': 'user@example.com',
  'phone': '+966501234567',
  'quantity': '3',  // days or km
  'pricing_type': 'per_day',  // or 'per_km'
  'pricing_unit': 'day',
  'delivery_required': true,
  'delivery_location': 'Address, City',
  'notes': 'Special instructions',
  'subtotal': 1500.0,
  'delivery_charge': 100.0,
  'tax_amount': 161.0,
  'tax_enabled': true,
  'tax_percentage': 15.0,
  'total': 1761.0,
  'car_id': 42,           // ← IMPORTANT: Car ID from VendorCar
  'id': 42,               // ← NEW: Duplicate for preview compatibility
  'car_name': 'Toyota Camry',
  'currency': 'SAR',
}
```

### PreviewController Reactive Variables

```dart
RxString Id = ''.obs;              // Car ID (initialized from bookingData)
RxString slug = ''.obs;            // Car slug (from API or fallback)
RxDouble totalPayable = 0.0.obs;   // Total amount (from bookingData)
RxString alias = ''.obs;           // Payment gateway alias
Rxn<Map<String, dynamic>> bookingData;  // Stored booking data reference
```

## Initialization Flow (onInit)

### Step 1: Extract Booking Data

```dart
if (Get.arguments != null && Get.arguments is Map) {
  bookingData.value = Get.arguments;
  
  // Extract total amount
  if (bookingData.value!.containsKey('total')) {
    totalPayable.value = (bookingData.value!['total'] ?? 0).toDouble();
    log.i('Initialized totalPayable from bookingData: ${totalPayable.value}');
  }
  
  // Extract car ID
  final carId = bookingData.value!['car_id'] ?? bookingData.value!['id'];
  if (carId != null) {
    Id.value = carId.toString();
    log.i('Initialized car ID from bookingData: ${Id.value}');
  }
}
```

### Step 2: Fallback to BookingController

If booking data wasn't passed as arguments, retrieve from BookingController:

```dart
final bookingController = Get.find<BookingController>();
bookingData.value = bookingController.getBookingData();
totalPayable.value = (bookingData.value?['total'] ?? 0).toDouble();

// Extract car ID
final carId = bookingData.value?['car_id'] ?? bookingData.value?['id'];
if (carId != null) {
  Id.value = carId.toString();
  log.i('Retrieved car ID from BookingController: ${Id.value}');
}
```

### Step 3: Fetch Preview Data

```dart
getPreviewData()
  ↓
  Extracts slug from API response:
  slug.value = _bookingPreviewModel.data.car.slug;
  
  OR falls back to default if API fails:
  slug.value = 'default_slug_${Id.value}';
```

## Payment Processing Flow

### processPayTabsPayment()

Uses car_id and slug in the PayTabs request:

```dart
final paymentResult = await PayTabsService.createPayment(
  cartId: cartId,
  cartAmount: amount,
  cartDescription: 'Car rental booking for ${carModel.value}',
  // ... other fields ...
  userDefined: {
    'car_id': Id.value,           // ← From bookingData
    'car_slug': slug.value,       // ← From API or fallback
    'location': bookingData.value?['delivery_location'] ?? '',
    'fees': amount.toString(),
    'tax_amount': bookingData.value?['tax_amount'] ?? 0,
    'delivery_charge': bookingData.value?['delivery_charge'] ?? 0,
    'subtotal': bookingData.value?['subtotal'] ?? 0,
    // ... other fields ...
  },
);
```

### handlePaymentSuccess()

Validates and submits complete booking:

```dart
Map<String, dynamic> inputBody = {
  // Booking details
  'location': bookingData.value?['delivery_location'] ?? '',
  'message': bookingData.value?['notes'] ?? '',
  'mobile': bookingData.value?['phone'] ?? '',
  'credentials': bookingData.value?['email'] ?? '',
  
  // Car identifiers (KEY DATA)
  'car_id': Id.value,          // ← From bookingData (via onInit)
  'car_slug': slug.value,      // ← From API (via getPreviewData)
  
  // Payment info
  'gateway_type': 'paytabs',
  'gateway_currency': alias.value,
  'payment': 'online-payment',
  'token': dashboardController.carToken.value,
  'fees': (bookingData.value?['total'] ?? 0).toString(),
  'transaction_ref': transactionRef,
  
  // Pricing breakdown
  'quantity': bookingData.value?['quantity'],
  'pricing_type': bookingData.value?['pricing_type'],
  'delivery_required': bookingData.value?['delivery_required'] ?? false,
  'delivery_charge': bookingData.value?['delivery_charge'] ?? 0,
  'subtotal': bookingData.value?['subtotal'] ?? 0,
  
  // Tax info
  'tax_amount': bookingData.value?['tax_amount'] ?? 0,
  'tax_enabled': bookingData.value?['tax_enabled'] ?? false,
  'tax_percentage': bookingData.value?['tax_percentage'] ?? 0,
  
  // Optional
  'car_area': _selectedCarAreaId,
};
```

## Logging Points

The data flow includes comprehensive logging:

### onInit() Logging
```
✓ Initialized totalPayable from bookingData: 1761.0
✓ Initialized car ID from bookingData: 42
```

### getPreviewData() Logging
```
✓ Car info - slug: "toyota-camry-2024", id: "42"
✓ Payment gateway selected: "PayTabs"
```

### handlePaymentProcess() Logging
```
✓ Car identifiers - ID: 42, Slug: toyota-camry-2024
```

### handlePaymentSuccess() Logging
```
✓ Processing payment success for transaction: TXN-12345
✓ Booking data: {...}
✓ Car identifiers - ID: 42, Slug: toyota-camry-2024
✓ Submitting booking confirmation with body: {...}
✓ Booking confirmation successful
```

## Data Validation

### In onInit()
- ✅ Checks if bookingData is not null
- ✅ Validates car_id exists
- ✅ Validates total amount exists

### In getPreviewData()
- ✅ Validates car ID not empty
- ✅ Validates car slug populated (from API)
- ✅ Fallback if API fails

### In handlePaymentProcess()
- ✅ Validates slug not empty
- ✅ Validates Id not empty
- ✅ Validates totalPayable > 0

### In handlePaymentSuccess()
- ✅ Validates bookingData exists
- ✅ Validates slug not empty
- ✅ Validates Id not empty

## Key Changes Made

### BookingController
```dart
// Added explicit 'id' field to bookingData for preview compatibility
Map<String, dynamic> getBookingData() {
  return {
    // ... existing fields ...
    'car_id': selectedCar.value?.id,
    'id': selectedCar.value?.id,  // ← NEW
    // ... rest of fields ...
  };
}
```

### PreviewController.onInit()
```dart
// Enhanced to extract car ID from bookingData
if (bookingData.value != null) {
  final carId = bookingData.value!['car_id'] ?? bookingData.value!['id'];
  if (carId != null) {
    Id.value = carId.toString();
    log.i('Initialized car ID from bookingData: ${Id.value}');
  }
}

// Also handles fallback from BookingController
final carId = bookingData.value?['car_id'] ?? bookingData.value?['id'];
if (carId != null) {
  Id.value = carId.toString();
  log.i('Retrieved car ID from BookingController: ${Id.value}');
}
```

## API Endpoints Used

### 1. Get Preview Data
- **Endpoint:** `ApiEndpoint.getPreviewData`
- **Method:** GET
- **Parameters:** `token`, `car_id` (from query params)
- **Returns:** `BookingPreviewModel` with car slug, payment gateways, etc.

### 2. Create Payment (PayTabs)
- **Endpoint:** PayTabs API
- **Method:** POST
- **Payload:** Includes `car_id` and `car_slug` in userDefined fields

### 3. Confirm Booking
- **Endpoint:** `ApiEndpoint.bookingConfirm`
- **Method:** POST
- **Payload:** Complete booking details including `car_id`, `car_slug`, payment info, pricing, tax, etc.
- **Returns:** `CommonSuccessModel`

## Testing Checklist

- [ ] Complete booking form with all required fields
- [ ] Navigate to preview screen → verify car_id initialized from bookingData
- [ ] Verify slug populated from API or fallback
- [ ] Click confirm booking → check logs show car_id and slug
- [ ] Complete payment in PayTabs
- [ ] Verify booking confirmation submitted with all data
- [ ] Check API receives car_id, slug, and all pricing fields
- [ ] Verify booking confirmation successful

## Troubleshooting

### Issue: Car ID Not Initialized
**Solution:** Check that bookingData is passed from BookingScreen or BookingController has getBookingData() available

### Issue: Slug Empty in Payment
**Solution:** Ensure getPreviewData API is returning car slug, or check fallback is working

### Issue: Booking Confirmation Fails
**Solution:** Verify all required fields (car_id, slug, email, phone, amount) are populated in inputBody

## Related Files

- `lib/views/booking/controller/booking_controller.dart` - Booking form and data
- `lib/views/preview/controller/preview_controller.dart` - Preview logic and data management
- `lib/views/preview/model/booking_preview_model.dart` - Data models
- `lib/base/api/endpoint/api_endpoint.dart` - API endpoints
- `lib/base/api/services/paytabs_service.dart` - Payment processing
