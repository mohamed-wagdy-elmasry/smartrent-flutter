# Booking History API Documentation

This document describes the paginated booking history endpoints for user and vendor roles, optimized for mobile lazy-loading patterns.

## Overview

Both endpoints support pagination with query parameters `page` and `per_page`, returning booking records in a mobile-friendly format with separate data array and pagination metadata.

---

## User Booking History

### Endpoint

```
GET /api/v1/user/car-booking/booking/history
```

### Authentication

- Required: Yes
- Guard: `api` (Laravel Passport token)
- Middleware: `auth:api`

### Query Parameters

| Parameter | Type    | Required | Default | Max | Description                 |
| --------- | ------- | -------- | ------- | --- | --------------------------- |
| page      | integer | No       | 1       | -   | Current page number         |
| per_page  | integer | No       | 5       | 50  | Number of bookings per page |

### Request Example

```http
GET /api/v1/user/car-booking/history?page=1&per_page=10
Authorization: Bearer YOUR_API_TOKEN
```

### Response Structure

#### Success Response (200)

```json
{
    "message": {
        "success": ["History fetched successfully!"]
    },
    "data": {
        "history": [
            {
                "id": 123,
                "user_id": 45,
                "pickup_date": "2025-12-15",
                "pickup_time": "10:00:00",
                "status": "completed",
                "created_at": "2025-12-13T08:30:00.000000Z",
                "cars": {
                    "id": 78,
                    "vendor_id": 12,
                    "image": "https://yourapp.com/frontend/images/site-section/car.jpg",
                    "vendor": {
                        "id": 12,
                        "firstname": "Ahmed",
                        "business_name": "Premium Rentals"
                    }
                },
                "price_breakdown": {
                    "rental_days": 3,
                    "rental": 900.0,
                    "delivery": 0.0,
                    "tax": 135.0,
                    "extensions": [
                        {
                            "id": 5,
                            "extra_days": 1,
                            "extra_amount": 300.0,
                            "daily_rate": 300.0,
                            "tax_percentage": 15.0,
                            "tax_amount": 45.0,
                            "total_amount": 345.0,
                            "old_return_at": "2025-12-18T10:00:00.000000Z",
                            "new_return_at": "2025-12-19T10:00:00.000000Z",
                            "status": "approved",
                            "status_label": "Approved",
                            "approved_at": "2025-12-16T08:00:00.000000Z",
                            "rejection_reason": null,
                            "notes": null,
                            "created_at": "2025-12-16T07:30:00.000000Z"
                        }
                    ]
                }
            }
        ],
        "pagination": {
            "current_page": 1,
            "per_page": 10,
            "total": 45,
            "total_pages": 5,
            "from": 1,
            "to": 10,
            "has_more": true
        }
    },
    "type": "success"
}
```

#### Error Response (422) - Validation Failed

```json
{
    "message": {
        "error": ["The per_page must not be greater than 50."]
    },
    "type": "error"
}
```

#### Error Response (401) - Unauthorized

```json
{
    "message": "Unauthenticated."
}
```

### Notes

