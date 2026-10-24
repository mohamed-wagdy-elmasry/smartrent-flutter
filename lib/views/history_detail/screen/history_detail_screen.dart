import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/api/services/basic_services.dart';
import '../../../base/utils/currency_formatter.dart';
import '../../../base/enums/enums.dart';
import '../../history/model/history_model.dart';
import '../controller/booking_detail_controller.dart';
import '../model/car_branch_model.dart';
import '../../all_vendors_dashboard/controller/all_vendors_dashboard_controller.dart';
import '../widget/delivery_badge.dart';
import '../widget/extension_banner.dart';
import '../widget/extension_preview_sheet.dart';
import '../controller/extension_controller.dart';
import '../../../base/widgets/app_cached_image.dart';

import '../../../base/localization/dynamic_language_shim.dart';

part 'history_detail_mobile_screen.dart';
part 'history_detail_tablet_screen.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  8px Base-Grid Spacing System
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _S {
  static const double x05 = 4;  // half-step
  static const double x1 = 8;   // base unit
  static const double x1h = 12; // 1.5×
  static const double x2 = 16;
  static const double x3 = 24;
  static const double x4 = 32;
  static const double x6 = 48;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  Border Radii
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _R {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double full = 999;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  Premium Color Palette
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _C {
  // Brand
  static const Color primary = Color(0xFF0A5EA8);
  static const Color primaryDark = Color(0xFF064078);
  static const Color primaryLight = Color(0xFFE6F0FA);
  static const Color accent = Color(0xFF1B8CE3);

  // Surfaces
  static const Color surface = Color(0xFFFAFBFC);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F3F5);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Semantic
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);

  // Borders & Neutral
  static const Color border = Color(0xFFE2E8F0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  Reusable Shadow Presets
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _Shadow {
  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: _C.black.withValues(alpha: 0.03),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get card => [
    BoxShadow(
      color: _C.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: _C.black.withValues(alpha: 0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: _C.black.withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: _C.black.withValues(alpha: 0.02),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get bottomBar => [
    BoxShadow(
      color: _C.black.withValues(alpha: 0.05),
      blurRadius: 20,
      offset: const Offset(0, -6),
    ),
  ];
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const HistoryDetailMobileScreen(),
      tablet: const HistoryDetailTabletScreen(),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  Premium Reusable Widgets
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ─── Car Image Hero Header ──────────────────────────────────────
class _BookingHeaderCard extends StatelessWidget {
  final History history;

  const _BookingHeaderCard({required this.history});

  @override
  Widget build(BuildContext context) {
    final carName = history.cars.carModel ?? 'Unknown Car';
    final carType = history.cars.carType ?? '';
    final year = history.pickupDate.year;

    // Resolve image: from history payload → fallback to already-loaded car list
    String? carImageUrl = history.cars.image;
    if (carImageUrl == null || carImageUrl.isEmpty) {
      try {
        final vendorCtrl = Get.find<AllVendorsDashboardController>();
        final match = vendorCtrl.allVendorCars
            .cast<dynamic>()
            .firstWhere((c) => c.id == history.carId, orElse: () => null);
        if (match != null) carImageUrl = match.modelImage as String?;
      } catch (_) {}
    }

    Widget imageContent = carImageUrl != null && carImageUrl.isNotEmpty
        ? AppCachedImage(
            imageUrl: carImageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 216,
            useShimmer: true,
            fadeIn: true,
            errorWidget: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _C.primary.withValues(alpha: 0.06),
                    _C.accent.withValues(alpha: 0.03),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.directions_car_rounded,
                  size: 72,
                  color: _C.primary.withValues(alpha: 0.18),
                ),
              ),
            ),
          )
        : Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _C.primary.withValues(alpha: 0.06),
                  _C.accent.withValues(alpha: 0.03),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.directions_car_rounded,
                size: 72,
                color: _C.primary.withValues(alpha: 0.12),
              ),
            ),
          );

    Widget card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_R.lg),
        boxShadow: _Shadow.elevated,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_R.lg),
        child: SizedBox(
          width: double.infinity,
          height: 216, // 27 × 8
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageContent,
              // Cinematic gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        _C.black.withValues(alpha: 0.35),
                        _C.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.0, 0.35, 0.65, 1.0],
                    ),
                  ),
                ),
              ),
              // Rental days badge
              if (history.rentalDays > 0)
                Positioned(
                  top: _S.x2,
                  right: _S.x2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _S.x1h,
                      vertical: _S.x05,
                    ),
                    decoration: BoxDecoration(
                      color: _C.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(_R.full),
                      boxShadow: _Shadow.subtle,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: _C.primary,
                        ),
                        const SizedBox(width: _S.x05),
                        Text(
                          '${history.rentalDays} ${history.rentalDays != 1 ? DynamicLanguage.key(Strings.rentalDays) : DynamicLanguage.key(Strings.rentalDays)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _C.primary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Car info
              Positioned(
                left: _S.x3,
                bottom: _S.x3,
                right: _S.x3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      carName,
                      style: const TextStyle(
                        color: _C.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: _S.x05),
                    Text(
                      '$year${carType.isNotEmpty ? '  ·  $carType' : ''}',
                      style: TextStyle(
                        color: _C.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (history.id != null) {
      return Hero(
        tag: 'booking-car-${history.id}',
        child: Material(color: Colors.transparent, child: card),
      );
    }
    return card;
  }
}

// ─── Status Pill ────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  final BookingStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: _S.x1h, vertical: _S.x1),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(_R.full),
        border: Border.all(
          color: status.textColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.textColor),
          const SizedBox(width: _S.x05),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: status.textColor,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info Chip ──────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_S.x2),
      decoration: BoxDecoration(
        color: _C.surfaceCard,
        borderRadius: BorderRadius.circular(_R.sm),
        border: Border.all(color: _C.border, width: 1),
        boxShadow: _Shadow.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: _C.textTertiary),
              const SizedBox(width: _S.x05),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _C.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: _S.x1),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _C.textPrimary,
              letterSpacing: -0.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Rental Schedule Card ───────────────────────────────────────
