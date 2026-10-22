# OpenWolf

@.wolf/OPENWOLF.md

This project uses OpenWolf for context management. Read and follow .wolf/OPENWOLF.md every session. Check .wolf/cerebrum.md before generating code. Check .wolf/anatomy.md before reading files.


# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run app
flutter run

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release

# Run all tests
flutter test

# Run a single test file
flutter test test/wallet_controller_test.dart

# Lint / analyze
flutter analyze

# Generate localization files (after editing .arb files)
flutter gen-l10n

# Get dependencies
flutter pub get
```

## Architecture

**Stack:** Flutter 3.32.x · GetX 4.7.2 · Laravel REST API · Firebase FCM · Pusher Channels · Moyasar payments

### Feature Structure (MVVM via GetX)

Every feature lives under `lib/views/<feature>/` with this exact layout:

```
screen/
  feature_screen.dart          ← GetView<Controller> → ResponsiveLayout(mobile:, tablet:)
  feature_mobile_screen.dart   ← `part of` feature_screen.dart
  feature_tablet_screen.dart   ← `part of` feature_screen.dart
controller/
  feature_controller.dart      ← GetxController with .obs state
widget/
  *.dart                       ← feature-scoped widgets
model/
  *.dart                       ← data models with fromJson factories
```

Screen files use `part of` / `part` directives — never standalone imports.

### Routing

- Route string constants: `lib/routes/routes.dart`
- `GetPage` registrations: `lib/routes/route_pages.dart` (a `part` file)
- Navigate: `Get.toNamed(Routes.historyDetailScreen, arguments: {'history': obj})`
- Arguments always pass as `Map<String, dynamic>` and are read in `controller.onInit()` via `Get.arguments`

### Bindings

Every route has a binding in `lib/bindings/` using `Get.lazyPut`. Register all controllers there — never `Get.put()` inside widgets.

### API Layer

- All endpoints are `enum ApiEndpoint` values in `lib/base/api/endpoint/api_endpoint.dart`
- Use `RequestProcess().request<T>(fromJson:, apiEndpoint:, isLoading:, onSuccess:)` for every API call
- Base URL: `ApiConfig.mainDomain` — **currently hardcoded to local dev IP `192.168.1.211:8000`; change for production** (production: `https://smartrent.sa`)
- Endpoints with path params use `.withId(int id)` — e.g. `ApiEndpoint.bookingCancel.withId(bookingId)`

### Key Files

| Purpose | Path |
|---|---|
| App entry | `lib/main.dart` |
| Global barrel import | `lib/base/utils/basic_import.dart` |
| API config & endpoints | `lib/base/api/endpoint/api_endpoint.dart` |
| Request wrapper | `lib/base/api/method/request_process.dart` |
| Global settings service | `lib/base/api/services/basic_services.dart` |
| Booking detail API calls | `lib/base/api/services/booking_detail_service.dart` |
| Routes | `lib/routes/routes.dart` + `lib/routes/route_pages.dart` |
| I18n keys | `lib/languages/strings.dart` |
| Booking validation rules | `lib/base/utils/booking_validators.dart` |

## Key Conventions

### Localization
Always use `DynamicLanguage.key(Strings.someKey)` — never hardcode user-facing strings. Keys are defined in `lib/languages/strings.dart`. ARB source files: `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`.

### Common Imports
`import '../../../base/utils/basic_import.dart'` provides `Get`, common widgets, `ResponsiveLayout`, `CustomColor`, spacing utils, etc. Use it instead of individual imports.

### Controller / UI Separation (strict)
- Controllers: **no** `Get.snackbar()`, **no** `Get.back()`, **no** UI calls. Return result objects to the UI.
- UI layer: handles all snackbars, dialogs, and navigation based on controller result objects.
- Async actions that can fail return `Future<String?>` — `null` = success, non-null = error message to display.

```dart
// ✅ Controller
Future<String?> cancelBooking() async {
  if (!canCancel) return 'Cannot cancel this booking';
  try {
    await BookingDetailService.cancelBooking(bookingId!);
    return null; // success
  } catch (e) {
    return e.toString();
  }
}

// ✅ UI (inside a button handler after Navigator.pop / dialog close)
onPressed: () async {
  Navigator.pop(ctx);
  final error = await controller.cancelBooking();
  if (error != null) CustomSnackBar.error(error);
},
```

