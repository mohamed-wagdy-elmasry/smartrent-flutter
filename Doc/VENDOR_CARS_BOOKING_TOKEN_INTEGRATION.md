# Vendor Cars Booking Token Integration

## Overview
Updated the vendor cars model and controllers to properly capture and use the booking token from the vendor cars API response through the entire booking flow.

## Changes Made

### 1. VendorCarsData Model Update
**File**: `lib/views/all_vendors_dashboard/model/vendor_cars_model.dart`

Added `token` field to `VendorCarsData` class to capture the booking token from the API response:

```dart
class VendorCarsData {
  String? token;  // NEW: Booking token from API
  List<VendorCar> cars;
  Pagination pagination;
  Map<String, dynamic> filtersApplied;
  MetaInfo meta;

  VendorCarsData({
    this.token,
    required this.cars,
    required this.pagination,
    required this.filtersApplied,
    required this.meta,
  });

  factory VendorCarsData.fromJson(Map<String, dynamic> json) => VendorCarsData(
    token: json["token"]?.toString(),  // Extract token from API response
    // ... rest of initialization
  );

  Map<String, dynamic> toJson() => {
    if (token != null) "token": token,  // Include in serialization
    // ... rest of fields
  };
}
```

**API Response Structure**:
```json
{
  "message": {
    "success": ["Vendor cars retrieved successfully"]
  },
  "data": {
    "token": "U5cOjXHRck3szMr3B338",  // NEW: This token is now captured
    "cars": [...],
    "pagination": {...},
    "filters_applied": [],
    "meta": {...}
  },
  "type": "success"
}
```

### 2. AllVendorsDashboardController Update
**File**: `lib/views/all_vendors_dashboard/controller/all_vendors_dashboard_controller.dart`

Updated the `searchAllVendorsCars()` method to extract and store the token from the API response:

```dart
if (vendorCarsModel.success) {
  if (loadMore) {
    vendorCars.addAll(vendorCarsModel.data.cars);
  } else {
    vendorCars.value = vendorCarsModel.data.cars;
  }

  // Update carToken from API response
  if (vendorCarsModel.data.token != null && 
      vendorCarsModel.data.token!.isNotEmpty) {
    carToken.value = vendorCarsModel.data.token!;
    log.i('Updated carToken from API: ${carToken.value}');
  }

  // ... rest of method
}
```

## Data Flow

### Step 1: Vendor Cars API Call
```
AllVendorsDashboardController.searchAllVendorsCars()
  ↓
API: GET /user/car-booking/cars
  ↓
Response includes token: "U5cOjXHRck3szMr3B338"
```

### Step 2: Token Storage
```
API Response parsed into VendorCarsModel
  ↓
VendorCarsData.token = "U5cOjXHRck3szMr3B338"
  ↓
AllVendorsDashboardController.carToken.value = token
```

### Step 3: Car Selection
```
User taps car in carousel
  ↓
all_vendors_car_carousel.dart:
  - Sets AllVendorsDashboardController.selectedCarId
  - Sets DashboardController.carToken from controller.carToken
```

```dart
dashController.carToken.value = controller.carToken.value;
```

### Step 4: Preview Booking API
```
PreviewController.getPreviewData()
  ↓
API: GET /user/booking/preview
Parameters:
  - token: dashboardController.carToken.value  // "U5cOjXHRck3szMr3B338"
  - car_id: dashboardController.selectedCarId
  ↓
Response includes booking preview data and another token
```

### Step 5: Confirm Booking
```
PreviewController.confirmBooking() [and other payment methods]
  ↓
Get bookingToken from:
  1. bookingData.value['token'] (from preview API response)
  2. bookingData.value['booking_token'] (fallback)
  3. LocalStorage.token (final fallback)
  ↓
API: POST /user/booking/confirm
Body includes:
  - token: bookingToken
  - car_id, fees, payment method, etc.
```

