**Wallet Frontend API & Integration Guide**

-   **Purpose:**: Mobile frontend reference for Wallet top-ups, balance, transactions, refunds, and PayTabs integration (top-up flow + webhook expectations).
-   **Audience:**: Flutter mobile engineers and QA.

**Overview**:

-   Wallet supports multi-currency (ISO 4217): `USD`, `SAR`, `EGP`.
-   **Default currency:** The server will use `SAR` as a runtime fallback when no default currency is configured in the database (see server notes). Frontend should still send the desired currency per-operation.
-   Money amounts: server expects decimal strings with two decimal places (e.g., `"100.00"`). Use server-side canonical amounts — do not send integers in minor units.
-   Authentication: All protected endpoints require `Authorization: Bearer <token>` (Laravel Passport API tokens) in the header.
-   Idempotency: For user-initiated monetary operations (top-ups, refunds) include a client-generated `idempotency_key` (UUID v4 recommended). The server uses this to deduplicate and guarantee single processing.

**Common Headers**:

-   `Authorization: Bearer <token>` (for protected endpoints)
-   `Content-Type: application/json`
-   `Idempotency-Key: <uuid>` (optional, server also accepts `idempotency_key` in request body; we recommend sending in header for clarity)

**Endpoints**

-   **GET /api/v1/wallet/balance**

    -   **Auth:** required
    -   **Query params:** optional `currency` (ISO code). If omitted, returns balances grouped by currency.
    -   **Response (200):**
        {
        "success": true,
        "data": {
        "balances": [
        { "currency": "SAR", "balance": "250.00" },
        { "currency": "USD", "balance": "50.00" }
        ]
        }
        }
    -   **Notes:** Use this to show the user's available wallet balance(s).

-   **GET /api/v1/wallet/transactions**

    -   **Auth:** required
    -   **Query params:** `page`, `per_page`, `currency`, `type` (topup|debit|refund_wallet|refund_card)
    -   **Response (200):** paginated list of wallet transactions with `id`, `type`, `amount`, `currency`, `status`, `balance_before`, `balance_after`, `created_at`.

-   **POST /api/v1/wallet/top-up**

    -   **Auth:** required
    -   **Body:** JSON
        {
        "amount": "100.00",
        "currency": "SAR",
        "idempotency_key": "<uuid-v4>",
        "description": "Top up wallet"
        }
    -   **Response (201):**
        {
        "success": true,
        "data": {
        "payment_url": "https://paytabs.com/pay/<token>",
        "wallet_transaction_id": 123,
        "status": "pending"
        }
        }
    -   **Client work:** Open the `payment_url` in an external browser, in-app webview, or deep-link flow. The final confirmation of wallet credit may come via PayTabs webhook. The app should also poll the wallet transactions or call a confirm endpoint after the user completes payment.
    -   **Idempotency:** If the client re-sends with the same `idempotency_key`, the server will return the existing pending/created transaction instead of duplicating.

-   **POST /api/v1/wallet/topup/test** (and `POST /api/v1/wallet/top-up/test`)

-   **Auth:** required (Bearer token). Intended for QA / development only.
-   **Purpose:** Immediately credits the authenticated user's wallet without invoking the payment gateway. Useful for automated tests, QA flows, and seeding balances during development.
-   **Body:**
    {
    "amount": "10.00",
    "currency": "SAR",
    "idempotency_key": "<optional-uuid>",
    "description": "QA credit"
    }
-   **Response (200):**
    {
    "success": true,
    "message": "Top-up completed successfully (test)",
    "data": {
    "transaction_id": 789,
    "amount": "10.00",
    "currency": "SAR",
    "balance_after": "110.00"
    }
    }
-   **Notes & Security:**
-   This endpoint is a powerful testing shortcut and should not be exposed in production. It is protected by `auth:api` but we recommend one of the following additional guards in production systems:
-   Restrict to admin users (role check or `can:admin`).
-   Enable only in non-production environments (`app()->environment()` guard).
-   Protect behind a feature flag (e.g., `wallet.test_topup_enabled`).
-   Keep `idempotency_key` support when re-using keys during automated retries.
-   **Example curl:**


    ```powershell
    curl -i -X POST "http://127.0.0.1:8000/api/v1/wallet/topup/test" \
      -H "Accept: application/json" \
      -H "Authorization: Bearer <token>" \
      -H "Content-Type: application/json" \
      -d '{"amount":"10.00","currency":"SAR","idempotency_key":"test-123","description":"QA credit"}'
    ```

    -   **Postman:** Add a request to the Wallet collection: `POST {{baseUrl}}/api/v1/wallet/topup/test` with the JSON body above and your `bearerToken` variable set.

