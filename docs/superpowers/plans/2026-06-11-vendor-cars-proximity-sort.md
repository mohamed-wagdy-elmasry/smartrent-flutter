# Vendor Cars Proximity Sort — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sort the vendor cars list by closest branch first by passing the user's GPS coordinates to `/api/v1/vendor/cars`; fall back to price-asc when location is unavailable or denied.

**Architecture:** `AllVendorsDashboardController.onInit` defers to `_initLocationAndFetch()` via `addPostFrameCallback`. That method checks GPS permission, shows a one-time dialog if `denied`, stores the resolved `Position?` in `_userPosition`, then calls `searchAllVendorsCars()` which passes `lat`/`lng` (distance sort) or `sort_by=price_asc` (fallback) to the API.

**Tech Stack:** Flutter 3.32.x · GetX 4.7.2 · `geolocator` (already in pubspec) · Laravel REST API (`/api/v1/vendor/cars`)

**Spec:** `docs/superpowers/specs/2026-06-11-vendor-cars-proximity-sort-design.md`

---

## File Map

| File | Change |
|------|--------|
| `lib/languages/strings.dart` | Add 3 new string constants |
| `lib/l10n/app_en.arb` | Add 3 new English translations |
| `lib/l10n/app_ar.arb` | Add 3 new Arabic translations |
| `lib/base/localization/i18n_service.dart` | Register 3 new keys in `_translationGetters` |
| `lib/views/all_vendors_dashboard/model/vendor_cars_model.dart` | Add `_parseDouble` helper + `distanceKm` field to `VendorCar` |
| `lib/views/all_vendors_dashboard/controller/all_vendors_dashboard_controller.dart` | Add `_userPosition` field, `_initLocationAndFetch()`, update `onInit`, `searchAllVendorsCars`, `refreshCars` |

---

## Task 1: Add Localization Strings

**Files:**
- Modify: `lib/languages/strings.dart`
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_ar.arb`
- Modify: `lib/base/localization/i18n_service.dart`

- [ ] **Step 1: Add string constants to `strings.dart`**

Open `lib/languages/strings.dart`. Find any existing constant block (e.g. near `static const String cancel = "appLCancel";`) and add after it:

```dart
  static const String locationPermissionTitle = "appLLocationPermissionTitle";
  static const String locationPermissionMessage = "appLLocationPermissionMessage";
  static const String allow = "appLAllow";
```

- [ ] **Step 2: Add English translations to `app_en.arb`**

Open `lib/l10n/app_en.arb`. Before the closing `}` on the last line, add (after `"appLOtpSentToPhone": "..."`):

```json
  "appLLocationPermissionTitle": "Enable Location",
  "appLLocationPermissionMessage": "Allow location access to show you the closest cars first",
  "appLAllow": "Allow"
```

The file must remain valid JSON. The last existing key (`appLOtpSentToPhone`) needs a comma added:

```json
  "appLOtpSentToPhone": "A 6-digit code was sent to your phone via SMS",

  "appLLocationPermissionTitle": "Enable Location",
  "appLLocationPermissionMessage": "Allow location access to show you the closest cars first",
  "appLAllow": "Allow"
}
```

- [ ] **Step 3: Add Arabic translations to `app_ar.arb`**

Open `lib/l10n/app_ar.arb`. Apply the same JSON comma fix on the last existing key, then append:

```json
  "appLLocationPermissionTitle": "تفعيل الموقع",
  "appLLocationPermissionMessage": "اسمح بالوصول إلى موقعك لعرض أقرب السيارات أولاً",
  "appLAllow": "السماح"
}
```

- [ ] **Step 4: Register keys in `i18n_service.dart`**

Open `lib/base/localization/i18n_service.dart`. Find the `_translationGetters` map. The last entry before the closing `};` is:

```dart
    'appLOtpSentToPhone': (l) => l.appLOtpSentToPhone,
  };
```

Add the three new entries before `};`:

```dart
    'appLOtpSentToPhone': (l) => l.appLOtpSentToPhone,
    'appLLocationPermissionTitle': (l) => l.appLLocationPermissionTitle,
    'appLLocationPermissionMessage': (l) => l.appLLocationPermissionMessage,
    'appLAllow': (l) => l.appLAllow,
  };
