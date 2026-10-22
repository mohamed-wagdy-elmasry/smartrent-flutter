import 'package:flutter/material.dart';

import '../../../base/api/services/basic_services.dart';
import '../../../base/enums/extension_status.dart';
import '../../../base/utils/currency_formatter.dart';
import '../../../base/utils/dimensions.dart';
import '../model/booking_extension_model.dart';

class ExtensionBanner extends StatelessWidget {
  final BookingExtension extension_;

  const ExtensionBanner({super.key, required this.extension_});

  @override
  Widget build(BuildContext context) {
    final currency = BasicServices.baseCurCode.value;

    if (!extension_.isPending) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: Dimensions.paddingSize * 0.8),
      padding: EdgeInsets.all(Dimensions.paddingSize * 0.8),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_top, color: Colors.orange[700], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Extension Request Pending',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange[900],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${extension_.extraDays} day${extension_.extraDays != 1 ? "s" : ""} — ${CurrencyFormatter.formatAmount(extension_.extraAmount, currency: currency)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExtensionListItem extends StatelessWidget {
  final BookingExtension extension_;

  const ExtensionListItem({super.key, required this.extension_});

  @override
  Widget build(BuildContext context) {
    final currency = BasicServices.baseCurCode.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(Dimensions.paddingSize * 0.8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: days + status
          Row(
            children: [
              Icon(Icons.date_range, size: 16, color: Colors.indigo[600]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '+${extension_.extraDays} day${extension_.extraDays != 1 ? "s" : ""}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _statusBadge(),
            ],
          ),
          const SizedBox(height: 8),

          // Date range
          Row(
            children: [
              Expanded(
                child: _dateColumn(
                    'Old Return', _formatDate(extension_.oldReturnAt)),
              ),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              Expanded(
                child: _dateColumn(
                    'New Return', _formatDate(extension_.newReturnAt)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Amount + rate
          Row(
            children: [
              Text(
                'Rate: ${CurrencyFormatter.formatAmount(extension_.dailyRate, currency: currency)}/day',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const Spacer(),
              Text(
                CurrencyFormatter.formatAmount(extension_.extraAmount,
                    currency: currency),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.indigo[700],
                ),
              ),
            ],
          ),

          // Notes
          if (extension_.notes != null && extension_.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              extension_.notes!,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],

          // Rejection reason
          if (extension_.isRejected && extension_.rejectionReason != null) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Reason: ${extension_.rejectionReason}',
                style: TextStyle(fontSize: 12, color: Colors.red[700]),
              ),
            ),
          ],

          // Approved at
          if (extension_.isApproved && extension_.approvedAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'Approved: ${_formatDateTime(extension_.approvedAt!)}',
              style: TextStyle(fontSize: 11, color: Colors.green[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge() {
    Color bg;
    Color fg;

    switch (extension_.status) {
      case ExtensionStatus.pending:
        bg = Colors.orange[100]!;
        fg = Colors.orange[800]!;
      case ExtensionStatus.approved:
        bg = Colors.green[100]!;
        fg = Colors.green[800]!;
      case ExtensionStatus.rejected:
        bg = Colors.red[100]!;
        fg = Colors.red[800]!;
      default:
        bg = Colors.grey[100]!;
        fg = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        extension_.statusLabel,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _dateColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatDateTime(DateTime d) =>
      '${_formatDate(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
