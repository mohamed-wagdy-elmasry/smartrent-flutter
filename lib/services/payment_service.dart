import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../base/utils/local_storage.dart';

class PaymentService {
  final String baseUrl;
  final String authToken;
  
  PaymentService({
    String? baseUrl,
    String? authToken,
  }) : 
    baseUrl = baseUrl ?? Env.apiBaseUrl,
    authToken = authToken ?? LocalStorage.token;
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $authToken',
  };
  
  /// Get Moyasar publishable key and configuration
  Future<PaymentConfig> getConfig() async {
    final response = await http.get(
      Uri.parse('$baseUrl/payments/gateway-config'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaymentConfig.fromJson(data['data']);
    }
    throw Exception('Failed to load payment config');
  }

  /// Create a payment with Moyasar token
  Future<PaymentResult> createPayment({
    required String token,
    required int amount, // in halalas
    String currency = Env.currency,
    String? description,
    String? orderId,
    String type = 'order', // order, topup, booking
    Map<String, dynamic>? metadata,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments'),
      headers: _headers,
      body: jsonEncode({
        'token': token,
        'amount': amount,
        'currency': currency,
        'description': description,
        'order_id': orderId,
        'type': type,
        'metadata': metadata,
      }),
    );
    
    final data = jsonDecode(response.body);
    
    if (response.statusCode == 201) {
      return PaymentResult.fromJson(data['data']);
    }
    
    throw PaymentException(data['message'] ?? 'Payment failed');
  }
  
  /// Create wallet top-up payment
  Future<PaymentResult> topupWallet({
    required String token,
    required int amount, // in halalas
    String currency = Env.currency,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/topup'),
      headers: _headers,
      body: jsonEncode({
        'token': token,
        'amount': amount,
        'currency': currency,
      }),
    );
    
    final data = jsonDecode(response.body);
    
    if (response.statusCode == 201) {
      return PaymentResult.fromJson(data['data']);
    }
    
    throw PaymentException(data['message'] ?? 'Top-up failed');
  }
  
  /// Verify payment status
  Future<PaymentResult> verifyPayment(int paymentId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/$paymentId/verify'),
      headers: _headers,
    );
    
    final data = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return PaymentResult.fromJson(data['data']);
    }
    
    throw PaymentException(data['message'] ?? 'Verification failed');
  }
  
  /// Get wallet balance and transactions
  Future<WalletInfo> getWalletBalance() async {
    final response = await http.get(
      Uri.parse('$baseUrl/payments/wallet'),
      headers: _headers,
    );
    
    final data = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return WalletInfo.fromJson(data['data']);
    }
    
    throw PaymentException(data['message'] ?? 'Failed to get wallet');
  }
  
  /// List saved payment tokens
  Future<List<SavedCard>> getSavedCards() async {
    final response = await http.get(
      Uri.parse('$baseUrl/payments/tokens'),
      headers: _headers,
    );
    
    final data = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return (data['data']['tokens'] as List)
          .map((e) => SavedCard.fromJson(e))
          .toList();
    }
    
    throw PaymentException(data['message'] ?? 'Failed to get cards');
  }
  
  /// Create payment with saved card
  Future<PaymentResult> payWithSavedCard({
    required int savedTokenId,
    required int amount,
    String currency = Env.currency,
    String? description,
    String type = 'order',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/tokenized'),
      headers: _headers,
      body: jsonEncode({
        'saved_token_id': savedTokenId,
        'amount': amount,
        'currency': currency,
        'description': description,
        'type': type,
      }),
    );
    
    final data = jsonDecode(response.body);
    
    if (response.statusCode == 201) {
      return PaymentResult.fromJson(data['data']);
    }
    
    throw PaymentException(data['message'] ?? 'Payment failed');
  }
}

class PaymentConfig {
  final String gateway;
  final String publishableKey;
  final List<String> supportedCurrencies;
  final List<String> supportedMethods;
  final bool isEnabled;
  
  PaymentConfig({
    required this.gateway,
    required this.publishableKey,
    required this.supportedCurrencies,
    required this.supportedMethods,
    required this.isEnabled,
  });
  
  factory PaymentConfig.fromJson(Map<String, dynamic> json) {
    return PaymentConfig(
      gateway: json['gateway'],
      publishableKey: json['publishable_key'],
      supportedCurrencies: List<String>.from(json['supported_currencies']),
      supportedMethods: List<String>.from(json['supported_methods']),
      isEnabled: json['is_enabled'],
    );
  }
}

// Models
class PaymentResult {
  final int paymentId;
  final String orderId;
  final String? moyasarPaymentId;
  final int amount;
  final String formattedAmount;
  final String currency;
  final String status;
  final String? paymentUrl;
  final String type;
  
  PaymentResult({
    required this.paymentId,
    required this.orderId,
    this.moyasarPaymentId,
    required this.amount,
    required this.formattedAmount,
    required this.currency,
    required this.status,
    this.paymentUrl,
    required this.type,
  });
  
  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      paymentId: json['payment_id'],
      orderId: json['order_id'],
      moyasarPaymentId: json['moyasar_payment_id'],
      amount: json['amount'],
      formattedAmount: json['formatted_amount'] ?? '',
      currency: json['currency'],
      status: json['status'],
      paymentUrl: json['payment_url'],
      type: json['type'] ?? 'order',
    );
  }
  
  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
  bool get requires3DS => paymentUrl != null && paymentUrl!.isNotEmpty;
}

class WalletInfo {
  final double balance;
  final String formattedBalance;
  final String currency;
  final List<WalletTransaction> transactions;
  
  WalletInfo({
    required this.balance,
    required this.formattedBalance,
    required this.currency,
    required this.transactions,
  });
  
  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      balance: (json['balance'] as num).toDouble(),
      formattedBalance: json['formatted_balance'],
      currency: json['currency'],
      transactions: (json['transactions'] as List)
          .map((e) => WalletTransaction.fromJson(e))
          .toList(),
    );
  }
}

class WalletTransaction {
  final int id;
  final String type;
  final double amount;
  final String formattedAmount;
  final String currency;
  final double balanceBefore;
  final double balanceAfter;
  final String status;
  final String? description;
  final DateTime createdAt;
  
  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.formattedAmount,
    required this.currency,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.status,
    this.description,
    required this.createdAt,
  });
  
  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      formattedAmount: json['formatted_amount'],
      currency: json['currency'],
      balanceBefore: (json['balance_before'] as num).toDouble(),
      balanceAfter: (json['balance_after'] as num).toDouble(),
      status: json['status'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class SavedCard {
  final int id;
  final String cardBrand;
  final String cardLastDigits;
  final String cardMonth;
  final String cardYear;
  final String? cardName;
  final bool isDefault;
  
  SavedCard({
    required this.id,
    required this.cardBrand,
    required this.cardLastDigits,
    required this.cardMonth,
    required this.cardYear,
    this.cardName,
    required this.isDefault,
  });
  
  factory SavedCard.fromJson(Map<String, dynamic> json) {
    return SavedCard(
      id: json['id'],
      cardBrand: json['card_brand'],
      cardLastDigits: json['card_last_digits'],
      cardMonth: json['card_month'],
      cardYear: json['card_year'],
      cardName: json['card_name'],
      isDefault: json['is_default'] ?? false,
    );
  }
  
  String get displayName => '$cardBrand •••• $cardLastDigits';
  String get expiry => '$cardMonth/$cardYear';
}

class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);
  
  @override
  String toString() => message;
}
