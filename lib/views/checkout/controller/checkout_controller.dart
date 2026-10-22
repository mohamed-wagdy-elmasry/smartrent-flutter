import 'dart:convert';
import 'package:carbo/base/utils/basic_import.dart';
import 'package:carbo/config/env.dart';
import 'package:http/http.dart' as http;
import 'package:moyasar/moyasar.dart' as moyasar;

class CheckoutController extends GetxController {
  RxBool isLoading = false.obs;
  
  // Payment Config - should come from backend
  String publishableKey = '';
  
  // Transaction details
  double amount = 0.0;
  String currency = 'SAR';
  String description = '';
  String mode = 'payment'; // 'payment' or 'tokenization'
  
  moyasar.PaymentConfig? paymentConfig;
  
  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      amount = double.tryParse(Get.arguments['amount'].toString()) ?? 0.0;
      currency = Get.arguments['currency'] ?? 'SAR';
      description = Get.arguments['description'] ?? 'Payment';
      mode = Get.arguments['mode'] ?? 'payment';
    }
    _loadPaymentConfig();
  }

  Future<void> _loadPaymentConfig() async {
    try {
      isLoading.value = true;
      // Fetch publishable key from backend
      final response = await http.get(
        Uri.parse('${Env.apiBaseUrl}/api/payments/config'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          publishableKey = data['data']['publishable_key'];
          
          // Initialize Moyasar payment config
          final amountInHalalas = (amount * 100).toInt();
          
          paymentConfig = moyasar.PaymentConfig(
            publishableApiKey: publishableKey,
            amount: amountInHalalas,
            description: description,
            metadata: {'currency': currency},
            creditCard: moyasar.CreditCardConfig(
              saveCard: mode == 'payment',
              manual: false,
            ),
          );
        }
      }
    } catch (e) {
      CustomSnackBar.error('Failed to load payment configuration: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onPaymentResult(moyasar.PaymentResponse result) {
    if (result.status == moyasar.PaymentStatus.paid) {
      if (mode == 'tokenization') {
        // Return token for further processing
        Get.back(result: {'token': result.id});
      } else {
        CustomSnackBar.success(
          title: 'Success',
          message: 'Payment completed successfully',
        );
        Get.back(result: {'success': true, 'payment_id': result.id});
      }
    } else if (result.status == moyasar.PaymentStatus.failed) {
      CustomSnackBar.error('Payment failed: ${result.source}');
    } else if (result.status == moyasar.PaymentStatus.authorized) {
      // Payment authorized but not captured yet
      if (mode == 'tokenization') {
        Get.back(result: {'token': result.id});
      } else {
        Get.snackbar(
          'Processing',
          'Payment is being processed',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back(result: {'success': true, 'payment_id': result.id, 'status': 'authorized'});
      }
    }
  }
}
