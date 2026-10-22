import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/basic_import.dart';
import '../endpoint/api_endpoint.dart';
import '../../utils/local_storage.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/logger.dart';

class CarBookingTestService {
  static final log = logger(CarBookingTestService);

  /// Test booking confirmation without payment
  ///
  /// This method confirms a car booking WITHOUT processing any payment.
  /// Useful for testing and development workflows.
  ///
  /// Parameters:
  ///   - searchToken: The 20-character booking token from car search
  ///   - carId: The ID of the selected car
  ///   - carSlug: The slug/identifier of the car
  ///   - mobile: Customer mobile number
  ///   - fees: Total booking amount
  ///   - credentials: (Optional) Customer email
  ///   - location: (Optional) Pickup location
  ///   - isDeliver: (Optional) Whether delivery is needed
  ///   - destination: (Optional) Delivery destination
  ///   - distance: (Optional) Delivery distance in km
  ///   - rentalDays: (Optional) Number of rental days
  ///   - message: (Optional) Special instructions
  static Future<Map<String, dynamic>?> testConfirmBooking({
    required String searchToken,
    required int carId,
    required String carSlug,
    required String mobile,
    required double fees,
    String? credentials,
    String? location,
    bool? isDeliver,
    String? destination,
    double? distance,
    int? rentalDays,
    String? message,
    String? pickupDate,
    String? pickupTime,
    double? pickupLat,
    double? pickupLng,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/user/car-booking/test-confirm',
      );

      final body = {
        'token': searchToken,
        'car_id': carId,
        'car_slug': carSlug,
        'mobile': mobile,
        'fees': fees,
        if (credentials != null) 'credentials': credentials,
        if (location != null) 'location': location,
        if (isDeliver != null) 'is_deliver': isDeliver,
        if (destination != null) 'destination': destination,
        if (distance != null) 'distance': distance,
        if (rentalDays != null) 'rental_days': rentalDays,
        if (message != null) 'message': message,
        if (pickupDate != null) 'pickup_date': pickupDate,
        if (pickupTime != null) 'pickup_time': pickupTime,
        if (pickupLat != null) 'pickup_lat': pickupLat,
        if (pickupLng != null) 'pickup_lng': pickupLng,
      };

      log.i('Test Confirm Booking Request:');
      log.i('URL: $url');
      log.i('Body: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${LocalStorage.token}',
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Test booking timeout');
        },
      );

