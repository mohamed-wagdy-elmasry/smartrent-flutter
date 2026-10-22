import 'package:flutter/material.dart';

import '../../../base/enums/transaction_category.dart';
import '../../../base/utils/dimensions.dart';

class TransactionCategoryBadge extends StatelessWidget {
  final TransactionCategory category;

  const TransactionCategoryBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(Dimensions.radius * 0.5),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _color => switch (category) {
    TransactionCategory.base => Colors.blue[800]!,
    TransactionCategory.delivery => Colors.purple[800]!,
    TransactionCategory.extend => Colors.indigo[800]!,
    TransactionCategory.penalty => Colors.red[800]!,
    TransactionCategory.refund => Colors.green[800]!,
  };

  Color get _backgroundColor => switch (category) {
    TransactionCategory.base => Colors.blue[50]!,
    TransactionCategory.delivery => Colors.purple[50]!,
    TransactionCategory.extend => Colors.indigo[50]!,
    TransactionCategory.penalty => Colors.red[50]!,
    TransactionCategory.refund => Colors.green[50]!,
  };
}