```

- [ ] **Step 5: Regenerate localization files**

```bash
flutter gen-l10n
```

Expected output: no errors. Files `lib/generated/l10n/app_localizations_en.dart` and `app_localizations_ar.dart` are updated.

- [ ] **Step 6: Verify generated getters exist**

```bash
grep -n "appLLocationPermissionTitle\|appLLocationPermissionMessage\|appLAllow" lib/generated/l10n/app_localizations_en.dart
```

Expected: 3 matches.

- [ ] **Step 7: Commit**

```bash
git add lib/languages/strings.dart lib/l10n/app_en.arb lib/l10n/app_ar.arb lib/base/localization/i18n_service.dart lib/generated/l10n/
git commit -m "feat: add localization keys for location permission dialog"
```

---

## Task 2: Add `distanceKm` to VendorCar Model

**Files:**
- Modify: `lib/views/all_vendors_dashboard/model/vendor_cars_model.dart`

- [ ] **Step 1: Add `_parseDouble` top-level helper**

Open `lib/views/all_vendors_dashboard/model/vendor_cars_model.dart`. After the existing imports (before `VendorCarsModel vendorCarsModelFromJson...`), add:

```dart
double? _parseDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}
```

- [ ] **Step 2: Add `distanceKm` field to `VendorCar`**

In the `VendorCar` class, find the existing field declarations and add `distanceKm` after `isDeliveryAvailable`:

```dart
  bool isDeliveryAvailable;
  double? distanceKm;        // ← add this line
```

- [ ] **Step 3: Add `distanceKm` to `VendorCar` constructor**

In the `VendorCar({...})` constructor, add after `required this.isDeliveryAvailable,`:

```dart
    required this.isDeliveryAvailable,
    this.distanceKm,         // ← add this line
  });
```

- [ ] **Step 4: Parse `distanceKm` in `VendorCar.fromJson`**

In `factory VendorCar.fromJson`, add after `isDeliveryAvailable: json["is_delivery_available"] ?? false,`:

```dart
    isDeliveryAvailable: json["is_delivery_available"] ?? false,
    distanceKm: _parseDouble(json["distance_km"]),   // ← add this line
  );
```

- [ ] **Step 5: Run analyze to confirm no errors**

```bash
flutter analyze lib/views/all_vendors_dashboard/model/vendor_cars_model.dart
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/views/all_vendors_dashboard/model/vendor_cars_model.dart
git commit -m "feat: add distanceKm field to VendorCar model"
```

---

## Task 3: Update AllVendorsDashboardController

**Files:**
- Modify: `lib/views/all_vendors_dashboard/controller/all_vendors_dashboard_controller.dart`

- [ ] **Step 1: Update imports**

At the top of the file, change the existing partial Flutter import to a full one:

```dart
// Before:
import 'package:flutter/material.dart' show ScrollController;

// After:
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
```

`geolocator` is already in `pubspec.yaml` (used by `LocationService`) — no `pub get` needed.

- [ ] **Step 2: Add `_userPosition` private field**

In the `AllVendorsDashboardController` class, after the `RxBool locationPermissionDenied = false.obs;` line, add:

```dart
  // Resolved GPS position for the current session (null = no location / denied)
  Position? _userPosition;
```

- [ ] **Step 3: Replace `onInit` body**

Find the current `onInit`:

```dart
  @override
  void onInit() {
    super.onInit();
    log.i('AllVendorsDashboardController initialized');
    log.i('Current language: ${DynamicLanguage.selectedLanguage.value}');
    log.i('App language is loading: ${DynamicLanguage.isLoading}');
    log.i('Language direction: ${DynamicLanguage.languageDirection}');
    scrollController.addListener(_onScroll);
    // Load all cars without filters
    searchAllVendorsCars();
  }
