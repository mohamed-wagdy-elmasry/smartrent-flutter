import 'dart:convert';

LedgerSummaryModel ledgerSummaryModelFromJson(String str) =>
    LedgerSummaryModel.fromJson(json.decode(str));

class LedgerSummaryModel {
  final LedgerMessage? message;
  final LedgerSummary? data;
  final String type;

  LedgerSummaryModel({
    this.message,
    this.data,
    required this.type,
  });

  factory LedgerSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    LedgerSummary? summary;

    if (rawData != null && rawData is Map<String, dynamic>) {
      summary = LedgerSummary.fromJson(rawData);
    }

    return LedgerSummaryModel(
      message: json['message'] != null
          ? LedgerMessage.fromJson(json['message'])
          : null,
      data: summary,
      type: json['type']?.toString() ?? '',
    );
  }

  LedgerSummary get summary => data ?? LedgerSummary.empty();
}

class LedgerMessage {
  final List<String> success;

  LedgerMessage({required this.success});

  factory LedgerMessage.fromJson(Map<String, dynamic> json) {
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
    return LedgerMessage(success: successList);
  }
}

class LedgerSummary {
  final double totalDebit;
  final double totalCredit;
  final double balance;

  LedgerSummary({
    required this.totalDebit,
    required this.totalCredit,
    required this.balance,
  });

  factory LedgerSummary.empty() => LedgerSummary(
    totalDebit: 0.0,
    totalCredit: 0.0,
    balance: 0.0,
  );

  factory LedgerSummary.fromJson(Map<String, dynamic> json) {
    return LedgerSummary(
      totalDebit: _parseDouble(json['total_debit']),
      totalCredit: _parseDouble(json['total_credit']),
      balance: _parseDouble(json['balance']),
    );
  }

  bool get hasOutstandingBalance => balance > 0;

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
