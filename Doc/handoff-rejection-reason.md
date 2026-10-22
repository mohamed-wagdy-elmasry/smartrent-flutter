# Flutter Handoff — Booking Rejection/Cancel Reason

**Endpoints:**
- `GET https://smartrent.sa/api/v1/user/car-booking/booking/history` (user)
- `GET https://smartrent.sa/api/v1/vendor/history/view` (vendor)

**Changed in:** `app/Http/Controllers/Api/V1/User/CarBookingController.php` · `app/Http/Controllers/Api/V1/Vendor/BookingHistoryController.php`

---

## What Changed on the Backend

### Each history item now has `rejection_reason`

Top-level field on every booking object in `data.history` (user) / `data.booking_history` (vendor):

```json
"rejection_reason": "Wrong car selected" 
```

| Type | When |
|------|------|
| `string` | Booking was cancelled/rejected — this is the reason text |
| `null` | Booking is **not** cancelled (or no cancel record exists) |

- Source: `booking_approvals.reason` from the latest transition with `status = "cancelled"` (the audit trail written on every state change).
- Typical values: user-typed reason, `Cancelled by user` (user cancelled), `No reason provided` (vendor rejected without typing a reason).
- **No request changes needed** — the field arrives automatically on the existing history calls.

---

## Recommended Integration

### Step 1 — Add the field to your booking model

```dart
class Booking {
  final int? id;
  final String? status;
  final String? rejectionReason; // <-- NEW
  // ... existing fields

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int?,
      status: json['status'] as String?,
      rejectionReason: json['rejection_reason'] as String?, // <-- NEW
      // ... existing fields
    );
  }
}
```

### Step 2 — Show it on the booking card / detail

```dart
// Simplest rule: display whenever the backend sent a reason
if (booking.rejectionReason != null &&
    booking.rejectionReason!.isNotEmpty)
  Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      '${tr("Reason")}: ${booking.rejectionReason}',
      style: TextStyle(color: Colors.red.shade700),
    ),
  ),
```

For an Arabic/English label, wrap the prefix in your own translation map — the reason text itself is **raw user text**, not translated by the backend.

---

## Response Shape (relevant fields)

```json
{
  "message": { "success": ["History fetched successfully!"] },
  "data": {
    "history": [
      {
        "id": 123,
        "status": "cancelled",
        "rejection_reason": "Wrong car selected",
        "price_breakdown": { "rental_days": 3, "rental": 900.0, "...": "..." }
      },
      {
        "id": 124,
        "status": "completed",
        "rejection_reason": null,
        "price_breakdown": { "...": "..." }
      }
    ],
    "pagination": { "current_page": 1, "per_page": 5, "has_more": true }
  },
  "type": "success"
}
```

Vendor endpoint: same field, items under `data.booking_history` instead of `data.history`.

---

## Edge Cases

| Scenario | Response | What to show |
|----------|----------|--------------|
| Booking not cancelled | `rejection_reason: null` | Hide the reason block entirely |
| Vendor rejected with no comment | `"No reason provided"` | Show it as-is (or localize the label) |
| User cancelled with no comment | `"Cancelled by user"` | Show it as-is (or localize the label) |
| Cancelled with typed reason | raw text | Show as-is; may contain any language |
| Old bookings (pre-feature) | `null` | Hide reason — cancel records exist only from the state-machine rollout onward |

**Note:** field is additive — old app versions ignore it, no breaking change. Field name must be exactly `rejection_reason`.

Related: `price_breakdown.extensions[].rejection_reason` already existed for **extension** rejections — don't confuse the two: top-level `rejection_reason` = whole booking cancelled; nested one = an extension request declined.
