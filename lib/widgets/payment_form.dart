import 'package:flutter/material.dart';
import 'package:moyasar/moyasar.dart' as moyasar;
import '../config/env.dart';

class MoyasarPaymentForm extends StatefulWidget {
  final int amountInHalalas;
  final String currency;
  final String description;
  final String publishableKey;
  final Function(moyasar.PaymentResponse) onPaymentComplete;
  final Function(String) onError;
  
  const MoyasarPaymentForm({
    Key? key,
    required this.amountInHalalas,
    this.currency = Env.currency,
    required this.description,
    required this.publishableKey,
    required this.onPaymentComplete,
    required this.onError,
  }) : super(key: key);
  
  @override
  State<MoyasarPaymentForm> createState() => _MoyasarPaymentFormState();
}

class _MoyasarPaymentFormState extends State<MoyasarPaymentForm> {
  late moyasar.PaymentConfig _paymentConfig;
  
  @override
  void initState() {
    super.initState();
    _initPaymentConfig();
  }
  
  void _initPaymentConfig() {
    _paymentConfig = moyasar.PaymentConfig(
      publishableApiKey: widget.publishableKey,
      amount: widget.amountInHalalas,
      description: widget.description,
      metadata: {
        'currency': widget.currency,
      },
      creditCard: moyasar.CreditCardConfig(
        saveCard: true,
        manual: false,
      ),
      applePay: moyasar.ApplePayConfig(
        merchantId: 'merchant.com.yourapp', // TODO: Update with real merchant ID
        label: widget.description,
        manual: false,
        saveCard: false,
      ),
    );
  }
  
  void _onPaymentResult(moyasar.PaymentResponse result) {
    if (result.status == moyasar.PaymentStatus.paid) {
      widget.onPaymentComplete(result);
    } else if (result.status == moyasar.PaymentStatus.failed) {
      widget.onError('Payment failed');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return moyasar.CreditCard(
      config: _paymentConfig,
      onPaymentResult: _onPaymentResult,
    );
  }
}