## Key Integration Points

### 1. AllVendorsDashboardController
- **Variable**: `RxString carToken = ''.obs;`
- **Set by**: API response in `searchAllVendorsCars()`
- **Used by**: Carousel widget to pass to DashboardController

### 2. DashboardController
- **Variable**: `RxString carToken = ''.obs;`
- **Set by**: `all_vendors_car_carousel.dart` when car is selected
- **Used by**: PreviewController for preview API call

### 3. PreviewController
- **Retrieves**: `dashboardController.carToken.value` for preview API
- **Receives**: New token from preview API response
- **Uses**: Preview API token for confirm booking operations

## Testing Checklist

- [x] Vendor cars API response parsed correctly with token field
- [x] Token extracted and stored in AllVendorsDashboardController
- [x] Token passed to DashboardController on car selection
- [x] Token used in preview booking API call
- [x] Token properly used in confirm booking operations
- [x] Fallback behavior preserved for compatibility

## API Response Example

The complete vendor cars API response structure:

```json
{
  "message": {
    "success": ["Vendor cars retrieved successfully"]
  },
  "data": {
    "token": "U5cOjXHRck3szMr3B338",
    "cars": [
      {
        "id": 13,
        "vendor_id": 258,
        "vendor_name": "تلجاني",
        "vendor_rating": 4.5,
        "make": "تويوتا",
        "model": "كامري",
        "type": "toyota-1762318712-690ad97834bb5",
        "year": 2025,
        "color": "Not specified",
        "pricing": {
          "type": "per_day",
          "currency": "SAR",
          "price": 100,
          "unit": "day",
          "display_name": "Price per day"
        },
        "currency": "SAR",
        "tax_enabled": true,
        "tax_percentage": 15,
        "rating": 4.5,
        "total_reviews": 0,
        "availability_status": "available",
        "insurance_included": true,
        "mileage_limit_per_day": 200,
        "mileage_unit": "km",
        "deposit_required": 0,
        "delivery_price": 150,
        "cancellation_policy": "free_24h",
        "vendor_location": {
          "city": "مكة",
          "address": "مكة",
          "latitude": null,
          "longitude": null
        },
        "images": [],
        "features": []
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 15,
      "total": 4,
      "total_pages": 1,
      "from": 1,
      "to": 4,
      "has_more": false
    },
    "filters_applied": [],
    "meta": {
      "available_types": [...],
      "pricing_types": ["per_day", "per_km"],
      "price_ranges": {
        "per_day": { "min": 100, "max": 200 },
        "per_km": { "min": 0, "max": 0 }
      },
      "year_range": { "min": 2022, "max": 2025 }
    }
  },
  "type": "success"
}
```

## Files Modified

1. **lib/views/all_vendors_dashboard/model/vendor_cars_model.dart**
   - Added `token` field to `VendorCarsData` class
   - Updated `fromJson()` to extract token
   - Updated `toJson()` to include token

2. **lib/views/all_vendors_dashboard/controller/all_vendors_dashboard_controller.dart**
   - Updated `searchAllVendorsCars()` to set `carToken` from API response

## Benefits

✅ **Proper Token Management**: Booking token is now properly captured from vendor cars API
✅ **Seamless Flow**: Token flows automatically through the booking process
✅ **Preview API**: Uses vendor-specific token for accurate preview calculation
✅ **Backward Compatible**: Fallback mechanisms still in place
✅ **Debugging**: Added logging for token updates
✅ **Type Safe**: Proper null handling with optional token field

## Summary

The vendor cars booking token integration is now complete. The system properly:
1. Captures the booking token from the vendor cars API response
2. Stores it in the AllVendorsDashboardController
3. Passes it to the DashboardController on car selection
4. Uses it in the booking preview API call
5. Receives and uses the booking token from the preview API response for confirmation

This ensures that each booking is processed with the correct vendor-specific token for accurate pricing and booking management.
