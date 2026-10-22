# PayTabs Flutter Integration with Laravel Backend

This guide explains how to integrate your Flutter mobile app with the PayTabs-enabled Laravel backend.

## Overview

The payment flow works as follows:

1. **Flutter App** → Calls Laravel API to create a payment
2. **Laravel Backend** → Creates PayTabs hosted payment page
3. **Laravel Backend** → Returns payment URL to Flutter
4. **Flutter App** → Opens payment URL in WebView or browser
5. **User** → Completes payment on PayTabs hosted page
6. **PayTabs** → Sends callback to Laravel backend
7. **PayTabs** → Redirects user back to return URL
8. **Flutter App** → Verifies payment status with Laravel API

## Prerequisites

### Laravel Backend Setup

Ensure your Laravel backend is properly configured:

1. PayTabs credentials set in `.env`:

```env
PAYTABS_PROFILE_ID=your_profile_id
PAYTABS_SERVER_KEY=your_server_key
PAYTABS_CURRENCY=SAR
PAYTABS_REGION=SAU
PAYTABS_ENVIRONMENT=sandbox  # or 'production'
```

2. Publicly accessible callback URL (required for PayTabs to send payment notifications)

### Flutter Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
    http: ^1.1.0
    webview_flutter: ^4.4.2 # For displaying PayTabs payment page
    url_launcher: ^6.2.1 # Alternative to WebView
```

## API Endpoints

### PayTabs Payment Endpoints

Base URL: `https://your-domain.com`

| Endpoint                       | Method | Authentication | Purpose                       |
| ------------------------------ | ------ | -------------- | ----------------------------- |
| `/api/paytabs/create-payment`  | POST   | Required       | Create payment page           |
| `/api/paytabs/verify-payment`  | POST   | Required       | Verify payment status         |
| `/api/paytabs/refund-payment`  | POST   | Required       | Process refund                |
| `/api/paytabs/payment-methods` | GET    | Required       | Get available payment methods |
| `/api/paytabs/currencies`      | GET    | Required       | Get supported currencies      |
| `/api/paytabs/callback`        | POST   | None           | PayTabs webhook callback      |

### Car Booking Endpoints

Base URL: `https://your-domain.com`

| Endpoint                                    | Method | Authentication | Purpose                      |
| ------------------------------------------- | ------ | -------------- | ---------------------------- |
| `/api/v1/user/car-booking/paytabs/verify`   | POST   | Required       | Verify car booking payment   |
| `/api/v1/user/car-booking/paytabs/callback` | POST   | None           | Car booking payment callback |

---

### 1. Create Payment (PayTabs Direct)

**Endpoint:** `POST /api/paytabs/create-payment`

**Authentication:** Required (Bearer token)

**Required Parameters:**

-   `cart_id` - Unique order/booking ID (string)
-   `cart_amount` - Total amount to charge (numeric, min: 0.01)
-   `customer_name` - Customer full name (string)
-   `customer_email` - Customer email address (valid email)
-   `customer_phone` - Customer phone number (string)

**Optional Parameters:**

-   `cart_description` - Order description (string, max: 255)
-   `customer_street` - Street address
-   `customer_city` - City name
-   `customer_state` - State/province
-   `customer_country` - Country code (3-letter ISO, default: SAU)
-   `customer_zip` - Postal code (default: 00000)
-   `return_url` - URL after payment completes (overrides config)
-   `callback_url` - Webhook URL for payment notifications (overrides config)
-   `transaction_type` - Type of transaction: `sale`, `auth`, `register` (default: sale)
-   `transaction_class` - Transaction class: `ecom`, `recurring`, `moto` (default: ecom)
-   `payment_method` - Payment method filter (default: all)
-   `language` - UI language: `en` or `ar` (default: en)
-   `hide_shipping` - Hide shipping form if same as billing (boolean, default: true)
-   `user_defined` - Custom fields as object (for storing booking data)
-   `shipping_name`, `shipping_email`, `shipping_phone`, `shipping_street`, `shipping_city`, `shipping_state`, `shipping_country`, `shipping_zip` - Shipping details (if hide_shipping is false)

**Request Body Example:**

