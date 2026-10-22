enum TransactionCategory {
  base('base'),
  delivery('delivery'),
  extend('extend'),
  penalty('penalty'),
  refund('refund');

  const TransactionCategory(this.value);
  final String value;

  static TransactionCategory fromValue(String value) {
    return TransactionCategory.values.firstWhere(
      (e) => e.value == value.toLowerCase().trim(),
      orElse: () => TransactionCategory.base,
    );
  }

  static TransactionCategory fromJson(dynamic value) {
    if (value == null) return TransactionCategory.base;
    if (value is String) return fromValue(value);
    return TransactionCategory.base;
  }

  String get label => switch (this) {
    base => 'Base Rental',
    delivery => 'Delivery Fee',
    extend => 'Rental Extension',
    penalty => 'Penalty',
    refund => 'Refund',
  };

  String get description => switch (this) {
    base => 'Initial rental charge for the booking period',
    delivery => 'Vehicle delivery service fee',
    extend => 'Additional charge for extending the rental period',
    penalty => 'Late return or damage penalty',
    refund => 'Refund credit for overpayment or cancellation',
  };

  String get defaultType => this == refund ? 'credit' : 'debit';

  bool get isCharge => defaultType == 'debit';
}
