class InvoiceRow {
  final String label;
  final double amount;

  const InvoiceRow({required this.label, required this.amount});

  factory InvoiceRow.fromJson(Map<String, dynamic> json) {
    return InvoiceRow(
      label: json['label'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'amount': amount};

  bool get isDiscount => amount < 0;
  bool get isTotal => label == 'invoice_total';

  static List<InvoiceRow> listFromJson(dynamic json) {
    if (json == null || json is! List) return [];
    return json
        .map((e) => InvoiceRow.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