```json
{
    "cart_id": "BOOKING_12345",
    "cart_amount": 500.0,
    "cart_description": "Car rental: Toyota Camry 5 days",
    "customer_name": "Ahmed Ali",
    "customer_email": "ahmed@example.com",
    "customer_phone": "+966501234567",
    "customer_city": "Riyadh",
    "customer_country": "SAU",
    "transaction_type": "sale",
    "transaction_class": "ecom",
    "payment_method": "all",
    "language": "en",
    "hide_shipping": true,
    "user_defined": {
        "booking_id": "12345",
        "user_id": "67890",
        "booking_token": "fnaC7ti2Sewh81tUkDkG",
        "car_id": "1",
        "rental_days": "5"
    }
}
```

**Response (Success - 200):**

```json
{
    "success": true,
    "message": "Payment page created successfully",
    "data": {
        "payment_url": "https://secure.paytabs.sa/payment/page/...",
        "transaction_ref": "TST2213800357411"
    }
}
```

**Response (Error - 400/422/500):**

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "cart_amount": ["The cart amount field is required."],
        "customer_email": ["The customer email must be a valid email address."]
    }
}
```

### 2. Verify Payment

**Endpoint:** `POST /api/paytabs/verify-payment`

**Authentication:** Required (Bearer token)

**Request Body:**

```json
{
    "transaction_ref": "TST2213800357411"
}
```

**Response (Payment Successful - 200):**

```json
{
    "success": true,
    "message": "Payment verification completed",
    "data": {
        "transaction_ref": "TST2213800357411",
        "cart_id": "BOOKING_12345",
        "amount": 500.0,
        "currency": "SAR",
        "status": "A",
        "code": "100",
        "transaction_time": "2025-11-13 14:30:00"
    }
}
```

**Response (Payment Failed - 200, but success=false):**

```json
{
    "success": false,
    "message": "Payment declined or cancelled",
    "data": {
        "transaction_ref": "TST2213800357411",
        "cart_id": "BOOKING_12345",
        "amount": 500.0,
        "currency": "SAR",
        "status": "D",
        "code": "400",
        "transaction_time": "2025-11-13 14:30:00"
    }
}
```

**Status Codes:**

-   `A` - Approved (Success)
-   `D` - Declined
-   `H` - Hold
-   `P` - Pending
-   `V` - Voided
-   `E` - Error

### 3. Refund Payment

**Endpoint:** `POST /api/paytabs/refund-payment`

**Authentication:** Required (Bearer token)

**Required Parameters:**

-   `transaction_ref` - Original transaction reference (string)
-   `refund_amount` - Amount to refund (numeric, min: 0.01)

**Optional Parameters:**

-   `refund_reason` - Reason for refund (string, max: 255)

**Request Body:**

```json
{
    "transaction_ref": "TST2213800357411",
    "refund_amount": 500.0,
    "refund_reason": "Customer cancellation"
}
```

**Response (Success - 200):**

```json
{
    "success": true,
    "message": "Refund processed successfully",
    "data": {
        "transaction_ref": "TST2213800357411",
        "refund_amount": 500.0,
        "status": "A",
        "message": "Refund approved"
    }
}
```

**Response (Error - 400/500):**

```json
{
    "success": false,
    "message": "Refund failed",
    "data": {
        "transaction_ref": "TST2213800357411",
        "refund_amount": 500.0,
        "status": "E",
        "message": "Transaction not found or already refunded"
    }
}
```

---

## Car Booking Payment Integration

### Verify Car Booking Payment

**Endpoint:** `POST /api/v1/user/car-booking/paytabs/verify`

**Authentication:** Required (Bearer token)

**Request Body:**

```json
{
    "token": "fnaC7ti2Sewh81tUkDkG"
}
```

Where `token` is the booking token from the search response.

**Response (Success - 200):**

```json
{
    "success": true,
    "message": "Payment verified successfully",
    "data": {
        "booking_id": "12345",
        "status": "confirmed",
        "payment_status": "paid"
    }
}
```

**Response (Error - 404/422):**

```json
{
    "success": false,
    "message": "Booking not found or invalid token",
    "error": ["Temporary booking not found"]
}
```

### Car Booking Payment Callback

**Endpoint:** `POST /api/v1/user/car-booking/paytabs/callback`

**Authentication:** None (PayTabs calls this endpoint)

**Description:** This endpoint handles PayTabs callback notifications for car booking payments. PayTabs will POST transaction results to this endpoint.

---

### Refund Payment

### 4. Get Payment Methods

**Endpoint:** `GET /api/paytabs/payment-methods`

**Authentication:** Required (Bearer token)

**Response (200):**

```json
{
    "success": true,
    "data": ["visa", "mastercard", "amex", "mada", "applepay", "googlepay"]
}
```

### 5. Get Supported Currencies

**Endpoint:** `GET /api/paytabs/currencies`

**Authentication:** Required (Bearer token)

**Response (200):**

```json
{
    "success": true,
    "data": [
        {
            "code": "SAR",
            "name": "Saudi Riyal"
        },
        {
            "code": "AED",
            "name": "UAE Dirham"
        },
        {
            "code": "USD",
            "name": "US Dollar"
        },
        {
            "code": "EUR",
            "name": "Euro"
        }
    ]
}
```

### 6. Handle Payment Callback (Server-to-Server)

**Endpoint:** `POST /api/paytabs/callback`

**Authentication:** None (PayTabs calls this endpoint)

**PayTabs will POST payment notification to this endpoint with the following data:**

```json
{
    "tran_ref": "TST2213800357411",
    "cart_id": "BOOKING_12345",
    "cart_amount": 500.0,
    "cart_currency": "SAR",
    "tran_status": "A",
    "payment_result": {
        "response_code": "100",
        "response_status": "A",
        "response_message": "Approved"
    },
    "user_defined": {
        "booking_id": "12345",
        "user_id": "67890"
    }
}
```

**What you should do in the callback:**

1. Store payment confirmation in your database
2. Update booking status to "confirmed" or "paid"
3. Send confirmation email to customer
4. Trigger post-payment business logic (send car details, confirm reservation, etc.)

**Response (200):**

```json
{
    "success": true,
    "message": "Callback received and processed"
}
```

## Flutter Implementation

### ⚠️ Important: Correct Endpoint Paths

When integrating PayTabs with your Flutter app, use the **correct full endpoint paths**:

```dart
// ✅ CORRECT - Use full paths
final url = Uri.parse('$baseUrl/api/paytabs/create-payment');
final url = Uri.parse('$baseUrl/api/v1/user/car-booking/paytabs/verify');

