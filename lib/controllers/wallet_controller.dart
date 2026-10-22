import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:carbo/models/wallet_balance.dart';
import 'package:carbo/models/wallet_transaction.dart';
import 'package:carbo/config/env.dart';
import 'package:carbo/base/utils/local_storage.dart';

class WalletController extends GetxController with GetSingleTickerProviderStateMixin {
  // Balance state
  final RxList<WalletBalance> balances = <WalletBalance>[].obs;
  final RxBool isLoadingBalance = false.obs;
  final RxMap<String, double> optimisticBalanceChanges = <String, double>{}.obs;
  final RxString selectedCurrency = 'SAR'.obs;

  // Transaction state
  final RxList<WalletTransaction> transactions = <WalletTransaction>[].obs;
  final RxBool isLoadingTransactions = false.obs;
  final RxBool hasMore = true.obs;
  final RxString error = ''.obs;
  final RxBool isRefreshing = false.obs;
  int currentPage = 1;

  // Animation controllers
  late AnimationController shimmerController;
  
  // Invoice/Top-up state
  final RxString topupStatus = ''.obs;
  final RxBool isProcessingTopup = false.obs;

  @override
  void onInit() {
    super.onInit();
    shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    refresh();
  }

  @override
  void onClose() {
    shimmerController.dispose();
    super.onClose();
  }

  Future<void> refresh() async {
    isRefreshing.value = true;
    await Future.wait([
      fetchBalance(),
      fetchTransactions(),
    ]);
    isRefreshing.value = false;
  }

  Future<void> fetchBalance() async {
    isLoadingBalance.value = true;
    error.value = '';
    try {
      final response = await http.get(
        Uri.parse('${Env.apiBaseUrl}/wallet/balance'),
        headers: {
          'Authorization': 'Bearer ${LocalStorage.token}',
          'Accept': 'application/json',
        },
      );

      print('Balance API Status: ${response.statusCode}');
      print('Balance API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // Handle both direct array and nested balances array
          final List balancesList;
          if (data['data'] is List) {
            // Direct array format: {"success": true, "data": [{...}]}
            balancesList = data['data'] as List;
          } else if (data['data']['balances'] != null) {
            // Nested format: {"success": true, "data": {"balances": [{...}]}}
            balancesList = data['data']['balances'] as List;
          } else {
            // Single balance object format
            balancesList = [data['data']];
          }
          
          balances.value = balancesList
              .map((b) => WalletBalance.fromJson(b))
              .toList();
          
          print('Parsed balances: ${balances.length} items');
          for (var bal in balances) {
            print('  - ${bal.currency}: ${bal.balanceAsString}');
          }
        } else {
          error.value = 'Invalid response format';
          print('Error: Invalid response - success=${data['success']}, data=${data['data']}');
        }
      } else {
        error.value = 'Failed to fetch balance: HTTP ${response.statusCode}';
        print('Error: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      error.value = 'Failed to fetch balance: $e';
      print('Exception in fetchBalance: $e');
    } finally {
      isLoadingBalance.value = false;
    }
  }

  Future<void> fetchTransactions({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoadingTransactions.value || !hasMore.value) return;
      currentPage++;
    } else {
      isLoadingTransactions.value = true;
      currentPage = 1;
    }
    
    try {
      final response = await http.get(
        Uri.parse('${Env.apiBaseUrl}/wallet/transactions?per_page=20&page=$currentPage'),
        headers: {
          'Authorization': 'Bearer ${LocalStorage.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final txList = (data['data']['data'] ?? []) as List;
          final newTransactions = txList
              .map((t) => WalletTransaction.fromJson(t))
              .toList();
          
          if (loadMore) {
            transactions.addAll(newTransactions);
          } else {
            transactions.value = newTransactions;
          }
          
          hasMore.value = data['data']['current_page'] < data['data']['last_page'];
        }
      }
    } catch (e) {
      error.value = 'Failed to fetch transactions: $e';
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  double getBalanceForCurrency(String currency) {
    final balance = balances.firstWhere(
      (b) => b.currency == currency,
      orElse: () => WalletBalance(currency: currency, balance: 0.0),
    );
    
    // Parse balance
    double balanceAmount = 0.0;
    if (balance.balance is String) {
      balanceAmount = double.tryParse(balance.balance) ?? 0.0;
    } else if (balance.balance is num) {
      balanceAmount = (balance.balance as num).toDouble();
    }
    
    // Add optimistic change if any
    final optimistic = optimisticBalanceChanges[currency] ?? 0.0;
    return balanceAmount + optimistic;
  }

  /// Check if user has sufficient balance for a booking
  bool hasSufficientBalance(double requiredAmount, String currency) {
    final currentBalance = getBalanceForCurrency(currency);
    return currentBalance >= requiredAmount;
  }

  /// Modern Moyasar Invoice Top-up (Recommended)
  Future<Map<String, dynamic>?> createTopUpInvoice({
    required double amount,
    required String currency,
  }) async {
    try {
      isProcessingTopup.value = true;
      topupStatus.value = 'Creating invoice...';
      
      print('📤 Creating top-up invoice:');
      print('  Amount: $amount $currency');
      
      final response = await http.post(
        Uri.parse('${Env.apiBaseUrl}/wallet/topup/invoice'),
        headers: {
          'Authorization': 'Bearer ${LocalStorage.token}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
        }),
      );

      print('📥 Invoice API Response:');
      print('  Status: ${response.statusCode}');
      print('  Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          topupStatus.value = 'Invoice created successfully';
          print('✅ Invoice created: ${data['data']}');
          return data['data'] as Map<String, dynamic>;
        }
      }
      
      topupStatus.value = 'Failed to create invoice';
      error.value = 'Failed to create top-up invoice';
      print('❌ Invoice creation failed');
      return null;
    } catch (e) {
      error.value = 'Top-up invoice error: $e';
      topupStatus.value = 'Error: $e';
      print('❌ Exception creating invoice: $e');
      return null;
    } finally {
      isProcessingTopup.value = false;
    }
  }

