import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../base/utils/local_storage.dart';
import '../base/storage/secure_storage_helper.dart';

/// Debug helper: run with
/// `flutter run -t lib/debug/print_auth_token.dart -d <device>`
/// It initializes storage and prints tokens to the debug console.
Future<void> printAuthTokenDebug({bool revealRaw = false}) async {
  // Ensure binding when called from non-Flutter entrypoints
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage (used by LocalStorage)
  await GetStorage.init();

  // Read token from GetStorage-backed LocalStorage
  final localToken = LocalStorage.token;

  // Try to read secure token (may fallback to LocalStorage internally)
  String? secureToken;
  try {
    secureToken = await SecureStorageHelper.getToken();
  } catch (e) {
    secureToken = null;
    // ignore: avoid_print
    print('Error reading secure token: $e');
  }

  // Print to console only — do NOT share this value publicly.
  // ignore: avoid_print
  print('===== AUTH TOKEN (DEBUG) =====');
  if (revealRaw) {
    // ignore: avoid_print
    print('LocalStorage.token: ${localToken.isEmpty ? '<empty>' : localToken}');
    // ignore: avoid_print
    print('SecureStorage.token: ${secureToken ?? '<empty>'}');
  } else {
    // ignore: avoid_print
    print('LocalStorage.token: ${localToken.isEmpty ? '<empty>' : '[REDACTED]'}');
    // For safety we avoid printing the real token string in repository logs —
    // but if you really need the raw value while developing, call this
    // function with `revealRaw: true` on a trusted machine only.
    // ignore: avoid_print
    print('SecureStorage: ${secureToken == null || secureToken.isEmpty ? 'empty' : 'present'}');
  }
}

/// Keep a minimal UI so standalone run doesn't immediately exit.
void main() async {
  await printAuthTokenDebug();
  runApp(const _DebugApp());
}

class _DebugApp extends StatelessWidget {
  const _DebugApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Printed auth token to console (check logs).'),
        ),
      ),
    );
  }
}
