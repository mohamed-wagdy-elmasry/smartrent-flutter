import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../base/api/services/basic_services.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/utils/currency_formatter.dart';
import '../../../routes/routes.dart';
import '../controller/extension_controller.dart';
import '../model/extension_preview_model.dart';

enum _Phase { normal, loading, success }

class ExtensionPreviewSheet extends StatefulWidget {
  final int bookingId;

  const ExtensionPreviewSheet({super.key, required this.bookingId});

  @override
  State<ExtensionPreviewSheet> createState() => _ExtensionPreviewSheetState();
}

class _ExtensionPreviewSheetState extends State<ExtensionPreviewSheet> {
  late final ExtensionController _controller;
  _Phase _phase = _Phase.normal;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ExtensionController>();
    _controller.reset();
    // Register the booking ID so +/- auto-debounce can recalculate
    _controller.setBookingId(widget.bookingId);
    // Auto-trigger preview as soon as the sheet is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.previewExtension(widget.bookingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final currency = BasicServices.baseCurCode.value;

    return Container(
      padding: EdgeInsets.all(Dimensions.paddingSize),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _phase == _Phase.loading
          ? _buildLoadingState()
          : _phase == _Phase.success
              ? _buildSuccessState(context, currency)
              : SingleChildScrollView(
                  child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(
              DynamicLanguage.key(Strings.extendBooking),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            // Day picker
            Center(
              child: Text(
                DynamicLanguage.key(Strings.additionalDays),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _counterButton(
                      Icons.remove,
                      controller.additionalDays.value > 1
                          ? controller.decrementDays
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${controller.additionalDays.value}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _counterButton(
                      Icons.add,
                      controller.additionalDays.value < 365
                          ? controller.incrementDays
                          : null,
                    ),
                  ],
                )),
            const SizedBox(height: 16),

            // Notes field
            Text(
              '${DynamicLanguage.key(Strings.notes)} (${DynamicLanguage.key(Strings.optional)})',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.notesController,
              maxLength: 1000,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: '${DynamicLanguage.key(Strings.notes)}...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 16),

            // Preview card — always visible, fixed height
            Obx(() {
              final hasTax = controller.preview.value?.taxEnabled ?? false;
              return Container(
                width: double.infinity,
                height: hasTax ? 175 : 155,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.indigo[100]!),
                ),
                child: _buildCardContent(controller, currency),
              );
            }),

            // Action buttons
            Obx(() {
              final hasPreview = controller.preview.value != null;
              final isLoading = controller.isRequestLoading.value;
              return Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: GestureDetector(
                      onTap: isLoading ? null : () => Get.back(),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DynamicLanguage.key(Strings.cancel),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Request button
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: (!hasPreview || isLoading)
                          ? null
                          : () => _confirmAndRequest(context, controller, currency),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: (!hasPreview || isLoading)
                              ? LinearGradient(
                                  colors: [
                                    Colors.grey[300]!,
                                    Colors.grey[300]!
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    CustomColor.primary,
                                    CustomColor.primary
                                        .withBlue(
                                            (CustomColor.primary.blue + 40)
                                                .clamp(0, 255)),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: (!hasPreview || isLoading)
                              ? []
                              : [
                                  BoxShadow(
                                    color:
                                        CustomColor.primary.withOpacity(0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        alignment: Alignment.center,
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.send_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    DynamicLanguage.key(Strings.requestExtension),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: (!hasPreview)
                                          ? Colors.grey[500]
                                          : Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: CustomColor.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              DynamicLanguage.key(Strings.requestExtension),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context, String currency) {
    return TweenAnimationBuilder<double>(
      key: const ValueKey('success'),
      tween: Tween(begin: 0.7, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (_, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: SizedBox(
        height: 340,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/success.svg',
              width: 110,
              height: 110,
            ),
            const SizedBox(height: 20),
            Text(
              DynamicLanguage.key(Strings.success),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              DynamicLanguage.key(Strings.requestExtension),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CustomColor.primary,
                      CustomColor.primary.withBlue(
                          (CustomColor.primary.blue + 40).clamp(0, 255)),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: CustomColor.primary.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  DynamicLanguage.key(Strings.back),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(ExtensionController controller, String currency) {
    // Loading
    if (controller.isPreviewLoading.value) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    // Error
    if (controller.previewError.value != null) {
      return Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: Colors.red[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.previewError.value!,
              style: TextStyle(fontSize: 13, color: Colors.red[700]),
            ),
          ),
        ],
      );
    }

    // Data
    final preview = controller.preview.value;
    if (preview != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _previewRow(
            DynamicLanguage.key(Strings.dailyRate),
            CurrencyFormatter.formatAmount(preview.dailyRate,
                currency: currency),
          ),
          _previewRow(
            DynamicLanguage.key(Strings.additionalDays),
            '${preview.extraDays}',
          ),
          _previewRow(
            DynamicLanguage.key(Strings.extraAmount),
            CurrencyFormatter.formatAmount(preview.extraAmount,
                currency: currency),
          ),
          if (preview.taxEnabled) ...[
            _previewRow(
              '${DynamicLanguage.key(Strings.tax)} (${preview.taxPercentage.toStringAsFixed(preview.taxPercentage.truncateToDouble() == preview.taxPercentage ? 0 : 2)}%)',
              CurrencyFormatter.formatAmount(preview.taxAmount,
                  currency: currency),
            ),
          ],
          const Divider(height: 16),
          _previewRow(
            DynamicLanguage.key(Strings.total),
            CurrencyFormatter.formatAmount(preview.totalAmount,
                currency: currency),
            valueBold: true,
          ),
        ],
      );
    }

    // Placeholder skeleton (no data yet, not loading)
    return Column(
      children: [
        _skeletonRow(),
        const SizedBox(height: 8),
        _skeletonRow(width: 100),
        const Divider(height: 16),
        _skeletonRow(width: 80),
      ],
    );
  }

  Widget _skeletonRow({double width = double.infinity}) {
    return Container(
      height: 12,
      width: width,
      decoration: BoxDecoration(
        color: Colors.indigo[100],
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _counterButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              onTap != null ? Colors.indigo[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onTap != null
                ? Colors.indigo[200]!
                : Colors.grey[300]!,
          ),
        ),
        child: Icon(
          icon,
          color:
              onTap != null ? Colors.indigo[700] : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _previewRow(String label, String value,
      {bool valueBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          Text(
            value,
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: 13,
              fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Confirm dialog → then request ─────────────────────────────
  void _confirmAndRequest(
    BuildContext context,
    ExtensionController controller,
    String currency,
  ) {
    final preview = controller.preview.value;
    final days = controller.additionalDays.value;
    final total = preview != null
        ? CurrencyFormatter.formatAmount(preview.totalAmount, currency: currency)
        : '';

    showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CustomColor.primary,
                    CustomColor.primary.withBlue(
                        (CustomColor.primary.blue + 40).clamp(0, 255)),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.timer_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    DynamicLanguage.key(Strings.requestExtension),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Days row
                  _confirmRow(
                    icon: Icons.calendar_today_rounded,
                    label: DynamicLanguage.key(Strings.additionalDays),
                    value: '$days ${DynamicLanguage.key(Strings.Day)}',
                  ),
                  const SizedBox(height: 10),
                  if (total.isNotEmpty)
                    _confirmRow(
                      icon: Icons.payments_outlined,
                      label: DynamicLanguage.key(Strings.total),
                      value: total,
                      valueColor: CustomColor.primary,
                    ),
                  const SizedBox(height: 20),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(dialogCtx, false),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              DynamicLanguage.key(Strings.cancel),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(dialogCtx, true),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  CustomColor.primary,
                                  CustomColor.primary.withBlue(
                                      (CustomColor.primary.blue + 40)
                                          .clamp(0, 255)),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: CustomColor.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              DynamicLanguage.key(Strings.confirm),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
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
    ).then((confirmed) async {
      if (confirmed != true) return;
      if (!mounted) return;

      setState(() => _phase = _Phase.loading);

      final result = await controller.requestExtension(widget.bookingId);

      if (!mounted) return;

      if (result.isInsufficientBalance) {
        setState(() => _phase = _Phase.normal);
        _showInsufficientBalanceDialog(
          context,
          result.insufficientBalance!,
          currency,
        );
        return;
      }

      if (result.success) {
        setState(() => _phase = _Phase.success);
      } else {
        setState(() => _phase = _Phase.normal);
      }
    });
  }

  Widget _confirmRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: CustomColor.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: CustomColor.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor ?? Colors.grey[800],
          ),
        ),
      ],
    );
  }

  void _showInsufficientBalanceDialog(
    BuildContext ctx,
    InsufficientBalanceInfo info,
    String currency,
  ) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                color: Colors.orange[700], size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                DynamicLanguage.key(Strings.insufficientBalance),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _balanceRow(
              DynamicLanguage.key(Strings.requiredAmount),
              CurrencyFormatter.formatAmount(info.requiredAmount,
                  currency: currency),
            ),
            const SizedBox(height: 8),
            _balanceRow(
              DynamicLanguage.key(Strings.walletBalance),
              CurrencyFormatter.formatAmount(info.walletBalance,
                  currency: currency),
            ),
            const Divider(height: 20),
            _balanceRow(
              DynamicLanguage.key(Strings.shortage),
              CurrencyFormatter.formatAmount(info.shortage,
                  currency: currency),
              valueColor: Colors.red[700],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(DynamicLanguage.key(Strings.cancel)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogCtx);
              Navigator.pop(ctx); // close the bottom sheet too
              Get.toNamed(Routes.walletScreen);
            },
            icon: const Icon(Icons.account_balance_wallet, size: 18),
            label: Text(DynamicLanguage.key(Strings.topUpWallet)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        Text(
          value,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

}
