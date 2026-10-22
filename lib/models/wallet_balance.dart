/// Wallet balance model representing user's available balance per currency
/// Supports both full and partial balance responses (with error field when currency lookup fails)
class WalletBalance {
  final int? userId;
  final String currency;
  final dynamic balance; // Can be String or numeric
  final int? walletId;
  final String? error; // Set when currency lookup fails in partial response

  WalletBalance({
    this.userId,
    required this.currency,
    required this.balance,
    this.walletId,
    this.error,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    // Handle both numeric and string balance values
    final balanceValue = json['balance'];
    final balanceStr = balanceValue is String
        ? balanceValue
        : (balanceValue is num ? balanceValue.toStringAsFixed(2) : '0.00');

    return WalletBalance(
      userId: json['user_id'] as int?,
      currency: json['currency'] as String,
      balance: balanceStr,
      walletId: json['wallet_id'] as int?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      'currency': currency,
      'balance': balance,
      if (walletId != null) 'wallet_id': walletId,
      if (error != null) 'error': error,
    };
  }

  /// Get balance as double string (always 2 decimal places)
  String get balanceAsString {
    if (balance is String) {
      return balance;
    }
    if (balance is num) {
      return (balance as num).toStringAsFixed(2);
    }
    return '0.00';
  }

  /// Get balance as double
  double get balanceAsDouble => double.tryParse(balanceAsString) ?? 0.0;

  /// Check if this balance entry has an error (partial response)
  bool get hasError => error != null && error!.isNotEmpty;

  @override
  String toString() =>
      'WalletBalance(userId: $userId, currency: $currency, balance: $balanceAsString, walletId: $walletId${error != null ? ', error: $error' : ''})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WalletBalance &&
        other.userId == userId &&
        other.currency == currency &&
        other.balanceAsString == balanceAsString &&
        other.walletId == walletId &&
        other.error == error;
  }

  @override
  int get hashCode =>
      userId.hashCode ^
      currency.hashCode ^
      balanceAsString.hashCode ^
      walletId.hashCode ^
      error.hashCode;
}
