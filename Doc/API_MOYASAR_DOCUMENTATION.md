# Payment & Wallet API Documentation

## Overview

This API handles payment transactions via **Moyasar (Visa)** and wallet management for the CarBo car rental platform.

### Key Points
- **Payment Gateway**: Moyasar only
- **Wallet Top-Up**: Users pay with Visa via Moyasar
- **Wallet Balance Updates**: Only via confirmed successful payments (backend-enforced)
- **Booking Payments**: Paid using wallet balance
- **Refunds**: Return money to wallet (not directly to Visa)
- **Idempotency**: Duplicate payment callbacks are handled safely
- **Security**: Card data never touches server (PCI-DSS compliant via Moyasar.js)

---

## Authentication

All protected endpoints require Bearer token authentication.

**Header:**
```
Authorization: Bearer {token}
```

**Token obtained from**: User login endpoint (not documented here)

---

## Base URL

```
https://api.example.com/api
```

---

# 1. Get Moyasar Publishable Key

Get the Moyasar publishable key for frontend integration (required to initialize Moyasar.js).

**Endpoint:** `GET /payments/config`  
**Authentication:** None (Public)

### Request Headers
```
Accept: application/json
```

### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Configuration retrieved successfully",
  "data": {
    "publishable_key": "pk_test_xxxxxxxxxxxxxxxxxxxxxxxx",
    "currency": "SAR",
    "supported_currencies": ["SAR", "USD", "EUR", "GBP", "AED", "KWD"],
    "supported_methods": ["creditcard", "applepay", "stcpay"]
  }
}
```

### Error Response (503 Service Unavailable)
```json
{
  "success": false,
  "message": "Payment gateway is currently disabled"
}
```

---

# 2. Create Payment (Wallet Top-Up or Order Payment)

Create a new payment transaction. This initiates the payment process and returns a payment URL for 3D Secure authentication.

**Endpoint:** `POST /payments`  
**Authentication:** Required

### Request Headers
```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

### Request Body
```json
{
  "token": "tok_xxxxxxxxxxxxxxxx",
  "amount": 10000,
  "currency": "SAR",
  "description": "Wallet top-up",
  "customer_name": "Ahmed Ali",
  "customer_email": "ahmed@example.com",
  "customer_phone": "+966501234567",
  "callback_url": "https://app.example.com/payment/callback",
  "metadata": {
    "type": "topup",
    "user_id": 123
  },
  "order_id": "ORD-2026-001",
  "given_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

### Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `token` | string | **Yes** | Payment token from Moyasar.js (frontend) |
| `amount` | integer | **Yes** | Amount in smallest currency unit (halalas for SAR). Min: 100 (1 SAR) |
| `currency` | string | No | Currency code. Default: `SAR`. Allowed: `SAR`, `USD`, `EUR`, `GBP`, `AED`, `KWD` |
| `description` | string | No | Payment description (max 255 chars) |
| `customer_name` | string | No | Customer full name |
| `customer_email` | string | No | Customer email |
| `customer_phone` | string | No | Customer phone number |
| `callback_url` | string | No | URL to redirect user after payment |
| `metadata` | object | No | Additional data to store with payment |
| `order_id` | string | No | Your unique order reference |
| `given_id` | string (UUID) | No | Idempotency key (auto-generated if not provided) |

### Success Response (201 Created)
```json
{
  "success": true,
  "message": "Payment created successfully",
  "data": {
    "payment_id": 123,
    "order_id": "ORD-2026-001",
    "moyasar_payment_id": "8e6789b9-c420-4960-9b4b-3d10f37a7801",
    "amount": 10000,
    "currency": "SAR",
    "status": "pending",
    "payment_url": "https://api.moyasar.com/v1/card_auth/xxx/prepare",
    "callback_url": "https://app.example.com/payment/callback"
  }
}
```

### Error Response (400 Bad Request)
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "token": ["Payment token is required. Please collect card details using Moyasar.js on the frontend."],
    "amount": ["Payment amount must be at least 100 halalas (1 SAR)"]
  }
}
```

### Error Response (503 Service Unavailable)
```json
{
  "success": false,
  "message": "Moyasar payment gateway is currently disabled"
}
```

### Important Notes
- **Token Generation**: Card data must be tokenized on frontend using Moyasar.js
- **Amount Format**: Always in smallest currency unit (100 = 1 SAR, 1000 = 10 SAR)
- **3D Secure**: Redirect user to `payment_url` for authentication
- **Idempotency**: Use same `given_id` to safely retry failed requests
- **Wallet Update**: Balance only updated after payment is `paid` (via webhook/callback)

