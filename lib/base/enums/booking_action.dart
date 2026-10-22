import 'booking_status.dart';

enum BookingAction { submit, cancel, extend, edit, pay }

class BookingActionGuard {
  const BookingActionGuard._();

  static bool canPerform(BookingAction action, BookingStatus status) {
    return switch (action) {
      BookingAction.submit => status == BookingStatus.draft,
      BookingAction.cancel => status.canCancel,
      BookingAction.extend => status.canExtend,
      BookingAction.edit => status.isEditable,
      BookingAction.pay => status.canAcceptPayment,
    };
  }
}
