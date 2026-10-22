enum TransactionStatus {
  pending('pending'),
  paid('paid'),
  failed('failed'),
  cancelled('cancelled');

  const TransactionStatus(this.value);
  final String value;

  static TransactionStatus fromValue(String value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.value == value.toLowerCase().trim(),
      orElse: () => TransactionStatus.pending,
    );
  }

  static TransactionStatus fromJson(dynamic value) {
    if (value == null) return TransactionStatus.pending;
    if (value is String) return fromValue(value);
    return TransactionStatus.pending;
  }

  String get label => switch (this) {
    pending => 'Pending',
    paid => 'Paid',
    failed => 'Failed',
    cancelled => 'Cancelled',
  };

  bool get isSettled => this == paid;

  bool get isPending => this == pending;

  bool get isFailed => this == failed || this == cancelled;

  bool get isTerminal => this != pending;
}
