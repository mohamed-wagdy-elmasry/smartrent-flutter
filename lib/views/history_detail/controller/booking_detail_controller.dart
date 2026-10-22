import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../base/api/services/booking_detail_service.dart';
import '../../../base/enums/enums.dart';
import '../../../base/utils/booking_validators.dart';

import '../../history/model/history_model.dart';
import '../model/booking_extension_model.dart';
import '../model/booking_transaction_model.dart';
import '../model/ledger_summary_model.dart';
import '../model/extension_preview_model.dart';
import '../model/car_branch_model.dart';

class BookingDetailController extends GetxController
    with WidgetsBindingObserver {
  final history = Rxn<History>();

  final isLoading = false.obs;
  final isCancelling = false.obs;
  final errorMessage = RxnString();

  // ── Fetched API data ──────────────────────────────────────────────────────
  final transactions = <BookingTransaction>[].obs;
  final ledgerSummary = Rxn<LedgerSummary>();
  final extensions = <BookingExtension>[].obs;

  final carBranch = Rxn<CarBranch>();

  final isLoadingTransactions = false.obs;
  final isLoadingLedger = false.obs;
  final isLoadingExtensions = false.obs;

  int? get bookingId => history.value?.id;

  BookingStatus get bookingStatus =>
      history.value?.status ?? BookingStatus.draft;

  bool get canExtend =>
      history.value != null &&
      (history.value!.canExtend ??
          (history.value!.status.canExtend && !hasPendingExtension));

  bool get canCancel =>
      history.value != null &&
      (history.value!.canCancel ??
          BookingValidators.canCancelBooking(history.value!));

  bool get showPayButton => history.value?.canPay ?? false;

  bool get hasPendingExtension =>
      (history.value?.priceBreakdown?.extensions ?? [])
          .any((e) => e.status == ExtensionStatus.pending);

  BookingExtension? get pendingExtension =>
      (history.value?.priceBreakdown?.extensions ?? [])
          .firstWhereOrNull((e) => e.status == ExtensionStatus.pending);

  /// Top-level booking rejection/cancel reason from the backend
  /// (`rejection_reason`). Null when absent — UI hides the card.
  String? get bookingRejectionReason {
    final r = history.value?.rejectionReason?.trim();
    if (r == null || r.isEmpty) return null;
    return r;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      history.value = args['history'] as History?;
      if (history.value == null && args['historyId'] != null) {
        // Fallback: try to find from HistoryController if available
        _tryFindFromHistoryController(args['historyId'] as int);
      }
    }

    if (bookingId != null) {
      loadAll();
    }
  }

  void _tryFindFromHistoryController(int historyId) {
    // Intentionally no-op: cannot safely find the history list controller
    // without a concrete type. The screen will gracefully show nothing.
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && bookingId != null) {
      loadAll();
    }
  }

  Future<void> loadAll() async {
    isLoading.value = false;
    if (bookingId == null) return;
    await Future.wait([
      refreshTransactions(),
      refreshLedger(),
      refreshExtensions(),
      _loadCarBranch().catchError((_) {}),
    ]);
  }

  Future<void> _loadCarBranch() async {
    final carId = history.value?.carId;
    if (carId == null) return;
    final result = await BookingDetailService.fetchCarBranch(carId);
    if (isClosed) return;
    carBranch.value = result?.branch;
  }

  Future<void> refreshTransactions() async {
    if (bookingId == null) return;
    isLoadingTransactions.value = true;
    try {
      final result = await BookingDetailService.fetchTransactions(bookingId!);
      if (result != null && isClosed == false) {
        transactions.value = result.transactions;
      }
    } finally {
      if (!isClosed) isLoadingTransactions.value = false;
    }
  }

  Future<void> refreshLedger() async {
    if (bookingId == null) return;
    isLoadingLedger.value = true;
    try {
      final result = await BookingDetailService.fetchLedgerSummary(bookingId!);
      if (result != null && isClosed == false) {
        ledgerSummary.value = result.data;
      }
    } finally {
      if (!isClosed) isLoadingLedger.value = false;
    }
  }

  Future<void> refreshExtensions() async {
    if (bookingId == null) return;
    isLoadingExtensions.value = true;
    try {
      final result = await BookingDetailService.fetchExtensions(bookingId!);
      if (result != null && isClosed == false) {
        extensions.value = result.extensions;
      }
    } finally {
      if (!isClosed) isLoadingExtensions.value = false;
    }
  }

  /// Apply an approved extension locally so the UI reflects
  /// the new return date and totals immediately.
  void applyExtension(ExtensionPreview preview) {
    final h = history.value;
    if (h == null) return;

    h.returnAt = preview.newReturnAt;
    h.rentalDays = preview.newRentalDays;

    if (h.totalAmount != null) {
      h.totalAmount = h.totalAmount! + preview.totalAmount;
    }
    if (h.ledgerBalance != null) {
      h.ledgerBalance = h.ledgerBalance! + preview.totalAmount;
    }

    // Add extension to local price_breakdown list so breakdown renders it immediately.
    if (h.priceBreakdown != null) {
      final newExt = BookingExtension(
        id: 0,
        carBookingId: h.id ?? 0,
        oldReturnAt: h.returnAt ?? DateTime.now(),
        newReturnAt: preview.newReturnAt,
        extraDays: preview.extraDays,
        extraAmount: preview.extraAmount,
        dailyRate: preview.dailyRate,
        taxPercentage: preview.taxPercentage,
        taxAmount: preview.taxAmount,
        totalAmount: preview.totalAmount,
        taxEnabled: preview.taxEnabled,
        status: ExtensionStatus.approved,
        statusLabel: ExtensionStatus.approved.label,
        createdAt: DateTime.now(),
      );
      final updated = PriceBreakdown(
        rentalDays: h.priceBreakdown!.rentalDays,
        rental: h.priceBreakdown!.rental,
        delivery: h.priceBreakdown!.delivery,
        tax: h.priceBreakdown!.tax + preview.taxAmount,
        extensions: [...h.priceBreakdown!.extensions, newExt],
        insuranceType: h.priceBreakdown!.insuranceType,
        insuranceDailyAmount: h.priceBreakdown!.insuranceDailyAmount,
        insuranceExcessLiabilityAmount: h.priceBreakdown!.insuranceExcessLiabilityAmount,
        insuranceMessage: h.priceBreakdown!.insuranceMessage,
      );
      h.priceBreakdown = updated;
    }

    // Trigger reactive rebuild
    history.refresh();
  }

  /// Returns null on success, or an error message string on failure.
  Future<String?> cancelBooking() async {
    if (bookingId == null) return null;
    if (!canCancel) {
      return 'Cannot cancel this booking';
    }

    isCancelling.value = true;
    try {
      final result = await BookingDetailService.cancelBooking(bookingId!);
      if (result != null) {
        // Update local status to cancelled, preserving all fields
        final prev = history.value!;
        history.value = History(
          id: prev.id,
          vendorId: prev.vendorId,
          branchId: prev.branchId,
          approvedBy: prev.approvedBy,
          approvedAt: prev.approvedAt,
          carId: prev.carId,
          userId: prev.userId,
          slug: prev.slug,
          phone: prev.phone,
          email: prev.email,
          tripId: prev.tripId,
          location: prev.location,
          isDeliver: prev.isDeliver,
          destination: prev.destination ?? '',
          paymentType: prev.paymentType,
          trxId: prev.trxId,
          amount: prev.amount,
          charges: prev.charges,
          distance: prev.distance,
          rentalDays: prev.rentalDays,
          pickupTime: prev.pickupTime,
          roundPickupTime: prev.roundPickupTime,
          pickupDate: prev.pickupDate,
          returnAt: prev.returnAt,
          roundPickupDate: prev.roundPickupDate,
          message: prev.message,
          status: BookingStatus.cancelled,
          createdAt: prev.createdAt,
          updatedAt: DateTime.now(),
          cars: prev.cars,
          vendorInfo: prev.vendorInfo,
          invoiceRows: prev.invoiceRows,
          dailyPrice: prev.dailyPrice,
          subtotal: prev.subtotal,
          deliveryFee: prev.deliveryFee,
          taxAmount: prev.taxAmount,
          discountAmount: prev.discountAmount,
          totalAmount: prev.totalAmount,
          ledgerBalance: prev.ledgerBalance,
          canExtend: false,
          canCancel: false,
          canPay: false,
          priceBreakdown: prev.priceBreakdown,
          rejectionReason: prev.rejectionReason,
        );
      }
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isCancelling.value = false;
    }
  }
}
