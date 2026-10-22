import 'package:carbo/base/utils/basic_import.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:carbo/base/localization/dynamic_language_shim.dart';
import 'package:carbo/base/widgets/logger.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../model/vendor_cars_model.dart';
import 'package:http/http.dart' as http;
import 'package:carbo/base/utils/local_storage.dart';
import 'package:carbo/base/services/location_service.dart';
import 'package:carbo/base/services/delivery_service.dart';

final log = logger(AllVendorsDashboardController);

class AllVendorsDashboardController extends GetxController {
  // Scroll controller for infinite scroll
  final scrollController = ScrollController();

  // Basic selections
  RxInt currentIndex = 0.obs;
  var selectedCarIndex = 0.obs;
  RxString selectedCarId = ''.obs;
  RxString carToken = ''.obs;

  // Cars list - New vendor cars model
  var vendorCars = <VendorCar>[].obs;
  // Keep a master copy of loaded cars so filters can be toggled on/off
  var allVendorCars = <VendorCar>[].obs;
  RxString carImgUrl = ''.obs;

  // Pagination
  Rx<Pagination?> pagination = Rx<Pagination?>(null);
  RxInt currentPage = 1.obs;
  RxBool hasMore = false.obs;

  // Meta info
  Rx<MetaInfo?> metaInfo = Rx<MetaInfo?>(null);

  // Loading states
  final _isLoad = false.obs;
  bool get isLoad => _isLoad.value;

  final _isSearchingCar = false.obs;
  bool get isSearchingCar => _isSearchingCar.value;

  final _isLoadingMore = false.obs;
  bool get isLoadingMore => _isLoadingMore.value;

  // Pull to refresh state
  final _isRefreshing = false.obs;
  bool get isRefreshing => _isRefreshing.value;

  // Favorites
  var favoriteCars = <String>[].obs;

  // Sorting
  RxString sortOption =
      'popularity'.obs; // popularity, priceLowToHigh, priceHighToLow, rating

  // Quick filters
  RxString quickFilter = 'all'.obs; // all, available, deliveryAvailable

  // Brand filter
  RxString selectedBrand = 'all'.obs;

  // City filter
  RxString selectedCity = 'all'.obs;

  // Delivery tracking
  final deliveryAvailabilityMap = <int, bool>{}.obs; // branchId -> isAvailable
  final deliveryFeeMap = <int, double>{}.obs; // branchId -> deliveryFee
  RxBool isCheckingDelivery = false.obs;
  RxBool locationPermissionDenied = false.obs;

  // Resolved GPS position for the current session (null = no location / denied)
  Position? _userPosition;

