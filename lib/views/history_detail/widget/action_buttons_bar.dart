import 'package:flutter/material.dart';

import '../../../base/api/services/basic_services.dart';
import '../../../base/enums/enums.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/utils/currency_formatter.dart';
import '../controller/booking_detail_controller.dart';
import '../controller/extension_controller.dart';
import 'extension_preview_sheet.dart';

class ActionButtonsBar extends StatelessWidget {
  const ActionButtonsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailController>(
      init: Get.find<BookingDetailController>(),
      builder: (controller) {
        return Obx(() {
          final status = controller.bookingStatus;

          // No actions for terminal statuses
          if (status.isTerminal) return const SizedBox.shrink();

          final buttons = <Widget>[];

          // Cancel button
          if (BookingActionGuard.canPerform(
              BookingAction.cancel, status)) {
            buttons.add(
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.isCancelling.value
                      ? null
                      : () => _confirmCancel(context, controller),
                  icon: controller.isCancelling.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cancel_outlined, size: 18),
                  label: Text(DynamicLanguage.key(Strings.cancel)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[700],
                    side: BorderSide(color: Colors.red[300]!),
                  ),
                ),
              ),
            );
          }

          // Extend button
          if (BookingActionGuard.canPerform(
              BookingAction.extend, status)) {
            if (buttons.isNotEmpty) {
              buttons.add(const SizedBox(width: 10));
            }
            buttons.add(
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.canExtend
                      ? () => _showExtensionSheet(context, controller)
                      : null,
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(controller.hasPendingExtension
                      ? DynamicLanguage.key(Strings.extensionPending)
                      : DynamicLanguage.key(Strings.extendBooking)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.indigo[700],
                    side: BorderSide(color: Colors.indigo[300]!),
                  ),
                ),
              ),
            );
          }

          // Pay button
          if (controller.showPayButton) {
            if (buttons.isNotEmpty) {
              buttons.add(const SizedBox(width: 10));
            }
            final currency = BasicServices.baseCurCode.value;
            final balance = controller.history.value?.ledgerBalance ?? 0;
            buttons.add(
              Expanded(
                child: PrimaryButton(
                  title:
                      'Pay ${CurrencyFormatter.formatAmount(balance, currency: currency)}',
                  onPressed: () {
                    // Navigate to payment screen
                    Get.toNamed('/bookingPaymentScreen', arguments: {
                      'bookingId': controller.bookingId,
                      'amount': balance,
                    });
                  },
                ),
              ),
            );
          }

          if (buttons.isEmpty) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(children: buttons),
            ),
          );
        });
      },
    );
  }

  void _confirmCancel(
      BuildContext context, BookingDetailController controller) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Danger header ──────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFEEEE), Color(0xFFFFF6F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD6D6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFDC2626),
                      size: 36,
                    ),
                  ),
                ),
              ),
              // ── Body ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  children: [
                    const Text(
                      'Cancel Booking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Are you sure you want to cancel this booking? This action cannot be undone.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // ── Action buttons ─────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF64748B),
                              side: const BorderSide(
                                color: Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'No',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              controller.cancelBooking();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Yes, Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExtensionSheet(
      BuildContext context, BookingDetailController controller) {
    // Ensure ExtensionController is registered (lazyPut from binding).
    final extCtrl = Get.isRegistered<ExtensionController>()
        ? Get.find<ExtensionController>()
        : Get.put(ExtensionController());
    extCtrl.reset();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ExtensionPreviewSheet(
          bookingId: controller.bookingId!,
        ),
      ),
    );
  }
}
