import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:get/get.dart';
import '../widgets/logger.dart';
import '../localization/dynamic_language_shim.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLocationServiceStatus();
    });
  }

  Future<void> checkLocationServiceStatus() async {
    try {
      isLocationServiceEnabled.value = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();
      hasLocationPermission.value =
          (permission == LocationPermission.always || permission == LocationPermission.whileInUse);
      locationPermissionDenied.value =
          (permission == LocationPermission.denied || permission == LocationPermission.deniedForever);
    } catch (e) {
      log.e('Error checking location service status: $e');
    }
  }

  DateTime? _lastFetchTime;

  /// Request location permission and get user's current position
  /// Returns null if permission denied or location unavailable
  Future<Position?> getUserLocation({bool forceRefresh = false}) async {
    // Return cached position if fresh (within 3 minutes)
    if (!forceRefresh &&
        currentPosition.value != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 3) {
      return currentPosition.value;
    }

    try {
      // 1. Check & request permission first
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

      // 2. Check if device location service (GPS) is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      isLocationServiceEnabled.value = serviceEnabled;
      if (!serviceEnabled) {
        log.w('Location services (GPS) are disabled on device');
        return null;
      }

      // Try last known position first (instant, non-blocking)
      Position? position = await getLastKnownLocation();

      // If not available, query current position with strict 2s timeout
      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 2),
            ),
          ).timeout(const Duration(seconds: 2));
        } catch (err) {
          log.w('getCurrentPosition timed out or failed: $err');
          position = null;
        }
      }

      if (position != null) {
        currentPosition.value = position;
        _lastFetchTime = DateTime.now();
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

  /// Unified flow to request permission and guide user to enable GPS if disabled
  Future<bool> requestAndEnableLocation({BuildContext? context}) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        hasLocationPermission.value = false;
        locationPermissionDenied.value = true;
        _showPermissionDeniedDialog();
        return false;
      }

      if (permission == LocationPermission.denied) {
        hasLocationPermission.value = false;
        locationPermissionDenied.value = true;
        return false;
      }

      hasLocationPermission.value = true;
      locationPermissionDenied.value = false;

      // Permission granted, now check device GPS
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      isLocationServiceEnabled.value = serviceEnabled;

      if (!serviceEnabled) {
        await _showEnableGpsDialog();
        return false;
      }

      final pos = await getUserLocation();
      return pos != null;
    } catch (e) {
      log.e('Error in requestAndEnableLocation: $e');
      return false;
    }
  }

  void _showPermissionDeniedDialog() {
    final isAr = DynamicLanguage.selectedLanguage.value.startsWith('ar');
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.location_off_rounded, color: Color(0xFFF59E0B)),
            const SizedBox(width: 8),
            Text(
              isAr ? 'إذن الموقع مطلوب' : 'Location Permission Needed',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          isAr
              ? 'يرجى تفعيل إذن الموقع من إعدادات التطبيق لتتمكن من تحديد موقعك وعرض خيارات التوصيل.'
              : 'Please enable location permission in app settings to see delivery options.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: Text(isAr ? 'فتح الإعدادات' : 'Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEnableGpsDialog() async {
    final isAr = DynamicLanguage.selectedLanguage.value.startsWith('ar');
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.location_disabled_rounded, color: Color(0xFFF59E0B)),
            const SizedBox(width: 8),
            Text(
              isAr ? 'خدمة الموقع (GPS) غير مفعلة' : 'Location Service Disabled',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          isAr
              ? 'تم منح إذن الموقع بنجاح، ولكن ميزة تحديد الموقع (GPS) مغلقة على هاتفك.\n\nيرجى تشغيل الموقع من إعدادات الهاتف لعرض خيارات التوصيل.'
              : 'Location permission is granted, but GPS is turned off on your device.\n\nPlease turn on Location (GPS) in phone settings to see delivery options.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isAr ? 'لاحقاً' : 'Later'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Get.back();
              await openLocationSettings();
            },
            child: Text(isAr ? 'تشغيل الموقع' : 'Turn On GPS'),
          ),
        ],
      ),
    );
  }

  /// Open device location settings (GPS toggle)
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings page
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }
}
