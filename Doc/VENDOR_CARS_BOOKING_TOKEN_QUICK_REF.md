# Vendor Cars Booking Token - Quick Reference

## API Response Token

The vendor cars API now returns a booking token in the response:

```json
{
  "data": {
    "token": "U5cOjXHRck3szMr3B338",
    "cars": [...]
  }
}
```

## Data Flow

```
1. Vendor Cars API Response
   ↓
   token: "U5cOjXHRck3szMr3B338"
   ↓
2. VendorCarsData Model
   ↓
   VendorCarsData.token = "U5cOjXHRck3szMr3B338"
   ↓
3. AllVendorsDashboardController
   ↓
   carToken.value = "U5cOjXHRck3szMr3B338"
   ↓
4. Car Selection
   ↓
   DashboardController.carToken.value = "U5cOjXHRck3szMr3B338"
   ↓
5. Preview Booking API
   ↓
   GET /user/booking/preview?token=U5cOjXHRck3szMr3B338&car_id=13
   ↓
6. Confirm Booking API
   ↓
   POST /user/booking/confirm with token from preview response
```

## Code Changes Summary

### 1. Model Changes
- **File**: `lib/views/all_vendors_dashboard/model/vendor_cars_model.dart`
- **Change**: Added `String? token;` field to `VendorCarsData` class
- **Impact**: Now captures booking token from API response

### 2. Controller Changes
- **File**: `lib/views/all_vendors_dashboard/controller/all_vendors_dashboard_controller.dart`
- **Change**: Extract token from API and set `carToken.value`
- **Code**:
  ```dart
  if (vendorCarsModel.data.token != null && 
      vendorCarsModel.data.token!.isNotEmpty) {
    carToken.value = vendorCarsModel.data.token!;
    log.i('Updated carToken from API: ${carToken.value}');
  }
  ```

### 3. Integration Points (No Changes Required)
These components already properly use the carToken:

- **all_vendors_car_carousel.dart** ✓
  - Already passes `carToken` to DashboardController
  
- **preview_controller.dart** ✓
  - Already uses `dashboardController.carToken.value` in API call
  - Already uses preview response token for confirm booking

- **booking_controller.dart** ✓
  - Already initialized with car on selection

## Token Usage Chain

| Component | Uses | Source | Purpose |
|-----------|------|--------|---------|
| AllVendorsDashboardController | carToken | Vendor Cars API Response | Store vendor booking token |
| DashboardController | carToken | AllVendorsDashboardController | Pass to preview request |
| PreviewController | dashboardController.carToken | DashboardController | Get booking preview with vendor token |
| PreviewController | bookingToken | Preview API Response | Confirm booking with booking-specific token |

## Testing Points

✓ Vendor cars API returns token in response
✓ VendorCarsData correctly parses token field
✓ AllVendorsDashboardController captures token
✓ CarToken is passed to DashboardController on car selection
✓ Preview API call includes token parameter
✓ Confirm booking uses correct token from preview response

## Logging

Added logging in AllVendorsDashboardController:
```dart
log.i('Updated carToken from API: ${carToken.value}');
```

Check logs to verify token is being properly updated from API response.
