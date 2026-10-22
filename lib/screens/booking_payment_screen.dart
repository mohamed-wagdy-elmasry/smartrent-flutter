import 'package:flutter/material.dart';
import 'package:moyasar/moyasar.dart' as moyasar;
import '../config/env.dart';
import '../services/payment_service.dart';
import '../services/payment_verification_service.dart';
import '../utils/payment_error_handler.dart';
import '../screens/payment/moyasar_webview_page.dart';

class BookingPaymentScreen extends StatefulWidget {
  final int bookingId;
  final int amount; // in halalas
  
  const BookingPaymentScreen({
    Key? key,
    required this.bookingId,
    required this.amount,
  }) : super(key: key);
  
  @override
  State<BookingPaymentScreen> createState() => _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends State<BookingPaymentScreen> {
  final _paymentService = PaymentService();
  
  String? _publishableKey;
  List<SavedCard> _savedCards = [];
  bool _isLoading = true;
  bool _useSavedCard = false;
  SavedCard? _selectedCard;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      final config = await _paymentService.getConfig();
      final cards = await _paymentService.getSavedCards();
      
      setState(() {
        _publishableKey = config.publishableKey;
        _savedCards = cards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _payWithSavedCard() async {
    if (_selectedCard == null) return;
    
    try {
      final payment = await _paymentService.payWithSavedCard(
        savedTokenId: _selectedCard!.id,
        amount: widget.amount,
        type: 'booking',
        description: 'Booking #${widget.bookingId}',
      );
      
      _handlePaymentResult(payment);
    } catch (e) {
      _showError(PaymentErrorHandler.getUserFriendlyMessage(e));
    }
  }
  
  void _onNewCardPayment(moyasar.PaymentResponse result) async {
    if (result.status != moyasar.PaymentStatus.paid) {
      _showError('Payment failed');
      return;
    }
    
    try {
      final payment = await _paymentService.createPayment(
        token: result.id,
        amount: widget.amount,
        type: 'booking',
        description: 'Booking #${widget.bookingId}',
        metadata: {'booking_id': widget.bookingId},
      );
      
      _handlePaymentResult(payment);
    } catch (e) {
      _showError(PaymentErrorHandler.getUserFriendlyMessage(e));
    }
  }
  
  void _handlePaymentResult(PaymentResult payment) {
    if (payment.isPaid) {
      Navigator.pop(context, true); // Success
    } else if (payment.requires3DS) {
      _handle3DS(payment);
    } else {
      _showError('Payment not completed');
    }
  }
  
  void _handle3DS(PaymentResult payment) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => MoyasarWebViewPage(
          paymentUrl: payment.paymentUrl!,
          transactionId: payment.paymentId.toString(),
          bookingToken: '', // Not needed for this flow
        ),
      ),
    );

    if (result == 'callback_detected') {
      // Verify payment status via backend
      try {
        final verificationService = PaymentVerificationService();
        final verification = await verificationService.pollPaymentStatus(
          payment.paymentId,
          maxAttempts: 15,
          interval: const Duration(seconds: 2),
        );

        if (verification.isPaid) {
          Navigator.pop(context, true); // Success
        } else if (verification.isFailed) {
          _showError('Payment failed. Please try again.');
        } else {
          _showError('Payment status: ${verification.status}');
        }
      } catch (e) {
        _showError('Payment verification failed: $e');
      }
    } else if (result == 'cancelled') {
      _showError('Payment cancelled by user.');
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount'),
                    Text(
                      '${(widget.amount / 100).toStringAsFixed(2)} ${Env.currency}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Saved Cards Toggle
            if (_savedCards.isNotEmpty) ...[
              SwitchListTile(
                title: const Text('Use saved card'),
                value: _useSavedCard,
                onChanged: (v) => setState(() => _useSavedCard = v),
              ),
              
              if (_useSavedCard) ...[
                ..._savedCards.map((card) => RadioListTile<SavedCard>(
                  value: card,
                  groupValue: _selectedCard,
                  title: Text(card.displayName),
                  subtitle: Text('Expires ${card.expiry}'),
                  onChanged: (v) => setState(() => _selectedCard = v),
                )),
                
                const SizedBox(height: 16),
                
                ElevatedButton(
                  onPressed: _selectedCard != null ? _payWithSavedCard : null,
                  child: const Text('Pay Now'),
                ),
              ],
            ],
            
            // New Card Form
            if (!_useSavedCard && _publishableKey != null) ...[
              const Text('Enter Card Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              moyasar.CreditCard(
                config: moyasar.PaymentConfig(
                  publishableApiKey: _publishableKey!,
                  amount: widget.amount,
                  description: 'Booking #${widget.bookingId}',
                  creditCard: moyasar.CreditCardConfig(saveCard: true, manual: false),
                ),
                onPaymentResult: _onNewCardPayment,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
