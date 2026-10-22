# Vendor Cars Model Update

## Overview
Updated the `VendorCar` model and related classes to match the new vendor cars API response structure.

## Changes Made

### 1. **VendorCar Model Updates**
   - **Replaced**: `double pricePerDay` field
   - **With**: `Pricing pricing` object containing:
     - `String type` (e.g., "per_day", "per_km")
     - `String currency` (e.g., "SAR")
     - `double price` (the actual price value)
     - `String unit` (e.g., "day", "km")
     - `String displayName` (e.g., "Price per day")

   - **Made nullable**: `String licensePlate` field (was previously required)

### 2. **New Pricing Class**
Created a new `Pricing` class to encapsulate pricing information:
```dart
class Pricing {
  String type;        // "per_day" or "per_km"
  String currency;    // "SAR", "USD", etc.
  double price;       // Actual price value
  String unit;        // "day", "km", etc.
  String displayName; // "Price per day", etc.
  
  factory Pricing.fromJson(Map<String, dynamic> json) => ...
  factory Pricing.empty() => ...
  Map<String, dynamic> toJson() => ...
}
```

### 3. **MetaInfo Class Updates**
   - **Added**: `List<String> pricingTypes` field
   - **Replaced**: `PriceRange priceRange` (single object)
   - **With**: `Map<String, PricingRange> priceRanges` (supports multiple pricing types)

   Now supports dynamic pricing ranges per pricing type (e.g., separate ranges for per_day and per_km).

### 4. **New PricingRange Class**
Created a new `PricingRange` class to handle per-pricing-type price ranges:
```dart
class PricingRange {
  double min;
  double max;
  
  factory PricingRange.fromJson(Map<String, dynamic> json) => ...
  factory PricingRange.empty() => ...
  Map<String, dynamic> toJson() => ...
}
```

### 5. **Updated VendorCar Methods**
   - **fromJson()**: Updated to parse new pricing structure
   - **toJson()**: Updated to serialize pricing object
   - **formattedPrice getter**: Updated to use `pricing.price` and `pricing.unit`

### 6. **Updated File References**
Updated usages of the old `pricePerDay` field in:
   - `all_vendors_dashboard_controller.dart` (sorting logic)
   - `all_vendors_car_list_view.dart` (price display formatting)

Changed from:
```dart
a.pricePerDay.compareTo(b.pricePerDay)
'${car.pricePerDay.toStringAsFixed(0)}/$dayText'
```

To:
```dart
a.pricing.price.compareTo(b.pricing.price)
'${car.pricing.price.toStringAsFixed(0)}/$unitText'
```

## JSON Response Mapping

### Old Structure
```json
{
  "price_per_day": 100,
  "currency": "SAR"
}
```

### New Structure
```json
{
  "pricing": {
    "type": "per_day",
    "currency": "SAR",
    "price": 100,
    "unit": "day",
    "display_name": "Price per day"
  },
  "currency": "SAR"
}
```

### Old MetaInfo
```json
{
  "available_types": [...],
  "price_range": { "min": 100, "max": 200 },
  "year_range": { "min": 2022, "max": 2025 }
}
```

### New MetaInfo
```json
{
  "available_types": [...],
  "pricing_types": ["per_day", "per_km"],
  "price_ranges": {
    "per_day": { "min": 100, "max": 200 },
    "per_km": { "min": 0, "max": 0 }
  },
  "year_range": { "min": 2022, "max": 2025 }
}
```

## Files Modified
1. `lib/views/all_vendors_dashboard/model/vendor_cars_model.dart`
2. `lib/views/all_vendors_dashboard/controller/all_vendors_dashboard_controller.dart`
3. `lib/views/all_vendors_dashboard/widget/all_vendors_car_list_view.dart`

## Testing Recommendations
1. Test parsing of vendor cars API response with the new structure
2. Verify sorting functionality (low-to-high and high-to-low price)
3. Verify price display formatting for different pricing types (per_day, per_km)
4. Test with multiple pricing types in MetaInfo
5. Ensure backward compatibility if needed for any legacy endpoints

## Benefits
- ✅ More flexible pricing model supporting multiple pricing types
- ✅ Better structured data from API response
- ✅ Cleaner separation of concerns with dedicated Pricing class
- ✅ More maintainable code with explicit field naming
- ✅ Supports future extensions (e.g., additional pricing fields)
