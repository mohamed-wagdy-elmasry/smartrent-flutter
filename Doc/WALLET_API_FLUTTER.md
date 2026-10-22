# Wallet API (Flutter Integration)

Date: 2026-02-01

This document is a **Flutter-team focused** reference for the Wallet module:
- Wallet balance screen
- Wallet top-up (recommended flow)
- Wallet transactions list

> For deeper details about the invoice-based payment system (Moyasar invoices, invoice statuses, webhook flow, and invoice management endpoints), see: `docs/INVOICE_PAYMENT_SYSTEM.md`.

---

## Base URL

All endpoints below are under:

- `https://{HOST}/api`

Examples use the prefix `GET /api/...`.

---

## Authentication

These wallet endpoints use Laravel `auth:api` (Passport token in this project).

- Header: `Authorization: Bearer {access_token}`
- Header: `Accept: application/json`
- Header: `Content-Type: application/json`

If token is missing/expired you will get **401 Unauthorized**.

---

## Data Model (what the mobile UI will see)

### Wallet Balance (per currency)

Balance objects returned by the API look like:

```json
{
  "user_id": 1,
  "currency": "SAR",
  "balance": 250.0,
  "wallet_id": 10
}
```

Notes:
- Currency codes: `SAR`, `USD`, `EGP`.
- On `GET /wallet/balance`, if one currency fails to load, the backend returns a **placeholder** entry with `balance: 0` and an `error` field for that currency (so the app can still render partial results).

### Wallet Transaction

Transactions are stored as `WalletTransaction` and include (most relevant for UI):

- `id`
- `type`: one of
  - `topup` (credit)
  - `debit` (debit)
  - `refund_wallet` (credit)
  - `refund_card` (debit-ish, represents a refund being sent to card)
- `status`: `pending | completed | failed | refunded`
- `amount` (decimal)
- `currency` (`SAR|USD|EGP`)
- `balance_before`, `balance_after`
- `description`
- `created_at`

UI recommendation:
- Display amount sign based on `type`:
  - credit: `topup`, `refund_wallet`
  - debit: `debit`, `refund_card`

---

## 1) Wallet Balance Screen

### Get balances for all currencies

`GET /api/v1/wallet/balance`

Response (success):

```json
{
  "success": true,
  "message": "Wallet balances retrieved successfully",
  "data": {
    "balances": [
      {"user_id": 1, "currency": "USD", "balance": 0, "wallet_id": 12},
      {"user_id": 1, "currency": "SAR", "balance": 250, "wallet_id": 10},
      {"user_id": 1, "currency": "EGP", "balance": 0, "wallet_id": 15}
    ]
  }
}
```

Edge case (partial): one currency may include:

```json
{
  "user_id": 1,
  "currency": "EGP",
  "balance": 0,
  "wallet_id": null,
  "error": "..."
}
```

### Get balance for one currency

`GET /api/v1/wallet/balance/{currency}`

Example: `GET /api/v1/wallet/balance/SAR`

Response:

```json
{
  "success": true,
  "message": "Wallet balance retrieved successfully",
  "data": {"user_id": 1, "currency": "SAR", "balance": 250, "wallet_id": 10}
}
```

---

## 2) Transactions Screen

### List wallet transactions (paginated)

`GET /api/v1/wallet/transactions?per_page=20`

- Query params:
  - `per_page` (optional, default `20`)

Response:

```json
{
  "success": true,
  "message": "Transaction history retrieved successfully",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 123,
        "type": "topup",
        "status": "completed",
        "amount": "100.00",
        "currency": "SAR",
        "balance_before": "150.00",
        "balance_after": "250.00",
        "description": "Top-up 100 SAR",
        "created_at": "2026-02-01T10:00:00.000000Z"
      }
    ],
    "first_page_url": "...",
    "from": 1,
    "last_page": 2,
    "last_page_url": "...",
    "next_page_url": "...",
    "path": "...",
    "per_page": 20,
    "prev_page_url": null,
    "to": 20,
    "total": 25
  }
}
```

