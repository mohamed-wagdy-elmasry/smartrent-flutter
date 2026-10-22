import 'dart:convert';

ExtensionPreviewModel extensionPreviewModelFromJson(String str) =>
    ExtensionPreviewModel.fromJson(json.decode(str));

class ExtensionPreviewModel {
  final PreviewMessage? message;
  final ExtensionPreview? data;
  final String type;

  ExtensionPreviewModel({
    this.message,
    this.data,
    required this.type,
  });

  factory ExtensionPreviewModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    ExtensionPreview? preview;

    if (rawData != null && rawData is Map<String, dynamic>) {
      preview = ExtensionPreview.fromJson(rawData);
    }

    return ExtensionPreviewModel(
      message: json['message'] != null
          ? PreviewMessage.fromJson(json['message'])
          : null,
      data: preview,
      type: json['type']?.toString() ?? '',
    );
  }
}

class PreviewMessage {
  final List<String> success;

  PreviewMessage({required this.success});

  factory PreviewMessage.fromJson(Map<String, dynamic> json) {
    List<String> successList = [];
    if (json['success'] != null) {
      if (json['success'] is List) {
        successList = List<String>.from(
          json['success'].map((x) => x?.toString() ?? ''),
        );
      } else if (json['success'] is String) {
        successList = [json['success'].toString()];
      }
    }
    return PreviewMessage(success: successList);
  }
}

class ExtensionPreview {
  final int bookingId;
  final double dailyRate;
  final int extraDays;
  final double extraAmount;
  final double taxPercentage;
  final double taxAmount;
  final double totalAmount;
  final bool taxEnabled;
  final DateTime oldReturnAt;
  final DateTime newReturnAt;
  final int currentRentalDays;
  final int newRentalDays;

  ExtensionPreview({
    required this.bookingId,
    required this.dailyRate,
    required this.extraDays,
    required this.extraAmount,
    required this.taxPercentage,
    required this.taxAmount,
    required this.totalAmount,
    required this.taxEnabled,
    required this.oldReturnAt,
    required this.newReturnAt,
    required this.currentRentalDays,
    required this.newRentalDays,
  });

  factory ExtensionPreview.fromJson(Map<String, dynamic> json) {
    return ExtensionPreview(
      bookingId: json['booking_id'] ?? 0,
      dailyRate: _parseDouble(json['daily_rate']),
      extraDays: json['extra_days'] ?? 0,
      extraAmount: _parseDouble(json['extra_amount']),
      taxPercentage: _parseDouble(json['tax_percentage']),
      taxAmount: _parseDouble(json['tax_amount']),
      totalAmount: _parseDouble(json['total_amount']),
      taxEnabled: json['tax_enabled'] == true,
      oldReturnAt:
          DateTime.tryParse(json['old_return_at']?.toString() ?? '') ??
              DateTime.now(),
      newReturnAt:
          DateTime.tryParse(json['new_return_at']?.toString() ?? '') ??
              DateTime.now(),
      currentRentalDays: json['current_rental_days'] ?? 0,
      newRentalDays: json['new_rental_days'] ?? 0,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Result returned by [ExtensionController.requestExtension].
/// The UI layer uses this to decide navigation / snackbar feedback.
class ExtensionRequestResult {
  final bool success;
  final String? message;
  final ExtensionPreview? preview;
  final InsufficientBalanceInfo? insufficientBalance;

  const ExtensionRequestResult({
    required this.success,
    this.message,
    this.preview,
    this.insufficientBalance,
  });

  const ExtensionRequestResult.ok({
    this.message,
    this.preview,
  })  : success = true,
        insufficientBalance = null;

  const ExtensionRequestResult.fail([this.message])
      : success = false,
        preview = null,
        insufficientBalance = null;

  bool get isInsufficientBalance => insufficientBalance != null;
}

/// Structured data from a 422 insufficient-wallet-balance response.
class InsufficientBalanceInfo {
  final double requiredAmount;
  final double walletBalance;
  final double shortage;
  final String? serverMessage;

  const InsufficientBalanceInfo({
    required this.requiredAmount,
    required this.walletBalance,
    required this.shortage,
    this.serverMessage,
  });

  factory InsufficientBalanceInfo.fromJson(Map<String, dynamic> json) {
    return InsufficientBalanceInfo(
      requiredAmount: _parseDouble(json['required_amount']),
      walletBalance: _parseDouble(json['wallet_balance']),
      shortage: _parseDouble(json['shortage']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
