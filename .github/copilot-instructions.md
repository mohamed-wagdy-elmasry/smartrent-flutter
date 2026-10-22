# Carbo User App — Copilot Instructions

## Stack
Flutter (3.32.x) · GetX 4.7.2 · Laravel REST API · Firebase FCM · Pusher Channels · Moyasar payments · `form_builder_validators`

## Architecture

### View Layer (MVVM via GetX)
Every feature lives under `lib/views/<feature>/` and follows this exact structure:
```
screen/
  feature_screen.dart          ← entry point: GetView<Controller> → ResponsiveLayout
  feature_mobile_screen.dart   ← part of feature_screen.dart
  feature_tablet_screen.dart   ← part of feature_screen.dart
controller/
  feature_controller.dart      ← GetxController with .obs state
widget/
  *.dart                       ← feature-scoped reusable widgets
model/
  *.dart                       ← data models (fromJson factories)
```
- Screen files use `part of` / `part` — never standalone imports.
- `BookingScreen` → `ResponsiveLayout(mobile: BookingMobileScreen(), tablet: BookingTabletScreen())` is the canonical pattern.

### Routing
Routes are string constants in `lib/routes/routes.dart`; `GetPage` registrations in `lib/routes/route_pages.dart` (a `part` file).  
Navigate: `Get.toNamed(Routes.historyDetailScreen, arguments: {'history': obj})`.  
Arguments always pass as `Map<String, dynamic>` and are read in `controller.onInit()` via `Get.arguments`.

### Bindings
Every route has a binding in `lib/bindings/` using `Get.lazyPut`. Register all controllers a screen needs there — never `Get.put()` inside widgets.

### API Layer
- All endpoints are `enum ApiEndpoint` values in `lib/base/api/endpoint/api_endpoint.dart`.
- Use `RequestProcess().request<T>(fromJson:, apiEndpoint:, isLoading:, onSuccess:)` for every API call — it handles loading state, logging, error display, and multipart uploads.
- Base URL: `ApiConfig.mainDomain` (currently points to local dev server `192.168.1.211:8000` — change for production).

## Key Conventions

### Localization
Always use `DynamicLanguage.key(Strings.someKey)` — never hardcoded strings for user-facing text. Keys live in `lib/languages/strings.dart`.

### Common Imports
`import '../../../base/utils/basic_import.dart'` provides `Get`, common widgets, `ResponsiveLayout`, `CustomColor`, spacing utils, etc. Use it instead of individual imports.

### UI Design System (screen-local classes)
Premium screens (e.g. `history_detail_screen.dart`) define private `_C` (colors), `_S` (8px-grid spacing), `_R` (border radii), `_Shadow` classes at the top of the `part` barrel file. New widgets in the same barrel inherit these. Global theme tokens are in `lib/base/themes/`.

### Dialogs — Critical GetX Bug
**Never use `Get.dialog()` + `Get.back()` together.** GetX's `back()` calls `closeCurrentSnackbar()` which crashes with `LateInitializationError` if no snackbar was shown.  
✅ Always use `showDialog(context: Get.context!, builder: (ctx) => ...) ` + `Navigator.pop(ctx)`.

### Forms & Validation
Use `Form` + `TextFormField` + `form_builder_validators` (`FormBuilderValidators.*`). Domain-specific booking rules live in `lib/base/utils/booking_validators.dart`.

## Real-time & Notifications
- **Pusher Channels** (`RealtimeService`) for live booking updates from Laravel broadcasting.
- **Firebase FCM + Pusher Beams** for push notifications — initialized *after* user login in the splash/login flow, **not** in `main()`.
- **awesome_notifications** for local notification display. Navigation on tap uses `NotificationNavigation.goToHistoryDetail(historyId: id)`.

## State Management Patterns
- Reactive primitive: `final foo = false.obs;` → `Obx(() => ...)` in UI.
- Complex refresh: `GetBuilder<Controller>` + `controller.update()`.
- Combine both: wrap `GetBuilder` around `Obx` when local and global state coexist (see `action_buttons_bar.dart`).

## Key Files
| Purpose | Path |
|---|---|
| App entry | `lib/main.dart` |
| Global barrel import | `lib/base/utils/basic_import.dart` |
| API endpoints | `lib/base/api/endpoint/api_endpoint.dart` |
| Request wrapper | `lib/base/api/method/request_process.dart` |
| Global settings | `lib/base/api/services/basic_services.dart` |
| Routes | `lib/routes/routes.dart` + `lib/routes/route_pages.dart` |
| I18n keys | `lib/languages/strings.dart` |
| Booking rules | `lib/base/utils/booking_validators.dart` |
| Booking detail (rich screen example) | `lib/views/history_detail/screen/history_detail_screen.dart` |



## 1️⃣ Controllers

**Goal:** Controllers are responsible only for **business logic**, **not UI or navigation**.

**Rules:**

* ✅ Do **not** use `Get.snackbar()` inside any Controller.
* ✅ Do **not** use `Get.back()` or any navigation call inside Controllers.
* ✅ Controllers should return **clear results** to the UI layer.
* ✅ Controllers must be **UI-agnostic** (should not know anything about Widgets or dialogs).
* ✅ Use **Return Objects / Result Classes** instead of calling UI methods.

**Example:**