class _RentalScheduleSection extends StatelessWidget {
  final History history;

  const _RentalScheduleSection({required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_S.x3),
      decoration: BoxDecoration(
        color: _C.surfaceCard,
        borderRadius: BorderRadius.circular(_R.md),
        border: Border.all(color: _C.border, width: 1),
        boxShadow: _Shadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.schedule_rounded, DynamicLanguage.key(Strings.rentalSchedule), _C.primaryLight, _C.primary),
          const SizedBox(height: _S.x3),
          _buildTimelineItem(
            label: DynamicLanguage.key(Strings.pickUp),
            date: _formatDateFriendly(history.pickupDate),
            time: _formatTime(history.pickupTime),
            location: history.location ?? DynamicLanguage.key(Strings.locationNotSpecified),
            isLast: history.roundPickupDate == null,
            lat: history.pickupLat,
            lng: history.pickupLng,
            showMapButton: history.location != null && history.location!.isNotEmpty,
          ),
          if (history.roundPickupDate != null)
            _buildTimelineItem(
              label: DynamicLanguage.key(Strings.returnLabel),
              date: history.roundPickupDate!,
              time: history.roundPickupTime != null
                  ? _formatTime(history.roundPickupTime!)
                  : '',
              location: history.location ?? DynamicLanguage.key(Strings.locationNotSpecified),
              isLast: true,
            ),
        ],
      ),
    );
  }

  Future<void> _openPickupMap(double? lat, double? lng, String locationLabel) async {
    if (lat != null && lng != null) {
      if (Platform.isIOS) {
        // Try Google Maps app first, fall back to Apple Maps
        final googleUri = Uri.parse('comgooglemaps://?q=$lat,$lng&zoom=16');
        try {
          await launchUrl(googleUri, mode: LaunchMode.externalApplication);
          return;
        } catch (_) {}
        await launchUrl(
          Uri.parse('https://maps.apple.com/?q=$lat,$lng'),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Try geo: URI first (opens default maps app on Android)
        final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($locationLabel)');
        try {
          await launchUrl(geoUri, mode: LaunchMode.externalApplication);
          return;
        } catch (_) {}
        await launchUrl(
          Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'),
          mode: LaunchMode.externalApplication,
        );
      }
    } else {
      final encoded = Uri.encodeComponent(locationLabel);
      await launchUrl(
        Uri.parse('https://maps.google.com/maps?q=$encoded'),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Widget _buildTimelineItem({
    required String label,
    required String date,
    required String time,
    required String location,
    required bool isLast,
    double? lat,
    double? lng,
    bool showMapButton = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _S.x3,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _C.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: _C.primaryLight, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: _C.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: _S.x05),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _C.primary.withValues(alpha: 0.3),
                            _C.primary.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: _S.x2),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : _S.x3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _C.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: _S.x05),
                  Text(
                    time.isNotEmpty ? '$date  ·  $time' : date,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _C.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: _S.x05),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(Icons.location_on_outlined, size: 14, color: _C.textTertiary),
                      ),
                      const SizedBox(width: _S.x05),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _C.textSecondary,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (showMapButton) ...
                    [
                      const SizedBox(height: _S.x1h),
                      GestureDetector(
                        onTap: () => _openPickupMap(lat, lng, location),
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: _S.x1h,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [_C.primary, _C.accent],
                              ),
                              borderRadius: BorderRadius.circular(_R.full),
                              boxShadow: [
                                BoxShadow(
                                  color: _C.primary.withValues(alpha: 0.28),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _C.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.map_rounded,
                                    size: 12,
                                    color: _C.white,
                                  ),
                                ),
                                const SizedBox(width: _S.x1),
                                const Text(
                                  'Open Map',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _C.white,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                                const SizedBox(width: _S.x05),
                                const Icon(
                                  Icons.open_in_new_rounded,
                                  size: 11,
                                  color: _C.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateFriendly(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _formatTime(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.isEmpty) return time24;
      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      String period = hour >= 12 ? 'PM' : 'AM';
      int hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return time24;
    }
  }
}

// ─── Price Breakdown Card ────────────────────────────────────────
class _PaymentSummarySection extends StatelessWidget {
  final History history;

  const _PaymentSummarySection({
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final currency = BasicServices.baseCurCode.value;

    return Container(
      padding: const EdgeInsets.all(_S.x3),
      decoration: BoxDecoration(
        color: _C.surfaceCard,
        borderRadius: BorderRadius.circular(_R.md),
        border: Border.all(color: _C.border, width: 1),
        boxShadow: _Shadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader(Icons.receipt_long_rounded, DynamicLanguage.key(Strings.priceBreakdown), _C.successLight, _C.success),
              if (history.trxId != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: _S.x1h, vertical: _S.x05),
                  decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(_R.full),
                  ),
                  child: Text(
                    DynamicLanguage.key(Strings.receipt),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _C.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: _S.x3),

          // ── Unified breakdown: merges API fields, invoice_rows,
          //    transactions, and extension data.
          _buildUnifiedBreakdown(currency),
          const SizedBox(height: _S.x4),
          // ── Excess Liability Insurance (displayed separately, not in total)
          if (history.priceBreakdown?.insuranceType == 'excess_liability' &&
              (history.priceBreakdown?.insuranceExcessLiabilityAmount ?? 0) > 0)
            _buildExcessLiabilitySection(currency),
        ],
      ),
    );
  }

  /// Excess Liability Insurance section — displayed separately below the price breakdown.
  /// Not included in the total calculation.
  Widget _buildExcessLiabilitySection(String currency) {
    final pb = history.priceBreakdown;
    final amount = pb?.insuranceExcessLiabilityAmount ?? 0.0;
    final msg = pb?.insuranceMessage;
    final lang = Get.locale?.languageCode ?? 'en';

    return Container(
      padding: const EdgeInsets.all(_S.x2),
      decoration: BoxDecoration(
        color: _C.warningLight,
        borderRadius: BorderRadius.circular(_R.sm),
        border: Border.all(color: _C.warning, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DynamicLanguage.key(Strings.insuranceExcessLiability),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrimary,
                ),
              ),
              Text(
                CurrencyFormatter.formatAmount(amount, currency: currency),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _C.warning,
                ),
              ),
            ],
          ),
          if (msg != null) ...[  
            const SizedBox(height: _S.x1),
            Text(
              (msg[lang] ?? msg['en'] ?? msg.values.first ?? '').toString(),
              style: const TextStyle(
                fontSize: 12,
                color: _C.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildUnifiedBreakdown(String currency) {
    final pb = history.priceBreakdown;

    final rentalDays = pb?.rentalDays ?? history.rentalDays;
    final rental = pb?.rental ?? _parseAmount(history.subtotal ?? history.amount);
    final dailyRate = history.dailyPrice ??
        (rentalDays > 0 ? rental / rentalDays : 0.0);
    final delivery = pb?.delivery ?? _parseAmount(history.deliveryFee ?? history.charges);
    final discount = history.discountAmount ?? 0;

    // Insurance
    final insuranceType = pb?.insuranceType ?? history.insuranceType;
    final insuranceDailyAmount = pb?.insuranceDailyAmount ?? history.insuranceDailyAmount ?? 0.0;
    final dailyInsuranceTotal = insuranceType == 'daily' ? insuranceDailyAmount * rentalDays : 0.0;

    // Extensions from price_breakdown (approved only)
    final approvedExts = (pb?.extensions ?? [])
        .where((e) => e.isApproved)
        .toList();

    // Tax: base tax + each extension's tax amount
    final baseTax = pb?.tax ?? (history.taxAmount ?? 0);
    final extensionTax = approvedExts.fold<double>(0, (s, e) => s + e.taxAmount);
    final tax = baseTax + extensionTax;

    // Grand total: Always use history.totalAmount (API's ground truth)
    // This total does NOT include Excess Liability Insurance (displayed separately below breakdown)
    final total = history.totalAmount ?? 0.0;

    String _fmtRate(double rate) => CurrencyFormatter.formatAmount(rate, currency: currency);

    return Column(
      children: [
        // Rental row: N × daily_rate
        _payRow(
          '${DynamicLanguage.key(Strings.baseRental)}${rentalDays > 0 && dailyRate > 0 ? ' · $rentalDays × ${_fmtRate(dailyRate)}' : ''}',
          CurrencyFormatter.formatAmount(rental, currency: currency),
        ),
        // Delivery (only when > 0)
        if (delivery > 0)
          _payRow(
            DynamicLanguage.key(Strings.deliveryFee),
            CurrencyFormatter.formatAmount(delivery, currency: currency),
          ),
        // Insurance row (daily only — excess_liability shown separately below)
        if (insuranceType == 'daily' && dailyInsuranceTotal > 0)
          _payRow(
            '${DynamicLanguage.key(Strings.insuranceDaily)} · $rentalDays × ${_fmtRate(insuranceDailyAmount)}',
            CurrencyFormatter.formatAmount(dailyInsuranceTotal, currency: currency),
          ),
        // One row per approved extension: N × daily_rate
        for (final ext in approvedExts)
          _payRow(
            '${DynamicLanguage.key(Strings.extensionCharge)} · ${ext.extraDays} × ${_fmtRate(ext.dailyRate)}',
            CurrencyFormatter.formatAmount(ext.extraAmount, currency: currency),
          ),
        // Tax (always)
        _payRow(
          DynamicLanguage.key(Strings.invoiceTax),
          CurrencyFormatter.formatAmount(tax, currency: currency),
        ),
        // Discount (conditional)
        if (discount > 0)
          _payRow(
            DynamicLanguage.key(Strings.invoiceDiscount),
            '- ${CurrencyFormatter.formatAmount(discount, currency: currency)}',
            valueColor: _C.success,
          ),
        _gradientDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DynamicLanguage.key(Strings.invoiceTotal),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              CurrencyFormatter.formatAmount(total, currency: currency),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _C.primary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _payRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _S.x1h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: _C.textSecondary, letterSpacing: -0.1)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: valueColor ?? _C.textPrimary, letterSpacing: -0.1)),
        ],
      ),
    );
  }

  Widget _gradientDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _S.x2),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_C.border.withValues(alpha: 0.0), _C.border, _C.border.withValues(alpha: 0.0)]),
        ),
      ),
    );
  }

  double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// ─── Branch Card ────────────────────────────────────────────────
