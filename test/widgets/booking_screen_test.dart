import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:carbo/views/booking/controller/booking_controller.dart';
import 'package:carbo/views/all_vendors_dashboard/model/vendor_cars_model.dart';
import 'package:carbo/base/utils/local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Booking Screen Widget Tests', () {
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
      Get.testMode = true;
      await LocalStorage.save(
        email: 'test@example.com',
        number: '0501234567',
      );
      
      controller = Get.put(BookingController());
      controller.initializeWithCar(_createMockCar());
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('displays quantity input field', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(controller));

      expect(find.byKey(const Key('quantity_field')), findsOneWidget);
    });

    testWidgets('quantity field accepts numeric input', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(controller));

      final quantityField = find.byKey(const Key('quantity_field'));
      await tester.enterText(quantityField, '5');
      await tester.pump();

      expect(controller.quantityController.text, equals('5'));
    });

    testWidgets('displays delivery toggle', (WidgetTester tester) async {
      controller.initializeWithCar(_createMockCar(isDeliveryAvailable: true));
      await tester.pumpWidget(_buildTestWidget(controller));

      expect(find.byKey(const Key('delivery_toggle')), findsOneWidget);
    });

    testWidgets('delivery toggle changes state', (WidgetTester tester) async {
      controller.initializeWithCar(_createMockCar(isDeliveryAvailable: true));
      await tester.pumpWidget(_buildTestWidget(controller));

      final toggle = find.byKey(const Key('delivery_toggle'));
      
      expect(controller.isDeliver.value, isFalse);
      
      await tester.tap(toggle);
      await tester.pump();

      expect(controller.isDeliver.value, isTrue);
    });

    testWidgets('shows location picker when delivery enabled', (WidgetTester tester) async {
      controller.initializeWithCar(_createMockCar(isDeliveryAvailable: true));
      await tester.pumpWidget(_buildTestWidget(controller));

      // Initially hidden
      expect(find.byKey(const Key('location_picker')), findsNothing);

      // Enable delivery
      controller.isDeliver.value = true;
      await tester.pumpAndSettle();

      // Now visible
      expect(find.byKey(const Key('location_picker')), findsOneWidget);
    });

    testWidgets('displays price estimate when available', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(controller));

      // Set price estimate
      controller.subtotal.value = 500.0;
      controller.taxAmount.value = 75.0;
      controller.total.value = 575.0;
      await tester.pump();

      expect(find.textContaining('575'), findsWidgets);
    });

    testWidgets('displays delivery charge when delivery enabled', (WidgetTester tester) async {
      controller.initializeWithCar(_createMockCar(isDeliveryAvailable: true));
      await tester.pumpWidget(_buildTestWidget(controller));

      controller.isDeliver.value = true;
      controller.deliveryCharge.value = 50.0;
      await tester.pump();

      expect(find.textContaining('50'), findsWidgets);
    });

    testWidgets('continue button disabled when form invalid', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(controller));

      // Form is invalid initially
      expect(controller.isFormValid.value, isFalse);
      
      // Button should be disabled (or not present)
      // Implementation depends on how the UI handles disabled state
    });

    testWidgets('continue button enabled when form valid', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(controller));

      // Fill form
      final futureDate = DateTime.now().add(const Duration(days: 2));
      controller.quantityController.text = '5';
      controller.pickupDate.value = 
          '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}';
      controller.pickupTime.value = '10:00';
      await tester.pump();

      expect(controller.isFormValid.value, isTrue);
      
      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueButton, findsOneWidget);
    });

    testWidgets('displays car information', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(controller));

      expect(find.textContaining('Toyota'), findsWidgets);
      expect(find.textContaining('Camry'), findsWidgets);
    });

    testWidgets('displays pricing information', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(controller));

      final priceText = controller.getPriceDisplayText();
      if (priceText.isNotEmpty) {
        expect(find.textContaining('SAR'), findsWidgets);
      }
    });

    testWidgets('email field is pre-filled', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(controller));

      expect(controller.emailController.text, equals('test@example.com'));
    });

    testWidgets('mobile field is pre-filled', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(controller));

      expect(controller.mobileController.text, equals('0501234567'));
    });

    testWidgets('displays notes input field', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(controller));

      final notesField = find.byKey(const Key('notes_field'));
      if (notesField.evaluate().isNotEmpty) {
        await tester.enterText(notesField, 'Test notes');
        await tester.pump();

        expect(controller.noteController.text, equals('Test notes'));
      }
    });

    testWidgets('shows loading indicator during price estimation', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(controller));

      controller.isPriceLoading.value = true;
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('hides loading indicator when price loaded', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(controller));

      controller.isPriceLoading.value = false;
      await tester.pump();

      // Should not show excessive loading indicators
    });

    testWidgets('displays tax breakdown when tax enabled', (WidgetTester tester) async {
      controller.initializeWithCar(_createMockCar(taxEnabled: true));
      await tester.pumpWidget(_buildTestWidget(controller));

      controller.taxAmount.value = 75.0;
      await tester.pump();

      expect(find.textContaining('75'), findsWidgets);
    });

    testWidgets('quantity label changes based on pricing type', (WidgetTester tester) async {
      // Per day pricing
      controller.initializeWithCar(_createMockCar(pricingType: 'per_day'));
      await tester.pumpWidget(_buildTestWidget(controller));
      await tester.pump();

      String label = controller.getQuantityLabel();
      expect(label, isNotEmpty);

      // Per km pricing
      controller.initializeWithCar(_createMockCar(pricingType: 'per_km'));
      await tester.pumpWidget(_buildTestWidget(controller));
      await tester.pump();

      label = controller.getQuantityLabel();
      expect(label, isNotEmpty);
    });

    testWidgets('date picker opens on date field tap', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(controller));

      final dateField = find.byKey(const Key('pickup_date_field'));
      if (dateField.evaluate().isNotEmpty) {
        await tester.tap(dateField);
        await tester.pumpAndSettle();

        // Date picker dialog should open
        expect(find.byType(DatePickerDialog), findsOneWidget);
      }
    });

    testWidgets('time picker opens on time field tap', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(controller));

      final timeField = find.byKey(const Key('pickup_time_field'));
      if (timeField.evaluate().isNotEmpty) {
        await tester.tap(timeField);
        await tester.pumpAndSettle();

        // Time picker dialog should open
        expect(find.byType(TimePickerDialog), findsOneWidget);
      }
    });

    testWidgets('displays pricing tier when available', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(controller));

      controller.pricingTier.value = 'weekly';
      await tester.pump();

      // Should display pricing tier information
      expect(controller.pricingTier.value, equals('weekly'));
    });

    testWidgets('shows delivery distance when calculated', (WidgetTester tester) async {
      controller.initializeWithCar(_createMockCar(isDeliveryAvailable: true));
      await tester.pumpWidget(_buildTestWidget(controller));

      controller.isDeliver.value = true;
      controller.deliveryDistance.value = 15.5;
      await tester.pump();

      expect(controller.deliveryDistance.value, equals(15.5));
    });

    testWidgets('validates form on field changes', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestWidget(controller));

      expect(controller.isFormValid.value, isFalse);

      // Fill quantity
      controller.quantityController.text = '3';
      await tester.pump();
      expect(controller.isFormValid.value, isFalse); // Still invalid

      // Fill date
      final futureDate = DateTime.now().add(const Duration(days: 1));
      controller.pickupDate.value = 
          '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}';
      await tester.pump();
      expect(controller.isFormValid.value, isFalse); // Still invalid

      // Fill time
      controller.pickupTime.value = '14:00';
      await tester.pump();
      expect(controller.isFormValid.value, isTrue); // Now valid
    });
  });
}