  Future<Map?> initiateTopUp({
    required String amount,
    required String currency,
    String? token,
  }) async {
    try {
      final amountInCents = (double.parse(amount) * 100).toInt();
      
      final response = await http.post(
        Uri.parse('${Env.apiBaseUrl}/wallet/top-up'),
        headers: {
          'Authorization': 'Bearer ${LocalStorage.token}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amountInCents,
          'currency': currency,
          if (token != null) 'token': token,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // If payment URL is returned, open WebView for 3DS
          if (data['data']?['payment_url'] != null) {
            // Navigate to payment WebView and verify after
            final paymentId = data['data']['payment_id'];
            await _handlePaymentWebView(
              data['data']['payment_url'],
              paymentId.toString(),
            );
          }
          await refresh(); // Refresh balance and transactions
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      error.value = 'Failed to initiate top-up: $e';
      return null;
    }
  }

  Future<void> _handlePaymentWebView(String url, String paymentId) async {
    // Open WebView for 3DS authentication
    final result = await Get.toNamed('/payment-webview', arguments: {
      'url': url,
      'payment_id': paymentId,
    });
    
    if (result == 'callback_detected') {
      // Verify payment status via backend
      await verifyPayment(int.parse(paymentId));
    }
  }

  Future<bool> verifyPayment(int paymentId) async {
    try {
      final response = await http.post(
        Uri.parse('${Env.apiBaseUrl}/api/payments/$paymentId/verify'),
        headers: {
          'Authorization': 'Bearer ${LocalStorage.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data']?['status'] == 'paid') {
          await refresh(); // Refresh wallet after successful payment
          return true;
        }
      }
      return false;
    } catch (e) {
      error.value = 'Payment verification failed: $e';
      return false;
    }
  }

  Future<Map?> initiateTopUpTest({required String amount, required String currency}) async {
    try {
      final response = await http.post(
        Uri.parse('${Env.apiBaseUrl}/api/v1/wallet/topup/test'),
        headers: {
          'Authorization': 'Bearer ${LocalStorage.token}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await refresh();
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      error.value = 'Test top-up failed: $e';
      return null;
    }
  }

  void startPollingTransaction(int transactionId) {
    // Poll transaction status every 2 seconds for up to 30 seconds
    int attempts = 0;
    const maxAttempts = 15;
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      attempts++;
      
      await fetchTransactions();
      
      final tx = transactions.firstWhereOrNull(
        (t) => t.id == transactionId && t.status == WalletTransactionStatus.completed,
      );
      
      return tx == null && attempts < maxAttempts;
    });
  }
}
