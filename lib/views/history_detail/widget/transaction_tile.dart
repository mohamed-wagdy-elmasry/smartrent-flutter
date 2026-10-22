import 'package:flutter/material.dart';

import '../../../base/api/services/basic_services.dart';
import '../../../base/utils/currency_formatter.dart';
import '../../../base/utils/dimensions.dart';
import '../model/booking_transaction_model.dart';
import 'transaction_category_badge.dart';
import 'transaction_status_badge.dart';

class TransactionTile extends StatelessWidget {
  final BookingTransaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currency = BasicServices.baseCurCode.value;
    final amountText = CurrencyFormatter.formatTransactionAmount(
      transaction,
      currency: currency,
    );
    final amountColor = CurrencyFormatter.transactionColor(transaction.type);

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(Dimensions.paddingSize * 0.8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: category label + amount
          Row(
            children: [
              Expanded(
                child: Text(
                  transaction.categoryLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                amountText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Description
          if (transaction.description != null &&
              transaction.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                transaction.description!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),

          // Bottom row: badges + date
          Row(
            children: [
              TransactionCategoryBadge(category: transaction.category),
              const SizedBox(width: 6),
              TransactionStatusBadge(status: transaction.status),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction.paymentMethodLabel,
                  style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(transaction.createdAt),
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