- The `cars.car_number` and `cars.experience` fields are hidden from the response for security
- Bookings are ordered by `created_at` descending (newest first)
- Empty result returns `history: []` with `total: 0`
- Each booking includes `price_breakdown` — see [Price Breakdown](#price-breakdown) section below

---

## Vendor Booking History

### Endpoint

```
GET /api/v1/vendor/history/view
```

### Authentication

- Required: Yes
- Guard: `vendor_api` (Laravel Passport vendor token)
- Middleware: `auth:vendor_api`

### Query Parameters

| Parameter | Type    | Required | Default | Max | Description                 |
| --------- | ------- | -------- | ------- | --- | --------------------------- |
| page      | integer | No       | 1       | -   | Current page number         |
| per_page  | integer | No       | 5       | 50  | Number of bookings per page |

### Request Example

```http
GET /api/v1/vendor/history/view?page=2&per_page=5
Authorization: Bearer YOUR_VENDOR_API_TOKEN
```

### Response Structure

#### Success Response (200) - With Data

```json
{
    "message": {
        "success": ["History fetch successfully"]
    },
    "data": {
        "booking_history": [
            {
                "id": 456,
                "user_id": 89,
                "pickup_date": "2025-12-10",
                "pickup_time": "14:00:00",
                "status": "completed",
                "created_at": "2025-12-09T12:00:00.000000Z",
                "cars": {
                    "id": 34,
                    "vendor_id": 12,
                    "branch_id": 2,
                    "image": "https://yourapp.com/frontend/images/site-section/car.jpg"
                },
                "price_breakdown": {
                    "rental_days": 2,
                    "rental": 600.0,
                    "delivery": 50.0,
                    "tax": 97.5,
                    "extensions": []
                }
            }
        ],
        "pagination": {
            "current_page": 2,
            "per_page": 5,
            "total": 23,
            "total_pages": 5,
            "from": 6,
            "to": 10,
            "has_more": true
        },
        "image-path": {
            "base_url": "https://yourapp.com",
            "image_path": "site-section"
        }
    },
    "type": "success"
}
```

#### Success Response (200) - Empty Results

```json
{
    "message": {
        "success": ["No booking history found"]
    },
    "data": {
        "booking_history": [],
        "pagination": {
            "current_page": 1,
            "per_page": 5,
            "total": 0,
            "total_pages": 0,
            "from": null,
            "to": null,
            "has_more": false
        },
        "image-path": {
            "base_url": "https://yourapp.com",
            "image_path": "site-section"
        }
    },
    "type": "success"
}
```

#### Error Response (422) - Validation Failed

```json
{
    "message": {
        "error": ["The page must be at least 1."]
    },
    "type": "error"
}
```

### Filtering Logic

- Returns bookings with `status` 3 (completed) or 4 (rejected)
- Filters by vendor's cars (based on `vendor_id`)
- For vendor employees: additionally filters by `branch_id`
- Bookings ordered by `id` descending

### Notes

- The `image-path` provides base URL and path for car images
- Owner vendors see all bookings for their company
- Employee vendors see only bookings for their assigned branch
- Each booking includes `price_breakdown` — see [Price Breakdown](#price-breakdown) section below

---

---

## Price Breakdown

Every booking object in both history endpoints includes a `price_breakdown` group.

### Field Reference

| Field         | Type    | Description                                               |
| ------------- | ------- | --------------------------------------------------------- |
| `rental_days` | integer | Number of rental days for base booking                    |
| `rental`      | float   | Base rental cost (`subtotal` column)                      |
| `delivery`    | float   | Delivery fee (0.0 if not delivered)                       |
| `tax`         | float   | Tax charged on base booking                               |
| `extensions`  | array   | List of approved/pending extensions (empty array if none) |

### Extension Object Fields

| Field              | Type           | Description                                   |
| ------------------ | -------------- | --------------------------------------------- |
| `id`               | integer        | Extension ID                                  |
| `extra_days`       | integer        | Additional days added                         |
| `extra_amount`     | float          | Rental cost for extra days                    |
| `daily_rate`       | float          | Daily rate applied to extension               |
| `tax_percentage`   | float          | Tax rate percentage                           |
| `tax_amount`       | float          | Tax charged on extension                      |
| `total_amount`     | float          | Total for this extension (extra_amount + tax) |
| `old_return_at`    | datetime       | Return date before extension                  |
| `new_return_at`    | datetime       | Return date after extension                   |
| `status`           | string         | `pending` / `approved` / `rejected`           |
| `status_label`     | string         | Human-readable status                         |
| `approved_at`      | datetime\|null | When vendor approved                          |
| `rejection_reason` | string\|null   | Reason if rejected                            |
| `notes`            | string\|null   | Optional notes                                |
| `created_at`       | datetime       | When extension was requested                  |

### Grand Total Calculation

The API does **not** return a pre-computed grand total. Compute it on the client:

```dart
double grandTotal(PriceBreakdown pb) {
  final extensionTotal = pb.extensions
      .fold(0.0, (sum, e) => sum + e.totalAmount);
  return pb.rental + pb.delivery + pb.tax + extensionTotal;
}
```

### Dart Models

```dart
class BookingExtension {
  final int id;
  final int extraDays;
  final double extraAmount;
  final double dailyRate;
  final double taxPercentage;
  final double taxAmount;
  final double totalAmount;
  final String? oldReturnAt;
  final String? newReturnAt;
  final String status;
  final String statusLabel;
  final String? approvedAt;
  final String? rejectionReason;
  final String? notes;
  final String createdAt;

  const BookingExtension({
    required this.id,
    required this.extraDays,
    required this.extraAmount,
    required this.dailyRate,
    required this.taxPercentage,
    required this.taxAmount,
    required this.totalAmount,
    this.oldReturnAt,
    this.newReturnAt,
    required this.status,
    required this.statusLabel,
    this.approvedAt,
    this.rejectionReason,
    this.notes,
    required this.createdAt,
  });

  factory BookingExtension.fromJson(Map<String, dynamic> json) {
    return BookingExtension(
      id:              json['id'] as int,
      extraDays:       json['extra_days'] as int,
      extraAmount:     (json['extra_amount'] as num).toDouble(),
      dailyRate:       (json['daily_rate'] as num).toDouble(),
      taxPercentage:   (json['tax_percentage'] as num).toDouble(),
      taxAmount:       (json['tax_amount'] as num).toDouble(),
      totalAmount:     (json['total_amount'] as num).toDouble(),
      oldReturnAt:     json['old_return_at'] as String?,
      newReturnAt:     json['new_return_at'] as String?,
      status:          json['status'] as String,
      statusLabel:     json['status_label'] as String,
      approvedAt:      json['approved_at'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      notes:           json['notes'] as String?,
      createdAt:       json['created_at'] as String,
    );
  }
}

class PriceBreakdown {
  final int rentalDays;
  final double rental;
  final double delivery;
  final double tax;
  final List<BookingExtension> extensions;

  const PriceBreakdown({
    required this.rentalDays,
    required this.rental,
    required this.delivery,
    required this.tax,
    required this.extensions,
  });

  factory PriceBreakdown.fromJson(Map<String, dynamic> json) {
    return PriceBreakdown(
      rentalDays: json['rental_days'] as int,
      rental:     (json['rental'] as num).toDouble(),
      delivery:   (json['delivery'] as num).toDouble(),
      tax:        (json['tax'] as num).toDouble(),
      extensions: (json['extensions'] as List<dynamic>)
          .map((e) => BookingExtension.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  double get grandTotal {
    final extTotal = extensions.fold(0.0, (sum, e) => sum + e.totalAmount);
    return rental + delivery + tax + extTotal;
  }
}
```

### Flutter Widget Example

```dart
Widget buildPriceBreakdown(PriceBreakdown pb) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _row('Rental (${pb.rentalDays} days)', pb.rental),
      if (pb.delivery > 0) _row('Delivery', pb.delivery),
      if (pb.tax > 0) _row('Tax', pb.tax),
      for (final ext in pb.extensions)
        _row(
          'Extension +${ext.extraDays}d (${ext.statusLabel})',
          ext.totalAmount,
          dimmed: ext.status == 'rejected',
        ),
      const Divider(),
      _row('Total', pb.grandTotal, bold: true),
    ],
  );
}

Widget _row(String label, double amount, {bool bold = false, bool dimmed = false}) {
  final style = TextStyle(
    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    color: dimmed ? Colors.grey : null,
  );
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(amount.toStringAsFixed(2), style: style),
      ],
    ),
  );
}
```

---

## Mobile Lazy Loading Implementation

### Flutter/React Native Example

```dart
// Dart/Flutter example
class BookingHistoryScreen extends StatefulWidget {
  @override
  _BookingHistoryScreenState createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  List<Booking> bookings = [];
  int currentPage = 1;
  bool hasMore = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    final response = await api.get(
      '/api/v1/user/car-booking/history',
      queryParameters: {'page': currentPage, 'per_page': 5},
    );

    if (response.data['type'] == 'success') {
      final data = response.data['data'];
      setState(() {
        bookings.addAll(data['history'].map((b) => Booking.fromJson(b)));
        hasMore = data['pagination']['has_more'];
        currentPage++;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bookings.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == bookings.length) {
          loadBookings(); // Load more when reaching end
          return CircularProgressIndicator();
        }
        return BookingCard(booking: bookings[index]);
      },
    );
  }
}
```

### JavaScript/React Example

```javascript
// React example with infinite scroll
import { useState, useEffect, useRef } from "react";

export default function BookingHistory() {
    const [bookings, setBookings] = useState([]);
    const [page, setPage] = useState(1);
    const [hasMore, setHasMore] = useState(true);
    const [loading, setLoading] = useState(false);
    const observer = useRef();

    const loadMore = async () => {
        if (loading || !hasMore) return;

        setLoading(true);
        const response = await fetch(
            `/api/v1/user/car-booking/history?page=${page}&per_page=5`,
            { headers: { Authorization: `Bearer ${token}` } },
        );

        const json = await response.json();
        if (json.type === "success") {
            setBookings((prev) => [...prev, ...json.data.history]);
            setHasMore(json.data.pagination.has_more);
            setPage((prev) => prev + 1);
        }
        setLoading(false);
    };

    useEffect(() => {
        loadMore();
    }, []);

    const lastBookingRef = useCallback(
        (node) => {
            if (loading) return;
            if (observer.current) observer.current.disconnect();
            observer.current = new IntersectionObserver((entries) => {
                if (entries[0].isIntersecting && hasMore) {
                    loadMore();
                }
            });
            if (node) observer.current.observe(node);
        },
        [loading, hasMore],
    );

    return (
        <div>
            {bookings.map((booking, index) => (
                <div
                    key={booking.id}
                    ref={index === bookings.length - 1 ? lastBookingRef : null}
                >
                    <BookingCard booking={booking} />
                </div>
            ))}
            {loading && <div>Loading...</div>}
        </div>
    );
}
```

---

## Status Codes

| Status | Meaning         |
| ------ | --------------- |
| 1      | Pending         |
| 2      | Active/Accepted |
| 3      | Completed       |
| 4      | Rejected        |

---

## Implementation Details

### Changes from Previous Version

- **Added**: `page` and `per_page` query parameters
- **Added**: `price_breakdown` object on every booking item (rental_days, rental, delivery, tax, extensions)
- **Changed**: Response now includes separate `pagination` object instead of full collection
- **Changed**: Data array is now under `history` or `booking_history` key (not a paginator object)
- **Changed**: `extensions` is no longer a top-level field on the booking object — it now lives exclusively inside `price_breakdown.extensions`
- **Fixed**: Vendor endpoint now correctly filters by status using `whereIn([3,4])` instead of buggy `orWhere`

### Performance Considerations

- Default `per_page=5` optimized for mobile bandwidth
- Maximum `per_page=50` to prevent server overload
- Indexed queries on `user_id`, `vendor_id`, and `status` columns recommended
- Consider caching for vendors with high booking volume

### Migration Notes for Existing Clients

If you have existing mobile clients expecting unpaginated arrays:

1. Update to read `data.history` instead of direct array
2. Add pagination support using `data.pagination.has_more`
3. Send `per_page=100` (or higher) as temporary workaround if lazy loading cannot be implemented immediately
4. Long-term: implement proper pagination to improve performance

---

## Related Documentation

- [Car Booking Flow Guide](CAR_BOOKING_FLOW_GUIDE.md)
- [Car Booking API Quick Reference](CAR_BOOKING_API_QUICK_REFERENCE.md)
- [Booking Token Explained](BOOKING_TOKEN_EXPLAINED.md)
- [Invoice Rows Flutter Handoff](INVOICE_ROWS_FLUTTER_HANDOFF.md)