```dart
class BookingController extends GetxController {
  Future<CancelResult> cancelBooking(int bookingId) async {
    final success = await bookingService.cancel(bookingId);
    if(success){
      return CancelResult(success: true, message: "Booking cancelled successfully");
    } else {
      return CancelResult(success: false, message: "Cannot cancel booking");
    }
  }
}
```

---

## 2️⃣ UI Layer

**Goal:** The UI layer is responsible for **all presentation and navigation**.

**Rules:**

* ✅ Receive results from Controller or Service.
* ✅ Use `Get.snackbar()` or `Get.dialog()` **only** in UI layer.
* ✅ Navigation calls like `Get.back()`, `Get.to()` should only be in UI layer.
* ✅ Use `Future.delayed()` or async where needed to avoid race conditions.

**Example:**

```dart
ElevatedButton(
  onPressed: () async {
    final result = await controller.cancelBooking(bookingId);
    
    if(result.success){
      Get.snackbar("Success", result.message);
      Get.back(); // navigation only here
    } else {
      Get.snackbar("Error", result.message);
    }
  },
  child: Text("Cancel Booking"),
)
```

---

## 3️⃣ Snackbar Rules

* ✅ Do **not** create Snackbar in Controller.
* ✅ Ensure the Snackbar is ready before closing (`Get.isSnackbarOpen`).
* ✅ Avoid `Get.closeCurrentSnackbar()` inside Controller.

---

## 4️⃣ Navigation Rules

* ✅ All navigation should happen in UI layer only.
* ✅ Do **not** rely on navigation inside Services or Controllers.
* ✅ Use **events** or **Result Objects** to notify the UI about navigation.

---

## 5️⃣ Error Handling

* ✅ All business logic errors should be returned to the UI via **Result Object**.
* ✅ Do **not** handle UI inside Controller with try-catch.

---

## 6️⃣ Best Practices

* ✅ Controllers must be **testable** without UI dependency.
* ✅ UI should only read from Controller or Service.
* ✅ Use Rx / GetX state for updating UI instead of direct UI calls in Controller.

---

## 7️⃣ Optional: Dry-Run Pattern

* ✅ Controllers or Services can support `dryRun` to **simulate operations** without changing data.
* ✅ Results are shown to UI for preview before actual execution.

**Example:**

```dart
final result = await bookingService.cancelBooking(bookingId, dryRun: true);
// UI shows a preview to the user
```

---

## 8️⃣ Race Condition Rules

Common mobile race conditions and how to prevent them in this project:

### Double-tap / Double-submit
**Problem:** User taps a button twice before the first async call completes — fires duplicate API requests.  
✅ Guard every async action with an `isLoading` flag and disable the button while it is `true`:
```dart
// Controller
final isSubmitting = false.obs;
Future<void> submit() async {
  if (isSubmitting.value) return; // guard
  isSubmitting.value = true;
  try { /* API call */ } finally { isSubmitting.value = false; }
}

// UI
Obx(() => ElevatedButton(
  onPressed: controller.isSubmitting.value ? null : controller.submit,
  child: Text('Submit'),
))
```

### Navigation before build completes
**Problem:** Calling `Get.toNamed()` or `Get.back()` inside `onInit()` / `initState()` crashes because the widget tree is not mounted yet.  
✅ Defer navigation with `WidgetsBinding.instance.addPostFrameCallback`:
```dart
@override
void onInit() {
  super.onInit();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (shouldRedirect) Get.offNamed(Routes.loginScreen);
  });
}
```

### setState / Rx update on unmounted widget
**Problem:** An async callback calls `.value =` or `update()` after the controller has been deleted (user navigated away).  
✅ Check `isClosed` before mutating state in async continuations:
```dart
Future<void> loadData() async {
  final result = await apiCall();
  if (isClosed) return; // widget already gone
  items.value = result;
}
```

### Overlapping async calls (stale response)
**Problem:** Two rapid API calls return out of order — the older response overwrites the newer one.  
✅ Use a generation counter or cancel the previous call:
```dart
int _loadGeneration = 0;
Future<void> loadData() async {
  final gen = ++_loadGeneration;
  final result = await apiCall();
  if (gen != _loadGeneration) return; // superseded
  items.value = result;
}
```

### Dialog + navigation conflict
**Problem:** Calling `Get.back()` while a dialog is open (or vice-versa) can pop the wrong route.  
✅ Always use `Navigator.pop(ctx)` with the dialog's own `BuildContext` (never `Get.back()` inside `showDialog` builders) — see Dialogs rule above.

### BuildContext across async gaps
**Problem:** Using a `BuildContext` captured before an `await` throws `use_build_context_synchronously` lint and can crash on context unmount.  
✅ Either capture `Get.context!` just before use, or check `mounted` (in `StatefulWidget`) / `isClosed` (in `GetxController`) after every `await`:
```dart
// In a StatefulWidget callback
onPressed: () async {
  final result = await controller.doWork();
  if (!mounted) return;           // ← always check after await
  ScaffoldMessenger.of(context).showSnackBar(...);
},
```

### GetX `lazyPut` not yet registered
**Problem:** `Get.find<MyController>()` throws if called before the binding runs (e.g. from a notification tap triggering deep navigation).  
✅ Use `Get.isRegistered<MyController>()` guard or register a fallback in the call site:
```dart
final ctrl = Get.isRegistered<MyController>()
    ? Get.find<MyController>()
    : Get.put(MyController());
```

---

✅  ensures **strict separation of UI and business logic** in Flutter + GetX projects and is ready for AI inspection or developer reference.
