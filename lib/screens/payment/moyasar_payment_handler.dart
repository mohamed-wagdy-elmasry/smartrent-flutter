import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/moyasar_payment_service.dart';
import 'moyasar_webview_page.dart';
import '../../routes/routes.dart';

class MoyasarPaymentHandler {
  final BuildContext context;
  final MoyasarPaymentService paymentService;

  MoyasarPaymentHandler({
    required this.context,
    required this.paymentService,
  });

  Future<void> processPayment({
    required String bookingToken,
    required String moyasarCardToken,
    required Map<String, dynamic> bookingData,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await paymentService.processCarBookingPayment(
        bookingToken: bookingToken,
        moyasarCardToken: moyasarCardToken,
        carId: bookingData['car_id'],
        carSlug: bookingData['car_slug'],
        fees: bookingData['fees'],
        email: bookingData['email'],
        mobile: bookingData['mobile'],
        rentalDays: bookingData['rental_days'],
        location: bookingData['location'],
        isDeliver: bookingData['is_deliver'],
        pickupLat: bookingData['pickup_lat'],
        pickupLng: bookingData['pickup_lng'],
        destination: bookingData['destination'],
        distance: bookingData['distance'],
        message: bookingData['message'],
      );

      Navigator.pop(context); // Close loading dialog

      if (response.requiresAuthentication && response.paymentUrl != null) {
        // Open 3D Secure authentication
        await _open3DSecureAuth(
          paymentUrl: response.paymentUrl!,
          transactionId: response.transactionId!,
          bookingToken: response.bookingToken!,
        );
      } else if (response.booking != null) {
        // Payment completed immediately
        _showBookingSuccess(response.booking!);
      }
    } on PaymentException catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showError(e.message);
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showError('Unexpected error: ${e.toString()}');
    }
  }

  Future<void> _open3DSecureAuth({
    required String paymentUrl,
    required String transactionId,
    required String bookingToken,
  }) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => MoyasarWebViewPage(
          paymentUrl: paymentUrl,
          transactionId: transactionId,
          bookingToken: bookingToken,
        ),
      ),
    );

    if (result == 'callback_detected') {
      // Always verify payment status via backend - never trust URL params
      await _checkBookingStatus(transactionId);
    } else if (result == 'cancelled') {
      _showError('Payment cancelled by user.');
    } else {
      _showError('Payment process incomplete. Please try again.');
    }
  }

  Future<void> _checkBookingStatus(String transactionId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Confirming booking...'),
          ],
        ),
      ),
    );

    // Poll for booking confirmation (max 10 attempts, 2 seconds interval)
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 2));

      final booking = await paymentService.checkBookingStatus(transactionId);

      if (booking != null) {
        Navigator.pop(context); // Close loading dialog
        _showBookingSuccess(booking);
        return;
      }
    }

    Navigator.pop(context); // Close loading dialog
    _showError('Booking confirmation timeout. Please check your bookings.');
  }

  void _showBookingSuccess(BookingDetails booking) {
    Get.offAllNamed(
      Routes.congratulationScreen,
      arguments: booking,
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payment Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
