# Booking Form Enhancement - Implementation Guide

## Overview
Updated the booking process to dynamically adapt based on car pricing type. The system now supports both **per_day** and **per_km** pricing models with automatic form field generation and price calculation.

## Key Changes

### 1. **BookingController Updates** 
**File**: `lib/views/booking/controller/booking_controller.dart`

#### New Fields:
```dart
final quantityController = TextEditingController(); // Days or Distance
Rxn<Pricing> selectedPricing = Rxn<Pricing>();
RxString pricingType = ''.obs;        // 'per_day' or 'per_km'
RxString pricingUnit = ''.obs;        // 'day', 'km', etc.
RxDouble deliveryCharge = 0.0.obs;
RxDouble subtotal = 0.0.obs;
RxDouble total = 0.0.obs;
```

#### New Methods:

**`initializeWithCar(VendorCar car)`**
- Called when user selects a car from the list
- Sets pricing information from the car object
- Initializes form validation

**`_calculateCharges()`**
- Calculates subtotal: `quantity × price`
- Adds delivery charge if enabled (10% of subtotal by default)
- Updates total: `subtotal + deliveryCharge`

**`getQuantityLabel()`** 
- Returns localized label based on pricing type:
  - "عدد الأيام" for per_day pricing
  - "المسافة" for per_km pricing

**`getQuantityHint()`**
- Returns context-aware hint text with unit info

**`getPriceDisplayText()`**
- Returns formatted price string: "100 SAR/day"

**`getBookingData()`**
- Prepares booking payload with all calculated charges

#### Form Validation:
- Email (auto-filled from profile)
- Phone (auto-filled from profile)
- Quantity (days or distance)
- Delivery location (only required if delivery enabled)

---

### 2. **Booking Form UI Updates**
**File**: `lib/views/booking/widget/booking_all_fields.dart`

#### Removed:
- Distance and Destination fields (old payment model)
- Round trip date/time picker
- Round trip checkbox

#### Added:
- **Dynamic Quantity Field**: Shows "Days" or "Distance" label based on pricing type
- **Delivery Section**: Checkbox with optional location input
- **Pricing Summary Card**: Shows:
  - Price per unit (from car pricing)
  - Subtotal (quantity × price)
  - Delivery charge (if enabled)
  - Total amount (with green highlight)

#### Layout:
```
┌─ Email (Read-only from profile)
├─ Phone (From profile)
├─ Quantity (Days/Distance - dynamic)
├─ Delivery Checkbox
├─ Delivery Location (conditional)
├─ Pricing Summary Box
│  ├─ Price per unit
│  ├─ Subtotal
│  ├─ Delivery charge (if enabled)
│  └─ Total (highlighted)
├─ Notes (Optional)
└─ Continue Button
```

---

### 3. **Navigation Updates**
**Files**: 
- `lib/views/all_vendors_dashboard/widget/all_vendors_car_list_view.dart`
- `lib/views/all_vendors_dashboard/widget/all_vendors_car_carousel.dart`

#### Changes:
```dart
// Pass car data when navigating to booking
Get.toNamed(
  Routes.bookingScreen, 
  arguments: {'car': car}
);

// Initialize BookingController with car data
try {
  final bookingController = Get.find<BookingController>();
  bookingController.initializeWithCar(car);
} catch (e) {
  // Will be initialized in booking screen
}
```

#### Added Import:
```dart
import 'package:carbo/views/booking/controller/booking_controller.dart';
```

---

## Data Flow

### 1. **Car Selection**
```
AllVendors Dashboard
    ↓ (Click "Book Now")
    ↓ (Pass VendorCar object)
    ↓
BookingScreen (receives car as argument)
    ↓
BookingController.initializeWithCar()
    ↓ (Sets pricing type, unit, pricing object)
    ↓
UI Updates with dynamic form fields
```

### 2. **User Input & Calculation**
```
User enters quantity (days/km)
    ↓
_calculateCharges() triggered
    ↓
Subtotal = quantity × price
    ↓
If delivery enabled: deliveryCharge = subtotal × 0.1
    ↓
Total = subtotal + deliveryCharge
    ↓
UI updates with calculated amounts (reactive)
```

