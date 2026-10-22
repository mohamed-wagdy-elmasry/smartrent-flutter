import 'package:flutter/material.dart';

import '../../views/history_detail/model/booking_transaction_model.dart';

class CurrencyFormatter {
  const CurrencyFormatter._();

  static String formatAmount(double amount, {String currency = 'SAR'}) {
    return '${amount.toStringAsFixed(2)} $currency';
  }

  static String formatTransactionAmount(BookingTransaction tx,
      {String currency = 'SAR'}) {
    final prefix = tx.isDebit ? '-' : '+';
    return '$prefix ${tx.amount.toStringAsFixed(2)} $currency';
  }

  static Color transactionColor(String type) {
    return type == 'debit' ? Colors.red[700]! : Colors.green[700]!;
  }
}
