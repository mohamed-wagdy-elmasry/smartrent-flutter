# Car Booking Test Endpoint (Without Payment)

**Created:** November 14, 2025  
**Status:** ✅ Available for Testing  
**Environment:** Development & Testing Only

---

## Overview

The **test booking endpoint** allows you to confirm car bookings **without going through payment processing**. This is useful for:

- ✅ Testing the complete booking flow without payment
- ✅ Development and debugging
- ✅ Integration testing
- ✅ QA and testing workflows
- ✅ Demo scenarios

---

## Endpoint Details

### Endpoint URL
```
POST /api/v1/user/car-booking/test-confirm
```

### Route Name
```
api.user.car.booking.test.confirm
```

### Authentication
```
Required: Bearer Token (JWT)
Header: Authorization: Bearer <your_jwt_token>
```

### Content Type
```
application/json
```

---

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `token` | string | ✅ Yes | 20-char booking token from `/search/car` endpoint |
| `car_id` | integer | ✅ Yes | ID of the car to book |
| `car_slug` | string | ✅ Yes | Slug/identifier of the car |
| `mobile` | string | ✅ Yes | Customer mobile number |
| `fees` | numeric | ✅ Yes | Booking amount (total fees) |
| `location` | string | ❌ Optional | Pickup location (if delivery requested) |
| `is_deliver` | boolean | ❌ Optional | Whether delivery is needed (default: false) |
| `destination` | string | ❌ Optional | Destination for delivery |
| `distance` | numeric | ❌ Optional | Distance for delivery (km) |
| `credentials` | email | ❌ Optional | Customer email address |
| `round_pickup_date` | date | ❌ Optional | Return pickup date (YYYY-MM-DD format) |
| `round_pickup_time` | string | ❌ Optional | Return pickup time (HH:mm format) |
| `rental_days` | integer | ❌ Optional | Number of rental days |
| `message` | string | ❌ Optional | Special instructions/message |

---

## Complete Example Workflow

### Step 1: Search for Cars (Get Booking Token)

```bash
curl -X POST "https://your-domain.com/api/v1/user/car-booking/search/car" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "car_type": 1,
    "car_model": 5,
    "pickup_date": "2025-11-20",
    "pickup_time": "10:00"
  }'
```

**Response:**
```json
{
  "message": ["Car search successful"],
  "status": 200,
  "data": {
    "token": "fnaC7ti2Sewh81tUkDkG",
    "cars": [
      {
        "id": 42,
        "slug": "toyota-camry-2024",
        "name": "Toyota Camry",
        "price_per_day": 150,
        ...
      }
    ],
    "data_path": { ... }
  }
}
```

**⚠️ IMPORTANT:** Save the `token` value - you'll need it for the next step!

---

### Step 2: Confirm Booking Without Payment

Use the **test endpoint** to confirm the booking directly (no payment required):

```bash
curl -X POST "https://your-domain.com/api/v1/user/car-booking/test-confirm" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "fnaC7ti2Sewh81tUkDkG",
    "car_id": 42,
    "car_slug": "toyota-camry-2024",
    "mobile": "+966501234567",
    "fees": 450,
    "credentials": "user@example.com",
    "location": "Riyadh, Saudi Arabia",
    "is_deliver": true,
    "destination": "Airport Road, Riyadh",
    "distance": 25,
    "rental_days": 3,
    "message": "Please pick up at the main entrance"
  }'
```

**✅ Success Response:**
```json
{
  "message": ["Booking Successful!"],
  "status": 200,
  "data": []
}
```

---

## Minimal Request Example

If you only want to test the absolute minimum:

```bash
curl -X POST "https://your-domain.com/api/v1/user/car-booking/test-confirm" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "fnaC7ti2Sewh81tUkDkG",
    "car_id": 42,
    "car_slug": "toyota-camry-2024",
    "mobile": "+966501234567",
    "fees": 450
  }'
```

---

## Differences: Test vs Real Booking

| Aspect | Test Endpoint | Real Booking |
|--------|---------------|--------------|
| **URL** | `/test-confirm` | `/confirm` |
| **Payment** | ❌ None | ✅ Required |
| **Payment Type** | N/A | `paytabs`, `cash`, or gateway name |
| **Status** | Test/Demo | Active |
| **Use Case** | Testing & QA | Production |
| **Notifications** | ✅ Sent | ✅ Sent |
| **Database** | ✅ Saved | ✅ Saved |
| **Trx ID** | Starts with `test_` | Starts with transaction prefix |

---

## Testing Scenarios

### Scenario 1: Basic Booking Test
```bash
# 1. Search
curl -X POST ".../car-booking/search/car" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"car_type": 1, "car_model": 5, "pickup_date": "2025-11-20", "pickup_time": "10:00"}'

# 2. Save the token from response
TOKEN_FROM_SEARCH="fnaC7ti2Sewh81tUkDkG"

# 3. Confirm without payment
curl -X POST ".../car-booking/test-confirm" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "token": "'$TOKEN_FROM_SEARCH'",
    "car_id": 42,
    "car_slug": "toyota-camry-2024",
    "mobile": "+966501234567",
    "fees": 450
  }'
```

### Scenario 2: With Delivery
```bash
curl -X POST ".../car-booking/test-confirm" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "token": "fnaC7ti2Sewh81tUkDkG",
    "car_id": 42,
    "car_slug": "toyota-camry-2024",
    "mobile": "+966501234567",
    "fees": 450,
    "location": "Riyadh, Saudi Arabia",
    "is_deliver": true,
    "destination": "Airport Road, Riyadh",
    "distance": 25
  }'
```

