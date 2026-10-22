import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../base/utils/local_storage.dart';

/// Service for verifying payment status with backend
/// CRITICAL: Never trust client-side payment status - always verify with backend
class PaymentVerificationService {
  final String baseUrl;
  final String authToken;

  PaymentVerificationService({
    String? baseUrl,
    String? authToken,
  })  : baseUrl = baseUrl ?? Env.apiBaseUrl,
        authToken = authToken ?? LocalStorage.token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

  /// Verify payment status by payment ID
  /// This should be called after 3DS completion or when payment status is uncertain
  Future<PaymentVerificationResult> verifyPayment(int paymentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/$paymentId/verify'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return PaymentVerificationResult.fromJson(data['data']);
      }

      throw PaymentVerificationException(
        data['message'] ?? 'Payment verification failed',
      );
    } catch (e) {
      throw PaymentVerificationException(
        'Network error during payment verification: $e',
      );
    }
  }

  /// Verify payment by Moyasar payment ID
  Future<PaymentVerificationResult> verifyByMoyasarId(
    String moyasarPaymentId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/verify-by-moyasar-id'),
        headers: _headers,
        body: jsonEncode({'moyasar_payment_id': moyasarPaymentId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return PaymentVerificationResult.fromJson(data['data']);
      }

      throw PaymentVerificationException(
        data['message'] ?? 'Payment verification failed',
      );
    } catch (e) {
      throw PaymentVerificationException(
        'Network error during payment verification: $e',
      );
    }
  }

  /// Poll payment status until it's no longer pending
  /// Max attempts: 15, interval: 2 seconds
  Future<PaymentVerificationResult> pollPaymentStatus(
    int paymentId, {
    int maxAttempts = 15,
    Duration interval = const Duration(seconds: 2),
  }) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final result = await verifyPayment(paymentId);

        // If status is final (not pending), return immediately
        if (!result.isPending) {
          return result;
        }

        // Wait before next attempt (except for last attempt)
        if (attempt < maxAttempts - 1) {
          await Future.delayed(interval);
        }
      } catch (e) {
        // On last attempt, rethrow the error
        if (attempt == maxAttempts - 1) {
          rethrow;
        }
        // Otherwise, wait and retry
        await Future.delayed(interval);
      }
    }

    throw PaymentVerificationException(
      'Payment verification timeout after $maxAttempts attempts',
    );
  }
}

/// Payment verification result
class PaymentVerificationResult {
  final int paymentId;
  final String? moyasarPaymentId;
  final String status; // pending, paid, failed, authorized, refunded, etc.
  final int amount;
  final String currency;
  final String? paidAt;
  final String type; // topup, booking, order

  PaymentVerificationResult({
    required this.paymentId,
    this.moyasarPaymentId,
    required this.status,
    required this.amount,
    required this.currency,
    this.paidAt,
    required this.type,
  });

  factory PaymentVerificationResult.fromJson(Map<String, dynamic> json) {
    return PaymentVerificationResult(
      paymentId: json['payment_id'] as int,
      moyasarPaymentId: json['moyasar_payment_id'] as String?,
      status: json['status'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
      paidAt: json['paid_at'] as String?,
      type: json['type'] as String? ?? 'order',
    );
  }

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
  bool get isAuthorized => status == 'authorized';
  bool get isRefunded => status == 'refunded' || status == 'partially_refunded';

  @override
  String toString() =>
      'PaymentVerificationResult(id: $paymentId, status: $status, amount: $amount $currency)';
}

class PaymentVerificationException implements Exception {
  final String message;

  PaymentVerificationException(this.message);

  @override
  String toString() => 'PaymentVerificationException: $message';
}
