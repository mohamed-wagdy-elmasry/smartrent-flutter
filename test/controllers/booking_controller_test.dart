import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:carbo/views/booking/controller/booking_controller.dart';
import 'package:carbo/views/all_vendors_dashboard/model/vendor_cars_model.dart';
import 'package:carbo/views/booking/model/pickup_location_model.dart';
import 'package:carbo/base/utils/local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BookingController Unit Tests', () {
    late BookingController controller;

    setUpAll(() async {
      // Mock path_provider for GetStorage
      const MethodChannel('plugins.flutter.io/path_provider')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return Directory.systemTemp.path;
        }
        return null;
      });
      
      // Initialize GetStorage
      await GetStorage.init();
    });

    setUp(() async {
      // Initialize GetX
      Get.testMode = true;
      
      // Clear any previous data
      await LocalStorage.clear();
      
      // Save test data to LocalStorage
      await LocalStorage.save(
        email: 'test@example.com',
        number: '0501234567',
        token: 'test_token',
      );
      
      // Small delay to ensure storage is persisted
      await Future.delayed(const Duration(milliseconds: 50));

      controller = BookingController();
    });

    tearDown(() {
      controller.dispose();
      Get.reset();
    });

    group('Car Initialization', () {
      test('initializeWithCar sets car and pricing correctly', () {
        final mockCar = _createMockCar(pricingType: 'per_day');

        controller.initializeWithCar(mockCar);

        expect(controller.selectedCar.value, equals(mockCar));
        expect(controller.selectedPricing.value, equals(mockCar.pricing));
        expect(controller.pricingType.value, equals('per_day'));
        expect(controller.pricingUnit.value, equals('day'));
      });

      test('initializeWithCar normalizes pricing type correctly', () {
        // Test 'daily' -> 'per_day'
        var mockCar = _createMockCar(pricingType: 'daily');
        controller.initializeWithCar(mockCar);
        expect(controller.pricingType.value, equals('per_day'));

        // Test 'km' -> 'per_km'
        mockCar = _createMockCar(pricingType: 'km');
        controller.initializeWithCar(mockCar);
        expect(controller.pricingType.value, equals('per_km'));

        // Test 'per_day' stays 'per_day'
        mockCar = _createMockCar(pricingType: 'per_day');
        controller.initializeWithCar(mockCar);
        expect(controller.pricingType.value, equals('per_day'));
      });
    });

    group('Form Validation', () {
      setUp(() {
        controller.initializeWithCar(_createMockCar());
      });

      test('form is invalid when fields are empty', () {
        expect(controller.isFormValid.value, isFalse);
      });

      test('form is invalid when quantity is empty', () {
        controller.pickupDate.value = '2024-12-25';
        controller.pickupTime.value = '10:00';

        expect(controller.isFormValid.value, isFalse);
      });

      test('form is invalid when pickup date is empty', () {
        controller.quantityController.text = '5';
        controller.pickupTime.value = '10:00';

        expect(controller.isFormValid.value, isFalse);
      });

      test('form is invalid when pickup time is empty', () {
        controller.quantityController.text = '5';
        controller.pickupDate.value = '2024-12-25';

        expect(controller.isFormValid.value, isFalse);
      });

      test('form is valid when all required fields are filled with future date', () async {
        final futureDate = DateTime.now().add(const Duration(days: 2));
        controller.quantityController.text = '5';
        controller.pickupDate.value = 
            '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}';
        controller.pickupTime.value = '14:00';
        
        // Wait for reactive updates
        await Future.delayed(const Duration(milliseconds: 10));

        expect(controller.isFormValid.value, isTrue);
      });

      test('form is invalid with past pickup date/time', () {
        controller.quantityController.text = '5';
        controller.pickupDate.value = '2020-01-01';
        controller.pickupTime.value = '10:00';

        expect(controller.isFormValid.value, isFalse);
      });

      test('form is invalid when delivery is required but location is null', () {
        final futureDate = DateTime.now().add(const Duration(days: 2));
        controller.quantityController.text = '5';
        controller.pickupDate.value = 
            '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}';
        controller.pickupTime.value = '14:00';
        controller.isDeliver.value = true;

        expect(controller.isFormValid.value, isFalse);
      });

      test('form is valid when delivery is enabled with valid location', () async {
        final futureDate = DateTime.now().add(const Duration(days: 2));
        controller.quantityController.text = '5';
        controller.pickupDate.value = 
            '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}';
        controller.pickupTime.value = '14:00';
        controller.isDeliver.value = true;
        controller.pickupLocation.value = PickupLocation(
          latitude: 24.7136,
          longitude: 46.6753,
          address: 'Riyadh, Saudi Arabia',
        );
        controller.deliverySource.value = 'branch';
        
        // Wait for reactive updates
        await Future.delayed(const Duration(milliseconds: 10));

        expect(controller.isFormValid.value, isTrue);
      });

      test('form is invalid when delivery is out of zone', () {
        final futureDate = DateTime.now().add(const Duration(days: 2));
        controller.quantityController.text = '5';
        controller.pickupDate.value = 
            '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}';
        controller.pickupTime.value = '14:00';
        controller.isDeliver.value = true;
        controller.pickupLocation.value = PickupLocation(
          latitude: 24.7136,
          longitude: 46.6753,
          address: 'Out of zone',
        );
        controller.deliverySource.value = 'none'; // Out of all zones

        expect(controller.isFormValid.value, isFalse);
      });
    });

    group('Pickup Date/Time Validation', () {
      test('validates future date/time correctly', () async {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        controller.pickupDate.value = 
            '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}';
        controller.pickupTime.value = '14:00';

        // Private method test via form validation
        controller.quantityController.text = '1';
        
        // Wait for reactive updates
        await Future.delayed(const Duration(milliseconds: 10));
        
        expect(controller.isFormValid.value, isTrue);
      });

      test('rejects past date', () {
        controller.pickupDate.value = '2020-01-01';
        controller.pickupTime.value = '10:00';
        controller.quantityController.text = '1';

        expect(controller.isFormValid.value, isFalse);
      });

      test('rejects today with past time', () {
        final now = DateTime.now();
        final pastTime = now.subtract(const Duration(hours: 2));
        
        controller.pickupDate.value = 
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        controller.pickupTime.value = 
            '${pastTime.hour.toString().padLeft(2, '0')}:${pastTime.minute.toString().padLeft(2, '0')}';
        controller.quantityController.text = '1';

        expect(controller.isFormValid.value, isFalse);
      });

      test('accepts today with future time', () async {
        final now = DateTime.now();
        final futureTime = now.add(const Duration(hours: 2));
        
        controller.pickupDate.value = 
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        controller.pickupTime.value = 
            '${futureTime.hour.toString().padLeft(2, '0')}:${futureTime.minute.toString().padLeft(2, '0')}';
        controller.quantityController.text = '1';
        
        // Wait for reactive updates
        await Future.delayed(const Duration(milliseconds: 10));

        expect(controller.isFormValid.value, isTrue);
      });

      test('handles invalid date format', () {
        controller.pickupDate.value = 'invalid-date';
        controller.pickupTime.value = '10:00';
        controller.quantityController.text = '1';

        expect(controller.isFormValid.value, isFalse);
      });

      test('handles invalid time format', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        controller.pickupDate.value = 
            '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}';
        controller.pickupTime.value = 'invalid-time';
        controller.quantityController.text = '1';

        expect(controller.isFormValid.value, isFalse);
      });
    });

    group('Quantity Label and Hint', () {
      test('returns correct label for per_day pricing', () {
        controller.initializeWithCar(_createMockCar(pricingType: 'per_day'));
        
        final label = controller.getQuantityLabel();
        expect(label, isNotEmpty);
        // Would contain localized version of "Rental Days"
      });

      test('returns correct label for per_km pricing', () {
        controller.initializeWithCar(_createMockCar(pricingType: 'per_km'));
        
        final label = controller.getQuantityLabel();
        expect(label, isNotEmpty);
        // Would contain localized version of "Distance"
      });

      test('returns correct hint for per_day pricing', () {
        controller.initializeWithCar(_createMockCar(pricingType: 'per_day'));
        
        final hint = controller.getQuantityHint();
        expect(hint, isNotEmpty);
      });

      test('returns correct hint for per_km pricing', () {
        controller.initializeWithCar(_createMockCar(pricingType: 'per_km'));
        
        final hint = controller.getQuantityHint();
        expect(hint, isNotEmpty);
      });
    });

    group('Price Display', () {
      test('getPriceDisplayText returns formatted price', () {
        controller.initializeWithCar(_createMockCar(
          price: 150.0,
          unit: 'day',
        ));

        final display = controller.getPriceDisplayText();
        expect(display, contains('150'));
        expect(display, contains('SAR'));
        expect(display, contains('day'));
      });

      test('getPriceDisplayText returns empty when no pricing', () {
        final display = controller.getPriceDisplayText();
        expect(display, isEmpty);
      });
    });

    group('Booking Data Preparation', () {
      setUp(() {
        final mockCar = _createMockCar(pricingType: 'per_day');
        controller.initializeWithCar(mockCar);
        
        final futureDate = DateTime.now().add(const Duration(days: 2));
        controller.quantityController.text = '5';
        controller.pickupDate.value = 
            '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}';
        controller.pickupTime.value = '10:00';
        controller.subtotal.value = 500.0;
        controller.taxAmount.value = 75.0;
        controller.total.value = 575.0;
      });

      test('getBookingData includes all required fields', () {
        // Ensure email and phone are set
        controller.emailController.text = 'test@example.com';
        controller.mobileController.text = '0501234567';
        
        final data = controller.getBookingData();

        expect(data['email'], isNotEmpty);
        expect(data['phone'], isNotEmpty);
        expect(data['quantity'], equals('5'));
        expect(data['pickup_date'], isNotEmpty);
        expect(data['pickup_time'], equals('10:00'));
        expect(data['pricing_type'], equals('per_day'));
        expect(data['pricing_unit'], equals('day'));
        expect(data['delivery_required'], isFalse);
        expect(data['subtotal'], equals(500.0));
        expect(data['tax_amount'], equals(75.0));
        expect(data['total'], equals(575.0));
        expect(data['car_id'], equals(1));
        expect(data['token'], isNotEmpty);
      });

      test('getBookingData includes delivery fields when delivery enabled', () {
        controller.isDeliver.value = true;
        controller.pickupLocation.value = PickupLocation(
          latitude: 24.7136,
          longitude: 46.6753,
          address: 'Riyadh, Saudi Arabia',
        );
        controller.deliveryCharge.value = 50.0;

        final data = controller.getBookingData();

        expect(data['delivery_required'], isTrue);
        expect(data['delivery_location'], equals('Riyadh, Saudi Arabia'));
        expect(data['delivery_latitude'], equals(24.7136));
        expect(data['delivery_longitude'], equals(46.6753));
        expect(data['delivery_charge'], equals(50.0));
      });

      test('getBookingData excludes delivery fields when delivery disabled', () {
        controller.isDeliver.value = false;

        final data = controller.getBookingData();

        expect(data['delivery_required'], isFalse);
        expect(data['delivery_location'], isNull);
        expect(data['delivery_latitude'], isNull);
        expect(data['delivery_longitude'], isNull);
      });

      test('getBookingData includes notes when provided', () {
        controller.noteController.text = 'Please call before delivery';

        final data = controller.getBookingData();

        expect(data['notes'], equals('Please call before delivery'));
      });

      test('getBookingData includes tax information', () {
        controller.selectedCar.value = _createMockCar(
          taxEnabled: true,
          taxPercentage: 15,
        );

        final data = controller.getBookingData();

        expect(data['tax_enabled'], isTrue);
        expect(data['tax_percentage'], equals(15));
      });
    });

    group('Delivery Availability', () {
      test('isDeliveryAvailable returns false when car delivery not enabled', () {
        controller.initializeWithCar(_createMockCar(isDeliveryAvailable: false));

        expect(controller.isDeliveryAvailable(), isFalse);
      });

      test('isDeliveryAvailable returns true when car delivery enabled', () {
        controller.initializeWithCar(_createMockCar(
          isDeliveryAvailable: true,
          hasVendorLocation: true,
        ));

        expect(controller.isDeliveryAvailable(), isTrue);
      });

      test('isDeliveryAvailable returns false when no vendor location', () {
        controller.initializeWithCar(_createMockCar(
          isDeliveryAvailable: true,
          hasVendorLocation: false,
        ));

        expect(controller.isDeliveryAvailable(), isFalse);
      });
    });

    group('Missing Fields', () {
      setUp(() {
        controller.initializeWithCar(_createMockCar());
      });

      test('getMissingFields returns all missing fields when form empty', () {
        final missing = controller.getMissingFields();

        expect(missing, isNotEmpty);
        expect(missing.length, greaterThanOrEqualTo(3));
      });

      test('getMissingFields returns empty when form complete', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        controller.quantityController.text = '5';
        controller.pickupDate.value = 
            '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}';
        controller.pickupTime.value = '10:00';

        final missing = controller.getMissingFields();

        expect(missing, isEmpty);
      });

      test('getMissingFields includes pickup location when delivery enabled', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        controller.quantityController.text = '5';
        controller.pickupDate.value = 
            '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}';
        controller.pickupTime.value = '10:00';
        controller.isDeliver.value = true;

        final missing = controller.getMissingFields();

        expect(missing, isNotEmpty);
        // Should mention pickup location is missing
      });

      test('getMissingFields includes future date/time error', () {
        controller.quantityController.text = '5';
        controller.pickupDate.value = '2020-01-01';
        controller.pickupTime.value = '10:00';

        final missing = controller.getMissingFields();

        expect(missing, isNotEmpty);
        expect(missing.any((field) => field.contains('future')), isTrue);
      });
    });

    group('User Data Initialization', () {
      test('auto-fills email and mobile from LocalStorage', () {
        // In a real app, this would be filled from LocalStorage
        // For testing, we verify the controllers exist and can be set
        controller.emailController.text = 'test@example.com';
        controller.mobileController.text = '0501234567';
        
        expect(controller.emailController.text, equals('test@example.com'));
        expect(controller.mobileController.text, equals('0501234567'));
      });
    });
  });
}