      log.i('Response Status: ${response.statusCode}');
      log.i('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Check if response type is success
        if (data['type'] == 'success') {
          log.i('✅ Test booking confirmed successfully!');
          
          // Extract success message from response
          String message = 'Booking confirmed without payment!';
          if (data['message'] is Map && data['message']['success'] is List) {
            final successList = data['message']['success'] as List;
            if (successList.isNotEmpty) {
              message = successList[0].toString();
            }
          }
          
          CustomSnackBar.success(
            title: 'Success',
            message: message,
          );
          return data;
        } else {
          // Extract error message from response
          String errorMsg = 'Failed to confirm booking';
          if (data['message'] is Map && data['message']['error'] is List) {
            final errorList = data['message']['error'] as List;
            if (errorList.isNotEmpty) {
              errorMsg = errorList[0].toString();
            }
          } else if (data['message'] is String) {
            errorMsg = data['message'];
          }
          
          log.e('Test Booking Error: $errorMsg');
          CustomSnackBar.error(errorMsg);
          return null;
        }
      } else if (response.statusCode == 401) {
        log.e('Unauthorized - JWT token invalid or expired');
        CustomSnackBar.error('Session expired. Please login again.');
        return null;
      } else if (response.statusCode == 404) {
        log.e('Not Found - Car or booking token not found');
        CustomSnackBar.error('Car or booking not found. Please search again.');
        return null;
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        String errorMsg = 'Validation failed';
        if (data['message'] is Map && data['message']['error'] is List) {
          final errorList = data['message']['error'] as List;
          errorMsg = errorList.map((e) => e.toString()).join(', ');
        } else if (data['message'] is List) {
          errorMsg = (data['message'] as List).map((e) => e.toString()).join(', ');
        } else if (data['message'] is String) {
          errorMsg = data['message'];
        }
        
        log.e('Validation Error: $errorMsg');
        CustomSnackBar.error(errorMsg);
        return null;
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        String errorMsg = 'Failed to confirm test booking';
        if (data['message'] is Map && data['message']['error'] is List) {
          final errorList = data['message']['error'] as List;
          errorMsg = errorList.map((e) => e.toString()).join(', ');
        } else if (data['message'] is List) {
          errorMsg = (data['message'] as List).map((e) => e.toString()).join(', ');
        } else if (data['message'] is String) {
          errorMsg = data['message'];
        }
        
        log.e('Error: $errorMsg');
        CustomSnackBar.error(errorMsg);
        return null;
      }
    } on TimeoutException catch (e) {
      log.e('Timeout: ${e.message}');
      CustomSnackBar.error('Request timeout - check your connection');
      return null;
    } catch (e) {
      log.e('Exception in testConfirmBooking: $e');
      CustomSnackBar.error('Error confirming booking: $e');
      return null;
    }
  }

  /// Complete test flow: Search -> Confirm (without payment)
  static Future<Map<String, dynamic>?> testCompleteBookingFlow({
    required int carType,
    required int carModel,
    required String pickupDate,
    required String pickupTime,
    required int rentalDays,
    required String mobile,
    String? email,
  }) async {
    try {
      // Step 1: Search for cars
      log.i('🔍 Step 1: Searching for cars...');

      final searchUrl = Uri.parse(
        '${ApiConfig.baseUrl}/user/car-booking/search/car',
      );

      final searchResponse = await http.post(
        searchUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${LocalStorage.token}',
        },
        body: jsonEncode({
          'car_type': carType,
          'car_model': carModel,
          'pickup_date': pickupDate,
          'pickup_time': pickupTime,
        }),
      ).timeout(const Duration(seconds: 30));

      if (searchResponse.statusCode != 200) {
        log.e('Search failed: ${searchResponse.body}');
        CustomSnackBar.error('Car search failed. Please try again.');
        return null;
      }

      final searchData = jsonDecode(searchResponse.body);
      final cars = searchData['data']?['cars'] as List?;
      final searchToken = searchData['data']?['token'] as String?;

      if (cars == null || cars.isEmpty || searchToken == null) {
        log.e('No cars found or no token in response');
        CustomSnackBar.error('No cars available for selected dates');
        return null;
      }

      log.i('✅ Found ${cars.length} car(s)');

      // Step 2: Confirm with first car
      final selectedCar = cars[0] as Map;
      final carId = selectedCar['id'] as int;
      final carSlug = selectedCar['slug'] as String;
      final pricePerDay = (selectedCar['price_per_day'] as num).toDouble();
      final totalFees = pricePerDay * rentalDays;

      log.i('✅ Step 2: Confirming test booking...');
      log.i('   Car: ${selectedCar['name']} (ID: $carId)');
      log.i('   Total Fees: $totalFees for $rentalDays days');

      final result = await testConfirmBooking(
        searchToken: searchToken,
        carId: carId,
        carSlug: carSlug,
        mobile: mobile,
        fees: totalFees,
        credentials: email,
        rentalDays: rentalDays,
        message: 'Test booking without payment',
      );

      if (result != null) {
        log.i('✅ Test booking flow completed successfully!');
        CustomSnackBar.success(
          title: 'Success',
          message: '✅ Test booking completed (no payment)',
        );
      }

      return result;
    } catch (e) {
      log.e('Error in testCompleteBookingFlow: $e');
      CustomSnackBar.error('Error in booking flow: $e');
      return null;
    }
  }
}
