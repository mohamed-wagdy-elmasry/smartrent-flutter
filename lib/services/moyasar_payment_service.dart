import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base/api/endpoint/api_endpoint.dart';
import '../views/history/model/history_model.dart';

class MoyasarPaymentService {
  final String baseUrl;
  final String userToken;

  MoyasarPaymentService({
    required this.baseUrl,
    required this.userToken,
  });

  /// Process car booking payment with Moyasar
  Future<PaymentResponse> processCarBookingPayment({
    required String bookingToken,
    required String moyasarCardToken,
    required int carId,
    required String carSlug,
    required double fees,
    required String email,
    required String mobile,
    required int rentalDays,
    required String location,
    required int isDeliver,
    required double pickupLat,
    required double pickupLng,
    String? destination,
    double? distance,
    String? message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/user/car-booking/confirm'),
        headers: {
          'Authorization': 'Bearer $userToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'car_id': carId,
          'car_slug': carSlug,
          'token': bookingToken,
          'payment': 'moyasar',
          'source_id': moyasarCardToken,
          'transaction_id': moyasarCardToken,
          'fees': fees,
          'credentials': email,
          'mobile': mobile,
          'rental_days': rentalDays,
          'location': location,
          'is_deliver': isDeliver,
          'pickup_lat': pickupLat,
          'pickup_lng': pickupLng,
          'destination': destination,
          'distance': distance,
          'message': message,
        }),
      );

      final data = jsonDecode(response.body);

      // Check if 3DS is required even if status is false
      bool requiresAuth = false;
      if (data['data'] != null && data['data'] is Map) {
        requiresAuth = data['data']['requires_authentication'] == true;
      }

      if ((response.statusCode == 200 || response.statusCode == 400 || response.statusCode == 422) && 
          (data['status'] == true || requiresAuth)) {
        return PaymentResponse.fromJson(data);
      } else {
        String errorMessage = 'Payment failed';
        final msg = data['message'];
        
        if (msg is String) {
          errorMessage = msg;
        } else if (msg is List) {
          errorMessage = msg.join(', ');
        } else if (msg is Map) {
          errorMessage = msg.values.map((v) {
            if (v is List) return v.join(' ');
            return v.toString();
          }).join(', ');
        }

        throw PaymentException(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on PaymentException {
      rethrow;
    } catch (e) {
      throw PaymentException(
        message: 'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Poll booking status after 3D Secure completion
  Future<BookingDetails?> checkBookingStatus(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoint.history.path}'),
        headers: {
          'Authorization': 'Bearer $userToken',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['data'] != null) {
        final historyModel = HistoryModel.fromJson(data);
        
        // Find booking with matching transaction ID
        final booking = historyModel.data.history.firstWhereOrNull(
          (element) => element.trxId == transactionId,
        );

        if (booking != null) {
          return BookingDetails(
            id: booking.id ?? 0,
            bookingNumber: booking.slug ?? '',
            carId: booking.carId ?? 0,
            userId: booking.userId ?? 0,
            status: booking.status.toString(),
            totalAmount: double.tryParse(booking.amount.toString()) ?? 0.0,
            paymentStatus: booking.paymentType,
            pickupDate: booking.pickupDate.toString(),
            pickupTime: booking.pickupTime,
            rentalDays: booking.rentalDays,
          );
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}

extension ListExtension<E> on List<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class PaymentResponse {
  final bool requiresAuthentication;
  final String? paymentUrl;
  final String? transactionId;
  final String? bookingToken;
  final String status;
  final String? message;
  final BookingDetails? booking;

  PaymentResponse({
    required this.requiresAuthentication,
    this.paymentUrl,
    this.transactionId,
    this.bookingToken,
    required this.status,
    this.message,
    this.booking,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return PaymentResponse(
      requiresAuthentication: data['requires_authentication'] ?? false,
      paymentUrl: data['payment_url'],
      transactionId: data['transaction_id'],
      bookingToken: data['booking_token'],
      status: data['status'] ?? 'pending',
      message: json['message'] as String?,
      booking: data['booking'] != null 
          ? BookingDetails.fromJson(data['booking']) 
          : null,
    );
  }
}

class BookingDetails {
  final int id;
  final String bookingNumber;
  final int carId;
  final int userId;
  final String status;
  final double totalAmount;
  final String paymentStatus;
  final String pickupDate;
  final String pickupTime;
  final int rentalDays;

  BookingDetails({
    required this.id,
    required this.bookingNumber,
    required this.carId,
    required this.userId,
    required this.status,
    required this.totalAmount,
    required this.paymentStatus,
    required this.pickupDate,
    required this.pickupTime,
    required this.rentalDays,
  });

  factory BookingDetails.fromJson(Map<String, dynamic> json) {
    return BookingDetails(
      id: json['id'],
      bookingNumber: json['booking_number'],
      carId: json['car_id'],
      userId: json['user_id'],
      status: json['status'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentStatus: json['payment_status'],
      pickupDate: json['pickup_date'],
      pickupTime: json['pickup_time'],
      rentalDays: json['rental_days'],
    );
  }
}

class PaymentException implements Exception {
  final String message;
  final int statusCode;

  PaymentException({required this.message, required this.statusCode});

  @override
  String toString() => message;
}
