import 'package:flutter/material.dart';

import '../../../base/enums/transaction_status.dart';
import '../../../base/utils/dimensions.dart';

class TransactionStatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const TransactionStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(Dimensions.radius * 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: _color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: _color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color get _color => switch (status) {
    TransactionStatus.pending => Colors.orange[800]!,
    TransactionStatus.paid => Colors.green[800]!,
    TransactionStatus.failed => Colors.red[800]!,
    TransactionStatus.cancelled => Colors.grey[700]!,
  };

  Color get _backgroundColor => switch (status) {
    TransactionStatus.pending => Colors.orange[50]!,
    TransactionStatus.paid => Colors.green[50]!,
    TransactionStatus.failed => Colors.red[50]!,
    TransactionStatus.cancelled => Colors.grey[100]!,
  };

  IconData get _icon => switch (status) {
    TransactionStatus.pending => Icons.schedule,
    TransactionStatus.paid => Icons.check_circle,
    TransactionStatus.failed => Icons.error,
    TransactionStatus.cancelled => Icons.block,
  };
}
