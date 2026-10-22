import 'package:flutter/material.dart';

import '../../../base/utils/dimensions.dart';

class DeliveryBadge extends StatelessWidget {
  final bool isDeliver;

  const DeliveryBadge({super.key, required this.isDeliver});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDeliver ? Colors.purple[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(Dimensions.radius * 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDeliver ? Icons.local_shipping : Icons.location_on,
            size: 14,
            color: isDeliver ? Colors.purple[700] : Colors.blue[700],
          ),
          const SizedBox(width: 4),
          Text(
            isDeliver ? 'Delivery' : 'Pickup',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDeliver ? Colors.purple[700] : Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }
}
