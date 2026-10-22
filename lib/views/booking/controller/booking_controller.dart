import 'dart:async';
import 'package:carbo/base/utils/local_storage.dart';
import 'package:carbo/views/all_vendors_dashboard/model/vendor_cars_model.dart';
import 'package:carbo/views/all_vendors_dashboard/controller/all_vendors_dashboard_controller.dart';
import 'package:carbo/views/vendor_cars/controller/vendor_cars_controller.dart';
import 'package:carbo/views/dashboard/controller/dashboard_controller.dart';
import 'package:carbo/languages/strings.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import 'package:carbo/views/booking/model/pickup_location_model.dart';
import 'package:carbo/views/booking/model/price_estimate_model.dart';
import 'package:carbo/base/api/endpoint/api_endpoint.dart';
import 'package:carbo/base/api/method/request_process.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingController extends GetxController {
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final emailController = TextEditingController();
  final locationController = TextEditingController();
  final noteController = TextEditingController();
  final mobileController = TextEditingController();
  final quantityController = TextEditingController(); // Days or Distance
  
  // Pickup date and time observables
  RxString pickupDate = ''.obs;
  RxString pickupTime = ''.obs;
  
  // Pickup location with lat/long
  Rxn<PickupLocation> pickupLocation = Rxn<PickupLocation>();
  RxDouble pickupLatitude = 0.0.obs;
  RxDouble pickupLongitude = 0.0.obs;
  
  RxBool isFormValid = false.obs;
  RxBool isDeliver = false.obs;
  
  // Pricing and car data
  Rxn<VendorCar> selectedCar = Rxn<VendorCar>();
  Rxn<Pricing> selectedPricing = Rxn<Pricing>();
  RxString pricingType = ''.obs; // 'per_day' or 'per_km'
  RxString pricingUnit = ''.obs; // 'day', 'km', etc.
  RxDouble deliveryCharge = 0.0.obs;
  Rxn<double> deliveryDistance = Rxn<double>();
  Rxn<String> deliverySource = Rxn<String>();
  RxDouble subtotal = 0.0.obs;
  RxDouble taxAmount = 0.0.obs;
  RxDouble total = 0.0.obs;
  RxDouble effectivePrice = 0.0.obs;
  RxBool isPriceLoading = false.obs;
  RxString pricingTier = ''.obs;
  
  // Insurance selection and amounts
  Rxn<String> selectedInsuranceType = Rxn<String>(); // 'daily' or 'excess_liability'
  RxDouble insuranceDailyAmount = 0.0.obs;
  RxDouble insuranceSubtotal = 0.0.obs;
  RxDouble insuranceExcessLiabilityAmount = 0.0.obs;
  Rxn<Map<String, String>> insuranceMessage = Rxn<Map<String, String>>();

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeUserData();
    _setupListeners();
    
    // Check if car was passed as argument
    if (Get.arguments != null && Get.arguments is Map) {
      final car = Get.arguments['car'];
      if (car is VendorCar) {
        initializeWithCar(car);
      }
    }
    // Ensure initial form validity is evaluated (accounts for auto-filled fields)
    _updateFormValidity();
  }

  void _initializeUserData() {
    // Auto-fill email and phone from user profile
    emailController.text = LocalStorage.email;
    mobileController.text = LocalStorage.number;
  }

  void _setupListeners() {
    // Set up listeners for form validation
    emailController.addListener(_updateFormValidity);
    quantityController.addListener(() {
      _updateFormValidity();
      _scheduleDebounce();
    });
    mobileController.addListener(_updateFormValidity);
    locationController.addListener(_updateFormValidity);
    
    // Listen to pickup date and time changes
    ever(pickupDate, (_) => _updateFormValidity());
    ever(pickupTime, (_) => _updateFormValidity());
    
    // Listen to pickup location changes — trigger price estimate when location is set
    ever(pickupLocation, (location) {
      debugPrint('[BookingController] pickupLocation changed: ${location?.address}');
      _updateFormValidity();
      if (isDeliver.value) {
        debugPrint('[BookingController] Delivery enabled, scheduling price estimate...');
        _scheduleDebounce();
      }
    });
    
    // Recalculate when delivery toggle changes
    ever(isDeliver, (deliver) {
      debugPrint('[BookingController] isDeliver changed: $deliver');
      _updateFormValidity();
      _scheduleDebounce();
    });
    
    // Debug: Track delivery charge changes
    ever(deliveryCharge, (charge) {
      debugPrint('[BookingController] deliveryCharge updated: $charge');
    });
    
    // Debug: Track delivery source changes
    ever(deliverySource, (source) {
      debugPrint('[BookingController] deliverySource updated: $source');
    });
    
    // Listen to insurance type selection changes — trigger price estimate
    ever(selectedInsuranceType, (type) {
      debugPrint('[BookingController] selectedInsuranceType changed: $type');
      _updateFormValidity();
      _scheduleDebounce();
    });
    
    // Debug: print validity changes to help trace why Continue is disabled
    ever(isFormValid, (val) {
      debugPrint('BookingController.isFormValid changed: \\$val');
      debugPrint('  email: "' + emailController.text + '"');
      debugPrint('  mobile: "' + mobileController.text + '"');
      debugPrint('  quantity: "' + quantityController.text + '"');
      debugPrint('  pickupDate: "' + pickupDate.value + '"');
      debugPrint('  pickupTime: "' + pickupTime.value + '"');
      debugPrint('  isDeliver: ' + isDeliver.value.toString());
      debugPrint('  pickupLocation: ' + (pickupLocation.value == null ? 'null' : pickupLocation.value!.address));
      debugPrint('  deliveryCharge: ' + deliveryCharge.value.toString());
      debugPrint('  deliverySource: ' + (deliverySource.value ?? 'null'));
      debugPrint('  selectedInsuranceType: ' + (selectedInsuranceType.value ?? 'null'));
    });
  }

  /// Initialize booking with selected car and pricing info
  void initializeWithCar(VendorCar car) {
    selectedCar.value = car;
    selectedPricing.value = car.pricing;
    // Normalize API type values: 'daily' → 'per_day', 'km' → 'per_km'
    pricingType.value = _normalizePricingType(car.pricing.type);
    pricingUnit.value = car.pricing.unit;
    _updateFormValidity();
  }

  /// Maps API pricing type values to internal constants.
  /// API may return 'daily' or 'per_day'; internally we use 'per_day'.
  String _normalizePricingType(String apiType) {
    switch (apiType) {
      case 'daily':
      case 'per_day':
        return 'per_day';
      case 'km':
      case 'per_km':
        return 'per_km';
      default:
        return apiType;
    }
  }

  void _updateFormValidity() {
    isFormValid.value =
        quantityController.text.isNotEmpty &&
        pickupDate.value.isNotEmpty &&
        pickupTime.value.isNotEmpty &&
        _isPickupDateTimeValid() &&
        // insurance must be selected (daily or excess_liability)
        selectedInsuranceType.value != null && selectedInsuranceType.value!.isNotEmpty &&
        // pickup location is required only when isDeliver is true
        (isDeliver.value ? pickupLocation.value != null : true) &&
        // block checkout if delivery is out of all zones
        !(isDeliver.value && deliverySource.value == 'none');
  }

  /// Validates that the selected pickup date and time is in the future
  bool _isPickupDateTimeValid() {
    if (pickupDate.value.isEmpty || pickupTime.value.isEmpty) {
      return false;
    }

    try {
      // Parse date (format: YYYY-MM-DD)
      final dateParts = pickupDate.value.split('-');
      if (dateParts.length != 3) return false;
      
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      // Parse time (format: HH:mm)
      final timeParts = pickupTime.value.split(':');
      if (timeParts.length != 2) return false;
      
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Create DateTime from selected date and time
      final selectedDateTime = DateTime(year, month, day, hour, minute);
      final now = DateTime.now();

      // Check if selected datetime is in the future
      return selectedDateTime.isAfter(now);
    } catch (e) {
      debugPrint('Error validating pickup datetime: $e');
      return false;
    }
  }

  void _scheduleDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), _fetchPriceEstimate);
  }

  Future<void> _fetchPriceEstimate() async {
    if (selectedCar.value == null) {
      debugPrint('[PriceEstimate] Skipped: selectedCar is null');
      return;
    }
    
    final int? days = int.tryParse(quantityController.text);
    if (days == null || days <= 0) {
      debugPrint('[PriceEstimate] Skipped: invalid rental days: ${quantityController.text}');
      subtotal.value = 0;
      deliveryCharge.value = 0;
      deliveryDistance.value = null;
      deliverySource.value = null;
      taxAmount.value = 0;
      total.value = 0;
      effectivePrice.value = 0;
      pricingTier.value = '';
      return;
    }

    final requestBody = {
      'car_id': selectedCar.value!.id,
      'rental_days': days,
      'with_delivery': isDeliver.value,
      if (isDeliver.value && pickupLocation.value != null) ...{
        'user_lat': pickupLatitude.value,
        'user_lng': pickupLongitude.value,
      },
      // Add insurance type to request (required)
      if (selectedInsuranceType.value != null && selectedInsuranceType.value!.isNotEmpty)
        'insurance_type': selectedInsuranceType.value,
    };
    
    debugPrint('[PriceEstimate] Calling API with body: $requestBody');

    await RequestProcess().request<PriceEstimateModel>(
      fromJson: PriceEstimateModel.fromJson,
      apiEndpoint: ApiEndpoint.priceEstimate,
      isLoading: isPriceLoading,
      method: HttpMethod.POST,
      showErrorMessage: false,
      body: requestBody,
      onSuccess: (estimate) {
        if (isClosed) {
          debugPrint('[PriceEstimate] Controller is closed, ignoring response');
          return;
        }
        if (estimate == null) {
          debugPrint('[PriceEstimate] Response model is null');
          return;
        }
        
        debugPrint('[PriceEstimate] ✅ API Success:');
        debugPrint('  - subtotal: ${estimate.subtotal}');
        debugPrint('  - deliveryFee: ${estimate.deliveryFee}');
        debugPrint('  - deliveryDistance: ${estimate.deliveryDistance}');
        debugPrint('  - deliverySource: ${estimate.deliverySource}');
        debugPrint('  - taxAmount: ${estimate.taxAmount}');
        debugPrint('  - total: ${estimate.total}');
        debugPrint('  - insuranceType: ${estimate.insuranceType}');
        debugPrint('  - insuranceDailyAmount: ${estimate.insuranceDailyAmount}');
        debugPrint('  - insuranceSubtotal: ${estimate.insuranceSubtotal}');
        debugPrint('  - insuranceExcessLiabilityAmount: ${estimate.insuranceExcessLiabilityAmount}');
        debugPrint('  - insuranceMessage: ${estimate.insuranceMessage}');
        
        subtotal.value = estimate.subtotal;
        deliveryCharge.value = estimate.deliveryFee ?? 0.0;
        deliveryDistance.value = estimate.deliveryDistance;
        deliverySource.value = estimate.deliverySource;
        taxAmount.value = estimate.taxAmount;
        total.value = estimate.total;
        effectivePrice.value = estimate.rateUsed;
        pricingTier.value = estimate.pricingTier;
        
        // Update insurance fields from response
        insuranceDailyAmount.value = estimate.insuranceDailyAmount ?? 0.0;
        insuranceSubtotal.value = estimate.insuranceSubtotal ?? 0.0;
        insuranceExcessLiabilityAmount.value = estimate.insuranceExcessLiabilityAmount ?? 0.0;
        if (estimate.insuranceMessage != null) {
          insuranceMessage.value = estimate.insuranceMessage;
        }
        
        _updateFormValidity();
      },
      onError: (error) {
        debugPrint('[PriceEstimate] ❌ API Error: $error');
        // Reset prices on error to force user to fix the issue
        if (!isClosed) {
          subtotal.value = 0;
          deliveryCharge.value = 0;
          deliveryDistance.value = null;
          deliverySource.value = null;
          taxAmount.value = 0;
          total.value = 0;
        }
      },
    );
  }

  /// Get label for quantity input based on pricing type
  String getQuantityLabel() {
    switch (pricingType.value) {
      case 'per_day':
        return DynamicLanguage.key(Strings.rentalDays); // Localized label
      case 'per_km':
        return DynamicLanguage.key(Strings.distance); // Localized label
      default:
        return DynamicLanguage.key(Strings.rentalDays); // Localized label
    }
  }

  /// Get hint text for quantity input based on pricing type
  String getQuantityHint() {
    switch (pricingType.value) {
      case 'per_day':
        return DynamicLanguage.key(Strings.enterDays);
      case 'per_km':
        return DynamicLanguage.key(Strings.enterDistance);
      default:
        return DynamicLanguage.key(Strings.enterDays);
    }
  }

  /// Get price display text
  String getPriceDisplayText() {
    if (selectedPricing.value == null) return '';
    final pricing = selectedPricing.value!;
    return '${pricing.price.toStringAsFixed(0)} ${pricing.currency}/${pricing.unit}';
  }

  @override
  void onClose() {
    try {
      emailController.removeListener(_updateFormValidity);
      quantityController.removeListener(_updateFormValidity);
      mobileController.removeListener(_updateFormValidity);
      locationController.removeListener(_updateFormValidity);
    } catch (_) {}

    dateController.dispose();
    timeController.dispose();
    emailController.dispose();
    locationController.dispose();
    noteController.dispose();
    mobileController.dispose();
    quantityController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// Prepare booking data for submission
  Map<String, dynamic> getBookingData() {
    // Try to get booking token from multiple sources
    String bookingToken = '';
    
    // First, try DashboardController
    try {
      final dashboardController = Get.find<DashboardController>();
      if (dashboardController.carToken.value.isNotEmpty) {
        bookingToken = dashboardController.carToken.value;
      }
    } catch (e) {
      // DashboardController not found, try AllVendorsDashboardController
    }
    
    // Second, try AllVendorsDashboardController if DashboardController didn't have token
    if (bookingToken.isEmpty) {
      try {
        final allVendorsController = Get.find<AllVendorsDashboardController>();
        if (allVendorsController.carToken.value.isNotEmpty) {
          bookingToken = allVendorsController.carToken.value;
        }
      } catch (e) {
        // AllVendorsDashboardController not found
      }
    }
    
    // Final fallback: use LocalStorage token if available
    if (bookingToken.isEmpty) {
      bookingToken = LocalStorage.token;
    }
    
    return {
      'email': emailController.text,
      'phone': mobileController.text,
      'quantity': quantityController.text,
      'pickup_date': pickupDate.value,
      'pickup_time': pickupTime.value,
      'pricing_type': pricingType.value,
      'pricing_unit': pricingUnit.value,
      'delivery_required': isDeliver.value,
      'delivery_location': isDeliver.value ? pickupLocation.value?.address ?? locationController.text : null,
      'delivery_latitude': isDeliver.value ? pickupLocation.value?.latitude : null,
      'delivery_longitude': isDeliver.value ? pickupLocation.value?.longitude : null,
      // Also include pickup coordinates with API-friendly keys
      'pickup_lat': pickupLocation.value?.latitude ?? pickupLatitude.value,
      'pickup_lng': pickupLocation.value?.longitude ?? pickupLongitude.value,
      'notes': noteController.text,
      'subtotal': subtotal.value,
      'delivery_charge': deliveryCharge.value,
      'tax_amount': taxAmount.value,
      'tax_enabled': selectedCar.value?.taxEnabled ?? false,
      'tax_percentage': selectedCar.value?.taxPercentage ?? 0,
      'total': total.value,
      'car_id': selectedCar.value?.id,
      'id': selectedCar.value?.id,  // Added: explicit id field for preview screen
      'car_name': '${selectedCar.value?.make} ${selectedCar.value?.model}',
      'currency': selectedCar.value?.currency ?? 'SAR',
      'token': bookingToken,  // Booking token from vendor cars API or fallback
      // Insurance
      'insurance_type': selectedInsuranceType.value,
      'insurance_daily_amount': insuranceDailyAmount.value,
      'insurance_excess_liability_amount': insuranceExcessLiabilityAmount.value,
    };
  }

  /// Check if delivery is available for the selected car
  bool isDeliveryAvailable() {
    if (selectedCar.value == null) return false;

    final car = selectedCar.value!;

    // Vendor must have marked this car as delivery-available
    if (!car.isDeliveryAvailable) return false;

    try {
      final vendorController = Get.find<AllVendorsDashboardController>();

      // Check if user is within branch delivery radius
      if (car.branchId != null) {
        return vendorController.deliveryAvailabilityMap[car.branchId] ?? false;
      }
    } catch (e) {
      // Controller not found, fall through to location check
    }

    // Fallback when no branch ID: require vendor location coordinates
    return car.vendorLocation?.latitude != null && car.vendorLocation?.longitude != null;
  }

  /// Look up the zone-based delivery fee from the dashboard controller.
  /// Returns the fee for [branchId] or null when not available.
  double? _lookupZoneDeliveryFee(int? branchId) {
    if (branchId == null) return null;
    try {
      final ctrl = Get.find<AllVendorsDashboardController>();
      return ctrl.deliveryFeeMap[branchId];
    } catch (_) {}
    // Try vendor cars controller as fallback
    try {
      final ctrl = Get.find<VendorCarsController>();
      return ctrl.deliveryFeeMap[branchId];
    } catch (_) {}
    return null;
  }

  /// Return a list of human-readable field names that are missing/invalid
  List<String> getMissingFields() {
    final missing = <String>[];
    // Email is optional, not included in validation
    if (quantityController.text.isEmpty) missing.add(DynamicLanguage.key(Strings.quantity));
    if (pickupDate.value.isEmpty) missing.add(DynamicLanguage.key(Strings.PickUpdate));
    if (pickupTime.value.isEmpty) missing.add(DynamicLanguage.key(Strings.PickUpTime));
    if (pickupDate.value.isNotEmpty && pickupTime.value.isNotEmpty && !_isPickupDateTimeValid()) {
      missing.add('Pickup date and time must be in the future');
    }
    if (isDeliver.value && pickupLocation.value == null) missing.add(DynamicLanguage.key(Strings.PickUpLocation));
    return missing;
  }
}