// ❌ WRONG - Do NOT use incomplete paths
// Uri.parse('$baseUrl/car-booking/paytabs/verify')  // Missing /api/v1/user/
// Uri.parse('$baseUrl/paytabs/verify')              // Missing /api prefix
```

If you get an error like "Route [car.booking.paytabs.verify] not defined", it means you're using an incomplete endpoint path. Always include the full path with all prefixes.

**See:** [SOLUTION_PAYTABS_ROUTE_ERROR.md](../SOLUTION_PAYTABS_ROUTE_ERROR.md) for detailed troubleshooting.

---

### 1. API Service Class

Create a PayTabs service class in Flutter:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PayTabsService {
  final String baseUrl;
  final String authToken;

  PayTabsService({
    required this.baseUrl,
    required this.authToken,
  });

  Future<Map<String, dynamic>> createPayment({
    required String cartId,
    required double cartAmount,
    required String cartDescription,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String? customerStreet,
    String? customerCity,
    String? customerState,
    String? customerCountry,
    String? customerZip,
    String transactionType = 'sale',
    String transactionClass = 'ecom',
    String paymentMethod = 'all',
    String language = 'en',
    bool hideShipping = true,
    Map<String, dynamic>? userDefined,
  }) async {
    final url = Uri.parse('$baseUrl/api/paytabs/create-payment');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'cart_id': cartId,
          'cart_amount': cartAmount,
          'cart_description': cartDescription,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'customer_phone': customerPhone,
          'customer_street': customerStreet ?? '',
          'customer_city': customerCity ?? '',
          'customer_state': customerState ?? '',
          'customer_country': customerCountry ?? 'SAU',
          'customer_zip': customerZip ?? '00000',
          'transaction_type': transactionType,
          'transaction_class': transactionClass,
          'payment_method': paymentMethod,
          'language': language,
          'hide_shipping': hideShipping,
          'user_defined': userDefined ?? {},
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - please check your connection');
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData;
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to create payment',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> verifyPayment(String transactionRef) async {
    final url = Uri.parse('$baseUrl/api/paytabs/verify-payment');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'transaction_ref': transactionRef,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Verification timeout');
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to verify payment',
        );
      }
    } catch (e) {
      throw Exception('Verification error: $e');
    }
  }

  Future<Map<String, dynamic>> refundPayment({
    required String transactionRef,
    required double refundAmount,
    String? refundReason,
  }) async {
    final url = Uri.parse('$baseUrl/api/paytabs/refund-payment');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'transaction_ref': transactionRef,
          'refund_amount': refundAmount,
          'refund_reason': refundReason ?? '',
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Refund request timeout');
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to process refund',
        );
      }
    } catch (e) {
      throw Exception('Refund error: $e');
    }
  }

  Future<List<String>> getPaymentMethods() async {
    final url = Uri.parse('$baseUrl/api/paytabs/payment-methods');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<String>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, String>>> getSupportedCurrencies() async {
    final url = Uri.parse('$baseUrl/api/paytabs/currencies');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, String>>.from(
            data['data'].map((item) => {
              'code': item['code'].toString(),
              'name': item['name'].toString(),
            }),
          );
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Verify car booking payment (Car Booking specific endpoint)
  ///
  /// Uses: POST /api/v1/user/car-booking/paytabs/verify
  Future<Map<String, dynamic>> verifyCarBookingPayment(String bookingToken) async {
    final url = Uri.parse('$baseUrl/api/v1/user/car-booking/paytabs/verify');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'token': bookingToken,  // The 20-char booking token from search
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Verification timeout');
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else if (response.statusCode == 404) {
        throw Exception('Booking not found - invalid token');
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to verify payment',
        );
      }
    } catch (e) {
      throw Exception('Verification error: $e');
    }
  }
}
```

