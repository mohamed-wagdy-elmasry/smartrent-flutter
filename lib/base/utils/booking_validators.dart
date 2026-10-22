import '../../base/enums/enums.dart';
import '../../views/history/model/history_model.dart';
import '../../views/history_detail/model/booking_extension_model.dart';
import '../../views/history_detail/model/ledger_summary_model.dart';

class BookingValidators {
  const BookingValidators._();

  static bool canRequestExtension(
    History booking,
    List<BookingExtension> extensions,
  ) {
    final status = booking.status;
    if (!status.canExtend) return false;

    final hasPending =
        extensions.any((e) => e.status == ExtensionStatus.pending);
    if (hasPending) return false;

    return true;
  }

  static bool canCancelBooking(History booking) {
    return booking.status.canCancel;
  }

  static bool showPayButton(History booking, LedgerSummary ledger) {
    if (!booking.status.canAcceptPayment) return false;
    if (ledger.balance <= 0) return false;
    return true;
  }
}
