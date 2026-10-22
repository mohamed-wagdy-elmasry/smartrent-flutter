# Delivery Zone API Documentation

## Overview

This API allows checking if car delivery is available for a user's location based on branch delivery zones.

## Endpoint

```
POST /api/delivery/check
```

### Authentication

Public endpoint - No authentication required

### Request Headers

```
Content-Type: application/json
Accept: application/json
```

### Request Body

| Parameter | Type    | Required | Description                    |
| --------- | ------- | -------- | ------------------------------ |
| branch_id | integer | Yes      | ID of the vendor branch        |
| user_lat  | float   | Yes      | User's latitude (-90 to 90)    |
| user_lng  | float   | Yes      | User's longitude (-180 to 180) |

### Example Request

```json
POST /api/delivery/check
Content-Type: application/json

{
    "branch_id": 1,
    "user_lat": 25.2048,
    "user_lng": 55.2708
}
```

---

## Response Scenarios

### 1. Delivery Available (200 OK)

When the user is within the branch's delivery radius:

```json
{
    "status": "available",
    "message": "Delivery available",
    "distance_km": 1.25,
    "delivery_fee": 50.0,
    "branch": {
        "id": 1,
        "name": "Main Branch",
        "city": "Dubai"
    }
}
```

### 2. Delivery Unavailable (200 OK)

When the user is outside the branch's delivery radius:

```json
{
    "status": "unavailable",
    "message": "Delivery not available for your location",
    "distance_km": 15.75,
    "max_radius_km": 10.0
}
```

### 3. Delivery Zone Not Configured (400 Bad Request)

When the branch doesn't have delivery zone configured:

```json
{
    "status": "error",
    "message": "Delivery zone not configured for this branch"
}
```

### 4. Branch Not Found (404 Not Found)

When the requested branch doesn't exist:

```json
{
    "status": "error",
    "message": "Branch not found"
}
```

### 5. Validation Error (422 Unprocessable Entity)

When request parameters are invalid:

```json
{
    "message": "The given data was invalid.",
    "errors": {
        "branch_id": ["Branch is required"],
        "user_lat": ["Invalid latitude value"],
        "user_lng": ["Invalid longitude value"]
    }
}
```

---

## Integration Guide

### Flutter Example

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> checkDeliveryAvailability({
  required int branchId,
  required double userLat,
  required double userLng,
}) async {
  final url = Uri.parse('https://your-domain.com/api/delivery/check');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'branch_id': branchId,
        'user_lat': userLat,
        'user_lng': userLng,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to check delivery availability');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

// Usage Example
void main() async {
  try {
    final result = await checkDeliveryAvailability(
      branchId: 1,
      userLat: 25.2048,
      userLng: 55.2708,
    );

    if (result['status'] == 'available') {
      print('Delivery available!');
      print('Fee: \${result['delivery_fee']}');
      print('Distance: \${result['distance_km']} km');
    } else if (result['status'] == 'unavailable') {
      print('Sorry, delivery not available for your location');
      print('You are \${result['distance_km']} km away');
      print('Maximum delivery radius is \${result['max_radius_km']} km');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

---

## Flutter UI Flow

### 1. User Requests Delivery

```dart
// Get user's current location
Position position = await Geolocator.getCurrentPosition();

// Check delivery availability
final result = await checkDeliveryAvailability(
  branchId: selectedBranch.id,
  userLat: position.latitude,
  userLng: position.longitude,
);
```

### 2. Handle Response

```dart
if (result['status'] == 'available') {
  // Show success message and delivery fee
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delivery Available'),
      content: Text(
        'Delivery fee: \$${result['delivery_fee']}\n'
        'Distance: ${result['distance_km']} km'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Proceed to checkout with delivery
            Navigator.pop(context);
            proceedToCheckout(withDelivery: true, fee: result['delivery_fee']);
          },
          child: Text('Continue'),
        ),
      ],
    ),
  );
} else if (result['status'] == 'unavailable') {
  // Show unavailable message and suggest alternatives
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delivery Unavailable'),
      content: Text(
        'Sorry, we cannot deliver to your location.\n\n'
        'Your location is ${result['distance_km']} km away.\n'
        'Maximum delivery radius is ${result['max_radius_km']} km.\n\n'
        'Please choose pickup instead or select a different branch.'
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // Show branch selection
          },
          child: Text('Choose Branch'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Proceed with pickup
            proceedToCheckout(withDelivery: false);
          },
          child: Text('Pickup Instead'),
        ),
      ],
    ),
  );
}
```

### 3. Error Handling

```dart
try {
  final result = await checkDeliveryAvailability(...);
  // Handle result
} on SocketException {
  showError('No internet connection');
} on HttpException {
  showError('Server error. Please try again');
} catch (e) {
  showError('Something went wrong: $e');
}
```

---

## Admin Configuration

Admins can configure delivery zones for each branch:

1. Navigate to **Admin Dashboard → Vendor Care → Vendor Branches**
2. Edit a branch
3. Set delivery zone parameters:
    - **Center Latitude**: Branch location latitude
    - **Center Longitude**: Branch location longitude
    - **Radius (km)**: Maximum delivery distance in kilometers

### Example:

```
Branch: Main Branch Dubai
Center Lat: 25.1972
Center Lng: 55.2744
Radius: 10.0 km
```

This configuration allows delivery within 10km of the branch location.

---

## Technical Details

### Distance Calculation

The API uses the **Haversine formula** to calculate the great-circle distance between two points on Earth:

```
a = sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlng/2)
c = 2 × atan2(√a, √(1−a))
distance = R × c
```

Where:

-   R = Earth's radius (6371 km)
-   Δlat = lat2 − lat1
-   Δlng = lng2 − lng1

### Delivery Fee

The delivery fee is retrieved from the vendor company settings (`vendor_companies.delivery_price`). If not configured, the fee defaults to 0.

---

## Database Schema

### Migration: `vendor_branches` table additions

```php
$table->decimal('center_lat', 10, 8)->nullable();
$table->decimal('center_lng', 11, 8)->nullable();
$table->decimal('radius_km', 8, 2)->nullable();
```

### Run Migration

```bash
php artisan migrate
```

---

## Testing

### Unit Tests

Test the Haversine calculation:

```bash
vendor/bin/phpunit tests/Unit/Services/GeoServiceTest.php
```

### Manual Testing with cURL

```bash
curl -X POST https://your-domain.com/api/delivery/check \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "branch_id": 1,
    "user_lat": 25.2048,
    "user_lng": 55.2708
  }'
```

---

## Notes

-   The endpoint is public and doesn't require authentication
-   Coordinates are validated to ensure they're within valid ranges (-90 to 90 for latitude, -180 to 180 for longitude)
-   Distance is calculated in kilometers and rounded to 2 decimal places
-   Delivery fee comes from the vendor company settings

---

## Support

For issues or questions, please contact the development team or create an issue in the repository.
