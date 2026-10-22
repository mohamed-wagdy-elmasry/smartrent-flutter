import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import '../widgets/logger.dart';

final log = logger(LocationService);

class LocationService extends GetxService {
  static LocationService get instance => Get.find();

  // Cached location
  Rxn<Position> currentPosition = Rxn<Position>();
  RxBool hasLocationPermission = false.obs;
  RxBool isLocationServiceEnabled = false.obs;
  RxBool locationPermissionDenied = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLocationServiceStatus();
  }

  Future<void> _checkLocationServiceStatus() async {
    try {
      isLocationServiceEnabled.value = await Geolocator.isLocationServiceEnabled();
      final permission = await Permission.location.status;
      hasLocationPermission.value = permission.isGranted;
      locationPermissionDenied.value = permission.isDenied || permission.isPermanentlyDenied;
    } catch (e) {
      log.e('Error checking location service status: $e');
    }
  }

  /// Request location permission and get user's current position
  /// Returns null if permission denied or location unavailable
  Future<Position?> getUserLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log.w('Location services are disabled');
        isLocationServiceEnabled.value = false;
        return null;
      }
      isLocationServiceEnabled.value = true;

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log.w('Location permission denied');
          hasLocationPermission.value = false;
          locationPermissionDenied.value = true;
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        log.w('Location permission denied forever');
        hasLocationPermission.value = false;
        locationPermissionDenied.value = true;
        return null;
      }

      hasLocationPermission.value = true;
      locationPermissionDenied.value = false;

      // Try last known position first (instant, non-blocking)
      Position? position = await getLastKnownLocation();

      // If not available, query current position with strict timeout
      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 4),
            ),
          ).timeout(const Duration(seconds: 4));
        } catch (err) {
          log.w('getCurrentPosition timed out or failed: $err');
          position = null;
        }
      }

      if (position != null) {
        currentPosition.value = position;
        log.i('Location obtained: ${position.latitude}, ${position.longitude}');
      }
      return position;
    } catch (e) {
      log.e('Error getting user location: $e');
      return null;
    }
  }

  /// Get last known position (faster, but may be outdated)
  Future<Position?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        currentPosition.value = position;
        log.i('Last known location: ${position.latitude}, ${position.longitude}');
      }
      return position;
    } catch (e) {
      log.e('Error getting last known location: $e');
      return null;
    }
  }

  /// Open app settings if permission is permanently denied
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings page
  Future<void> openAppSettings() async {
    await Permission.location.request();
    if (await Permission.location.isPermanentlyDenied) {
      await openAppSettings();
    }
  }
}