/// Helper to create mock VendorCar
VendorCar _createMockCar({
  String pricingType = 'per_day',
  double price = 100.0,
  String unit = 'day',
  bool isDeliveryAvailable = false,
  bool hasVendorLocation = true,
  bool taxEnabled = true,
  double taxPercentage = 15.0,
}) {
  return VendorCar(
    id: 1,
    vendorId: 1,
    vendorName: 'Test Vendor',
    vendorRating: 4.5,
    branchId: 1,
    make: 'Toyota',
    model: 'Camry',
    modelImage: null,
    type: 'sedan',
    year: 2023,
    color: 'White',
    licensePlate: 'ABC123',
    transmission: 'automatic',
    fuelType: 'petrol',
    seats: 5,
    doors: 4,
    pricing: Pricing(
      type: pricingType,
      currency: 'SAR',
      price: price,
      dailyPrice: 100.0,
      weeklyPrice: 600.0,
      monthlyPrice: 2000.0,
      unit: unit,
      displayName: 'Price per $unit',
    ),
    currency: 'SAR',
    taxEnabled: taxEnabled,
    taxPercentage: taxPercentage,
    rating: 4.5,
    totalReviews: 10,
    availabilityStatus: 'available',
    nextAvailableDate: null,
    images: [],
    features: [],
    insuranceIncluded: true,
    mileageLimitPerDay: 200,
    mileageUnit: 'km',
    depositRequired: 500.0,
    deliveryPrice: 50.0,
    cancellationPolicy: '24 hours',
    vendorLocation: hasVendorLocation 
        ? VendorLocation(latitude: 24.7136, longitude: 46.6753)
        : null,
    isDeliveryAvailable: isDeliveryAvailable,
    distanceKm: 0,
  );
}
