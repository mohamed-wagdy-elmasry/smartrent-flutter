import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:carbo/base/services/delivery_service.dart';

void main() {
  group('Delivery Check Tests', () {
    late DeliveryService deliveryService;

    setUpAll(() {
      // Initialize GetX service
      if (!Get.isRegistered<DeliveryService>()) {
        Get.put(DeliveryService());
      }
      deliveryService = Get.find<DeliveryService>();
    });

    test('Check delivery availability for Branch 3', () async {
      // Test coordinates (Riyadh, Saudi Arabia)
      const userLat = 24.7136;
      const userLng = 46.6753;

      print('\n🚗 Checking Branch 3 delivery...');
      print('📍 Location: Lat $userLat, Lng $userLng');

      final result = await deliveryService.checkDeliveryAvailability(
        branchId: 3,
        userLat: userLat,
        userLng: userLng,
      );

      expect(result, isNotNull);
      print('✓ Branch 3 Status: ${result?.status}');
      print('  Message: ${result?.message}');
      print('  Available: ${result?.isAvailable}');
      print('  Distance: ${result?.distanceKm?.toStringAsFixed(2)} km');
      print('  Delivery Fee: ${result?.deliveryFee} SAR');
      print('  Max Radius: ${result?.maxRadiusKm?.toStringAsFixed(2)} km');
      print('  Source: ${result?.deliverySource}');
    });

    test('Check delivery availability for Branch 4', () async {
      // Test coordinates (Riyadh, Saudi Arabia)
      const userLat = 24.7136;
      const userLng = 46.6753;

      print('\n🚗 Checking Branch 4 delivery...');
      print('📍 Location: Lat $userLat, Lng $userLng');

      final result = await deliveryService.checkDeliveryAvailability(
        branchId: 4,
        userLat: userLat,
        userLng: userLng,
      );

      expect(result, isNotNull);
      print('✓ Branch 4 Status: ${result?.status}');
      print('  Message: ${result?.message}');
      print('  Available: ${result?.isAvailable}');
      print('  Distance: ${result?.distanceKm?.toStringAsFixed(2)} km');
      print('  Delivery Fee: ${result?.deliveryFee} SAR');
      print('  Max Radius: ${result?.maxRadiusKm?.toStringAsFixed(2)} km');
      print('  Source: ${result?.deliverySource}');
    });

    test('Check delivery for multiple branches at once', () async {
      const userLat = 24.7136;
      const userLng = 46.6753;

      print('\n🚗 Checking both branches simultaneously...');

      final results = await deliveryService.checkMultipleBranches(
        branchIds: [3, 4],
        userLat: userLat,
        userLng: userLng,
      );

      expect(results, isNotEmpty);
      print('📊 Summary:');
      results.forEach((branchId, response) {
        print('Branch $branchId: ${response.isAvailable ? '✓ Available' : '✗ Unavailable'} - ${response.message}');
      });
    });
  });
}
