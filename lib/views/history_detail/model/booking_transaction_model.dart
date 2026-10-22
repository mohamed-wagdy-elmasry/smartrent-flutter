import 'dart:convert';

import '../../../base/enums/transaction_status.dart';
import '../../../base/enums/transaction_category.dart';
import '../../../base/enums/payment_method.dart';

BookingTransactionListModel bookingTransactionListModelFromJson(String str) =>
    BookingTransactionListModel.fromJson(json.decode(str));

class BookingTransactionListModel {
  final TransactionMessage? message;
  final TransactionData? data;
  final String type;

  BookingTransactionListModel({
    this.message,
    this.data,
    required this.type,
  });

  factory BookingTransactionListModel.fromJson(Map<String, dynamic> json) =>
      BookingTransactionListModel(
        message: json['message'] != null
            ? TransactionMessage.fromJson(json['message'])
            : null,
        data: json['data'] is List
            ? TransactionData(
                transactions: (json['data'] as List)
                    .map((x) => BookingTransaction.fromJson(x as Map<String, dynamic>))
                    .toList(),
              )
            : json['data'] != null
                ? TransactionData.fromJson(json['data'])
                : null,
        type: json['type']?.toString() ?? '',
      );

  List<BookingTransaction> get transactions => data?.transactions ?? [];
}

class TransactionMessage {
  final List<String> success;

  TransactionMessage({required this.success});

  factory TransactionMessage.fromJson(Map<String, dynamic> json) {
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
    return TransactionMessage(success: successList);
  }
}

class TransactionData {
  final List<BookingTransaction> transactions;

  TransactionData({required this.transactions});

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    final txList = json['transactions'] ?? json['data'] ?? [];
    return TransactionData(
      transactions: (txList is List)
          ? txList.map((x) => BookingTransaction.fromJson(x)).toList()
          : [],
    );
  }
}

class BookingTransaction {
  final int id;
  final int carBookingId;
  final int? bookingExtensionId;
  final TransactionCategory category;
  final String categoryLabel;
  final String type; // 'debit' | 'credit'
  final PaymentMethod paymentMethod;
  final String paymentMethodLabel;
  final double amount;
  final TransactionStatus status;
  final String statusLabel;
  final String? reference;
  final String? description;
  final DateTime? paidAt;
  final DateTime createdAt;

  BookingTransaction({
    required this.id,
    required this.carBookingId,
    this.bookingExtensionId,
    required this.category,
    required this.categoryLabel,
    required this.type,
    required this.paymentMethod,
    required this.paymentMethodLabel,
    required this.amount,
    required this.status,
    required this.statusLabel,
    this.reference,
    this.description,
    this.paidAt,
    required this.createdAt,
  });

  factory BookingTransaction.fromJson(Map<String, dynamic> json) {
    return BookingTransaction(
      id: json['id'] ?? 0,
      carBookingId: json['car_booking_id'] ?? 0,
      bookingExtensionId: json['booking_extension_id'],
      category: TransactionCategory.fromJson(json['category']),
      categoryLabel: json['category_label']?.toString() ??
          TransactionCategory.fromJson(json['category']).label,
      type: json['type']?.toString() ?? 'debit',
      paymentMethod: PaymentMethod.fromJson(json['payment_method']),
      paymentMethodLabel: json['payment_method_label']?.toString() ??
          PaymentMethod.fromJson(json['payment_method']).label,
      amount: _parseDouble(json['amount']),
      status: TransactionStatus.fromJson(json['status']),
      statusLabel: json['status_label']?.toString() ??
          TransactionStatus.fromJson(json['status']).label,
      reference: json['reference']?.toString(),
      description: json['description']?.toString(),
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  bool get isDebit => type == 'debit';
  bool get isCredit => type == 'credit';

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