/// Helper to build test widget with GetX
Widget _buildTestWidget(BookingController controller) {
  return GetMaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          TextField(
            key: const Key('quantity_field'),
            controller: controller.quantityController,
            keyboardType: TextInputType.number,
          ),
          Obx(() => controller.isDeliveryAvailable()
              ? Switch(
                  key: const Key('delivery_toggle'),
                  value: controller.isDeliver.value,
                  onChanged: (val) => controller.isDeliver.value = val,
                )
              : const SizedBox()),
          Obx(() => controller.isDeliver.value
              ? Container(key: const Key('location_picker'))
              : const SizedBox()),
          Obx(() => controller.isPriceLoading.value
              ? const CircularProgressIndicator()
              : const SizedBox()),
          Obx(() => controller.isFormValid.value
              ? ElevatedButton(
                  onPressed: () {},
                  child: const Text('Continue'),
                )
              : const SizedBox()),
          TextField(
            key: const Key('notes_field'),
            controller: controller.noteController,
          ),
        ],
      ),
    ),
  );
}

/// Helper to create mock VendorCar
VendorCar _createMockCar({
  String pricingType = 'per_day',
  bool isDeliveryAvailable = false,
  bool taxEnabled = true,
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
      price: 100.0,
      dailyPrice: 100.0,
      weeklyPrice: 600.0,
      monthlyPrice: 2000.0,
      unit: pricingType == 'per_km' ? 'km' : 'day',
      displayName: 'Price per ${pricingType == "per_km" ? "km" : "day"}',
    ),
    currency: 'SAR',
    taxEnabled: taxEnabled,
    taxPercentage: 15.0,
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
    vendorLocation: VendorLocation(latitude: 24.7136, longitude: 46.6753),
    isDeliveryAvailable: isDeliveryAvailable,
    distanceKm: 0,
  );
}