### 3. **Form Submission**
```
User clicks "Continue"
    ↓
BookingController.getBookingData()
    ↓
Returns map with all booking info:
  {
    email, phone, quantity,
    pricing_type, pricing_unit,
    delivery_required, delivery_location,
    notes, subtotal, delivery_charge, total
  }
    ↓
Preview Screen receives data
```

---

## Pricing Type Handling

### Per Day Pricing
```json
"pricing": {
  "type": "per_day",
  "currency": "SAR",
  "price": 100,
  "unit": "day",
  "display_name": "Price per day"
}
```
**Form shows**: "عدد الأيام" (Number of Days) input field

### Per Kilometer Pricing
```json
"pricing": {
  "type": "per_km",
  "currency": "SAR",
  "price": 5,
  "unit": "km",
  "display_name": "Price per kilometer"
}
```
**Form shows**: "المسافة" (Distance) input field

---

## Form Validation Rules

| Field | Required | Condition |
|-------|----------|-----------|
| Email | ✓ | Always (auto-filled from profile) |
| Phone | ✓ | Always (auto-filled from profile) |
| Quantity | ✓ | Always |
| Delivery Location | ✓ | Only when delivery checkbox is enabled |
| Notes | ✗ | Optional |

---

## Delivery Charge Logic

**Default Formula**: `deliveryCharge = subtotal × 0.1` (10%)

**To modify delivery calculation**, update in `BookingController._calculateCharges()`:
```dart
if (isDeliver.value) {
  // Option 1: Fixed amount
  deliveryCharge.value = 50;  // SAR 50 fixed
  
  // Option 2: Percentage-based (current)
  deliveryCharge.value = subtotal.value * 0.1;
  
  // Option 3: Dynamic based on distance/days
  double quantity = double.tryParse(quantityController.text) ?? 0;
  deliveryCharge.value = quantity * 5;  // SAR 5 per unit
} else {
  deliveryCharge.value = 0;
}
```

---

## Preview Screen Integration

The preview screen should:

1. **Receive booking data** from BookingController
2. **Display summary** including:
   - Car details (make, model, year)
   - Quantity and unit
   - Base price
   - Subtotal
   - Delivery charge (if applicable)
   - Total amount

3. **Example mapping**:
```dart
final bookingData = Get.find<BookingController>().getBookingData();

// Display in preview:
- Quantity: "${bookingData['quantity']} ${bookingData['pricing_unit']}"
- Subtotal: "${bookingData['subtotal']}"
- Delivery: "${bookingData['delivery_charge']}"
- Total: "${bookingData['total']}"
```

---

## User Profile Data

Email and phone are auto-filled from `LocalStorage`:
```dart
emailController.text = LocalStorage.email;
mobileController.text = LocalStorage.number;
```

**Ensure these values are saved** when user logs in or updates profile.

---

## Testing Checklist

- [ ] Per day pricing: user enters days → subtotal calculates correctly
- [ ] Per km pricing: user enters distance → subtotal calculates correctly
- [ ] Delivery checkbox: toggling shows/hides location field
- [ ] Form validation: all required fields validated
- [ ] Price display: shows correct unit and currency symbol
- [ ] Delivery charge: calculates as 10% of subtotal
- [ ] Quantity change: updates all calculations in real-time
- [ ] Email/phone: pre-filled from profile, not editable
- [ ] Continue button: disabled until form is valid
- [ ] Preview screen: receives correct booking data

---

## Files Modified

1. ✅ `lib/views/booking/controller/booking_controller.dart`
2. ✅ `lib/views/booking/widget/booking_all_fields.dart`
3. ✅ `lib/views/all_vendors_dashboard/screen/all_vendors_dashboard_screen.dart` (import added)
4. ✅ `lib/views/all_vendors_dashboard/widget/all_vendors_car_list_view.dart`
5. ✅ `lib/views/all_vendors_dashboard/widget/all_vendors_car_carousel.dart`

---

## Next Steps

1. **Update Preview Controller** to handle new booking data format
2. **Update Preview Screen UI** to display delivery charges
3. **Test API integration** with real vendor cars endpoint
4. **Adjust delivery charge formula** if needed
5. **Add analytics** to track booking with different pricing types
