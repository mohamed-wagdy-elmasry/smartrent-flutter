# Handoff: Distance-Based Delivery Pricing

**Date:** 2026-06-19  
**Feature branch:** main  
**Scope:** Flutter app + any external API consumer

---

## What Changed

Delivery fees are now **distance-based**. Vendors configure per-branch delivery zones (km ranges → fees) via the Vendor Panel at `/vendor/settings`. The two affected API endpoints now accept optional coordinates and return enriched delivery data.

---

## 1. Price Estimate API

### Endpoint
```
POST /api/v1/user/car-booking/price-estimate
Authorization: Bearer <passport_token>
```

### Request — new optional fields
```json
{
  "car_id": 42,
  "rental_days": 3,
  "with_delivery": true,
  "user_lat": 24.7800,
  "user_lng": 46.6753
}
```

- `user_lat` / `user_lng` — optional pair (both required if either is provided)
- When omitted and `with_delivery=true`, falls back to branch flat delivery fee

### Response — new fields in `data`
```json
{
  "status": "success",
  "data": {
    "base_price": 150.00,
    "delivery_fee": 10.00,
    "total_price": 160.00,
    "delivery_distance": 8.3,
    "delivery_source": "zone"
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `delivery_fee` | number\|null | Fee in branch currency. `null` when `delivery_source` is `"none"` |
| `delivery_distance` | number\|null | Haversine distance in km from branch to user. `null` when no coords sent |
| `delivery_source` | string\|null | `"zone"` matched a range · `"flat"` branch fallback · `"none"` zones exist but no match · `null` no coords/delivery |

### Flutter integration
```dart
final body = {
  'car_id': carId,
  'rental_days': rentalDays,
  'with_delivery': withDelivery,
  if (withDelivery && userPosition != null) ...{
    'user_lat': userPosition.latitude,
    'user_lng': userPosition.longitude,
  },
};

// After response:
final source = data['delivery_source'];
final fee    = data['delivery_fee'];
final distKm = data['delivery_distance'];

if (source == 'none') {
  // Show: "No delivery available to your location"
} else if (source == 'zone' || source == 'flat') {
  // Show: "Delivery: $fee" + optional "$distKm km away"
}
```

---

## 2. Delivery Check API

### Endpoint
```
POST /api/v1/user/check-delivery
Authorization: Bearer <passport_token>
```

### Request — unchanged shape, coordinates already existed
```json
{
  "branch_id": 5,
  "user_lat": 24.7800,
  "user_lng": 46.6753
}
```

### Response — new fields
```json
{
  "status": "success",
  "data": {
    "delivery_available": true,
    "delivery_fee": 10.00,
    "distance_km": 8.3,
    "delivery_source": "zone",
    "zone_id": 3
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `delivery_fee` | number\|null | Same semantics as price-estimate |
| `distance_km` | number | Always present when delivery_available |
| `delivery_source` | string | `"zone"` · `"flat"` · `"none"` |
| `zone_id` | int\|null | ID of matched `branch_delivery_zones` row, or `null` |

---

## 3. Zone Rules

- Zones are `[min_km, max_km)` — **inclusive min, exclusive max**
- A `null` max_km means open-ended (matches everything ≥ min_km)
- Distance = 10 km falls into the **10–20** zone, not the 0–10 zone
- Inactive zones (`is_active=false`) are excluded from matching
- If no zones are configured → source = `"flat"` (branch delivery_price)
- If zones exist but user is outside all of them → source = `"none"`, fee = `null`

---

## 4. Display Recommendations

| delivery_source | UI behaviour |
|-----------------|-------------|
| `"zone"` | Show fee + distance badge |
| `"flat"` | Show fee (no distance badge needed) |
| `"none"` | Show "Out of delivery range" warning, disable checkout |
| `null` | No delivery selected — hide delivery row |

---

## 5. No Breaking Changes

All new request fields are **optional**. Existing Flutter builds that omit `user_lat`/`user_lng` continue to receive flat-fee responses with `delivery_source: "flat"` and `delivery_distance: null`. No forced client update needed.
