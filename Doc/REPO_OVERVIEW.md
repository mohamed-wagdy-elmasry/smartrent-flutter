# Repository Overview

This file documents the repository folder structure (as present in the workspace), a concise architecture overview, and the main tech/tools and third-party plugins used.

**Note:** The folder tree is generated from the workspace snapshot and may be truncated in places where the workspace listing was abbreviated.

**Full Folder Structure (snapshot)**

- `android/`
  - `app/`
    - `build.gradle`
    - `gradle.properties`
    - `gradlew`
    - `gradlew.bat`
    - `local.properties`
    - `settings.gradle`
  - `build.gradle`
- `assets/`
- `background/`
- `html/`
- `icons/`
- `logo/`
- `build/`
  - `app/`
  - `awesome_notifications/`
  - `bd46c570ad3fa8ea92ee3fa1c37d9150/`
  - `file_picker/`
  - `flutter_inappwebview_android/`
  - `flutter_plugin_android_lifecycle/`
  - `flutter_secure_storage/`
  - `geocoding_android/`
  - `geolocator_android/`
  - `google_maps_flutter_android/`
  - `image_picker_android/`
  - `native_assets/`
  - `path_provider_android/`
  - `permission_handler_android/`
  - `pusher_channels_flutter/`
  - `reports/`
  - `restart_app/`
  - `shared_preferences_android/`
  - `sqflite_android/`
  - `webview_flutter_android/`
- `Doc/`
  - many project docs (IMPLEMENTATION_SUMMARY.md, BOOKING_* docs, etc.)
- `ios/`
  - `Podfile`
- `lib/`
- `test/`
- `web/`
- Root files:
  - `analysis_options.yaml`
  - `constants.txt`
  - `devtools_options.yaml`
  - `en_arb.txt`
  - `en_keys.txt`
  - `FEATURE_COMPLETE_SUMMARY.md`
  - `firebase.json`
  - `IMPLEMENTATION_SUMMARY.md`
  - `l10n.yaml`
  - `local.properties.example`
  - `LOCALIZATION_REIMPLEMENTATION.md`
  - `pubspec.yaml`
  - `README.md`
  - `svc_keys.txt`
  - `svc.txt`
  - `WALLET_IMPLEMENTATION.md`


**Architecture (concise)**

- App type: Flutter application targeting Android, iOS and Web.
- Layered design (recommended / visible in code patterns):
  - Presentation: UI widgets, screens, forms, localized strings (in `lib/` and `l10n` files).
  - State/Domain: business logic (state management may use Provider, Bloc, GetX, Riverpod, or plain ChangeNotifier depending on code in `lib/` — check `lib/` for specifics).
  - Data: repositories, services talking to remote APIs and local storage (Firebase, REST endpoints, SQLite via `sqflite`, shared preferences, secure storage).

- Key concerns addressed in repo docs:
  - Booking flow and token handling (lots of `Doc/BOOKING_*` files).
  - Localization (see `l10n.yaml`, `en_arb.txt`, `en_keys.txt`).
  - Payment & wallet handling (`WALLET_IMPLEMENTATION.md`).

**Runtime integration points / services**

- Firebase (project contains `firebase.json`).
- Push / real-time: Pusher channels (`pusher_channels_flutter`).
- Notifications: `awesome_notifications`.
- Maps & geolocation: `google_maps_flutter`, `geolocator`, `geocoding`.
- Image & file handling: `image_picker`, `file_picker`.
- Web views / in-app web: `flutter_inappwebview`, `webview_flutter`.
- Local persistence: `sqflite`, `shared_preferences`, `flutter_secure_storage`.


**Tech Tools & Libraries**

- Primary stack:
  - **Flutter**: cross-platform UI framework (Dart language).
  - **Dart SDK**: language/runtime for Flutter.

- Build & platform tooling:
  - **Gradle** for Android builds (`android/gradle` files present).
  - **CocoaPods** for iOS (`ios/Podfile`).
  - **Android SDK** and **Xcode** (for platform-specific builds).

- Dev & CI-related files present / recommended tools:
  - `pubspec.yaml` for dependency management.
  - `analysis_options.yaml` for linting rules.
  - `firebase.json` for Firebase hosting/ems/CI integration.

- Plugins & packages (inferred from `build/` output folders and repo contents):
  - `awesome_notifications` — local and push notifications.
  - `file_picker` — pick files from device.
  - `flutter_inappwebview` — advanced in-app web views.
  - `flutter_plugin_android_lifecycle` — Android lifecycle support.
  - `flutter_secure_storage` — secure key/value storage.
  - `geocoding` — reverse geocoding and address lookup.
  - `geolocator` — device location.
  - `google_maps_flutter` — Google Maps widget.
  - `image_picker` — camera/gallery images.
  - `path_provider` — file system paths.
  - `permission_handler` — runtime permissions.
  - `pusher_channels_flutter` — real-time channels/events.
  - `shared_preferences` — simple key/value storage.
  - `sqflite` — SQLite database.
  - `webview_flutter` — webview for Flutter.

- Common developer tooling (recommended):
  - **VS Code** or **Android Studio** with Flutter & Dart plugins.
  - **git** for version control.
  - **flutter CLI** and **dart** tools: `flutter analyze`, `flutter test`, `flutter build`.


**Notes & Next Steps**

- The repository contains an extensive `Doc/` folder with many feature-specific design notes — consult those files for implementation details of booking flows, bug fixes, and APIs.
- For a more exhaustive inventory of packages, open `pubspec.yaml`.
- If you want, I can:
  - Generate a complete file tree from disk (recursively) and insert it here.
  - Extract exact package versions from `pubspec.yaml` and list them under Tech Tools.

---
Generated by workspace snapshot on request.
