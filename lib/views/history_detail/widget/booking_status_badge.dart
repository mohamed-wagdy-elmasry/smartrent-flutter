import 'package:flutter/material.dart';

import '../../../base/enums/booking_status.dart';
import '../../../base/utils/dimensions.dart';

class BookingStatusBadge extends StatelessWidget {
  final BookingStatus status;
  final bool showIcon;
  final bool large;

  const BookingStatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.large = false,
  });

  /// Convenience: build from raw int or string status value.
  factory BookingStatusBadge.fromRaw(dynamic rawStatus,
      {bool showIcon = true, bool large = false}) {
    return BookingStatusBadge(
      status: BookingStatus.fromJson(rawStatus),
      showIcon: showIcon,
      large: large,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = large ? 14.0 : 12.0;
    final iconSize = large ? 18.0 : 14.0;
    final hPad = large ? 14.0 : 10.0;
    final vPad = large ? 8.0 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(Dimensions.radius * 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(status.icon, size: iconSize, color: status.textColor),
            SizedBox(width: 4),
          ],
          Text(
            status.label,
            style: TextStyle(
              color: status.textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
