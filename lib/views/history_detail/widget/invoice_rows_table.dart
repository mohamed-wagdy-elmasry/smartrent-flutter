import 'package:flutter/material.dart';

import '../../../base/api/services/basic_services.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import '../../../base/utils/currency_formatter.dart';
import '../model/invoice_row_model.dart';

class InvoiceRowsTable extends StatelessWidget {
  final List<InvoiceRow> rows;
  const InvoiceRowsTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(rows.length, (i) {
          final row = rows[i];
          final isLast = i == rows.length - 1;
          return _buildRow(row, isLast);
        }),
      ),
    );
  }

  Widget _buildRow(InvoiceRow row, bool isLast) {
    final isDiscount = row.isDiscount;
    final isTotal = row.isTotal;
    final label = _localiseLabel(row.label);
    final currency = BasicServices.baseCurCode.value;
    final absAmount = row.amount.abs();
    final formatted =
        '${isDiscount ? '−' : ''}${CurrencyFormatter.formatAmount(absAmount, currency: currency)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isTotal ? const Color(0xFFF9FAFB) : Colors.transparent,
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
        borderRadius: isTotal
            ? const BorderRadius.vertical(bottom: Radius.circular(12))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: const Color(0xFF374151),
            ),
          ),
          Text(
            formatted,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isDiscount
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  static String _localiseLabel(String key) {
    // Map backend invoice_rows label keys to ARB localization keys
    const _arbKeyMap = {
      'invoice_rental': 'appLInvoiceRental',
      'invoice_delivery': 'appLInvoiceDelivery',
      'invoice_extension': 'appLExtensionCharge',
      'invoice_tax': 'appLInvoiceTax',
      'invoice_discount': 'appLInvoiceDiscount',
      'invoice_total': 'appLInvoiceTotal',
    };

    final arbKey = _arbKeyMap[key];
    if (arbKey != null) {
      final localized = DynamicLanguage.key(arbKey);
      if (localized != arbKey) return localized;
    }

    // Fallback: simple English display
    const _fallback = {
      'invoice_rental': 'Rental',
      'invoice_delivery': 'Delivery',
      'invoice_extension': 'Extension Charge',
      'invoice_tax': 'Tax',
      'invoice_discount': 'Discount',
      'invoice_total': 'Total',
    };
    return _fallback[key] ?? key;
  }
}
