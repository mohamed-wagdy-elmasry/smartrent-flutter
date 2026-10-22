import 'dart:convert';
import 'package:http/http.dart' as http;

import '../endpoint/api_endpoint.dart';
import '../method/api_method.dart';
import '../model/common_success_model.dart';
import 'api_services.dart';
import '../../../views/history_detail/model/extension_preview_model.dart';
import '../../../views/history_detail/model/booking_transaction_model.dart';
import '../../../views/history_detail/model/ledger_summary_model.dart';
import '../../../views/history_detail/model/booking_extension_model.dart';
import '../../../views/history_detail/model/car_branch_model.dart';

class BookingDetailService {
  const BookingDetailService._();

  static Future<ExtensionPreviewModel?> previewExtension(
    int bookingId,
    int additionalDays,
  ) async {
    return ApiServices.apiService<ExtensionPreviewModel>(
      ExtensionPreviewModel.fromJson,
      ApiEndpoint.bookingExtendPreview.withId(bookingId),
      method: 'POST',
      body: {'additional_days': additionalDays},
    );
  }

  /// Sends the extension request. Returns:
  /// - [ExtensionRequestResult.ok] on 201 (auto-approved)
  /// - [ExtensionRequestResult] with [InsufficientBalanceInfo] on 422
  /// - [ExtensionRequestResult.fail] on any other failure
  static Future<ExtensionRequestResult> requestExtension(
    int bookingId,
    int additionalDays, {
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'additional_days': additionalDays,
    };
    if (notes != null && notes.trim().isNotEmpty) {
      body['notes'] = notes.trim();
    }

    try {
      final url = ApiEndpoint.bookingExtendRequest.withId(bookingId);
      final headers = await bearerHeaderInfo();
      final response = await http
          .post(Uri.parse(url), body: jsonEncode(body), headers: headers)
          .timeout(const Duration(seconds: 120));

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decoded is Map<String, dynamic>) {
        String? msg;
        try {
          final model = CommonSuccessModel.fromJson(decoded);
          msg = model.message.success.firstOrNull;
        } catch (_) {}
        return ExtensionRequestResult.ok(message: msg);
      }

      if (response.statusCode == 422 && decoded is Map<String, dynamic>) {
        // Parse the structured insufficient-balance payload
        String? errorMsg;
        InsufficientBalanceInfo? balanceInfo;

        // Error message from message.error[]
        final msgMap = decoded['message'];
        if (msgMap is Map<String, dynamic>) {
          final errors = msgMap['error'];
          if (errors is List && errors.isNotEmpty) {
            errorMsg = errors.map((e) => e.toString()).join('');
          }
        }

        // Structured data payload
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          balanceInfo = InsufficientBalanceInfo.fromJson(data);
          balanceInfo = InsufficientBalanceInfo(
            requiredAmount: balanceInfo.requiredAmount,
            walletBalance: balanceInfo.walletBalance,
            shortage: balanceInfo.shortage,
            serverMessage: errorMsg,
          );
        }

        return ExtensionRequestResult(
          success: false,
          message: errorMsg,
          insufficientBalance: balanceInfo,
        );
      }

      // Any other failure
      String? errText;
      if (decoded is Map<String, dynamic>) {
        final msgMap = decoded['message'];
        if (msgMap is Map<String, dynamic>) {
          final errors = msgMap['error'];
          if (errors is List && errors.isNotEmpty) {
            errText = errors.map((e) => e.toString()).join('');
          }
        }
      }
      return ExtensionRequestResult.fail(errText);
    } catch (e) {
      return ExtensionRequestResult.fail(e.toString());
    }
  }

  static Future<CommonSuccessModel?> cancelBooking(int bookingId) async {
    return ApiServices.apiService<CommonSuccessModel>(
      CommonSuccessModel.fromJson,
      ApiEndpoint.bookingCancel.withId(bookingId),
      method: 'POST',
      showSuccessMessage: true,
    );
  }

  static Future<BookingTransactionListModel?> fetchTransactions(
    int bookingId,
  ) async {
    return ApiServices.apiService<BookingTransactionListModel>(
      BookingTransactionListModel.fromJson,
      ApiEndpoint.bookingTransactions.withId(bookingId),
      method: 'GET',
    );
  }

  static Future<LedgerSummaryModel?> fetchLedgerSummary(
    int bookingId,
  ) async {
    return ApiServices.apiService<LedgerSummaryModel>(
      LedgerSummaryModel.fromJson,
      ApiEndpoint.bookingLedgerSummary.withId(bookingId),
      method: 'GET',
    );
  }

  static Future<BookingExtensionListModel?> fetchExtensions(
    int bookingId,
  ) async {
    return ApiServices.apiService<BookingExtensionListModel>(
      BookingExtensionListModel.fromJson,
      ApiEndpoint.bookingExtensions.withId(bookingId),
      method: 'GET',
    );
  }

  static Future<CarBranchResponseModel?> fetchCarBranch(int carId) async {
    return ApiServices.apiService<CarBranchResponseModel>(
      CarBranchResponseModel.fromJson,
      ApiEndpoint.carBranch.withId(carId),
      method: 'GET',
      showErrorMessage: false, // 404 = no branch assigned; silently ignore
    );
  }
}