Implementation notes:
- The backend uses Laravel pagination, so you can paginate either by following `next_page_url` or by adding `?page=N`.
- Sort order is newest-first.

---

## 3) Wallet Top-up (Recommended for Flutter): Moyasar Invoice

This is the **recommended** top-up method for mobile:
- Flutter requests an invoice
- Flutter opens a **hosted payment page** (invoice URL) in a WebView/in-app browser
- Backend credits the wallet via webhook after successful payment

### Create top-up invoice

`POST /api/v1/wallet/topup/invoice`

Body:

```json
{
  "amount": 100.0,
  "currency": "SAR"
}
```

Rules:
- `amount`: numeric, `min=1`, `max=50000`
- `currency`: optional; if sent must be one of `SAR`, `USD`, `EGP` (defaults to `SAR` if omitted)

Response:

```json
{
  "success": true,
  "message": "...",
  "data": {
    "id": 1,
    "moyasar_invoice_id": "inv_xxx",
    "invoice_url": "https://pay.moyasar.com/invoices/xxx",
    "amount": 100.0,
    "currency": "SAR",
    "reference": "TOPUP-...",
    "expires_at": "2026-02-01T12:00:00Z",
    "status": "pending"
  }
}
```

Flutter flow suggestion:
1. Call `POST /wallet/topup/invoice`
2. Open `invoice_url` in WebView/in-app browser
3. When the user finishes payment and returns to the app:
   - refresh balance via `GET /wallet/balance`
   - refresh list via `GET /wallet/transactions`

If you want to show an intermediate “Payment pending” state:
- Poll balance/transactions for a short time (e.g., every 2–3 seconds up to 30–60 seconds), or
- Use invoice endpoints from `docs/INVOICE_PAYMENT_SYSTEM.md` to check invoice status.

Validation errors:
- Returns **422** with `errors` object.

---

## 4) Wallet Top-up (Legacy): PayTabs Hosted Payment Page

> Only use this if you still rely on PayTabs. For Flutter, prefer Moyasar Invoice.

### Initiate PayTabs top-up

`POST /api/v1/wallet/topup`  (alias: `POST /api/v1/wallet/top-up`)

Body:

```json
{
  "amount": 100.0,
  "currency": "SAR",
  "customer_name": "Optional Name",
  "customer_phone": "Optional Phone",
  "customer_city": "Optional City",
  "customer_country": "SAU"
}
```

Response:

```json
{
  "success": true,
  "message": "Top-up initiated successfully. Please complete payment.",
  "data": {
    "transaction_id": 123,
    "payment_url": "https://...",
    "cart_id": "TOPUP-...",
    "tran_ref": "TST...",
    "amount": 100,
    "currency": "SAR"
  }
}
```

Mobile handling:
- Open `payment_url` in WebView.
- PayTabs redirects to the API return endpoint:
  - `GET /api/v1/wallet/topup/return?cart_id=...&tran_ref=...`
- That endpoint returns JSON with `status`: `completed | failed | pending`.

Notes:
- Wallet crediting is primarily handled by the PayTabs webhook; the return endpoint is mainly for UI feedback.

---

## 5) QA / Dev-only (Do not ship to production)

### Test top-up (credits wallet immediately)

`POST /api/v1/wallet/topup/test` (alias: `POST /api/v1/wallet/top-up/test`)

- Disabled when `APP_ENV=production`.

Body:

```json
{
  "amount": 10.0,
  "currency": "SAR",
  "idempotency_key": "optional-string",
  "description": "optional"
}
```

---

## Quick Screen-to-API mapping (Flutter)

- **Wallet Balance Screen**
  - Load: `GET /api/v1/wallet/balance`
  - Pull-to-refresh: same

- **Top-up Screen**
  - Create invoice: `POST /api/v1/wallet/topup/invoice`
  - Open returned `invoice_url`
  - After returning to app: refresh `balance` + `transactions`

- **Transactions Screen**
  - Initial: `GET /api/v1/wallet/transactions?per_page=20`
  - Load more: follow `next_page_url` or use `?page=N`