### 2. Payment Screen Widget

Create a payment screen that opens the PayTabs hosted page:

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String transactionRef;
  final Function(bool success, String transactionRef) onPaymentComplete;

  const PaymentScreen({
    Key? key,
    required this.paymentUrl,
    required this.transactionRef,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });

            // Check if redirected to return URL
            if (url.contains('/payment/return') || url.contains('/booking/payment/return')) {
              _handlePaymentReturn();
            }
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _error = 'Failed to load payment page: ${error.description}';
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Intercept return URL
            if (request.url.contains('/payment/return') || request.url.contains('/booking/payment/return')) {
              _handlePaymentReturn();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    try {
      _controller.loadRequest(Uri.parse(widget.paymentUrl));
    } catch (e) {
      setState(() {
        _error = 'Invalid payment URL: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _handlePaymentReturn() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Verifying payment...'),
          ],
        ),
      ),
    );

    try {
      // Get auth token from your app state/secure storage
      final authToken = await _getAuthToken();

      final payTabsService = PayTabsService(
        baseUrl: 'https://your-domain.com',
        authToken: authToken,
      );

      // Verify payment with backend
      final result = await payTabsService.verifyPayment(widget.transactionRef);

      Navigator.of(context).pop(); // Close loading dialog

      if (mounted) {
        Navigator.of(context).pop(); // Close payment screen

        // Call callback with result
        widget.onPaymentComplete(
          result['success'] == true,
          widget.transactionRef,
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog

      if (mounted) {
        Navigator.of(context).pop(); // Close payment screen
        widget.onPaymentComplete(false, widget.transactionRef);
      }
    }
  }

  Future<String> _getAuthToken() async {
    // Implement this based on your auth system
    // Example using secure_storage:
    // final storage = const FlutterSecureStorage();
    // return await storage.read(key: 'auth_token') ?? '';
    return 'your_auth_token';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancel Payment?'),
            content: const Text('Are you sure you want to cancel this payment?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  widget.onPaymentComplete(false, widget.transactionRef);
                },
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete Payment'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onPaymentComplete(false, widget.transactionRef);
            },
          ),
        ),
        body: Stack(
          children: [
            // Show error if page failed to load
            if (_error != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                    ),
                  ],
                ),
              )
            else
              WebViewWidget(controller: _controller),
            // Loading indicator
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Usage Example - Car Rental Booking Flow

Here's how to use the payment flow in your app with the booking token:

