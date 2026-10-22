# Invoice Rows — Flutter Frontend Handoff

**Feature:** Invoice breakdown rows on car booking response  
**Backend file:** `app/Http/Resources/BookingResource.php` → key `invoice_rows`  
**Service:** `app/Services/Booking/InvoiceRowsService.php`  
**Columns:** `car_bookings.subtotal / delivery_fee / tax_amount / discount_amount / total_amount`

---

## Table of Contents

1. [What is `invoice_rows`](#1-what-is-invoice_rows)
2. [API Contract](#2-api-contract)
3. [Sending Breakdown on Booking Confirm](#3-sending-breakdown-on-booking-confirm)
4. [Dart Models](#4-dart-models)
5. [Rendering in Flutter](#5-rendering-in-flutter)
6. [Label Translation](#6-label-translation)
7. [Edge Cases & Rules](#7-edge-cases--rules)
8. [Full Example Response](#8-full-example-response)

---

## 1. What is `invoice_rows`

Every `GET /api/v1/bookings/{id}` response (and any endpoint that returns a `BookingResource`) now includes an `invoice_rows` array.

Each element is a single line item in the pricing breakdown:

```json
"invoice_rows": [
  { "label": "invoice_rental",   "amount": 1200.00 },
  { "label": "invoice_delivery", "amount":  150.00 },
  { "label": "invoice_tax",      "amount":  189.00 },
  { "label": "invoice_discount", "amount": -100.00 },
  { "label": "invoice_total",    "amount": 1439.00 }
]
```

**Rules your UI must honour:**

| Rule | Detail |
|---|---|
| Empty array | Booking has no pricing breakdown stored — show nothing (legacy booking) |
| Negative amount | Only `invoice_discount` — render in red / with `−` prefix |
| `invoice_total` | Always the last row; always present when any rows exist |
| Row order | Fixed: Rental → Delivery → Tax → Discount → Total |
| Zero-value rows | Never included (except Total) — don't add conditional checks |

---

## 2. API Contract

### Endpoint that returns `invoice_rows`

```
GET /api/v1/bookings/{id}
Authorization: Bearer {token}
```

### Response shape (trimmed to relevant keys)

```json
{
  "status": 200,
  "data": {
    "id": 42,
    "slug": "car-7",
    "status": "pending",
    "rental_days": 3,
    "daily_price": 400.00,
    "invoice_rows": [
      { "label": "invoice_rental",   "amount": 1200.00 },
      { "label": "invoice_delivery", "amount":  150.00 },
      { "label": "invoice_tax",      "amount":  189.00 },
      { "label": "invoice_discount", "amount": -100.00 },
      { "label": "invoice_total",    "amount": 1439.00 }
    ]
  }
}
```

### `invoice_rows` element schema

| Field    | Type   | Notes |
|----------|--------|-------|
| `label`  | String | Translation key (see §6) |
| `amount` | double | Negative only for `invoice_discount` |

---

## 3. Sending Breakdown on Booking Confirm

When your app knows the pricing breakdown at booking confirm time (e.g. after a pricing preview), send the optional breakdown fields alongside the regular `confirm` payload. The backend stores them as the immutable invoice snapshot.

### Endpoint

```
POST /api/v1/bookings/confirm
Authorization: Bearer {token}
Content-Type: application/json
```

### New optional fields

```json
{
  "car_id": 7,
  "car_slug": "car-7",
  "mobile": "0501234567",
  "fees": 1439.00,
  "token": "abc123bookingtoken",
  "payment": "wallet",
  "rental_days": 3,
  "pickup_date": "2026-03-10",
  "pickup_time": "10:00",

  "subtotal":        1200.00,
  "delivery_fee":     150.00,
  "tax_amount":       189.00,
  "discount_amount":  100.00
}
```

**Notes:**
- `discount_amount` is sent as a **positive number** — the backend stores and returns it as negative (`-100.00`)
- All four breakdown fields are optional — omit any that don't apply
- `fees` must equal `subtotal + delivery_fee + tax_amount − discount_amount`
- If breakdown fields are omitted, `subtotal` is auto-computed as `daily_price × rental_days`

---

## 4. Dart Models

### `InvoiceRow`

```dart
class InvoiceRow {
  final String label;
  final double amount;

  const InvoiceRow({required this.label, required this.amount});

  factory InvoiceRow.fromJson(Map<String, dynamic> json) {
    return InvoiceRow(
      label:  json['label'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  bool get isDiscount => amount < 0;
  bool get isTotal    => label == 'invoice_total';
}
```

### Parsing inside your `BookingModel`

```dart
class BookingModel {
  // ... other fields ...
  final List<InvoiceRow> invoiceRows;

  BookingModel.fromJson(Map<String, dynamic> json)
      : invoiceRows = (json['invoice_rows'] as List<dynamic>? ?? [])
            .map((e) => InvoiceRow.fromJson(e as Map<String, dynamic>))
            .toList();
}
```

### `BookingConfirmRequest` — with optional breakdown

```dart
class BookingConfirmRequest {
  final int carId;
  final String carSlug;
  final String mobile;
  final double fees;
  final String token;
  final String payment;
  final int rentalDays;
  final String pickupDate;
  final String pickupTime;

  // Optional breakdown (send when known)
  final double? subtotal;
  final double? deliveryFee;
  final double? taxAmount;
  final double? discountAmount;

  Map<String, dynamic> toJson() => {
    'car_id':    carId,
    'car_slug':  carSlug,
    'mobile':    mobile,
    'fees':      fees,
    'token':     token,
    'payment':   payment,
    'rental_days': rentalDays,
    'pickup_date': pickupDate,
    'pickup_time': pickupTime,
    if (subtotal != null)        'subtotal':        subtotal,
    if (deliveryFee != null)     'delivery_fee':    deliveryFee,
    if (taxAmount != null)       'tax_amount':      taxAmount,
    if (discountAmount != null)  'discount_amount': discountAmount,
  };
}
```

---

## 5. Rendering in Flutter

### Label helper

```dart
String localiseInvoiceLabel(String key, BuildContext context) {
  // Add to your app_localizations or use a simple map
  const labels = {
    'invoice_rental':   'Rental',
    'invoice_delivery': 'Delivery',
    'invoice_tax':      'Tax',
    'invoice_discount': 'Discount',
    'invoice_total':    'Total',
  };
  return labels[key] ?? key;
}
```

### `InvoiceRowsTable` widget

```dart
class InvoiceRowsTable extends StatelessWidget {
  final List<InvoiceRow> rows;
  const InvoiceRowsTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: rows.map((row) => _buildRow(context, row)).toList(),
      ),
    );
  }

  Widget _buildRow(BuildContext context, InvoiceRow row) {
    final isDiscount = row.isDiscount;
    final isTotal    = row.isTotal;
    final label      = localiseInvoiceLabel(row.label, context);
    final amount     = row.amount.abs();
    final formatted  = '${isDiscount ? '−' : ''}${amount.toStringAsFixed(2)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isTotal ? const Color(0xFFF9FAFB) : Colors.transparent,
        border: rows.last == row
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
        borderRadius: isTotal
            ? const BorderRadius.vertical(bottom: Radius.circular(12))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize:   isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: const Color(0xFF374151),
            ),
          ),
          Text(
            formatted,
            style: TextStyle(
              fontSize:   isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isDiscount
                  ? const Color(0xFF16A34A)  // green for discount
                  : const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Usage

```dart
// In your booking detail screen:
InvoiceRowsTable(rows: booking.invoiceRows)

// Or inline:
if (booking.invoiceRows.isNotEmpty)
  InvoiceRowsTable(rows: booking.invoiceRows),
```

---

## 6. Label Translation

The `label` field is a translation **key**, not a display string. Map it in your localization layer:

| Key                | English    | Arabic    | Spanish    | French    |
|--------------------|------------|-----------|------------|-----------|
| `invoice_rental`   | Rental     | الإيجار   | Alquiler   | Location  |
| `invoice_delivery` | Delivery   | التوصيل   | Entrega    | Livraison |
| `invoice_tax`      | Tax        | الضريبة   | Impuesto   | Taxe      |
| `invoice_discount` | Discount   | الخصم     | Descuento  | Remise    |
| `invoice_total`    | Total      | الإجمالي  | Total      | Total     |

> All keys are already in `lang/en.json`, `lang/ar.json`, `lang/es.json`, `lang/fr.json` on the backend.

---

## 7. Edge Cases & Rules

### Empty `invoice_rows`

```dart
if (booking.invoiceRows.isEmpty) {
  // Don't show the invoice table at all.
  // This is a legacy booking created before the snapshot migration.
}
```

### Discount is always negative

```dart
// Backend always returns discount as negative: -100.00
// Your display should show: "Discount   −100.00"
// Use row.isDiscount (amount < 0) to apply green color
```

### Amounts are already rounded to 2 decimal places

The backend rounds via `round($value, 2)` — no client-side rounding needed.

### `fees` must equal the sum

When building the confirm request:

```dart
double computeTotal({
  required double subtotal,
  double deliveryFee   = 0,
  double taxAmount     = 0,
  double discountAmount = 0,
}) {
  return subtotal + deliveryFee + taxAmount - discountAmount;
}

// fees must equal this computed total
final fees = computeTotal(
  subtotal:        1200,
  deliveryFee:     150,
  taxAmount:       189,
  discountAmount:  100,
); // → 1439.0
```

### RTL layout

For Arabic, `Row` with `MainAxisAlignment.spaceBetween` handles RTL automatically. No extra changes needed — `Directionality` from `MaterialApp.locale` drives it.

---

## 8. Full Example Response

```json
{
  "status": 200,
  "message": ["Booking data fetched successfully"],
  "data": {
    "id": 42,
    "slug": "car-7",
    "status": "approved",
    "status_label": "Approved",
    "pickup_at": "2026-03-10 10:00:00",
    "return_at": "2026-03-13 10:00:00",
    "rental_days": 3,
    "daily_price": 400.00,
    "ledger_balance": 1439.00,
    "is_deliver": true,
    "location": "King Fahd Road, Riyadh",
    "can_extend": false,
    "can_cancel": true,
    "can_pay": false,
    "invoice_rows": [
      { "label": "invoice_rental",   "amount": 1200.00 },
      { "label": "invoice_delivery", "amount":  150.00 },
      { "label": "invoice_tax",      "amount":  189.00 },
      { "label": "invoice_discount", "amount": -100.00 },
      { "label": "invoice_total",    "amount": 1439.00 }
    ],
    "car": {
      "id": 7,
      "car_model": "Toyota Camry",
      "car_number": null
    },
    "extensions": [],
    "transactions": [
      {
        "id": 1,
        "category": "base",
        "type": "debit",
        "payment_method": "wallet",
        "amount": "1439.00",
        "status": "paid"
      }
    ],
    "created_at": "2026-02-27 14:30:00",
    "updated_at": "2026-02-27 14:30:00"
  }
}
```

---

## Quick Checklist for Flutter Developer

- [ ] Parse `invoice_rows` from every booking response (safe: defaults to `[]`)
- [ ] Show `InvoiceRowsTable` only when `invoiceRows.isNotEmpty`
- [ ] Apply green / minus sign for negative `amount` (discount row)
- [ ] Bold + background tint on `invoice_total` row
- [ ] Map `label` key → localized string via your l10n layer
- [ ] On booking confirm, compute `fees = subtotal + delivery_fee + tax_amount − discount_amount` and send all four breakdown fields
- [ ] `discount_amount` is sent **positive** to the backend (backend stores/returns it as negative)