### Scenario 3: Round Trip Booking
```bash
curl -X POST ".../car-booking/test-confirm" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "token": "fnaC7ti2Sewh81tUkDkG",
    "car_id": 42,
    "car_slug": "toyota-camry-2024",
    "mobile": "+966501234567",
    "fees": 450,
    "rental_days": 7,
    "round_pickup_date": "2025-11-27",
    "round_pickup_time": "10:00"
  }'
```

---

## Response Codes

| Code | Status | Meaning |
|------|--------|---------|
| `200` | ✅ Success | Booking confirmed successfully |
| `400` | ❌ Bad Request | Invalid/missing parameters |
| `401` | ❌ Unauthorized | JWT token invalid or expired |
| `404` | ❌ Not Found | Car or booking token not found |
| `422` | ❌ Validation Error | Validation failed on parameters |
| `500` | ❌ Server Error | Internal server error |

---

## Error Examples

### Missing Token
```json
{
  "message": ["The token field is required."],
  "status": 422
}
```

### Invalid Car ID
```json
{
  "message": ["Car not found or unavailable"],
  "status": 404
}
```

### Booking Session Expired
```json
{
  "message": ["Booking session expired. Please search for a car and try again."],
  "status": 400
}
```

### Unauthorized (No JWT)
```json
{
  "message": "Unauthenticated."
}
```

---

## Logging

Test bookings are logged to help with debugging:

**Log Location:** `storage/logs/carbooking.log`

**Log Entry Example:**
```
[2025-11-14 10:30:15] CarBooking.INFO: TEST: Booking confirmation without payment initiated 
  {"token":"fnaC7ti2Sewh81tUkDkG","car_id":42,"user_id":5}
```

---

## Important Notes

### ⚠️ FOR TESTING ONLY
- This endpoint is **for testing and development only**
- Do **NOT** use in production for real bookings
- Test bookings are still saved to database with payment_type = "test"
- All notifications are still sent

### ✅ What Gets Created
- ✅ CarBooking record in database
- ✅ Notifications sent to vendor
- ✅ Email notifications sent (if enabled)
- ✅ Push notifications sent (if enabled)
- ✅ Trip ID generated
- ✅ Transaction ID generated (with "test_" prefix)

### ❌ What Doesn't Happen
- ❌ No payment processing
- ❌ No charge to customer
- ❌ No PayTabs interaction
- ❌ No wallet deduction

---

## Flutter Integration Example

```dart
/// Test booking without payment
Future<void> testBookCar() async {
  final token = await _getJwtToken();
  final searchToken = "fnaC7ti2Sewh81tUkDkG"; // From search response
  
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/user/car-booking/test-confirm'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'token': searchToken,
      'car_id': 42,
      'car_slug': 'toyota-camry-2024',
      'mobile': '+966501234567',
      'fees': 450,
      'credentials': 'user@example.com',
      'location': 'Riyadh, Saudi Arabia',
      'is_deliver': true,
      'destination': 'Airport Road, Riyadh',
      'distance': 25,
    }),
  );

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    print('✅ Test booking successful!');
    print('Message: ${result['message']}');
  } else {
    print('❌ Test booking failed: ${response.body}');
  }
}
```

---

## Postman Collection

**Quick Postman Setup:**

1. **Method:** `POST`
2. **URL:** `{{base_url}}/api/v1/user/car-booking/test-confirm`
3. **Headers:**
   - `Authorization: Bearer {{jwt_token}}`
   - `Content-Type: application/json`
4. **Body (raw JSON):**
   ```json
   {
     "token": "{{search_token}}",
     "car_id": 42,
     "car_slug": "toyota-camry-2024",
     "mobile": "+966501234567",
     "fees": 450,
     "credentials": "user@example.com",
     "location": "Riyadh, Saudi Arabia",
     "is_deliver": true,
     "destination": "Airport Road, Riyadh",
     "distance": 25
   }
   ```

---

## Troubleshooting

### Issue: "Route not defined"
**Solution:** Make sure you're using the full path `/api/v1/user/car-booking/test-confirm`

### Issue: "Booking token not found"
**Solution:** 
1. Make sure you got the token from the search endpoint
2. Verify the token is exactly 20 characters
3. Check if the booking session hasn't expired

### Issue: "Unauthorized"
**Solution:**
1. Verify JWT token is valid and not expired
2. Add `Authorization: Bearer <token>` header
3. Make sure you're logged in

### Issue: "Car not found"
**Solution:**
1. Verify car_id is correct
2. Make sure car is approved and active in database
3. Check car hasn't been deleted

---

## Related Documentation

- **Full Booking Flow:** `CAR_BOOKING_FLOW_GUIDE.md`
- **PayTabs Integration:** `PAYTABS_FLUTTER_INTEGRATION.md`
- **Booking Validation:** `CAR_BOOKING_VALIDATION_UPDATES.md`
- **Booking API Reference:** `CAR_BOOKING_API_QUICK_REFERENCE.md`

---

## Summary

| Feature | Status |
|---------|--------|
| Endpoint available | ✅ Yes |
| Requires authentication | ✅ Yes |
| Creates database records | ✅ Yes |
| Sends notifications | ✅ Yes |
| Processes payment | ❌ No |
| Good for testing | ✅ Yes |
| Production ready | ❌ No |

---

**Last Updated:** November 14, 2025  
**Status:** ✅ Ready for Use