-   **POST /api/v1/wallet/refund-to-wallet**

    -   **Auth:** required (user)
    -   **Body:**
        {
        "wallet_transaction_id": 456,
        "idempotency_key": "<uuid>",
        "reason": "Booking cancelled"
        }
    -   **Response (200):** refund transaction created and wallet credited (or pending).

-   **POST /api/v1/wallet/refund-to-card**

    -   **Auth:** admin or privileged user (controller checks policy)
    -   **Body:**
        {
        "wallet_transaction_id": 456,
        "refund_amount": "50.00",
        "currency": "SAR",
        "idempotency_key": "<uuid>",
        "reason": "Chargeback"
        }
    -   **Response (202):** refund initiated to original card via PayTabs; status will be returned and logged when PayTabs confirms. Admins should monitor refund status in the app dashboard.

-   **PayTabs Webhook (public)**

    -   **POST /api/v1/wallet/paytabs/webhook**
    -   **Notes:**
        -   The server will verify the payload using HMAC-SHA256 against the `PAYTABS_SERVER_KEY` (signature header `X-Paytabs-Signature` or `X-Signature` if configured).
        -   Webhook events signal payment success/failure. The server updates pending wallet transactions accordingly.
        -   Do not rely only on the browser return URL; use webhook and transaction status checks.

-   **Return URL (user-facing)**
    -   **GET /api/v1/wallet/paytabs/return**
    -   **Notes:** This is used for redirecting users after PayTabs completes the flow. The app/webview should parse the return and then call the server (or poll the transactions endpoint) to get final status.

**Error responses**

-   400 Bad Request: validation errors (body missing, invalid currency, invalid amount format)
-   401 Unauthorized: missing/invalid Bearer token
-   403 Forbidden: insufficient role for `refund-to-card`
-   409 Conflict: duplicate idempotency_key detected for completed transaction
-   422 Unprocessable Entity: attempt to debit more than available balance
-   500 Server Error: retry later; the app should surface a generic error and allow retry with same idempotency key

Example (currency not found when requesting a specific currency):

```
{
  "success": false,
  "message": "Failed to retrieve wallet balance",
  "error": "Currency SAR not found in database"
}
```

Partial balances & missing currencies

-   When calling `GET /api/v1/wallet/balance` (no `currency` param) the server now returns partial results if one or more supported currencies cannot be resolved in the database. This prevents the entire request from failing when a single currency record is missing.
-   For currencies that fail lookup the API includes a placeholder entry so the app can present partial data. Placeholder fields:

    -   `user_id`: integer (auth user id)
    -   `currency`: ISO code (e.g., `SAR`)
    -   `balance`: `0.00` (numeric) — zero fallback so UI can show a numeric amount
    -   `wallet_id`: `null` (no wallet record exists)
    -   `error`: string (exception message, e.g. "Currency SAR not found in database")

-   Example partial response (200):

```
{
  "success": true,
  "message": "Wallet balances retrieved successfully",
  "data": {
    "balances": [
      { "user_id": 123, "currency": "USD", "balance": 50.00, "wallet_id": 11 },
      { "user_id": 123, "currency": "SAR", "balance": 0.00, "wallet_id": null, "error": "Currency SAR not found in database" }
    ]
  }
}
```

-   Single-currency requests (e.g. `GET /api/v1/wallet/balance?currency=SAR` or `GET /api/v1/wallet/balance/SAR`) will still return an error response (success: false) when that currency cannot be resolved. The error body looks like the example above.

Frontend guidance

-   Prefer to call the single-currency endpoint if you only need one currency and want explicit errors.
-   For multi-currency displays call `GET /api/v1/wallet/balance` and handle placeholder entries by showing a zero balance and a subtle warning or a retry button for that currency.

**Idempotency Guidance**

-   Use UUID v4 for `idempotency_key`.
-   Store the idempotency key client-side for retries until transaction completes.
-   Do not reuse the same `idempotency_key` for different logical operations.

**Currency & Rounding Rules**

-   Frontend must send currency as ISO 4217 (`"SAR"`, `"USD"`, `"EGP"`).
-   Amount should be a string with two decimal places (e.g., `"10.50"`). The backend uses `decimal(12,2)` — do not send more than two decimals.
-   If the app calculates exchange or shows currency conversions, treat backend as source-of-truth.

**Recommended frontend flows & UX**

