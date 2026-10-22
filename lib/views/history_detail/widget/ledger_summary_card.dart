import 'package:flutter/material.dart';

import '../../../base/api/services/basic_services.dart';
import '../../../base/utils/currency_formatter.dart';
import '../../../base/utils/dimensions.dart';
import '../model/ledger_summary_model.dart';

class LedgerSummaryCard extends StatelessWidget {
  final LedgerSummary summary;

  const LedgerSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final currency = BasicServices.baseCurCode.value;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.paddingSize),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius * 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Total Charges
          _buildRow(
            'Total Charges',
            CurrencyFormatter.formatAmount(summary.totalDebit,
                currency: currency),
            Colors.red[700]!,
            Icons.arrow_upward,
          ),
          const SizedBox(height: 10),

          // Total Credits
          _buildRow(
            'Total Credits',
            CurrencyFormatter.formatAmount(summary.totalCredit,
                currency: currency),
            Colors.green[700]!,
            Icons.arrow_downward,
          ),
          const SizedBox(height: 10),

          const Divider(),
          const SizedBox(height: 10),

          // Balance Due
          _buildRow(
            'Balance Due',
            CurrencyFormatter.formatAmount(summary.balance,
                currency: currency),
            summary.balance > 0 ? Colors.red[800]! : Colors.green[800]!,
            summary.balance > 0
                ? Icons.account_balance_wallet
                : Icons.check_circle,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value,
    Color valueColor,
    IconData icon, {
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: valueColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
