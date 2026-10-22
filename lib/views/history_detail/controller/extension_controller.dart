import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../base/api/services/booking_detail_service.dart';
import '../model/extension_preview_model.dart';
import 'booking_detail_controller.dart';

class ExtensionController extends GetxController {
  final additionalDays = 1.obs;
  final notes = ''.obs;
  final preview = Rxn<ExtensionPreview>();
  final isPreviewLoading = false.obs;
  final isRequestLoading = false.obs;
  final previewError = RxnString();

  final notesController = TextEditingController();

  int? _pendingBookingId;
  Timer? _debounceTimer;

  @override
  void onClose() {
    _debounceTimer?.cancel();
    notesController.dispose();
    super.onClose();
  }

  void setAdditionalDays(int days, {int? bookingId}) {
    additionalDays.value = days.clamp(1, 365);
    // Show spinner in the card immediately — don't wait for the debounce
    isPreviewLoading.value = true;
    previewError.value = null;

    // Auto-recalculate after user stops tapping +/- for 600 ms
    final id = bookingId ?? _pendingBookingId;
    if (id != null) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 600), () {
        if (!isClosed) previewExtension(id);
      });
    }
  }

  /// Call once the booking ID is known so auto-recalculate works without
  /// passing it on every +/- tap.
  void setBookingId(int id) => _pendingBookingId = id;

  void incrementDays() => setAdditionalDays(additionalDays.value + 1);

  void decrementDays() => setAdditionalDays(additionalDays.value - 1);

  Future<void> previewExtension(int bookingId) async {
    isPreviewLoading.value = true;
    previewError.value = null;

    try {
      final result = await BookingDetailService.previewExtension(
        bookingId,
        additionalDays.value,
      );

      if (isClosed) return;

      if (result?.data != null) {
        preview.value = result!.data;
        return;
      }

      // Backend route not yet available — compute locally from booking data
      final localPreview = _computeLocalPreview(bookingId);
      if (localPreview != null) {
        preview.value = localPreview;
        return;
      }

      // Surface server message if present, otherwise generic fallback
      final serverMsg = result?.message?.success.firstOrNull;
      previewError.value = serverMsg ?? 'Unable to calculate extension';
    } catch (e) {
      if (!isClosed) previewError.value = e.toString();
    } finally {
      if (!isClosed) isPreviewLoading.value = false;
    }
  }

  /// Computes a preview locally from the booking data already loaded in
  /// [BookingDetailController] — used when the backend route is unavailable.
  ExtensionPreview? _computeLocalPreview(int bookingId) {
    try {
      final hist = Get.find<BookingDetailController>().history.value;
      if (hist == null) return null;

      final dailyRate = hist.dailyPrice ?? 0.0;
      if (dailyRate <= 0) return null;

      // Derive return date: prefer API-provided returnAt, otherwise compute
      final oldReturnAt = hist.returnAt ??
          hist.pickupDate.add(Duration(days: hist.rentalDays));

      final extra = additionalDays.value;
      final extraAmount = dailyRate * extra;
      return ExtensionPreview(
        bookingId: bookingId,
        dailyRate: dailyRate,
        extraDays: extra,
        extraAmount: extraAmount,
        taxPercentage: 0,
        taxAmount: 0,
        totalAmount: extraAmount,
        taxEnabled: false,
        oldReturnAt: oldReturnAt,
        newReturnAt: oldReturnAt.add(Duration(days: extra)),
        currentRentalDays: hist.rentalDays,
        newRentalDays: hist.rentalDays + extra,
      );
    } catch (_) {
      return null;
    }
  }

  Future<ExtensionRequestResult> requestExtension(int bookingId) async {
    if (additionalDays.value < 1 || additionalDays.value > 365) {
      previewError.value = 'Additional days must be between 1 and 365';
      return const ExtensionRequestResult.fail('Additional days must be between 1 and 365');
    }

    final noteText = notesController.text.trim();
    if (noteText.length > 1000) {
      previewError.value = 'Notes must be 1000 characters or less';
      return const ExtensionRequestResult.fail('Notes must be 1000 characters or less');
    }

    isRequestLoading.value = true;
    previewError.value = null;

    // Capture preview before API call — used to update local History
    final previewSnapshot = preview.value;

    try {
      final result = await BookingDetailService.requestExtension(
        bookingId,
        additionalDays.value,
        notes: noteText.isNotEmpty ? noteText : null,
      );

      if (isClosed) return const ExtensionRequestResult.fail();

      // 422 — insufficient wallet balance
      if (result.isInsufficientBalance) {
        previewError.value = result.message;
        return result;
      }

      // Any other failure
      if (!result.success) {
        previewError.value = result.message;
        return result;
      }

      // Success (201 auto-approved)
      try {
        final detailCtrl = Get.find<BookingDetailController>();

        // Update local History immediately so the UI
        // shows the new return date / rental days
        if (previewSnapshot != null) {
          detailCtrl.applyExtension(previewSnapshot);
        }

        // Refresh all backend data (extensions, ledger, transactions)
        await Future.wait([
          detailCtrl.refreshExtensions(),
          detailCtrl.refreshLedger(),
          detailCtrl.refreshTransactions(),
        ]);
      } catch (_) {}

      if (isClosed) return const ExtensionRequestResult.fail();

      final snapshot = previewSnapshot;
      reset();
      return ExtensionRequestResult.ok(
        message: result.message,
        preview: snapshot,
      );
    } catch (e) {
      if (!isClosed) previewError.value = e.toString();
      return ExtensionRequestResult.fail(e.toString());
    } finally {
      if (!isClosed) isRequestLoading.value = false;
    }
  }

  void reset() {
    _debounceTimer?.cancel();
    _pendingBookingId = null;
    additionalDays.value = 1;
    notes.value = '';
    notesController.clear();
    preview.value = null;
    previewError.value = null;
    // Start in loading state — previewExtension is always called right after reset
    isPreviewLoading.value = true;
  }
}