```dart
import 'package:flutter/material.dart';

class CarBookingScreen extends StatefulWidget {
  final String bookingToken; // Token from /api/v1/user/car-booking/search
  final Car selectedCar;
  final BookingDetails bookingDetails;

  const CarBookingScreen({
    Key? key,
    required this.bookingToken,
    required this.selectedCar,
    required this.bookingDetails,
  }) : super(key: key);

  @override
  State<CarBookingScreen> createState() => _CarBookingScreenState();
}

class _CarBookingScreenState extends State<CarBookingScreen> {
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Get auth token
      final authToken = await _getAuthToken();

      // Initialize PayTabs service
      final payTabsService = PayTabsService(
        baseUrl: 'https://your-domain.com',
        authToken: authToken,
      );

      // Calculate total cost
      final totalDays = widget.bookingDetails.returnDate
          .difference(widget.bookingDetails.pickupDate)
          .inDays;
      final totalCost = widget.selectedCar.dailyRate * totalDays;

      // Create payment with booking details
      final paymentResponse = await payTabsService.createPayment(
        cartId: 'BOOKING_${widget.bookingToken}',
        cartAmount: totalCost,
        cartDescription: 'Car rental: ${widget.selectedCar.name} for $totalDays days',
        customerName: widget.bookingDetails.customerName,
        customerEmail: widget.bookingDetails.customerEmail,
        customerPhone: widget.bookingDetails.customerPhone,
        customerCity: widget.bookingDetails.city,
        customerCountry: 'SAU',
        language: 'en',
        // IMPORTANT: Include booking token in user_defined for reference
        userDefined: {
          'booking_token': widget.bookingToken,  // ← INCLUDE BOOKING TOKEN
          'booking_id': 'booking_${DateTime.now().millisecondsSinceEpoch}',
          'user_id': 'user_123', // Get from your auth
          'car_id': widget.selectedCar.id.toString(),
          'rental_days': totalDays.toString(),
          'pickup_date': widget.bookingDetails.pickupDate.toIso8601String(),
          'return_date': widget.bookingDetails.returnDate.toIso8601String(),
        },
      );

      setState(() {
        _isProcessing = false;
      });

      if (paymentResponse['success']) {
        final paymentUrl = paymentResponse['data']['payment_url'];
        final transactionRef = paymentResponse['data']['transaction_ref'];

        if (mounted) {
          // Navigate to payment screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentScreen(
                paymentUrl: paymentUrl,
                transactionRef: transactionRef,
                onPaymentComplete: (success, transactionRef) {
                  _handlePaymentComplete(success, transactionRef, authToken);
                },
              ),
            ),
          );
        }
      } else {
        _showError(
          paymentResponse['message'] ?? 'Failed to create payment',
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Error: $e');
    }
  }

  void _handlePaymentComplete(
    bool success,
    String transactionRef,
    String authToken,
  ) async {
    if (success) {
      // Payment successful - confirm booking
      try {
        final response = await _confirmBooking(authToken, transactionRef);

        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            '/booking-confirmation',
            arguments: {'bookingId': response['booking_id']},
          );
        }
      } catch (e) {
        _showError('Failed to confirm booking: $e');
      }
    } else {
      // Payment failed
      _showError('Payment was not completed');
    }
  }

  Future<Map<String, dynamic>> _confirmBooking(
    String authToken,
    String transactionRef,
  ) async {
    // Call your backend endpoint to confirm the booking
    // Example: POST /api/v1/user/car-booking/confirm-payment
    final response = await http.post(
      Uri.parse('https://your-domain.com/api/v1/user/car-booking/confirm-payment'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'token': widget.bookingToken,
        'transaction_ref': transactionRef,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to confirm booking');
    }
  }

  Future<String> _getAuthToken() async {
    // Implement based on your auth system
    return 'your_auth_token';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Payment')),
      body: Center(
        child: _isProcessing
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing payment...'),
                ],
              )
            : ElevatedButton(
                onPressed: _processPayment,
                child: const Text('Pay Now'),
              ),
      ),
    );
  }
}
```

## Payment Status Codes

PayTabs uses the following status codes in the `status` field:

-   **A** - Approved (Payment successful) ✅
-   **D** - Declined (Customer rejected or card declined) ❌
-   **H** - Hold (Payment is on hold, requires manual review)
-   **P** - Pending (Payment is still processing)
-   **V** - Voided (Transaction has been voided)
-   **E** - Error (An error occurred during processing)

**Response Code Values:**

-   **100** - Success
-   **200** - Soft decline (try again)
-   **300-399** - Hard decline (do not retry)
-   **400-499** - Invalid request
-   **500+** - Server error

## Testing

### Sandbox Test Cards

When using sandbox mode, use these test cards:

**Successful Payment:**

-   Card Number: `4111 1111 1111 1111`
-   Expiry: Any future date
-   CVV: `123`

**Declined Payment:**

-   Card Number: `4000 0000 0000 0002`
-   Expiry: Any future date
-   CVV: `123`