```

Replace with:

```dart
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
```

- [ ] **Step 4: Add `_initLocationAndFetch()` method**

Add this private method directly after `onInit` (before `_onScroll`):

```dart
  Future<void> _initLocationAndFetch() async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // Already granted — fetch position silently
      final locationService = Get.find<LocationService>();
      _userPosition = await locationService.getUserLocation();
    } else if (permission == LocationPermission.denied) {
      // Show one-time dialog asking user to allow
      final allowed = await showDialog<bool>(
        context: Get.context!,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.location_on_outlined,
            size: 48,
            color: Color(0xFF0EA5E9),
          ),
          title: Text(DynamicLanguage.key(Strings.locationPermissionTitle)),
          content: Text(
            DynamicLanguage.key(Strings.locationPermissionMessage),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(DynamicLanguage.key(Strings.cancel)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                DynamicLanguage.key(Strings.allow),
                style: const TextStyle(
                  color: Color(0xFF0EA5E9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      if (allowed == true) {
        final locationService = Get.find<LocationService>();
        _userPosition = await locationService.getUserLocation();
      } else {
        _userPosition = null;
      }
    } else {
      // deniedForever — no dialog, silent fallback
      _userPosition = null;
    }

    if (isClosed) return;
    await searchAllVendorsCars();
  }
```

- [ ] **Step 5: Update `searchAllVendorsCars()` query params**

Find the `queryParams` block inside `searchAllVendorsCars()`:

```dart
      Map<String, String> queryParams = {
        'page': currentPage.value.toString(),
        'per_page': '15',
      };
      if (selectedCity.value != 'all') {
        queryParams['city'] = selectedCity.value;
      }
```

Replace with:

```dart
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
```

- [ ] **Step 6: Update `refreshCars()` to re-run location check**

Find the current `refreshCars`:

```dart
  Future<void> refreshCars() async {
    _isRefreshing.value = true;
    log.i('Refreshing vendor cars list');
    await searchAllVendorsCars();
    _isRefreshing.value = false;
  }
```

Replace with:

```dart
  Future<void> refreshCars() async {
    _isRefreshing.value = true;
    log.i('Refreshing vendor cars list');
    await _initLocationAndFetch();
    _isRefreshing.value = false;
  }
```

- [ ] **Step 7: Run analyze on the controller**

```bash
flutter analyze lib/views/all_vendors_dashboard/controller/all_vendors_dashboard_controller.dart
```

Expected: `No issues found!`

- [ ] **Step 8: Run full project analyze**

```bash
flutter analyze
```

Expected: `No issues found!` (or only pre-existing warnings — no new errors).

- [ ] **Step 9: Commit**

```bash
git add lib/views/all_vendors_dashboard/controller/all_vendors_dashboard_controller.dart
git commit -m "feat: sort vendor cars by proximity using GPS coordinates"
```

---

## Task 4: Manual Smoke Test

No automated tests exist in this project. Verify the feature manually.

- [ ] **Step 1: Run the app on a device/emulator**

```bash
flutter run
```

- [ ] **Step 2: Test — location permission already granted**

Pre-condition: Grant location permission to the app in device settings before launching.

Expected:
- All Vendors Dashboard opens without any dialog
- Network request to `GET /api/v1/vendor/cars` includes `lat=<value>&lng=<value>` (check Flutter DevTools Network tab or logcat)
- Cars load sorted by proximity

- [ ] **Step 3: Test — first time, location `denied`**

Pre-condition: Revoke location permission in device settings. Open the All Vendors Dashboard.

Expected:
1. Blue location icon dialog appears with title "Enable Location"
2. Tap **Cancel** → dialog closes → cars load sorted by price (cheapest first)
3. No crash

- [ ] **Step 4: Test — dialog → Allow path**

Pre-condition: Revoke permission again. Open All Vendors Dashboard.

Expected:
1. Dialog appears
2. Tap **Allow** → system permission dialog appears
3. Grant permission → cars load with `lat`/`lng` in request (distance sort)

- [ ] **Step 5: Test — `deniedForever`**

Pre-condition: Deny location permission permanently (on Android: deny twice, or set in settings to "Don't ask again").

Expected:
- No dialog shown
- Cars load silently with `sort_by=price_asc`

- [ ] **Step 6: Test — pull to refresh with `denied` permission**

Pre-condition: Permission is `denied`. App is showing cars (price sort). Pull to refresh.

Expected:
- Dialog re-appears
- Same behaviour as Step 3

- [ ] **Step 7: Test — city filter still works**

Select any city chip while location is granted.

Expected:
- API request includes both `lat`/`lng` AND `city=<selected>` params
- Results update correctly

- [ ] **Step 8: Final commit if any test-driven tweaks were made**

```bash
git add -p   # stage only what changed
git commit -m "fix: address smoke test findings for proximity sort"
```

If no changes were needed, skip this step.
