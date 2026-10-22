# Flutter Handoff — Vendor Cars Proximity Sort

**Endpoint:** `GET https://smartrent.sa/api/v1/vendor/cars`  
**Your file:** `lib/views/all_vendors_dashboard/controller/all_vendors_dashboard_controller.dart:103`

---

## What Changed on the Backend

### 1. Default sort is now closest-first

The endpoint now defaults to `sort_by=distance_asc`. You don't need to pass `sort_by` explicitly — just pass the user's coordinates and the response is already sorted nearest branch first.

If you pass **no coordinates**, the server falls back to `recommended` order (year → price → seats). No error is thrown.

### 2. Two new query parameters

| Param | Type | Required? | Valid range |
|-------|------|-----------|-------------|
| `lat` | float | No — but needed for distance sort | `-90` to `90` |
| `lng` | float | No — but needed for distance sort | `-180` to `180` |

### 3. Each car now has a `distance_km` field

Every car object in `data.cars` includes:

```json
"distance_km": 3.47
```

- **Float** — distance in kilometres from the supplied `lat`/`lng` to the car's branch.
- **`null`** when no coordinates were passed in the request, or when the branch has no location configured.

---

## Recommended Integration

### Step 1 — Request device location before calling the API

```dart
// pubspec.yaml — already add: geolocator: ^11.x
import 'package:geolocator/geolocator.dart';

Future<Position?> _getUserLocation() async {
  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    final requested = await Geolocator.requestPermission();
    if (requested == LocationPermission.denied) return null;
  }
  if (permission == LocationPermission.deniedForever) return null;
  return await Geolocator.getCurrentPosition();
}
```

### Step 2 — Pass coordinates to the API call

In `all_vendors_dashboard_controller.dart` around line 103, update your query params:

```dart
final position = await _getUserLocation();

final queryParams = <String, dynamic>{
  'per_page': 20,
  // Add lat/lng when available — backend sorts by distance automatically
  if (position != null) 'lat': position.latitude.toString(),
  if (position != null) 'lng': position.longitude.toString(),
};

final response = await _apiService.get(
  '/api/v1/vendor/cars',
  queryParameters: queryParams,
);
```

### Step 3 — Display `distance_km` on the car card

```dart
// In your car card widget
final distanceKm = car['distance_km'] as double?;

if (distanceKm != null)
  Text(
    '${distanceKm.toStringAsFixed(1)} km away',
    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
  ),
```

---

## Full Response Shape (relevant fields)

```json
{
  "message": { "success": ["Vendor cars retrieved successfully"] },
  "data": {
    "token": "...",
    "cars": [
      {
        "id": 12,
        "vendor_name": "Al Noor Rent",
        "model": "Camry",
        "year": 2023,
        "seats": 5,
        "distance_km": 1.83,
        "vendor_location": {
          "city": "Riyadh",
          "address": "King Fahd Road",
          "latitude": 24.7500,
          "longitude": 46.7100,
          "radius_km": 10.0
        },
        "pricing": {
          "type": "per_day",
          "price": 180.0,
          "unit": "day",
          "display_name": "Price per day"
        },
        "is_delivery_available": true,
        "delivery_price": 25.0,
        "tax_enabled": true,
        "tax_percentage": 15.0
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total": 47,
      "total_pages": 3,
      "has_more": true
    },
    "filters_applied": {
      "lat": "24.7136",
      "lng": "46.6753"
    },
    "meta": {
      "available_cities": ["Riyadh", "Jeddah", "Dammam"],
      "available_types": ["sedan", "suv", "economy"],
      "price_ranges": {
        "per_day": { "min": 80.0, "max": 950.0 },
        "per_km":  { "min": 1.2,  "max": 12.0 }
      }
    }
  },
  "type": "success"
}
```

---

## All Supported `sort_by` Values

| Value | Behaviour |
|-------|-----------|
| `distance_asc` | **Default.** Closest branch first. Falls back to recommended when no coords. |
| `recommended` | Year desc → price asc → seats desc |
| `price_asc` | Cheapest first (works across per_day and per_km) |
| `price_desc` | Most expensive first |
| `year_desc` | Newest cars first |
| `rating_desc` | Placeholder — ordered by id desc for now |

---

## Filter by City

Pass `?city=Riyadh` to restrict results to branches in that city (partial match, case-insensitive). The full list of available cities is in `meta.available_cities` on every response — use that to populate a city picker.

---

## Edge Cases to Handle in Flutter

| Scenario | Backend response | What to show |
|----------|-----------------|--------------|
| Location permission denied | 200, `distance_km: null` | Hide distance label, show results normally |
| Branch has no coordinates | 200, `distance_km: null` on that car | Hide distance label on that card only |
| Explicit `sort_by=distance_asc` but no coords | 200, falls back to recommended | Same as above |
| `lat=999` (out of range) | 422 validation error | Show generic error / retry |
