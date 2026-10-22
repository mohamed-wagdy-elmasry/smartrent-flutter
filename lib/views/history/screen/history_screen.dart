import 'package:cached_network_image/cached_network_image.dart';
import 'package:carbo/base/api/services/basic_services.dart';
import 'package:carbo/base/localization/dynamic_language_shim.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../base/enums/booking_status.dart';
import '../../../base/utils/basic_import.dart';
import '../../../routes/routes.dart';
import '../../../base/widgets/empty_data_widget.dart';
import '../controller/history_controller.dart';
import '../model/history_model.dart';
import '../widget/history_shimmer.dart';
part 'history_tablet_screen.dart';
part 'history_mobile_screen.dart';
part '../widget/expanded_card_info.dart';
part '../widget/expandable_card.dart';
part '../widget/history_card.dart';
part '../widget/history_status_badge.dart';
part '../widget/booking_info_section.dart';

// ─── Design Tokens ────────────────────────────────────────────────
class _C {
  static const surface = Color(0xFFF7F8FA);
  static const card = Colors.white;
  static const divider = Color(0xFFEEF0F4);
  static const subtle = Color(0xFF94A3B8);
  static const ink = Color(0xFF1E293B);
  static const inkLight = Color(0xFF64748B);

  static const pending = Color(0xFFF59E0B);
  static const approved = Color(0xFF3B82F6);
  static const ongoing = Color(0xFF10B981);
  static const completed = Color(0xFF0B5FA5);
  static const cancelled = Color(0xFFEF4444);
  static const draft = Color(0xFF94A3B8);

  static Color statusColor(BookingStatus s) => switch (s) {
    BookingStatus.pending => pending,
    BookingStatus.approved => approved,
    BookingStatus.ongoing => ongoing,
    BookingStatus.completed => completed,
    BookingStatus.cancelled => cancelled,
    BookingStatus.draft => draft,
  };
}

class _R {
  static const card = 16.0;
  static const badge = 8.0;
  static const image = 12.0;
  static const chip = 24.0;
}

class HistoryScreen extends GetView<HistoryController> {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: HistoryMobileScreen(),
      tablet: HistoryTabletScreen(),
    );
  }
}

// ─── Modern Header ────────────────────────────────────────────────
class _HistoryHeader extends StatelessWidget {
  final HistoryController controller;
  const _HistoryHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        Dimensions.defaultHorizontalSize,
        topPadding + 16,
        Dimensions.defaultHorizontalSize,
        16,
      ),
      child: Row(
        children: [
          // ── Back button ─────────────────────────────────────
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Get.offAllNamed(Routes.dashboardScreen);
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: _C.ink,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // ── Title + subtitle ─────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DynamicLanguage.key(Strings.history),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _C.ink,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(
                  () => Text(
                    '${controller.filteredList.length} ${DynamicLanguage.key(Strings.totalBooked)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _C.subtle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Icon accent ──────────────────────────────────────
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CustomColor.primary,
                  CustomColor.primary.withOpacity(0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