class _BranchCard extends StatelessWidget {
  final CarBranch branch;

  const _BranchCard({required this.branch});

  Future<void> _launch(String uri) async {
    try {
      final u = Uri.parse(uri);
      if (await canLaunchUrl(u)) {
        await launchUrl(u, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(u, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _openMap(double lat, double lng, String label) async {
    try {
      if (Platform.isIOS) {
        final googleUri = Uri.parse('comgooglemaps://?q=$lat,$lng&zoom=16');
        try {
          await launchUrl(googleUri, mode: LaunchMode.externalApplication);
          return;
        } catch (_) {}
        await launchUrl(
          Uri.parse('https://maps.apple.com/?q=$lat,$lng'),
          mode: LaunchMode.externalApplication,
        );
      } else {
        final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($label)');
        try {
          await launchUrl(geoUri, mode: LaunchMode.externalApplication);
          return;
        } catch (_) {}
        await launchUrl(
          Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('[_BranchCard] Failed to open map: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhone = branch.phone != null;
    final hasEmail = branch.email != null;
    final hasAddress = branch.address != null || branch.city != null;
    final addressLine = [branch.city, branch.address]
        .whereType<String>()
        .join(', ');

    return Container(
      padding: const EdgeInsets.all(_S.x3),
      decoration: BoxDecoration(
        color: _C.surfaceCard,
        borderRadius: BorderRadius.circular(_R.md),
        border: Border.all(color: _C.border, width: 1),
        boxShadow: _Shadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.store_mall_directory_rounded,
            DynamicLanguage.key(Strings.branchInfo),
            _C.primaryLight,
            _C.primary,
          ),
          if (branch.name != null) ...[
            const SizedBox(height: _S.x2),
            Text(
              DynamicLanguage.key(Strings.branchName),
              style: const TextStyle(fontSize: 11, color: _C.textTertiary, letterSpacing: 0.2),
            ),
            const SizedBox(height: _S.x05),
            Text(
              branch.name!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
          if (hasAddress) ...[
            const SizedBox(height: _S.x1),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: _C.textSecondary),
                const SizedBox(width: _S.x1),
                Expanded(
                  child: Text(
                    addressLine,
                    style: const TextStyle(fontSize: 13, color: _C.textSecondary),
                  ),
                ),
                if (branch.centerLat != null && branch.centerLng != null) ...[
                  const SizedBox(width: _S.x1),
                  InkWell(
                    onTap: () => _openMap(branch.centerLat!, branch.centerLng!, addressLine),
                    borderRadius: BorderRadius.circular(_R.sm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: _S.x1, horizontal: _S.x1h),
                      decoration: BoxDecoration(
                        color: _C.primaryLight,
                        borderRadius: BorderRadius.circular(_R.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map_outlined, size: 14, color: _C.primary),
                          const SizedBox(width: _S.x05),
                          Text(
                            DynamicLanguage.key(Strings.openMap),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _C.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (hasPhone) ...[
            const SizedBox(height: _S.x2),
            _ContactRow(
              value: branch.phone!,
              icon: Icons.phone_rounded,
              label: DynamicLanguage.key(Strings.Phone),
              onTap: () => _launch('tel:${branch.phone!}'),
            ),
          ],
          if (hasEmail) ...[
            const SizedBox(height: _S.x1h),
            _ContactRow(
              value: branch.email!,
              icon: Icons.email_outlined,
              label: DynamicLanguage.key(Strings.email),
              onTap: () => _launch('mailto:${branch.email!}'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final String value;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactRow({
    required this.value,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: _C.textSecondary,
              letterSpacing: -0.1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: _S.x2),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_R.sm),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: _S.x1, horizontal: _S.x1h),
            decoration: BoxDecoration(
              color: _C.primaryLight,
              borderRadius: BorderRadius.circular(_R.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: _C.primary),
                const SizedBox(width: _S.x05),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _C.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Notes Card ─────────────────────────────────────────────────
class _NotesCard extends StatelessWidget {
  final String message;

  const _NotesCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_S.x3),
      decoration: BoxDecoration(
        color: _C.surfaceCard,
        borderRadius: BorderRadius.circular(_R.md),
        border: Border.all(color: _C.border, width: 1),
        boxShadow: _Shadow.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.sticky_note_2_outlined, DynamicLanguage.key(Strings.notes), _C.surfaceMuted, _C.textSecondary),
          const SizedBox(height: _S.x2),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: _C.textSecondary, height: 1.6, letterSpacing: -0.1),
          ),
        ],
      ),
    );
  }
}

// ─── Rejection Reason Card ──────────────────────────────────────
// Shows the top-level booking `rejection_reason` from the backend.
// Raw user text — only the label is localized, never the body.
class _RejectionReasonCard extends StatelessWidget {
  final String reason;

  const _RejectionReasonCard({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_S.x3),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(_R.md),
        border: Border.all(color: _C.error.withValues(alpha: 0.35), width: 1),
        boxShadow: _Shadow.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.info_outline_rounded,
            DynamicLanguage.key(Strings.rejectionReason),
            const Color(0xFFFEE2E2),
            _C.error,
          ),
          const SizedBox(height: _S.x2),
          Text(
            reason,
            style: const TextStyle(
              fontSize: 14,
              color: _C.textPrimary,
              height: 1.6,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gradient Primary Button ────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _PrimaryButton({required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_R.sm),
          gradient: enabled
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_C.primary, _C.primaryDark],
                )
              : null,
          color: enabled ? null : _C.surfaceMuted,
          boxShadow: enabled
              ? [BoxShadow(color: _C.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: enabled ? _C.white : _C.textTertiary,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_R.sm)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}

// ─── Secondary Outlined Button ──────────────────────────────────
class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SecondaryButton({required this.text, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _C.error,
          side: const BorderSide(color: _C.error, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_R.sm)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        ),
        child: isLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: _C.error))
            : Text(text),
      ),
    );
  }
}

// ─── Shared Section Header Helper ───────────────────────────────
Widget _sectionHeader(IconData icon, String title, Color bgColor, Color iconColor) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(_S.x1),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(_R.xs)),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      const SizedBox(width: _S.x1h),
      Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _C.textPrimary, letterSpacing: -0.3),
      ),
    ],
  );
}
