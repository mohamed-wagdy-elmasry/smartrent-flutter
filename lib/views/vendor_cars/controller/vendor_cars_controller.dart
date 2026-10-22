import 'package:carbo/base/utils/basic_import.dart';
import 'package:carbo/base/localization/dynamic_language_shim.dart';
import 'package:carbo/base/widgets/logger.dart';
import 'package:carbo/base/utils/local_storage.dart';
import 'package:carbo/base/services/location_service.dart';
import 'package:carbo/base/services/delivery_service.dart';
import 'package:carbo/views/all_vendors_dashboard/model/vendor_cars_model.dart';
import 'package:carbo/views/vendor_cars/model/vendor_cars_filter_model.dart';
import 'package:carbo/views/booking/controller/booking_controller.dart';
import 'package:carbo/routes/routes.dart';
import 'package:http/http.dart' as http;
import '../../../base/api/endpoint/api_endpoint.dart';

final log = logger(VendorCarsController);

/// Controller for displaying vendor cars with filtering, pagination, 
/// and auth-guarded booking functionality
class VendorCarsController extends GetxController {
  // ═══════════════════════════════════════════════════════════════════════════
  // CONSTRUCTOR & ARGUMENTS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Vendor ID passed via Get.arguments
  int? vendorId;
  
  /// Vendor name for display
  RxString vendorName = ''.obs;

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE VARIABLES
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// List of cars from this vendor
  var vendorCars = <VendorCar>[].obs;
  
  /// Master copy of all loaded cars (for client-side filtering)
  var allVendorCars = <VendorCar>[].obs;
  
  /// Currently selected car for booking
  var selectedCarIndex = 0.obs;
  RxString selectedCarId = ''.obs;
  RxString carToken = ''.obs;

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGINATION
  // ═══════════════════════════════════════════════════════════════════════════
  
  Rx<Pagination?> pagination = Rx<Pagination?>(null);
  RxInt currentPage = 1.obs;
  RxBool hasMore = false.obs;
  static const int _perPage = 15;

  // ═══════════════════════════════════════════════════════════════════════════
  // META INFO
  // ═══════════════════════════════════════════════════════════════════════════
  
  Rx<MetaInfo?> metaInfo = Rx<MetaInfo?>(null);

  // ═══════════════════════════════════════════════════════════════════════════
  // LOADING STATES
  // ═══════════════════════════════════════════════════════════════════════════
  
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _isLoadingMore = false.obs;
  bool get isLoadingMore => _isLoadingMore.value;

  final _isRefreshing = false.obs;
  bool get isRefreshing => _isRefreshing.value;

  // ═══════════════════════════════════════════════════════════════════════════
  // ERROR STATE
  // ═══════════════════════════════════════════════════════════════════════════
  
  final _hasError = false.obs;
  bool get hasError => _hasError.value;
  
  RxString errorMessage = ''.obs;

  // ═══════════════════════════════════════════════════════════════════════════
  // FILTERS & SORTING
  // ═══════════════════════════════════════════════════════════════════════════
  
  Rx<VendorCarsFilter> filter = VendorCarsFilter().obs;
  
  RxString sortOption = 'popularity'.obs;
  RxString quickFilter = 'all'.obs;
  RxString selectedBrand = 'all'.obs;
  RxString selectedCity = 'all'.obs;

  // ═══════════════════════════════════════════════════════════════════════════
  // DELIVERY TRACKING
  // ═══════════════════════════════════════════════════════════════════════════
  
  final deliveryAvailabilityMap = <int, bool>{}.obs;
  final deliveryFeeMap = <int, double>{}.obs; // branchId -> deliveryFee
  RxBool isCheckingDelivery = false.obs;
  RxBool locationPermissionDenied = false.obs;

  // ═══════════════════════════════════════════════════════════════════════════
  // FAVORITES
  // ═══════════════════════════════════════════════════════════════════════════
  
  var favoriteCars = <String>[].obs;

  // ═══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void onInit() {
    super.onInit();
    log.i('VendorCarsController initialized');
    
    // Extract arguments
    _extractArguments();

