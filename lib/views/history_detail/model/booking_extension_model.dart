import 'dart:convert';

import '../../../base/enums/extension_status.dart';

BookingExtensionListModel bookingExtensionListModelFromJson(String str) =>
    BookingExtensionListModel.fromJson(json.decode(str));

class BookingExtensionListModel {
  final ExtListMessage? message;
  final ExtListData? data;
  final String type;

  BookingExtensionListModel({
    this.message,
    this.data,
    required this.type,
  });

  factory BookingExtensionListModel.fromJson(Map<String, dynamic> json) =>
      BookingExtensionListModel(
        message: json['message'] != null
            ? ExtListMessage.fromJson(json['message'])
            : null,
        data: json['data'] is List
            ? ExtListData(
                extensions: (json['data'] as List)
                    .map((x) => BookingExtension.fromJson(x as Map<String, dynamic>))
                    .toList(),
              )
            : json['data'] != null
                ? ExtListData.fromJson(json['data'])
                : null,
        type: json['type']?.toString() ?? '',
      );

  List<BookingExtension> get extensions => data?.extensions ?? [];
}

class ExtListMessage {
  final List<String> success;

  ExtListMessage({required this.success});

  factory ExtListMessage.fromJson(Map<String, dynamic> json) {
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
    return ExtListMessage(success: successList);
  }
}

class ExtListData {
  final List<BookingExtension> extensions;

  ExtListData({required this.extensions});

  factory ExtListData.fromJson(Map<String, dynamic> json) {
    final extList = json['extensions'] ?? json['data'] ?? [];
    return ExtListData(
      extensions: (extList is List)
          ? extList.map((x) => BookingExtension.fromJson(x)).toList()
          : [],
    );
  }
}

class BookingExtension {
  final int id;
  final int carBookingId;
  final DateTime oldReturnAt;
  final DateTime newReturnAt;
  final int extraDays;
  final double extraAmount;
  final double dailyRate;
  final double taxPercentage;
  final double taxAmount;
  final double totalAmount;
  final bool taxEnabled;
  final ExtensionStatus status;
  final String statusLabel;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final String? notes;
  final DateTime createdAt;

  BookingExtension({
    required this.id,
    required this.carBookingId,
    required this.oldReturnAt,
    required this.newReturnAt,
    required this.extraDays,
    required this.extraAmount,
    required this.dailyRate,
    this.taxPercentage = 0,
    this.taxAmount = 0,
    this.totalAmount = 0,
    this.taxEnabled = false,
    required this.status,
    required this.statusLabel,
    this.approvedAt,
    this.rejectionReason,
    this.notes,
    required this.createdAt,
  });

  factory BookingExtension.fromJson(Map<String, dynamic> json) {
    final status = ExtensionStatus.fromJson(json['status']);
    final extraAmount = _parseDouble(json['extra_amount']);
    return BookingExtension(
      id: json['id'] ?? 0,
      carBookingId: json['car_booking_id'] ?? 0,
      oldReturnAt: DateTime.tryParse(json['old_return_at']?.toString() ?? '') ??
          DateTime.now(),
      newReturnAt: DateTime.tryParse(json['new_return_at']?.toString() ?? '') ??
          DateTime.now(),
      extraDays: json['extra_days'] ?? 0,
      extraAmount: extraAmount,
      dailyRate: _parseDouble(json['daily_rate']),
      taxPercentage: _parseDouble(json['tax_percentage']),
      taxAmount: _parseDouble(json['tax_amount']),
      totalAmount: _parseDouble(json['total_amount']),
      taxEnabled: json['tax_enabled'] == true,
      status: status,
      statusLabel: json['status_label']?.toString() ?? status.label,
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'].toString())
          : null,
      rejectionReason: json['rejection_reason']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  bool get isPending => status.isPending;
  bool get isApproved => status == ExtensionStatus.approved;
  bool get isRejected => status == ExtensionStatus.rejected;

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