---

# 3. Moyasar Webhook (Payment Status Update)

Moyasar sends webhook notifications when payment status changes. This endpoint updates payment status and credits wallet if applicable.

**Endpoint:** `POST /moyasar/webhook`  
**Authentication:** Signature verification (automatic)  
**Caller:** Moyasar servers

### Request Headers
```
Content-Type: application/json
X-Moyasar-Signature: sha256=xxxxxxxxxxxxx
```

### Webhook Payload (from Moyasar)
```json
{
  "type": "payment_paid",
  "data": {
    "id": "8e6789b9-c420-4960-9b4b-3d10f37a7801",
    "status": "paid",
    "amount": 10000,
    "currency": "SAR",
    "refunded_amount": 0,
    "source": {
      "type": "creditcard",
      "transaction_id": "txn_xxxxxxxx"
    }
  }
}
```

### Webhook Event Types
- `payment_paid` - Payment successful
- `payment_failed` - Payment failed
- `payment_refunded` - Payment refunded

### Payment Status Values
| Status | Description | Wallet Update |
|--------|-------------|---------------|
| `pending` | Payment initiated, awaiting authentication | No |
| `authorized` | Card authorized, awaiting capture | No |
| `paid` | Payment successful | **Yes** (for topup type) |
| `failed` | Payment failed | No |
| `refunded` | Full refund processed | Yes (amount returned) |
| `partially_refunded` | Partial refund processed | Yes (partial amount) |
| `expired` | Payment expired | No |
| `canceled` | Payment canceled | No |

### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Webhook processed successfully"
}
```

### Error Response (401 Unauthorized)
```json
{
  "success": false,
  "message": "Invalid signature"
}
```

### Important Notes
- **Signature Verification**: Required in production (via webhook secret)
- **Idempotency**: Duplicate webhooks are safely ignored
- **Wallet Crediting**: Automatic for `type: "topup"` payments when status = `paid`
- **Transaction Logging**: All balance changes logged in `wallet_transactions` table
- **Async Processing**: Wallet crediting queued for reliability

---

# 4. Payment Callback (User Redirect)

User is redirected here after completing 3D Secure authentication. Displays payment status page.

**Endpoint:** `GET /moyasar/callback`  
**Authentication:** None (Public)  
**Method:** GET

### Query Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | **Yes** | Moyasar payment ID |
| `status` | string | No | Payment status hint (not used, DB is source of truth) |

### Example Request
```
GET /moyasar/callback?id=8e6789b9-c420-4960-9b4b-3d10f37a7801&status=paid
```

### Response
Returns HTML page displaying payment status (success/pending/failed) with payment details.

### Important Notes
- **No Wallet Update Here**: Balance only updated via webhook (not callback)
- **Display Only**: This endpoint shows status, doesn't process payment
- **Status Source**: Always reads from database (ignores query param)

---

# 5. Get Wallet Balance

Retrieve user's wallet balance for all supported currencies.

**Endpoint:** `GET /v1/wallet/balance`  
**Authentication:** Required

### Request Headers
```
Authorization: Bearer {token}
Accept: application/json
```

### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Wallet balances retrieved successfully",
  "data": {
    "balances": [
      {
        "user_id": 123,
        "currency": "SAR",
        "balance": 250.50,
        "wallet_id": 45
      },
      {
        "user_id": 123,
        "currency": "USD",
        "balance": 0.00,
        "wallet_id": 46
      }
    ]
  }
}
```

### Error Response (500 Internal Server Error)
```json
{
  "success": false,
  "message": "Failed to retrieve wallet balance",
  "error": "Database connection error"
}
```

---

# 6. Get Wallet Balance by Currency

Get wallet balance for a specific currency.

**Endpoint:** `GET /v1/wallet/balance/{currency}`  
**Authentication:** Required

### URL Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `currency` | string | **Yes** | Currency code (SAR, USD, EUR, etc.) |

### Example Request
```
GET /v1/wallet/balance/SAR
```

### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Wallet balance retrieved successfully",
  "data": {
    "user_id": 123,
    "currency": "SAR",
    "balance": 250.50,
    "wallet_id": 45
  }
}
```

### Error Response (400 Bad Request)
```json
{
  "success": false,
  "message": "Failed to retrieve wallet balance",
  "error": "Unsupported currency"
}
```

---

# 7. Get Wallet Transactions

Retrieve user's wallet transaction history.

**Endpoint:** `GET /v1/wallet/transactions`  
**Authentication:** Required

### Request Headers
```
Authorization: Bearer {token}
Accept: application/json
```

### Query Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `currency` | string | No | Filter by currency |
| `type` | string | No | Filter by transaction type |
| `page` | integer | No | Page number (default: 1) |
| `per_page` | integer | No | Items per page (default: 20) |

### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Transaction history retrieved successfully",
  "data": {
    "transactions": [
      {
        "id": 789,
        "type": "topup",
        "amount": 100.00,
        "currency": "SAR",
        "balance_before": 150.50,
        "balance_after": 250.50,
        "status": "completed",
        "description": "Wallet top-up via Moyasar",
        "moyasar_payment_id": "8e6789b9-c420-4960-9b4b-3d10f37a7801",
        "created_at": "2026-01-11T12:30:00Z"
      },
      {
        "id": 788,
        "type": "debit",
        "amount": -50.00,
        "currency": "SAR",
        "balance_before": 200.50,
        "balance_after": 150.50,
        "status": "completed",
        "description": "Car booking payment",
        "booking_id": 456,
        "created_at": "2026-01-10T14:20:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total": 45,
      "last_page": 3
    }
  }
}
```

### Transaction Types
- `topup` - Wallet top-up via payment
- `debit` - Payment for booking
- `refund` - Refund from canceled booking
- `adjustment` - Admin adjustment

---

# 8. Initiate Wallet Top-Up

Start wallet top-up process. Creates a payment and returns payment URL.

**Endpoint:** `POST /v1/wallet/topup`  
**Authentication:** Required  
**Alias:** `POST /v1/wallet/top-up` (both work)

### Request Headers
```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

### Request Body
```json
{
  "amount": 100.00,
  "currency": "SAR",
  "customer_name": "Ahmed Ali",
  "customer_phone": "+966501234567"
}
```

### Request Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `amount` | number | **Yes** | Amount in main currency unit (100.00 = 100 SAR) |
| `currency` | string | **Yes** | Currency code (SAR, USD, etc.) |
| `customer_name` | string | No | Customer name (defaults to user's name) |
| `customer_phone` | string | No | Customer phone |

### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Wallet top-up initiated successfully",
  "data": {
    "transaction_id": "txn_abc123",
    "payment_url": "https://secure.paytabs.com/payment/page/abc123",
    "amount": 100.00,
    "currency": "SAR"
  }
}
```

### Error Response (400 Bad Request)
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "amount": ["Amount must be at least 10.00 SAR"]
  }
}
```

### Important Notes
- **Amount Conversion**: Frontend sends main units (100.00), backend converts to halalas (10000)
- **Payment Flow**: User redirected to `payment_url` → completes payment → redirected to callback
- **Balance Update**: Only after successful payment confirmation via webhook
- **User Info**: Email auto-filled from authenticated user

---

# 9. Verify Payment Status

Check current payment status.

**Endpoint:** `POST /payments/{id}/verify`  
**Authentication:** Required

### URL Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | integer | **Yes** | Payment ID (not Moyasar payment ID) |

### Example Request
```
POST /payments/123/verify
```

### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Payment status retrieved successfully",
  "data": {
    "payment_id": 123,
    "moyasar_payment_id": "8e6789b9-c420-4960-9b4b-3d10f37a7801",
    "status": "paid",
    "amount": 10000,
    "currency": "SAR",
    "paid_at": "2026-01-11T12:30:00Z"
  }
}
```

### Error Response (404 Not Found)
```json
{
  "success": false,
  "message": "Payment not found"
}
```

---

# 10. Get Payment Details

Retrieve detailed payment information.

**Endpoint:** `GET /payments/{id}`  
**Authentication:** Required

### URL Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | integer | **Yes** | Payment ID |

### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Payment retrieved successfully",
  "data": {
    "id": 123,
    "order_id": "ORD-2026-001",
    "payment_id": "8e6789b9-c420-4960-9b4b-3d10f37a7801",
    "user_id": 456,
    "type": "topup",
    "gateway": "moyasar",
    "amount": 10000,
    "currency": "SAR",
    "status": "paid",
    "method": "creditcard",
    "amount_refunded": 0,
    "customer_name": "Ahmed Ali",
    "customer_email": "ahmed@example.com",
    "customer_phone": "+966501234567",
    "description": "Wallet top-up",
    "paid_at": "2026-01-11T12:30:00Z",
    "created_at": "2026-01-11T12:25:00Z",
    "updated_at": "2026-01-11T12:30:00Z"
  }
}
```

---

# 11. List User Payments

Get list of all payments for authenticated user.

**Endpoint:** `GET /payments`  
**Authentication:** Required

### Query Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string | No | Filter by status |
| `type` | string | No | Filter by type (topup, order) |
| `page` | integer | No | Page number |
| `per_page` | integer | No | Items per page |

### Success Response (200 OK)
```json
{
  "success": true,
  "data": {
    "payments": [
      {
        "id": 123,
        "order_id": "ORD-2026-001",
        "amount": 10000,
        "currency": "SAR",
        "status": "paid",
        "type": "topup",
        "created_at": "2026-01-11T12:25:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total": 5,
      "last_page": 1
    }
  }
}
```

---

# 12. Refund to Wallet

Process refund back to user's wallet (e.g., from canceled booking).

**Endpoint:** `POST /v1/wallet/refund/wallet`  
**Authentication:** Required

### Request Headers
```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

### Request Body
```json
{
  "payment_id": 123,
  "amount": 50.00,
  "currency": "SAR",
  "reason": "Booking canceled by user"
}
```

### Request Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `payment_id` | integer | **Yes** | Original payment ID |
| `amount` | number | **Yes** | Refund amount (main currency units) |
| `currency` | string | **Yes** | Currency code |
| `reason` | string | No | Refund reason |

### Success Response (200 OK)
```json
{
  "success": true,
  "message": "Refund processed successfully",
  "data": {
    "transaction_id": 890,
    "amount": 50.00,
    "currency": "SAR",
    "new_balance": 300.50
  }
}
```

### Error Response (400 Bad Request)
```json
{
  "success": false,
  "message": "Refund amount exceeds original payment amount"
}
```

### Important Notes
- **Wallet Only**: Refunds go to wallet, never directly back to Visa card
- **Transaction Logged**: Creates new `refund` transaction in history
- **Balance Update**: Immediate (not via webhook)
- **Partial Refunds**: Supported

---

## Data Flow Summary

### Wallet Top-Up Flow
1. **Frontend**: User enters amount → Moyasar.js tokenizes card → gets `token`
2. **POST /payments**: Send `token` + `amount` → get `payment_url`
3. **Frontend**: Redirect user to `payment_url` (3D Secure)
4. **User**: Completes authentication on Moyasar page
5. **Moyasar**: Processes payment → sends webhook to `/moyasar/webhook`
6. **Backend**: Webhook updates payment status to `paid` → credits wallet
7. **Moyasar**: Redirects user to `/moyasar/callback` → shows success page

### Booking Payment Flow
1. **Frontend**: User selects car → checks wallet balance via `/v1/wallet/balance`
2. **Frontend**: Confirms booking → backend debits wallet
3. **Backend**: Creates `debit` transaction → updates balance
4. **Frontend**: Shows booking confirmation

### Refund Flow
1. **User/Admin**: Cancels booking
2. **Backend**: POST `/v1/wallet/refund/wallet` → credits wallet
3. **Backend**: Creates `refund` transaction
4. **User**: Sees updated balance in wallet

---

## Important Security Notes

1. **PCI-DSS Compliance**
   - Card data never sent to backend
   - Only Moyasar tokens accepted
   - Frontend must use Moyasar.js

2. **Wallet Balance Protection**
   - Never updated from frontend
   - Only via verified webhook signatures
   - All changes logged with before/after balance

3. **Idempotency**
   - Use `given_id` (UUID) for safe retries
   - Duplicate webhooks ignored automatically
   - Same `given_id` returns same payment

4. **Amount Handling**
   - Always validate amount > minimum
   - Store in smallest unit (halalas)
   - Display in main units (SAR)

5. **Webhook Security**
   - Signature verification required in production
   - Payload logged for audit
   - Invalid signatures rejected

---

## Error Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Resource created |
| 400 | Bad request / Validation error |
| 401 | Unauthorized / Invalid signature |
| 404 | Resource not found |
| 500 | Internal server error |
| 503 | Service unavailable |

---

## Testing

### Test Webhook (Development Only)
```
POST /moyasar/webhook/test
```

**Not available in production.**

### Test Top-Up (Development Only)
```
POST /v1/wallet/topup/test
```

Credits wallet immediately without payment gateway. **Not available in production.**

---

## Contact

For integration support or issues, contact the backend team.