-   Top-up flow

    1. User taps top-up and chooses amount and currency.
    2. App generates `idempotency_key` (UUID) and POSTs to `/api/v1/wallet/top-up`.
    3. Server returns `payment_url` and `wallet_transaction_id` with `status: pending`.
    4. App opens `payment_url` in secure webview or external browser. Prefer external browser on iOS to avoid webview limitations for some payment providers.
    5. After payment, the server receives PayTabs webhook and credits wallet.
    6. App detects completion via push, polling `/api/v1/wallet/transactions` or `/api/v1/wallet/balance`.

-   Polling guidelines:
    -   After user is redirected from PayTabs, poll the transaction ID every 2s up to 10 attempts, then fall back to manual refresh.
    -   Prefer server push (websocket/push notifications) in future; polling is acceptable short-term.

**Flutter Examples**

-   Dependencies (examples):

    -   `dio` for HTTP
    -   `uuid` for idempotency
    -   `flutter_secure_storage` for tokens
    -   `url_launcher` or `webview_flutter` for payment_url

-   Example: Dart service (simplified)

```dart
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class WalletApi {
  final Dio _dio;
  final String baseUrl;
  WalletApi(this._dio, {this.baseUrl = 'https://api.example.com/api/v1'});

  Future<Map<String, dynamic>> getBalance(String token, {String? currency}) async {
    final resp = await _dio.get(
      '$baseUrl/wallet/balance',
      queryParameters: currency != null ? {'currency': currency} : null,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return resp.data;
  }

  Future<Map<String, dynamic>> initiateTopUp(String token, String amount, String currency) async {
    final idempotency = Uuid().v4();
    final resp = await _dio.post(
      '$baseUrl/wallet/top-up',
      data: {
        'amount': amount,
        'currency': currency,
        'idempotency_key': idempotency,
        'description': 'Mobile top up'
      },
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Idempotency-Key': idempotency,
      }),
    );

    return resp.data['data'];
  }
}
```

-   Launching the payment URL

```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> openPaymentUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceSafariVC: false, forceWebView: false);
  } else {
    throw 'Could not open payment url';
  }
}
```

-   Using in-app WebView with return detection (simplified)
    -   Open `payment_url` in a `WebView`.
    -   Listen for navigation changes; if URL contains a configured `return` path, close the webview and call transaction status endpoint.

**Handling PayTabs return vs webhook**

-   The PayTabs return URL is user-facing and may be blocked or interrupted by the user. The server-side webhook is authoritative.
-   UX suggestion: after webview returns to app, immediately refresh transaction status by calling `/api/v1/wallet/transactions` for the returned `wallet_transaction_id` or call `/api/v1/wallet/balance`.

**Security Notes**

-   Always use HTTPS.
-   Store tokens securely (e.g., `flutter_secure_storage`).
-   Do not attempt to verify webhook signatures on the client — verification happens server-side with `PAYTABS_SERVER_KEY`.
-   Never embed secret keys in the app.

**Edge Cases & QA Checklist (short)**

-   Attempt double top-up with same `idempotency_key` — app should receive a single pending/created transaction.
-   Simulate network interruption mid-flow, then retry with same `idempotency_key`.
-   Test top-ups in each supported currency.
-   Test quick successive transactions to ensure UI remains responsive and duplicates are not created.
-   Confirm refund flows (refund to wallet and refund to card) are disallowed for normal users (refund-to-card is admin-only).

**Monitoring & Logging (frontend suggestions)**

-   Log (client-side) top-up attempts with `idempotency_key` and returned `wallet_transaction_id`.
-   Track failures and number of retries for top-ups.
-   Monitor time between `payment_url` opened and final webhook confirmation for UX improvements.

**Useful server-side notes for mobile team**

-   The server may return `status: pending` immediately after `top-up`; it will be updated to `completed` when PayTabs notifies us.
-   If you need immediate confirmation, poll the transactions endpoint using the returned `wallet_transaction_id`.
-   Refunds triggered from server may take additional time to reflect in card statements — app should show refund `status` values and timestamps from `/wallet/transactions`.

**FAQ**

-   Q: Should the client trust the return URL to indicate success?
    -   A: No. Use the webhook/transaction status calls as authoritative.
-   Q: What if the user closes the webview before redirect?
    -   A: Poll transactions or instruct the user to check "Transactions" -> refresh.

**Contact / escalation**

-   Backend owner: `payments` team (use internal slack channel `#payments`)
-   If a payment fails and the wallet was not credited, include `idempotency_key`, `wallet_transaction_id`, `paytabs_ref` (if available) in the support ticket.

---

Generated on: 2025-11-20
File: `docs/WALLET_FRONTEND_API.md`