  @override
  void onInit() {
    super.onInit();
    log.i('AllVendorsDashboardController initialized');
    log.i('Current language: ${DynamicLanguage.selectedLanguage.value}');
    log.i('App language is loading: ${DynamicLanguage.isLoading}');
    log.i('Language direction: ${DynamicLanguage.languageDirection}');
    scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLocationAndFetch());
  }

  Future<void> _initLocationAndFetch() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.deniedForever) {
        final locationService = Get.find<LocationService>();
        _userPosition = await locationService.getUserLocation();
      } else {
        _userPosition = null;
      }
    } catch (e) {
      log.e('Location init error: $e');
      _userPosition = null;
    }

    if (isClosed) return;
    await searchAllVendorsCars();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 300) {
      if (hasMore.value && !_isLoadingMore.value) {
        searchAllVendorsCars(loadMore: true);
      }
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  // SEARCH ALL CARS FROM ALL VENDORS - Simplified without filters
  Future<void> searchAllVendorsCars({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMore.value || _isLoadingMore.value) return;
      _isLoadingMore.value = true;
      currentPage.value++;
    } else {
      vendorCars.clear();
      allVendorCars.clear();
      currentPage.value = 1;
      _isSearchingCar.value = true;
    }

    try {
      // Build query parameters - only pagination, no filters
      Map<String, String> queryParams = {
        'page': currentPage.value.toString(),
        'per_page': '15',
      };
      if (selectedCity.value != 'all') {
        queryParams['city'] = selectedCity.value;
      }
      if (_userPosition != null) {
        queryParams['lat'] = _userPosition!.latitude.toString();
        queryParams['lng'] = _userPosition!.longitude.toString();
        // No sort_by needed — backend defaults to distance_asc when coords supplied
      } else {
        queryParams['sort_by'] = 'price_asc';
      }

      final token = LocalStorage.token;
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Build URI with query parameters properly
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
          log.d(
            'Response body (first 2000 chars): ${response.body.length > 2000 ? response.body.substring(0, 2000) : response.body}',
          );
          throw e;
        }

        if (vendorCarsModel.success) {
          if (loadMore) {
            // append to master list and current view
            allVendorCars.addAll(vendorCarsModel.data.cars);
            vendorCars.addAll(vendorCarsModel.data.cars);
          } else {
            // replace master list and current view
            allVendorCars.value = vendorCarsModel.data.cars;
            vendorCars.value = List<VendorCar>.from(allVendorCars);
          }

          // Update carToken from API response
          if (vendorCarsModel.data.token != null && 
              vendorCarsModel.data.token!.isNotEmpty) {
            carToken.value = vendorCarsModel.data.token!;
            log.i('Updated carToken from API: ${carToken.value}');
          }

          pagination.value = vendorCarsModel.data.pagination;
          hasMore.value = vendorCarsModel.data.pagination.hasMore;
          metaInfo.value = vendorCarsModel.data.meta;

          // Check delivery availability after loading cars (always check for all loaded cars)
          if (!loadMore) {
            _checkDeliveryForCars();
          } else {
            // For load more we also want to check delivery for newly added branches
            _checkDeliveryForCars();
          }

          if (vendorCars.isEmpty && !loadMore) {
            CustomSnackBar.error(
              DynamicLanguage.isLoading
                  ? ""
                  : DynamicLanguage.key(Strings.noCarFindMessage),
            );
          }
        } else {
          CustomSnackBar.error(
            vendorCarsModel.message.isNotEmpty
                ? vendorCarsModel.message.first
                : 'Failed to load cars',
          );
        }
      } else {
        log.e('Failed to fetch vendor cars: ${response.statusCode}');
        CustomSnackBar.error('Failed to load cars. Please try again.');
      }
    } catch (e) {
      log.e('searchAllVendorsCars error: $e');
      CustomSnackBar.error('An error occurred. Please try again.');
    } finally {
      if (loadMore) {
        _isLoadingMore.value = false;
      } else {
        _isSearchingCar.value = false;
      }
    }
  }

  // Pull to refresh
  Future<void> refreshCars() async {
    _isRefreshing.value = true;
    log.i('Refreshing vendor cars list');
    await _initLocationAndFetch();
    _isRefreshing.value = false;
  }

  // Check delivery availability for loaded cars
  Future<void> _checkDeliveryForCars() async {
    try {
      isCheckingDelivery.value = true;
      locationPermissionDenied.value = false;

      // Get user location
      final locationService = Get.find<LocationService>();
      final position = await locationService.getUserLocation();

      if (position == null) {
        // Location permission denied or unavailable
        locationPermissionDenied.value = locationService.locationPermissionDenied.value;
        log.w('Cannot check delivery: location unavailable');
        isCheckingDelivery.value = false;
        return;
      }

      log.i('User current location - Lat: ${position.latitude}, Lng: ${position.longitude}');

        // Extract unique branch IDs from all loaded cars (master list)
        final branchIds = allVendorCars
          .where((car) => car.branchId != null)
          .map((car) => car.branchId!)
          .toSet()
          .toList();

      if (branchIds.isEmpty) {
        log.w('No branch IDs found in cars');
        // Note: Delivery badge will show based on vendor location availability
        // Cars with vendor_location data will display delivery badge
        // Shimmer will remain visible until completion in finally block
      } else {
        log.i('Checking delivery for ${branchIds.length} branches');

        // Check delivery for all unique branches
        final deliveryService = Get.find<DeliveryService>();
        final results = await deliveryService.checkMultipleBranches(
          branchIds: branchIds,
          userLat: position.latitude,
          userLng: position.longitude,
        );

        // Update delivery availability & fee maps
        deliveryAvailabilityMap.clear();
        deliveryFeeMap.clear();
        results.forEach((branchId, response) {
          deliveryAvailabilityMap[branchId] = response.isAvailable;
          if (response.isAvailable && response.deliveryFee != null && response.deliveryFee! > 0) {
            deliveryFeeMap[branchId] = response.deliveryFee!;
          }
        });

        log.i('Delivery check complete: ${deliveryAvailabilityMap.length} branches checked');
      }
    } catch (e) {
      log.e('Error checking delivery: $e');
    } finally {
      isCheckingDelivery.value = false;
      // Re-apply filter now that delivery map is populated
      if (quickFilter.value == 'deliveryAvailable') {
        _applySortAndFilter();
      }
    }
  }

  // Check if a car has delivery available
  bool isDeliveryAvailable(VendorCar car) {
    // Vendor must have marked this car as delivery-available
    if (!car.isDeliveryAvailable) return false;
    // Check if user is within branch delivery radius
    if (car.branchId != null) {
      return deliveryAvailabilityMap[car.branchId] ?? false;
    }
    // Fallback when no branch ID: require vendor location coordinates
    return car.vendorLocation?.latitude != null && car.vendorLocation?.longitude != null;
  }

  // Manually trigger delivery check (when user enables location)
  Future<void> retryDeliveryCheck() async {
    await _checkDeliveryForCars();
  }

  // Toggle favorite
  void toggleFavorite(String carId) {
    if (favoriteCars.contains(carId)) {
      favoriteCars.remove(carId);
      log.i('Removed car $carId from favorites');
    } else {
      favoriteCars.add(carId);
      log.i('Added car $carId to favorites');
    }
    // TODO: Persist to backend or local storage
  }

  bool isFavorite(String carId) {
    return favoriteCars.contains(carId);
  }

  // Change sort option
  void changeSortOption(String option) {
    sortOption.value = option;
    log.i('Sort option changed to: $option');
    _applySortAndFilter();
  }

  // Change quick filter
  void changeQuickFilter(String filter) {
    quickFilter.value = filter;
    log.i('Quick filter changed to: $filter');
    _applySortAndFilter();
  }

  // Change brand filter
  void changeBrandFilter(String brand) {
    selectedBrand.value = brand;
    log.i('Brand filter changed to: $brand');
    _applySortAndFilter();
  }

  // Change city filter — server-side, re-fetches
  void changeCityFilter(String city) {
    selectedCity.value = city;
    log.i('City filter changed to: $city');
    searchAllVendorsCars();
  }

  /// Unique sorted list of cities from meta info
  List<String> get availableCities => metaInfo.value?.availableCities ?? [];

  /// Unique sorted list of brands from all loaded cars
  List<String> get availableBrands {
    final brands = allVendorCars
        .map((c) => c.make.trim())
        .where((m) => m.isNotEmpty)
        .toSet()
        .toList();
    brands.sort();
    return brands;
  }

  /// Count of cars matching a brand ('all' returns total)
  int brandCarCount(String brand) {
    if (brand == 'all') return allVendorCars.length;
    return allVendorCars.where((c) => c.make.trim() == brand).length;
  }

  // Apply sorting and filtering
  void _applySortAndFilter() {
    var filteredCars = List<VendorCar>.from(allVendorCars);

    // Apply brand filter
    if (selectedBrand.value != 'all') {
      filteredCars = filteredCars
          .where((car) => car.make.trim() == selectedBrand.value)
          .toList();
    }

    // Apply filter
    if (quickFilter.value == 'available') {
      filteredCars = filteredCars
          .where((car) => car.availabilityStatus == 'available')
          .toList();
    } else if (quickFilter.value == 'deliveryAvailable') {
      filteredCars = filteredCars
          .where((car) => isDeliveryAvailable(car))
          .toList();
    } else if (quickFilter.value == 'all') {
      // no-op, keep full list
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
      case 'popularity':
      default:
        // Keep original order (assumed to be popularity-based from API)
        break;
    }

    vendorCars.value = filteredCars;
    log.i('Applied sort and filter. Result: ${filteredCars.length} cars');
  }
}