### Testing Checklist

-   [ ] Create payment successfully returns payment URL
-   [ ] WebView loads and displays PayTabs payment page
-   [ ] Successful payment redirects to return URL
-   [ ] Payment verification returns correct status
-   [ ] Failed payment is handled gracefully
-   [ ] Network errors are caught and displayed
-   [ ] Callback endpoint receives payment notifications

## Security Best Practices

1. **Never expose server key in Flutter app** - All API calls should go through your Laravel backend
2. **Use HTTPS only** - Ensure your Laravel backend uses SSL/TLS
3. **Validate on backend** - Always verify payment status on the server side
4. **Implement rate limiting** - Protect your payment endpoints from abuse
5. **Store auth tokens securely** - Use `flutter_secure_storage` or similar
6. **Validate callback signatures** - Verify PayTabs callbacks are authentic (implement in Laravel)
7. **Include booking token in user_defined** - Store booking token in `user_defined` field for traceability
8. **Never store sensitive data locally** - Don't cache card numbers, server keys, or sensitive info

### Secure Token Storage (Flutter)

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenManager {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

// Usage:
final authToken = await SecureTokenManager.getToken();
```

---

## Car Rental Booking Integration

### Complete Booking Flow with Payments

This is the complete flow for integrating PayTabs with car rental bookings:

```
┌─────────────────────────────────────────────────────────────┐
│ Step 1: Search for cars and get booking token              │
├─────────────────────────────────────────────────────────────┤
│ POST /api/v1/user/car-booking/search                        │
│ Response: { token: "fnaC7ti2Sewh81tUkDkG", cars: [...] }   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 2: Create PayTabs payment                              │
├─────────────────────────────────────────────────────────────┤
│ POST /api/paytabs/create-payment                            │
│ Body: {                                                      │
│   cart_id: "BOOKING_ABC123",                                │
│   cart_amount: 500.00,                                      │
│   user_defined: {                                           │
│     booking_token: "fnaC7ti2Sewh81tUkDkG",  ← Important    │
│     car_id: "1",                                            │
│     rental_days: "5"                                        │
│   }                                                          │
│ }                                                            │
│ Response: { payment_url: "...", transaction_ref: "TST123" }│
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 3: User completes payment on PayTabs                   │
├─────────────────────────────────────────────────────────────┤
│ - Open payment_url in WebView                               │
│ - User enters payment details                               │
│ - PayTabs processes payment                                 │
│ - PayTabs redirects back with result                        │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 4: Verify payment in Flutter                           │
├─────────────────────────────────────────────────────────────┤
│ Option A: Verify via Car Booking endpoint (Recommended)     │
│   POST /api/v1/user/car-booking/paytabs/verify              │
│   Body: { token: "fnaC7ti2Sewh81tUkDkG" }   ← Booking token│
│                                                              │
│ Option B: Verify via PayTabs endpoint                       │
│   POST /api/paytabs/verify-payment                          │
│   Body: { transaction_ref: "TST123" }      ← Transaction ref│
│                                                              │
│ Response: { success: true, booking_id: "12345" }            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Step 5: Booking confirmed                                   │
├─────────────────────────────────────────────────────────────┤
│ - Payment stored in database                                │
│ - Booking marked as paid/confirmed                          │
│ - User receives confirmation                                │
│ - Car details sent to user                                  │
└─────────────────────────────────────────────────────────────┘
```

### Payment Verification Options

**Option A: Using Car Booking Endpoint (RECOMMENDED)**

```dart
// Use the car-booking-specific endpoint
final result = await payTabsService.verifyCarBookingPayment(
  'fnaC7ti2Sewh81tUkDkG',  // Booking token from search
);

// This endpoint:
// - Validates the booking token
// - Updates booking status directly
// - Handles car-booking-specific logic
// - Returns: { success: true, booking_id: "12345" }
```

**Option B: Using PayTabs Endpoint**

```dart
// Use the generic PayTabs verification endpoint
final result = await payTabsService.verifyPayment(
  'TST123',  // Transaction ref from create-payment
);

// This endpoint:
// - Validates the transaction with PayTabs
// - Returns payment details
// - Does not update booking status
// - Returns: { success: true, status: "A", ... }
// - You must then confirm booking separately
```

### Recommended Implementation

Use **Option A** (Car Booking endpoint) because:

-   ✅ Validates both payment AND booking token
-   ✅ Updates booking status automatically
-   ✅ Prevents double-bookings
-   ✅ Integrates with car-booking workflow
-   ✅ Returns booking ID directly

### Backend Endpoint (Laravel)

You need to create an endpoint that handles payment confirmation:

```php
// routes/api.php
Route::middleware('auth:api')->group(function () {
    Route::post('v1/user/car-booking/confirm-payment',
        [CarBookingController::class, 'confirmPayment']);
});

// app/Http/Controllers/Api/V1/User/CarBookingController.php
public function confirmPayment(Request $request)
{
    $validated = Validator::make($request->all(), [
        'token' => 'required|string', // Booking token
        'transaction_ref' => 'required|string', // PayTabs transaction ref
    ])->validate();

    try {
        // Get booking session from token
        $booking = TemporaryData::where(
            'identifier',
            $validated['token']
        )->first();

        if (!$booking) {
            return Response::error(['Booking not found'], [], 404);
        }

        // Create actual booking record
        $carBooking = CarBooking::create([
            'user_id' => auth()->id(),
            'car_id' => $booking->data['car_id'],
            'booking_token' => $validated['token'],
            'transaction_ref' => $validated['transaction_ref'],
            'status' => 'confirmed',
            'paid_at' => now(),
            // ... other fields
        ]);

        // Clean up temporary session
        $booking->delete();

        return Response::success(
            ['Booking confirmed successfully'],
            ['booking_id' => $carBooking->id],
            200
        );
    } catch (Exception $e) {
        Log::error('Booking confirmation failed', ['error' => $e->getMessage()]);
        return Response::error(['Failed to confirm booking'], [], 500);
    }
}
```

### Key Integration Points

1. **Booking Token** - Always include in `user_defined` field for reference
2. **Transaction Ref** - Use PayTabs-provided reference for payment verification
3. **Status Tracking** - Monitor booking through states: pending → paid → confirmed
4. **Error Recovery** - If payment fails, allow user to retry without re-searching
5. **Callback Processing** - Backend updates status via PayTabs callback webhook

## Troubleshooting

### Common Issues

**Issue: 422 Validation failed**

**Symptoms:** Getting validation errors in response

**Solution:**

-   Check all required fields are provided: `cart_id`, `cart_amount`, `customer_name`, `customer_email`, `customer_phone`
-   Verify `cart_amount` is numeric and >= 0.01
-   Verify `customer_email` is a valid email format
-   Verify `customer_country` is a 3-letter ISO code (e.g., "SAU", "AED")

**Issue: Payment URL not loading in WebView**

**Symptoms:** Blank page or "Failed to load payment page"

**Solution:**

1. Check CORS settings in Laravel `config/cors.php` - should allow PayTabs domain
2. Ensure payment URL is not expired (usually 15-30 min timeout)
3. Check `return_url` and `callback_url` are publicly accessible URLs
4. Enable JavaScript in WebView (code example has `setJavaScriptMode(JavaScriptMode.unrestricted)`)
5. Check logs: `storage/logs/paytabs.log` on Laravel backend

**Issue: Callback not received by backend**

**Symptoms:** Payment completed but backend doesn't receive notification

**Solution:**

1. Ensure `callback_url` in `config/paytabs.php` is publicly accessible
2. Configure webhook/callback endpoint in PayTabs dashboard
3. Check Laravel logs: `storage/logs/paytabs.log`
4. Verify environment is production/live (not sandbox with wrong credentials)
5. Check firewall/security rules don't block incoming PayTabs requests

**Issue: Payment verification returns status "P" (Pending)**

**Symptoms:** Payment appears incomplete even after user sees success page

**Solution:**

-   This is normal - payments may take 1-5 seconds to process
-   Implement a retry mechanism (wait 2-3 seconds before retrying)
-   Don't immediately mark booking as paid - wait for callback or status "A"

**Issue: Status "D" (Declined) or "E" (Error)**

**Symptoms:** Payment was declined or errored

**Solution:**

-   Check the `code` field in response for specific error (100=success, 200=soft decline, 3xx=hard decline)
-   For soft declines (code 200): Allow user to retry
-   For hard declines (code 3xx): Show user that payment was declined
-   Check PayTabs logs for transaction-level details

**Issue: "Invalid token format" error**

**Symptoms:** Backend rejects the payment token

**Solution:**

-   Verify you're using `transaction_ref` from create-payment response, not JWT token
-   Don't send authentication JWT token as `transaction_ref`
-   `transaction_ref` is returned in create-payment response as `data.transaction_ref`

**Issue: WebView redirects to blank page**

**Symptoms:** After payment, WebView shows blank/white page

**Solution:**

1. The redirect might be successful - wait for `_handlePaymentReturn()` to verify
2. Check that `return_url` is configured in `config/paytabs.php`
3. Default return URL should contain `/payment/return` or `/booking/payment/return`
4. The code intercepts this URL - if not caught, add a timeout to auto-close

**Issue: Timeout errors (30 seconds)**

**Symptoms:** "Request timeout - please check your connection"

**Solution:**

1. Check network connectivity in Flutter app
2. Check Laravel backend is running and accessible
3. Check PayTabs API is up (check https://status.paytabs.com)
4. Increase timeout in service if needed (modify `.timeout()` value)

**Issue: Auth token expired**

**Symptoms:** 401 Unauthorized in API responses

**Solution:**

1. Refresh auth token before payment
2. Implement token refresh in `_getAuthToken()` method
3. Use `flutter_secure_storage` to store and refresh tokens securely
4. Check token expiration and refresh if needed

### Debug Checklist

Before going to production:

-   [ ] PayTabs credentials set in `.env` (`PAYTABS_PROFILE_ID`, `PAYTABS_SERVER_KEY`)
-   [ ] PayTabs environment set to `sandbox` for testing, `production` for live
-   [ ] `return_url` and `callback_url` are publicly accessible
-   [ ] WebView loads payment page successfully
-   [ ] Successful payment redirects correctly
-   [ ] Payment verification returns accurate status
-   [ ] Callback endpoint receives and processes notifications
-   [ ] Error handling works (declined cards, timeouts, etc.)
-   [ ] Logs are being written to `storage/logs/paytabs.log`
-   [ ] HTTPS is used in production (not HTTP)
-   [ ] Booking token is included in `user_defined` field

### Logs to Check

1. **Laravel:** `storage/logs/paytabs.log` (PayTabs-specific logs)
2. **Laravel:** `storage/logs/laravel.log` (general errors)
3. **Flutter:** Use `debugPrint()` to log request/response data
4. **PayTabs:** Dashboard > Transactions for transaction status

## Additional Resources

-   [PayTabs Official Documentation](https://docs.paytabs.com/)
-   [PayTabs Laravel Package](https://github.com/paytabscom/paytabs-laravel)
-   [Flutter WebView Plugin](https://pub.dev/packages/webview_flutter)

## Support

For Laravel backend issues:

-   Check logs: `storage/logs/PayTabs.log`
-   Check Laravel logs: `storage/logs/laravel.log`

For PayTabs issues:

-   Contact PayTabs support: customercare@paytabs.com
-   Visit: https://support.paytabs.com/

## Example Project Structure

```
flutter_app/
├── lib/
│   ├── models/
│   │   └── payment_request.dart
│   ├── services/
│   │   └── paytabs_service.dart
│   ├── screens/
│   │   ├── payment_screen.dart
│   │   └── booking_screen.dart
│   └── main.dart
└── pubspec.yaml
```

---

## Summary of Updates (November 14, 2025 - Final)

✅ **Clarified Endpoint Paths**

-   Added endpoint table showing all available routes
-   Distinguished between PayTabs endpoints (`/api/paytabs/...`) and Car Booking endpoints (`/api/v1/user/car-booking/...`)
-   Added warning about common route errors and how to fix them

✅ **Added Car Booking Payment Verification**

-   New endpoint: `POST /api/v1/user/car-booking/paytabs/verify`
-   New service method: `verifyCarBookingPayment()`
-   Explains how to use booking token for verification

✅ **Improved Booking Flow Diagram**

-   Visual flow showing all 5 steps of booking process
-   Clarified two payment verification options
-   Recommended using car-booking-specific endpoint

✅ **Added Payment Verification Options**

-   Option A: Car Booking endpoint (recommended)
-   Option B: PayTabs endpoint (alternative)
-   Explained pros/cons of each approach

✅ **Reference to Troubleshooting Guides**

-   Added link to route error documentation
-   Points to comprehensive troubleshooting guides
-   Helps developers resolve common issues

---

**Last Updated:** November 14, 2025  
**Status:** Complete with car-booking-specific integration ✅
