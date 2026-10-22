part of 'history_detail_screen.dart';

class HistoryDetailTabletScreen extends StatelessWidget {
  const HistoryDetailTabletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailController>(
      init: Get.find<BookingDetailController>(),
      builder: (controller) {
        return Obx(() {
          final history = controller.history.value;

          if (history == null) {
            return Scaffold(
              backgroundColor: _C.surface,
              appBar: _buildAppBar(context),
              body: controller.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(color: _C.primary),
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(_S.x3),
                            decoration: BoxDecoration(
                              color: _C.surfaceMuted,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.event_busy_rounded,
                              size: 48,
                              color: _C.textTertiary,
                            ),
                          ),
                          const SizedBox(height: _S.x2),
                          Text(
                            DynamicLanguage.key(Strings.bookingNotFound),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _C.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          }

          final status = controller.bookingStatus;

          return Scaffold(
            backgroundColor: _C.surface,
            appBar: _buildAppBar(context),
            body: _buildBody(history, status, controller),
            bottomNavigationBar: _buildBottomActions(controller, status),
          );
        });
      },
    );
  }

  // ─── App Bar ────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _C.surface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(_S.x1),
        child: IconButton(
          style: IconButton.styleFrom(
            backgroundColor: _C.surfaceMuted,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_R.sm)),
          ),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _C.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        DynamicLanguage.key(Strings.bookingDetails),
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: _C.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  // ─── Body Content (Two-Column Tablet Layout) ──────────────────
  Widget _buildBody(
    History history,
    BookingStatus status,
    BookingDetailController controller,
  ) {
    return RefreshIndicator(
      color: _C.primary,
      backgroundColor: _C.white,
      onRefresh: controller.loadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: _S.x4, vertical: _S.x3),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Car Image
                _BookingHeaderCard(history: history),

                const SizedBox(height: _S.x3),

                // ── Status Row (3 chips wide)
                Row(
                  children: [
                    _StatusPill(status: status),
                    const SizedBox(width: _S.x1h),
                    Expanded(
                      child: _InfoChip(
                        label: DynamicLanguage.key(Strings.bookingId),
                        value: '#${history.tripId ?? "N/A"}',
                        icon: Icons.tag_rounded,
                      ),
                    ),
                    if (history.slug != null) ...[
                      const SizedBox(width: _S.x1h),
                      Expanded(
                        child: _InfoChip(
                          label: DynamicLanguage.key(Strings.reference),
                          value: history.slug!,
                          icon: Icons.receipt_long_rounded,
                        ),
                      ),
                    ],
                  ],
                ),

                // ── Delivery / Extension banners
                if (history.isDeliver != null || controller.hasPendingExtension) ...[
                  const SizedBox(height: _S.x2),
                  Row(
                    children: [
                      if (history.isDeliver != null)
                        DeliveryBadge(isDeliver: history.isDeliver!),
                      if (history.isDeliver != null && controller.hasPendingExtension)
                        const SizedBox(width: _S.x1h),
                      if (controller.hasPendingExtension)
                        Expanded(
                          child: ExtensionBanner(extension_: controller.pendingExtension!),
                        ),
                    ],
                  ),
                ],

                // ── Rejection reason (backend `rejection_reason`, shown as-is)
                if (controller.bookingRejectionReason != null) ...[
                  const SizedBox(height: _S.x2),
                  _RejectionReasonCard(reason: controller.bookingRejectionReason!),
                ],

                const SizedBox(height: _S.x4),

                // ── Two-Column Layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _RentalScheduleSection(history: history),
                          Obx(() {
                            final branch = controller.carBranch.value;
                            if (branch == null) return const SizedBox.shrink();
                            return Column(
                              children: [
                                const SizedBox(height: _S.x3),
                                _BranchCard(branch: branch),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(width: _S.x3),
                    // Right Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PaymentSummarySection(
                            history: history,
                          ),
                          if (history.message.isNotEmpty) ...[
                            const SizedBox(height: _S.x3),
                            _NotesCard(message: history.message),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: _S.x6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Bottom Action Bar ────────────────────────────────────────
  Widget _buildBottomActions(
    BookingDetailController controller,
    BookingStatus status,
  ) {
    if (status.isTerminal) return const SizedBox.shrink();

    return Obx(() {
      final canCancel = controller.canCancel;
      final canExtend = controller.canExtend;
      final isOngoing = status == BookingStatus.ongoing;

      if (!canCancel && !canExtend && !isOngoing) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(_S.x4, _S.x1h, _S.x4, _S.x3),
        decoration: BoxDecoration(
          color: _C.white,
          boxShadow: _Shadow.bottomBar,
        ),
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Row(
                children: [
                  if (canExtend || isOngoing)
                    Expanded(
                      child: _PrimaryButton(
                        text: controller.hasPendingExtension
                            ? DynamicLanguage.key(Strings.extensionPending)
                            : DynamicLanguage.key(Strings.extendBooking),
                        onPressed: controller.hasPendingExtension
                            ? null
                            : () => _showExtensionSheet(controller),
                      ),
                    ),
                  if ((canExtend || isOngoing) && canCancel)
                    const SizedBox(width: _S.x2),
                  if (canCancel)
                    Expanded(
                      child: _SecondaryButton(
                        text: DynamicLanguage.key(Strings.cancelBooking),
                        isLoading: controller.isCancelling.value,
                        onPressed: () => _confirmCancel(controller),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _confirmCancel(BookingDetailController controller) {
    final context = Get.context;
    if (context == null) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
        child: Container(
          decoration: BoxDecoration(
            color: _C.surfaceCard,
            borderRadius: BorderRadius.circular(_R.lg),
            boxShadow: [
              BoxShadow(
                color: _C.black.withValues(alpha: 0.14),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Danger header ────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: _S.x4),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFEEEE), Color(0xFFFFF6F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(_R.lg),
                    topRight: Radius.circular(_R.lg),
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(_S.x2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD6D6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: _C.error,
                      size: 36,
                    ),
                  ),
                ),
              ),
              // ── Body ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(_S.x3, _S.x3, _S.x3, _S.x3),
                child: Column(
                  children: [
                    Text(
                      DynamicLanguage.key(Strings.cancelBooking),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: _S.x1),
                    Text(
                      DynamicLanguage.key(Strings.cancelBookingConfirm),
                      style: const TextStyle(
                        fontSize: 14,
                        color: _C.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: _S.x3),
                    // ── Action buttons ────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _C.textSecondary,
                              side: const BorderSide(color: _C.border, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(_R.sm),
                              ),
                            ),
                            child: Text(
                              DynamicLanguage.key(Strings.no),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: _S.x2),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              final error = await controller.cancelBooking();
                              if (error != null) CustomSnackBar.error(error);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _C.error,
                              foregroundColor: _C.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(_R.sm),
                              ),
                            ),
                            child: Text(
                              DynamicLanguage.key(Strings.yesCancel),
                              style: const TextStyle(
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

  void _showExtensionSheet(BookingDetailController controller) {
    final context = Get.context;
    if (context == null) return;

    final extCtrl = Get.isRegistered<ExtensionController>()
        ? Get.find<ExtensionController>()
        : Get.put(ExtensionController());
    extCtrl.reset();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ExtensionPreviewSheet(bookingId: controller.bookingId!),
      ),
    );
  }
}
