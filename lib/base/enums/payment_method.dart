enum PaymentMethod {
  cash('cash'),
  card('card'),
  wallet('wallet'),
  bankTransfer('bank_transfer');

  const PaymentMethod(this.value);
  final String value;

  static PaymentMethod fromValue(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value.toLowerCase().trim(),
      orElse: () => PaymentMethod.cash,
    );
  }

  static PaymentMethod fromJson(dynamic value) {
    if (value == null) return PaymentMethod.cash;
    if (value is String) return fromValue(value);
    return PaymentMethod.cash;
  }

  String get label => switch (this) {
    cash => 'Cash',
    card => 'Card',
    wallet => 'Wallet',
    bankTransfer => 'Bank Transfer',
  };

  bool get isOnline => this == card || this == wallet || this == bankTransfer;

  bool get supportsAutoRefund => this == card || this == wallet;
}
