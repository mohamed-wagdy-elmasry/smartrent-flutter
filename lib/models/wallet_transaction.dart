/// Transaction types supported by wallet
enum WalletTransactionType {
  topup,
  debit,
  refundWallet,
  refundCard;

  static WalletTransactionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'topup':
        return WalletTransactionType.topup;
      case 'debit':
        return WalletTransactionType.debit;
      case 'refund_wallet':
        return WalletTransactionType.refundWallet;
      case 'refund_card':
        return WalletTransactionType.refundCard;
      default:
        throw ArgumentError('Unknown transaction type: $value');
    }
  }

  String toApiString() {
    switch (this) {
      case WalletTransactionType.topup:
        return 'topup';
      case WalletTransactionType.debit:
        return 'debit';
      case WalletTransactionType.refundWallet:
        return 'refund_wallet';
      case WalletTransactionType.refundCard:
        return 'refund_card';
    }
  }
}

/// Transaction status
enum WalletTransactionStatus {
  pending,
  completed,
  failed,
  cancelled;

  static WalletTransactionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return WalletTransactionStatus.pending;
      case 'completed':
        return WalletTransactionStatus.completed;
      case 'failed':
        return WalletTransactionStatus.failed;
      case 'cancelled':
        return WalletTransactionStatus.cancelled;
      default:
        return WalletTransactionStatus.pending;
    }
  }
}

/// Wallet transaction model
class WalletTransaction {
  final int id;
  final WalletTransactionType type;
  final String amount;
  final String currency;
  final WalletTransactionStatus status;
  final String? balanceBefore;
  final String? balanceAfter;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    this.balanceBefore,
    this.balanceAfter,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as int,
      type: WalletTransactionType.fromString(json['type'] as String),
      amount: json['amount'] as String,
      currency: json['currency'] as String,
      status: WalletTransactionStatus.fromString(json['status'] as String),
      balanceBefore: json['balance_before'] as String?,
      balanceAfter: json['balance_after'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toApiString(),
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'balance_before': balanceBefore,
      'balance_after': balanceAfter,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  double get amountAsDouble => double.tryParse(amount) ?? 0.0;

  bool get isPending => status == WalletTransactionStatus.pending;
  bool get isCompleted => status == WalletTransactionStatus.completed;
  bool get isFailed => status == WalletTransactionStatus.failed;

  @override
  String toString() =>
      'WalletTransaction(id: $id, type: $type, amount: $amount $currency, status: $status)';
}
