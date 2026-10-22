import '../services/payment_service.dart';

class PaymentErrorHandler {
  static String getUserFriendlyMessage(dynamic error) {
    if (error is PaymentException) {
      return error.message;
    }
    
    final message = error.toString().toLowerCase();
    
    if (message.contains('insufficient')) {
      return 'Insufficient funds. Please try a different card.';
    }
    if (message.contains('declined')) {
      return 'Card declined. Please contact your bank.';
    }
    if (message.contains('expired')) {
      return 'Card has expired. Please use a different card.';
    }
    if (message.contains('network') || message.contains('timeout')) {
      return 'Network error. Please check your connection.';
    }
    if (message.contains('invalid') && message.contains('token')) {
      return 'Payment session expired. Please try again.';
    }
    
    return 'Payment failed. Please try again.';
  }
  
  static bool isRetryable(dynamic error) {
    final message = error.toString().toLowerCase();
    return message.contains('network') ||
           message.contains('timeout') ||
           message.contains('temporary');
  }
}
