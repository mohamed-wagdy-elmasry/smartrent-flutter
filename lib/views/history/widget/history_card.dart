part of '../screen/history_screen.dart';

class HistoryCard extends StatelessWidget {
  final History info;

  const HistoryCard(this.info, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = _C.statusColor(info.status);
    final hasImage = info.cars.image != null && info.cars.image!.isNotEmpty;
    final currency = BasicServices.baseCurCode.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(_R.card),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: statusColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_R.card),
        child: InkWell(
          onTap: () {
            Get.toNamed('/historyDetailScreen', arguments: {'history': info});
          },
          borderRadius: BorderRadius.circular(_R.card),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // ── Left Accent Bar ────────────────────────────
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(_R.card),
                      bottomLeft: Radius.circular(_R.card),
                    ),
                  ),
                ),
                // ── Card Content ───────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        // ── Top Row: Image + Info + Status ──────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Car image thumbnail
                            Hero(
                              tag: 'booking-car-${info.id}',
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: CustomColor.primary.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(_R.image),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: hasImage
                                    ? CachedNetworkImage(
                                        imageUrl: info.cars.image!,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Center(
                                          child: Icon(
                                            Icons.directions_car_rounded,
                                            color: CustomColor.primary
                                                .withOpacity(0.3),
                                            size: 28,
                                          ),
                                        ),
                                        errorWidget: (_, __, ___) => Icon(
                                          Icons.directions_car_rounded,
                                          color: CustomColor.primary
                                              .withOpacity(0.4),
                                          size: 28,
                                        ),
                                      )
                                    : Icon(
                                        Icons.directions_car_rounded,
                                        color:
                                            CustomColor.primary.withOpacity(0.4),
                                        size: 28,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Car info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Car name
                                  Text(
                                    '${info.cars.carType ?? ''} ${info.cars.carModel ?? ''}'
                                        .trim(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: _C.ink,
                                      height: 1.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),

                                  // Vendor
                                  if (info.vendorInfo?.fullname != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.storefront_rounded,
                                          size: 13,
                                          color: _C.subtle,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            info.vendorInfo!.fullname!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _C.inkLight,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 6),

                                  // Status badge
                                  HistoryStatusBadge(status: info.status),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ── Divider ────────────────────────────
                        Container(
                          height: 1,
                          color: _C.divider,
                        ),

                        const SizedBox(height: 10),

                        // ── Bottom Row: Date + Price + Arrow ───
                        Row(
                          children: [
                            // Date chip
                            _InfoChip(
                              icon: Icons.calendar_today_rounded,
                              text: DateFormat('dd MMM yyyy')
                                  .format(info.pickupDate),
                            ),

                            const SizedBox(width: 12),

                            // Rental days chip
                            if (info.rentalDays > 0)
                              _InfoChip(
                                icon: Icons.timelapse_rounded,
                                text: '${info.rentalDays}d',
                              ),

                            const Spacer(),

                            // Price (includes extension totals when available)
                            Builder(builder: (_) {
                              final displayTotal = info.priceBreakdown?.grandTotal ?? info.totalAmount;
                              if (displayTotal == null || displayTotal <= 0) return const SizedBox.shrink();
                              return Text(
                                '${displayTotal.toStringAsFixed(displayTotal == displayTotal.roundToDouble() ? 0 : 2)} $currency',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: CustomColor.primary,
                                ),
                              );
                            }),

                            const SizedBox(width: 6),

                            // Arrow
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: _C.subtle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable info chip ─────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _C.subtle),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _C.inkLight,
            ),
          ),
        ],
      ),
    );
  }
}
