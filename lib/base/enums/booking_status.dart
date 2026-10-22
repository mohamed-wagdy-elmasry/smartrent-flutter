import 'package:flutter/material.dart';

enum BookingStatus {
  draft('draft'),
  pending('pending'),
  approved('approved'),
  ongoing('ongoing'),
  completed('completed'),
  cancelled('cancelled');

  const BookingStatus(this.value);
  final String value;

  static BookingStatus fromValue(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.value == value.toLowerCase().trim(),
      orElse: () => BookingStatus.draft,
    );
  }

  /// Parse from legacy integer status used in existing History model.
  static BookingStatus fromInt(int status) {
    return switch (status) {
      0 => BookingStatus.draft,
      1 => BookingStatus.pending,
      2 => BookingStatus.ongoing,
      3 => BookingStatus.completed,
      4 => BookingStatus.cancelled,
      5 => BookingStatus.approved,
      _ => BookingStatus.draft,
    };
  }

  /// Parse from either int or String coming from API JSON.
  static BookingStatus fromJson(dynamic value) {
    if (value == null) return BookingStatus.draft;
    if (value is int) return fromInt(value);
    if (value is String) {
      final asInt = int.tryParse(value);
      if (asInt != null) return fromInt(asInt);
      return fromValue(value);
    }
    return BookingStatus.draft;
  }

  String get label => switch (this) {
    draft => 'Draft',
    pending => 'Pending',
    approved => 'Approved',
    ongoing => 'Ongoing',
    completed => 'Completed',
    cancelled => 'Cancelled',
  };

  bool get isTerminal => this == completed || this == cancelled;

  bool get isActive => !isTerminal;

  bool get canExtend => this == approved || this == ongoing;

  bool get isEditable => this == draft || this == pending;

  bool get canCancel => this == pending || this == approved;

  bool get canAcceptPayment => this != cancelled && this != completed;

  List<BookingStatus> get allowedTransitions => switch (this) {
    draft => [pending],
    pending => [approved, cancelled],
    approved => [ongoing, cancelled],
    ongoing => [completed],
    completed => [],
    cancelled => [],
  };

  Color get backgroundColor => switch (this) {
    draft => Colors.grey[200]!,
    pending => Colors.orange[100]!,
    approved => Colors.blue[100]!,
    ongoing => Colors.green[100]!,
    completed => Colors.teal[100]!,
    cancelled => Colors.red[100]!,
  };

  Color get textColor => switch (this) {
    draft => Colors.grey[800]!,
    pending => Colors.orange[900]!,
    approved => Colors.blue[900]!,
    ongoing => Colors.green[900]!,
    completed => Colors.teal[900]!,
    cancelled => Colors.red[900]!,
  };

  IconData get icon => switch (this) {
    draft => Icons.edit_note,
    pending => Icons.hourglass_top,
    approved => Icons.check_circle_outline,
    ongoing => Icons.directions_car,
    completed => Icons.done_all,
    cancelled => Icons.cancel,
  };
}