    // Load cars
    fetchVendorCars().then((_) => resumeBookingIfPending());
  }

  void _extractArguments() {
    final args = Get.arguments;
    if (args != null && args is Map) {
      vendorId = args['vendorId'] as int?;
      vendorName.value = args['vendorName'] as String? ?? '';
      
      // Initialize filter with vendor ID
      if (vendorId != null) {
        filter.value = VendorCarsFilter(vendorId: vendorId);
      }
    }
    log.i('Vendor ID: $vendorId, Name: ${vendorName.value}');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DATA FETCHING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fetch cars from the vendor
  Future<void> fetchVendorCars({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMore.value || _isLoadingMore.value) return;
      _isLoadingMore.value = true;
      currentPage.value++;
    } else {
      vendorCars.clear();
      allVendorCars.clear();
      currentPage.value = 1;
      _isLoading.value = true;
      _hasError.value = false;
      errorMessage.value = '';
    }

    try {
      // Build query parameters
      final queryParams = <String, String>{
        'page': currentPage.value.toString(),
        'per_page': _perPage.toString(),
        ...filter.value.toQueryParams(),
      };

      final token = LocalStorage.token;
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      // Build URI
      final baseUri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiEndpoint.vendorCars.path}',
      );
      final uri = baseUri.replace(queryParameters: queryParams);

      log.i('Fetching vendor cars from: $uri');
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        VendorCarsModel? vendorCarsModel;
        try {
          vendorCarsModel = vendorCarsModelFromJson(response.body);
        } catch (e) {
          log.e('Failed to parse vendor cars JSON: $e');
          _setError(DynamicLanguage.key(Strings.serverError));
          return;
        }

        if (vendorCarsModel.success) {
          if (loadMore) {
            allVendorCars.addAll(vendorCarsModel.data.cars);
            vendorCars.addAll(vendorCarsModel.data.cars);
          } else {
            allVendorCars.value = vendorCarsModel.data.cars;
            vendorCars.value = List<VendorCar>.from(allVendorCars);
            
            // Update vendor name from first car if not set
            if (vendorName.value.isEmpty && vendorCarsModel.data.cars.isNotEmpty) {
              vendorName.value = vendorCarsModel.data.cars.first.vendorName;
            }
          }

          // Update token
          if (vendorCarsModel.data.token != null &&
              vendorCarsModel.data.token!.isNotEmpty) {
            carToken.value = vendorCarsModel.data.token!;
            log.i('Updated carToken: ${carToken.value}');
          }

          pagination.value = vendorCarsModel.data.pagination;
          hasMore.value = vendorCarsModel.data.pagination.hasMore;
          metaInfo.value = vendorCarsModel.data.meta;

          // Check delivery availability
          _checkDeliveryForCars();

          if (vendorCars.isEmpty && !loadMore) {
            log.w('No cars found for vendor');
          }
        } else {
          _setError(
            vendorCarsModel.message.isNotEmpty
                ? vendorCarsModel.message.first
                : DynamicLanguage.key(Strings.serverError),
          );
        }
      } else {
        log.e('Failed to fetch vendor cars: ${response.statusCode}');
        _setError(DynamicLanguage.key(Strings.serverError));
      }
    } catch (e) {
      log.e('fetchVendorCars error: $e');
      _setError(DynamicLanguage.key(Strings.serverError));
    } finally {
      if (loadMore) {
        _isLoadingMore.value = false;
      } else {
        _isLoading.value = false;
      }
    }
  }

  void _setError(String message) {
    _hasError.value = true;
    errorMessage.value = message;
    CustomSnackBar.error(message);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════════════════════════

  /// Pull to refresh
  Future<void> refreshCars() async {
    _isRefreshing.value = true;
    log.i('Refreshing vendor cars');
    await fetchVendorCars();
    _isRefreshing.value = false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DELIVERY CHECK
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _checkDeliveryForCars() async {
    try {
      isCheckingDelivery.value = true;
      locationPermissionDenied.value = false;

      final locationService = Get.find<LocationService>();
      final position = await locationService.getUserLocation();

      if (position == null) {
        locationPermissionDenied.value =
            locationService.locationPermissionDenied.value;
        log.w('Cannot check delivery: location unavailable');
        isCheckingDelivery.value = false;
        return;
      }

      log.i('User location - Lat: ${position.latitude}, Lng: ${position.longitude}');

      final branchIds = allVendorCars
          .where((car) => car.branchId != null)
          .map((car) => car.branchId!)
          .toSet()
          .toList();

      if (branchIds.isEmpty) {
        log.w('No branch IDs found');
      } else {
        log.i('Checking delivery for ${branchIds.length} branches');

        final deliveryService = Get.find<DeliveryService>();
        final results = await deliveryService.checkMultipleBranches(
          branchIds: branchIds,
          userLat: position.latitude,
          userLng: position.longitude,
        );

        deliveryAvailabilityMap.clear();
        deliveryFeeMap.clear();
        results.forEach((branchId, response) {
          deliveryAvailabilityMap[branchId] = response.isAvailable;
          if (response.isAvailable && response.deliveryFee != null && response.deliveryFee! > 0) {
            deliveryFeeMap[branchId] = response.deliveryFee!;
          }
        });

        log.i('Delivery check complete: ${deliveryAvailabilityMap.length} branches');
      }
    } catch (e) {
      log.e('Error checking delivery: $e');
    } finally {
      isCheckingDelivery.value = false;
    }
  }

  bool isDeliveryAvailable(VendorCar car) {
    if (!car.isDeliveryAvailable) return false;
    if (car.branchId != null) {
      return deliveryAvailabilityMap[car.branchId] ?? false;
    }
    return car.vendorLocation?.latitude != null && car.vendorLocation?.longitude != null;
  }

  Future<void> retryDeliveryCheck() async {
    await _checkDeliveryForCars();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SORTING & FILTERING
  // ═══════════════════════════════════════════════════════════════════════════

  void changeSortOption(String option) {
    sortOption.value = option;
    log.i('Sort option: $option');
    _applySortAndFilter();
  }

  void changeQuickFilter(String filterValue) {
    quickFilter.value = filterValue;
    log.i('Quick filter: $filterValue');
    _applySortAndFilter();
  }

  void changeBrandFilter(String brand) {
    selectedBrand.value = brand;
    log.i('Brand filter: $brand');
    _applySortAndFilter();
  }

  void changeCityFilter(String city) {
    selectedCity.value = city;
    log.i('City filter: $city');
    final f = filter.value;
    filter.value = VendorCarsFilter(
      vendorId: f.vendorId,
      carType: f.carType,
      minYear: f.minYear,
      maxYear: f.maxYear,
      minPrice: f.minPrice,
      maxPrice: f.maxPrice,
      sortBy: f.sortBy,
      sortOrder: f.sortOrder,
      city: city == 'all' ? null : city,
    );
    fetchVendorCars();
  }

  /// Unique sorted list of brands from all loaded cars, uppercase-normalised
  List<String> get availableBrands {
    final brands = allVendorCars
        .map((c) => c.make.trim())
        .where((m) => m.isNotEmpty)
        .toSet()
        .toList();
    brands.sort();
    return brands;
  }

  /// Unique sorted list of cities from meta info
  List<String> get availableCities => metaInfo.value?.availableCities ?? [];

  /// How many cars match a given brand ('all' returns total)
  int brandCarCount(String brand) {
    if (brand == 'all') return allVendorCars.length;
    return allVendorCars.where((c) => c.make.trim() == brand).length;
  }

  void _applySortAndFilter() {
    var filteredCars = List<VendorCar>.from(allVendorCars);

    // Apply brand filter
    if (selectedBrand.value != 'all') {
      filteredCars = filteredCars
          .where((car) => car.make.trim() == selectedBrand.value)
          .toList();
    }

    // Apply quick filter
    switch (quickFilter.value) {
      case 'available':
        filteredCars = filteredCars
            .where((car) => car.availabilityStatus == 'available')
            .toList();
        break;
      case 'deliveryAvailable':
        filteredCars = filteredCars
            .where((car) => isDeliveryAvailable(car))
            .toList();
        break;
    }

    // Apply sort
    switch (sortOption.value) {
      case 'priceLowToHigh':
        filteredCars.sort((a, b) => a.pricing.price.compareTo(b.pricing.price));
        break;
      case 'priceHighToLow':
        filteredCars.sort((a, b) => b.pricing.price.compareTo(a.pricing.price));
        break;
      case 'rating':
        filteredCars.sort((a, b) => b.vendorRating.compareTo(a.vendorRating));
        break;
    }

    vendorCars.value = filteredCars;
    log.i('Applied filters. Result: ${filteredCars.length} cars');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FAVORITES
  // ═══════════════════════════════════════════════════════════════════════════

  void toggleFavorite(String carId) {
    if (favoriteCars.contains(carId)) {
      favoriteCars.remove(carId);
      log.i('Removed car $carId from favorites');
    } else {
      favoriteCars.add(carId);
      log.i('Added car $carId to favorites');
    }
  }

  bool isFavorite(String carId) => favoriteCars.contains(carId);

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH & BOOKING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Handle book now tap with auth guard
  void onBookNowTap(VendorCar car) {
    if (!LocalStorage.isLoggedIn) {
      _redirectToLogin(car);
      return;
    }
    _proceedToBooking(car);
  }

  void _proceedToBooking(VendorCar car) {
    selectedCarId.value = car.id.toString();

    // Initialize booking controller
    try {
      final bookingController = Get.find<BookingController>();
      bookingController.initializeWithCar(car);
    } catch (e) {
      log.w('BookingController not initialized yet');
    }

    Get.toNamed(Routes.bookingScreen, arguments: {'car': car});
  }

  void _redirectToLogin(VendorCar car) {
    // Store the car data for resuming after login
    Get.toNamed(
      Routes.otpLoginScreen,
      arguments: {
        'resumeRoute': Routes.vendorCarsScreen,
        'resumeArgs': {
          'vendorId': vendorId,
          'vendorName': vendorName.value,
          'pendingCarId': car.id,
        },
      },
    );
  }

  /// Resume booking after successful login
  void resumeBookingIfPending() {
    final args = Get.arguments;
    if (args != null && args is Map && args['pendingCarId'] != null) {
      final pendingCarId = args['pendingCarId'] as int;
      final car = vendorCars.firstWhereOrNull((c) => c.id == pendingCarId);
      if (car != null && LocalStorage.isLoggedIn) {
        // Small delay to ensure UI is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          onBookNowTap(car);
        });
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  String formatPrice(VendorCar car) {
    final currencySymbols = {
      'SAR': 'ريال',
      'USD': '\$',
      'AED': 'د.إ',
      'EGP': '£',
      'KWD': 'د.ك',
    };
    final symbol = currencySymbols[car.currency] ?? car.currency;
    final unitText = car.pricing.unit == 'day'
        ? DynamicLanguage.key(Strings.Day)
        : car.pricing.unit;
    return '$symbol ${car.pricing.price.toStringAsFixed(0)}/$unitText';
  }
}
