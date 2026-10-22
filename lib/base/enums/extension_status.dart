enum ExtensionStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  const ExtensionStatus(this.value);
  final String value;

  static ExtensionStatus fromValue(String value) {
    return ExtensionStatus.values.firstWhere(
      (e) => e.value == value.toLowerCase().trim(),
      orElse: () => ExtensionStatus.pending,
    );
  }

  static ExtensionStatus fromJson(dynamic value) {
    if (value == null) return ExtensionStatus.pending;
    if (value is String) return fromValue(value);
    return ExtensionStatus.pending;
  }

  String get label => switch (this) {
    pending => 'Pending',
    approved => 'Approved',
    rejected => 'Rejected',
  };

  bool get isTerminal => this == approved || this == rejected;

  bool get isPending => this == pending;
}