> **Why:** `Get.showSnackbar()` / `CustomSnackBar` require an active `Overlay`. Calling them from a controller (or before the route's Overlay is fully mounted) throws `No Overlay widget found`. Always show snackbars from the UI layer, after any dialog/navigator transition completes.

### Dialogs — Critical GetX Bug
**Never use `Get.dialog()` + `Get.back()` together.** GetX's `back()` calls `closeCurrentSnackbar()` which crashes with `LateInitializationError`.
✅ Always use `showDialog(context: Get.context!, builder: (ctx) => ...) ` + `Navigator.pop(ctx)`.

### State Management
- Reactive: `final foo = false.obs;` → `Obx(() => ...)` in UI
- Non-reactive refresh: `GetBuilder<Controller>` + `controller.update()`

### Race Conditions
- Guard async actions with `isLoading.obs` flag; disable button while `true`
- Defer navigation from `onInit()` with `WidgetsBinding.instance.addPostFrameCallback`
- Check `if (isClosed) return;` after `await` in controllers
- Use generation counter for overlapping async calls

### Real-time & Notifications
- **Pusher Channels** (`RealtimeService`): live booking updates from Laravel broadcasting
- **Firebase FCM + Pusher Beams**: push notifications — initialized **after** user login in splash/login flow, not in `main()`
- **awesome_notifications**: local notification display
- Notification taps navigate via `NotificationNavigation.goToHistoryDetail(historyId: id)`

#### Pusher `event.data` Type Safety
The Pusher Flutter SDK on Android can deliver `event.data` as a pre-parsed `Map<Object?, Object?>` (from the Java layer) instead of a JSON string. Always handle both:
```dart
final decoded = event.data is String
    ? jsonDecode(event.data as String) as Map<String, dynamic>
    : Map<String, dynamic>.from(event.data as Map);
```
Also null-check any nested key before casting — Pusher fires internal events (e.g. connection/presence) with `{}` as data, so `decoded['notification']` may be null. Return early with a warning log instead of crashing.

### UI Design System
Premium screens define private `_C` (colors), `_S` (8px-grid spacing), `_R` (border radii), `_Shadow` classes at the top of the barrel file. Global theme tokens are in `lib/base/themes/`.

### Booking Detail Feature

`BookingDetailController` fetches all booking sub-resources in parallel via `loadAll()`:
- `fetchTransactions(bookingId)` → `ApiEndpoint.bookingTransactions`
- `fetchLedgerSummary(bookingId)` → `ApiEndpoint.bookingLedgerSummary`
- `fetchExtensions(bookingId)` → `ApiEndpoint.bookingExtensions`
- `fetchCarBranch(carId)` → `ApiEndpoint.carBranch` (silently ignored on 404 — branch may not be assigned)

Car branch is stored as `carBranch = Rxn<CarBranch>()` on the controller. The model is in `lib/views/history_detail/model/car_branch_model.dart`. Display using `Strings.branchInfo` / `Strings.branchName` keys.

Extension flow: preview via `previewExtension` → confirm → `requestExtension` returns `ExtensionRequestResult` which carries an `InsufficientBalanceInfo` on 422 (wallet shortage).

### Model `fromJson` — Int Field Safety
Laravel can return integer columns as JSON strings under certain conditions (query builder, string-typed DB columns, middleware). **Never assign `json["field"]` directly to a Dart `int` or `int?` field.** Always use a safe parser:

```dart
int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}
int _parseIntOr(dynamic v, int fallback) => _parseInt(v) ?? fallback;
```

Apply `_parseInt` / `_parseIntOr` to all int fields in `fromJson`. **Never cast double/coord fields with `as num?` either** — use a safe parser for all numeric types:

```dart
double? _parseDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}
```

Define `_parseInt` / `_parseDouble` as top-level functions in the model file. See `lib/views/history_detail/model/car_branch_model.dart` for the pattern. A `fromJson` cast crash silently leaves `Rxn<T>` fields null, hiding entire UI sections.

### Localization — Always Add Missing Translations
When adding or using any `Strings.*` key, ensure the key exists in **both** `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`, then run `flutter gen-l10n` to regenerate. Never leave a key untranslated in either language.

**Critical:** Every new key must also be added to `_translationGetters` in `lib/base/localization/i18n_service.dart`. Without this entry, `DynamicLanguage.key()` returns the raw key string as a fallback (e.g. shows `"appLOpenMap"` instead of `"Open Map"`). ARB + generated files alone are not enough.

### GetX `lazyPut` Guard
When accessing a controller that may not be registered yet (e.g. from a deep-link or notification):
```dart
final ctrl = Get.isRegistered<MyController>()
    ? Get.find<MyController>()
    : Get.put(MyController());
```
