# Vendor Cars Proximity Sort — Design Spec

**Date:** 2026-06-11  
**Feature:** Sort `/api/v1/vendor/cars` results by closest branch first; fall back to price-asc when location is unavailable.

---

## Overview

When the user opens the All Vendors Dashboard, the app requests their GPS location and passes `lat`/`lng` to the vendor cars API. The backend already defaults to `sort_by=distance_asc` when coordinates are supplied, returning cars sorted nearest-branch-first. When location is unavailable or denied, the app falls back to `sort_by=price_asc`.

Distance is not displayed on car cards — it affects sort order only.

---

## Section 1: Controller Changes

**File:** `lib/views/all_vendors_dashboard/controller/all_vendors_dashboard_controller.dart`

### `onInit` change

Remove the direct `searchAllVendorsCars()` call. Replace with a deferred orchestrator:

```dart
@override
void onInit() {
  super.onInit();
  scrollController.addListener(_onScroll);
  WidgetsBinding.instance.addPostFrameCallback((_) => _initLocationAndFetch());
}
```

### New private field

```dart
Position? _userPosition; // set once per session; reused for load-more and city-filter calls
```

### New method: `_initLocationAndFetch()`

```
1. Call Geolocator.checkPermission()
2. If granted / whileInUse:
     → Geolocator.getCurrentPosition() → store in _userPosition
     → searchAllVendorsCars()
3. If denied:
     → showDialog(context: Get.context!, ...) — returns bool?
     → true  → LocationService.getUserLocation()
                  success → store in _userPosition → searchAllVendorsCars()
                  still denied → _userPosition = null → searchAllVendorsCars()
     → false / null (dismissed) → _userPosition = null → searchAllVendorsCars()
4. If deniedForever:
     → _userPosition = null → searchAllVendorsCars() (no dialog)
```

### `searchAllVendorsCars()` change

No new parameter needed — the method reads `_userPosition` directly (private field already on the controller).

Query param logic:

```dart
if (_userPosition != null) {
  queryParams['lat'] = _userPosition!.latitude.toString();
  queryParams['lng'] = _userPosition!.longitude.toString();
  // no sort_by — backend defaults to distance_asc
} else {
  queryParams['sort_by'] = 'price_asc';
}
```

### `refreshCars()` change

Re-runs `_initLocationAndFetch()` (not `searchAllVendorsCars()` directly), so the location dialog re-appears on pull-to-refresh if permission is still `denied`.

### `changeCityFilter()` — unchanged

Calls `searchAllVendorsCars()` directly. Reuses the already-stored `_userPosition`. City param is added alongside lat/lng or sort_by as appropriate.

---

## Section 2: Model Changes

**File:** `lib/views/all_vendors_dashboard/model/vendor_cars_model.dart`

Add one nullable field to `VendorCar`:

```dart
double? distanceKm;
```

Parse using the project-standard safe double parser:

```dart
distanceKm: _parseDouble(json["distance_km"]),
```

`_parseDouble` is defined as a top-level function in the model file per CLAUDE.md convention. `distanceKm` is `null` when the API returns `null` (no coords sent, or branch has no location). Field is not displayed in the UI.

No changes to `VendorCarsData`, `Pagination`, or `MetaInfo`.

---

## Section 3: Location Permission Dialog

Triggered from `_initLocationAndFetch()` when permission is `LocationPermission.denied`.

```dart
final result = await showDialog<bool>(
  context: Get.context!,
  barrierDismissible: true,
  builder: (ctx) => AlertDialog(
    // icon, title, message, two buttons
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx, false), // Not now
        child: ...,
      ),
      TextButton(
        onPressed: () => Navigator.pop(ctx, true),  // Allow
        child: ...,
      ),
    ],
  ),
);
```

**Dialog content:**
- Icon: `Icons.location_on_outlined`
- Title: `DynamicLanguage.key(Strings.locationPermissionTitle)`
- Body: `DynamicLanguage.key(Strings.locationPermissionMessage)`
- Buttons: "Not now" (left) / "Allow" (right, primary color)

**Localization — new keys:**

| Key | English | Arabic |
|-----|---------|--------|
| `locationPermissionTitle` | "Enable Location" | "تفعيل الموقع" |
| `locationPermissionMessage` | "Allow location access to show you the closest cars first" | "اسمح بالوصول إلى موقعك لعرض أقرب السيارات أولاً" |

Keys added to:
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ar.arb`
- `_translationGetters` in `lib/base/localization/i18n_service.dart`

Run `flutter gen-l10n` after.

---

## Section 4: Infinite Scroll & Refresh

### Query param matrix

| State | lat/lng | sort_by | city |
|-------|---------|---------|------|
| Location granted | ✓ sent | not sent (API defaults to distance_asc) | optional |
| Location denied / dismissed | not sent | `price_asc` | optional |
| deniedForever | not sent | `price_asc` | optional |

### Load more

`_onScroll` calls `searchAllVendorsCars(loadMore: true)`. No location re-check — `_userPosition` is already set. Pages stay consistent with the same sort throughout the session.

### Pull-to-refresh

`refreshCars()` → `_initLocationAndFetch()`. Dialog re-shown if permission is still `denied`. Correct per "every time" requirement.

### City filter

`changeCityFilter(city)` → `searchAllVendorsCars()`. Reuses `_userPosition` — no location re-check. City param sent alongside whatever sort strategy is active.

---

## Edge Cases

| Scenario | Behaviour |
|----------|-----------|
| Permission already granted on screen open | No dialog. Fetch with lat/lng immediately. |
| User taps outside dialog (dismissed) | Treated as "Not now" → price_asc fallback |
| User allows dialog but system denies | `getUserLocation()` returns null → price_asc fallback |
| `deniedForever` | No dialog shown. Silent price_asc fallback. |
| GPS disabled (service off) | `getUserLocation()` returns null → price_asc fallback |
| `lat=null` / branch has no location | API returns `distance_km: null` on that car — silently ignored (field not displayed) |

---

## Files Changed

| File | Change |
|------|--------|
| `lib/views/all_vendors_dashboard/controller/all_vendors_dashboard_controller.dart` | `onInit`, `_initLocationAndFetch()`, `searchAllVendorsCars()`, `refreshCars()` |
| `lib/views/all_vendors_dashboard/model/vendor_cars_model.dart` | Add `distanceKm` field + `_parseDouble` call |
| `lib/l10n/app_en.arb` | 2 new keys |
| `lib/l10n/app_ar.arb` | 2 new keys |
| `lib/base/localization/i18n_service.dart` | Register 2 new keys in `_translationGetters` |
| `lib/languages/strings.dart` | 2 new string constants |

No new files. No routing changes. No binding changes.
