# Quick Reference - Booking Form Changes

## What Changed?

### Before:
- Distance field + Destination field
- Round trip checkbox
- Manual calculation
- No real-time pricing display

### After:
- Dynamic "Days" or "Distance" field based on car pricing type
- Delivery location checkbox (optional)
- Real-time price calculation
- Live pricing summary with breakdown

---

## How It Works

### Step 1: User Selects Car
```dart
// VendorCar with pricing data
VendorCar {
  id: 13,
  pricing: Pricing {
    type: "per_day",
    price: 100,
    unit: "day",
    currency: "SAR",
  }
}
```

### Step 2: Booking Form Opens
- Email auto-filled: user@example.com ✓
- Phone auto-filled: +966501234567 ✓
- Form shows "عدد الأيام" (Days) field

### Step 3: User Enters Quantity
- Enters: 5 days
- Real-time calc: 5 × 100 = 500 SAR subtotal

### Step 4: User Toggles Delivery
- Checks delivery checkbox
- Form shows delivery location input
- Calc: 500 × 10% = 50 SAR delivery charge
- Total: 550 SAR

### Step 5: Submit
- Booking data sent to preview with all calculations

---

## Key Controller Methods

### Initialize with Car
```dart
bookingController.initializeWithCar(vendorCar);
// Sets: pricingType, pricingUnit, selectedPricing
```

### Get Form Labels
```dart
String label = bookingController.getQuantityLabel();
// Returns: "عدد الأيام" or "المسافة"

String hint = bookingController.getQuantityHint();
// Returns: hint with unit info
```

### Get Booking Data
```dart
Map<String, dynamic> data = bookingController.getBookingData();
// Returns: complete booking with all charges
```

---

## Form Fields

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| Email | Text | ✓ | Read-only from profile |
| Phone | Text | ✓ | From profile, editable |
| Quantity | Number | ✓ | Days or km (dynamic label) |
| Delivery? | Checkbox | ✗ | Enables location field |
| Location | Text | Conditional | Required only if delivery enabled |
| Notes | Text | ✗ | Optional |

---

## Pricing Display

Shows in a box below form:

```
═══════════════════════════════
  السعر                 100 ريال/يوم
  المجموع الفرعي        500 ريال
  رسم التوصيل           50 ريال
───────────────────────────────
  الإجمالي              550 ريال  ← GREEN
═══════════════════════════════
```

---

## Delivery Charge Logic

**Default**: 10% of subtotal

```dart
if (isDeliver.value) {
  deliveryCharge = subtotal × 0.1
}
```

**To customize**, edit `BookingController._calculateCharges()`:
- Fixed: `deliveryCharge = 50`
- Percentage: `deliveryCharge = subtotal × 0.15`
- Per unit: `deliveryCharge = quantity × 5`

---

## Validation

Form is valid when:
1. ✓ Email filled (auto-filled)
2. ✓ Phone filled (auto-filled)
3. ✓ Quantity filled (user input)
4. ✓ If delivery enabled → location filled

Continue button enables → disabled while invalid

---

## Per Day vs Per KM

| Aspect | Per Day | Per KM |
|--------|---------|--------|
| Pricing Type | `per_day` | `per_km` |
| Unit | `day` | `km` |
| Form Label | عدد الأيام | المسافة |
| Example Input | 5 | 200 |
| Calc | 5 × 100 = 500 | 200 × 5 = 1000 |

---

## Data to Preview Screen

```dart
{
  email: "user@example.com",
  phone: "+966501234567",
  quantity: "5",
  pricing_type: "per_day",
  pricing_unit: "day",
  delivery_required: true,
  delivery_location: "Riyadh, Downtown",
  notes: "Please call before arrival",
  subtotal: 500.0,
  delivery_charge: 50.0,
  total: 550.0,
}
```

---

## Testing Checklist

- [ ] Per day car: form shows "عدد الأيام"
- [ ] Per km car: form shows "المسافة"
- [ ] Email and phone pre-filled
- [ ] Quantity updates calculate totals
- [ ] Delivery checkbox shows/hides location
- [ ] Prices display correctly
- [ ] Form validation works
- [ ] Data passed to preview

---

## Files Changed

1. `booking_controller.dart` ← Main logic
2. `booking_all_fields.dart` ← UI form
3. `all_vendors_car_list_view.dart` ← Navigation
4. `all_vendors_car_carousel.dart` ← Navigation (2 places)
5. `all_vendors_dashboard_screen.dart` ← Import

---

## Common Issues & Fixes

**Problem**: Form shows "distance" instead of "days"
- Check: Car pricing type is correct in API response

**Problem**: Prices show 0
- Check: User has entered quantity value
- Check: Pricing object initialized from car

**Problem**: Continue button stays disabled
- Check: All required fields are filled
- Check: If delivery enabled, location field is filled

**Problem**: Delivery charge doesn't show
- Check: Delivery checkbox is checked
- Check: Subtotal is > 0

---

## Next Steps

1. Test with real cars from API
2. Update preview screen to show delivery charges
3. Adjust delivery charge percentage if needed
4. Add analytics tracking
5. Handle edge cases (very large distances, etc.)
