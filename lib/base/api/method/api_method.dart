import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../routes/routes.dart';
import '../../maintenance/maintenance_dialog.dart';
import '../../maintenance/maintenance_model.dart';
import '../../utils/basic_import.dart';
import '../../utils/local_storage.dart';
import '../../widgets/logger.dart';
import '../model/error_message_model.dart';

final log = logger(ApiMethod);

/// Helper method to safely parse JSON response with UTF-8 decoding
/// Handles Arabic and Unicode text correctly
dynamic _parseJsonResponse(http.Response response) {
  try {
    // Ensure we have the complete response body
    if (response.bodyBytes.isEmpty) {
      throw FormatException('Empty response body');
    }

    // Decode response body bytes as UTF-8 to properly handle Arabic/Unicode
    final bodyString = utf8.decode(response.bodyBytes, allowMalformed: false);

    // Verify we have valid JSON string
    if (bodyString.isEmpty) {
      throw FormatException('Empty JSON string after UTF-8 decode');
    }

    // Basic check: JSON should start with { or [ and end with } or ]
    final trimmed = bodyString.trim();
    if ((trimmed.startsWith('{') && !trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && !trimmed.endsWith(']'))) {
      throw FormatException(
        'Incomplete JSON: starts with ${trimmed.substring(0, 1)} but doesn\'t end properly',
      );
    }

    return jsonDecode(bodyString);
  } catch (e) {
    log.e(
      'JSON Parse Error Details:\n'
      'Error: $e\n'
      'Response bytes length: ${response.bodyBytes.length}\n'
      'First 500 chars: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}\n'
      'Last 500 chars: ${response.body.length > 500 ? response.body.substring(response.body.length - 500) : "N/A"}',
    );
    rethrow;
  }
}

Map<String, String> basicHeaderInfo() {
  return {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
  };
}

Future<Map<String, String>> bearerHeaderInfo() async {
  String accessToken = LocalStorage.token;

  return {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.authorizationHeader: "Bearer $accessToken",
  };
}

class ApiMethod {
  ApiMethod({required this.isBasic});

  bool isBasic;

  // Get method
  Future<Map<String, dynamic>?> get(
    String url, {
    int code = 200,
    int duration = 120,
    bool showResult = false,
    bool showErrorMessage = true,
  }) async {
    log.i(
      '|📍📍📍|----------------- [[ GET ]] method details start -----------------|📍📍📍|',
    );
    log.i(url);
    log.i(
      '|📍📍📍|----------------- [[ GET ]] method details ended -----------------|📍📍📍|',
    );

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(Duration(seconds: duration));

      log.i(
        '|📒📒📒|-----------------[[ GET ]] method response start -----------------|📒📒📒|',
      );

      if (showResult) {
        log.i(response.body.toString());
      }

      log.i(response.statusCode);

      log.i(
        '|📒📒📒|-----------------[[ GET ]] method response end -----------------|📒📒📒|',
      );

      bool isMaintenance = response.statusCode == 503;

      // Check Server Error
      if (response.statusCode == 500) {
        log.e(
          '❌ Server Error (500)\n'
          'URL: $url\n'
          'Response: ${response.body}',
        );
        CustomSnackBar.error(Strings.serverError);
        Get.offAllNamed(Routes.otpLoginScreen);
      }
      if (response.statusCode == 401) {
        log.e(
          '❌ Unauthorized (401)\n'
          'URL: $url\n'
          'Clearing local storage and redirecting to login',
        );
        Get.offAllNamed(Routes.otpLoginScreen);
        LocalStorage.clear();
      }

      _maintenanceCheck(isMaintenance, response.body);

      if (response.statusCode == code) {
        try {
          // Parse JSON with UTF-8 decoding to handle Arabic text
          return _parseJsonResponse(response);
        } on FormatException catch (fe) {
          log.e(
            '❌ JSON Parse Error (GET)\n'
            'URL: $url\n'
            'Error: ${fe.message}\n'
            'Response Length: ${response.bodyBytes.length} bytes\n'
            'Content-Type: ${response.headers['content-type']}',
          );
          if (showErrorMessage) {
            try {
              CustomSnackBar.error('Invalid response format from server');
            } catch (e) {
              log.e('Failed to show error snackbar: $e');
            }
          }
          return null;
        } catch (e) {
          log.e(
            '❌ Unexpected JSON Decode Error (GET)\n'
            'URL: $url\n'
            'Error: $e\n'
            'Response Length: ${response.body.length} bytes',
          );
          if (showErrorMessage) {
            try {
              CustomSnackBar.error('Failed to process server response');
            } catch (e) {
              log.e('Failed to show error snackbar: $e');
            }
          }
          return null;
        }
      } else {
        log.e(
          '❌ GET Request Failed - Status Code Mismatch\n'
          'URL: $url\n'
          'Expected: $code\n'
          'Received: ${response.statusCode}',
        );

        try {
          final decoded = _parseJsonResponse(response);
          ErrorResponse res = ErrorResponse.fromJson(decoded);
          if (isMaintenance) {
            // Maintenance check will handle display
          } else {
            if (showErrorMessage) {
              CustomSnackBar.error(res.message.error.join(''));
            }
          }
        } catch (e) {
          log.e(
            '❌ Error Response Parse Error\n'
            'URL: $url\n'
            'Parse Error: $e',
          );
          if (showErrorMessage) CustomSnackBar.error(Strings.serverError);
        }

        return null;
      }
    } on SocketException catch (e, stackTrace) {
      log.e(
        '❌ Socket Exception (Network Error)\n'
        'URL: $url\n'
        'Error: $e\n'
        'Stack Trace: $stackTrace',
      );
      if (showErrorMessage) {
        CustomSnackBar.error('Check your Internet Connection and try again!');
      }
      return null;
    } on TimeoutException catch (e, stackTrace) {
      log.e(
        '❌ Timeout Exception\n'
        'URL: $url\n'
        'Duration: ${duration}s\n'
        'Error: $e\n'
        'Stack Trace: $stackTrace',
      );
      if (showErrorMessage) {
        CustomSnackBar.error('Request timeout. Try again!');
      }
      return null;
    } on http.ClientException catch (err, stackTrace) {
      log.e(
        '❌ HTTP Client Exception\n'
        'URL: $url\n'
        'Error: $err\n'
        'Stack Trace: $stackTrace',
      );
      return null;
    } catch (e, stackTrace) {
      log.e(
        '❌ Unexpected GET Error\n'
        'URL: $url\n'
        'Error: $e\n'
        'Type: ${e.runtimeType}\n'
        'Stack Trace: $stackTrace',
      );
      return null;
    }
  }

  // Post Method
  Future<Map<String, dynamic>?> post(
    String url,
    Map<String, dynamic> body, {
    int code = 201,
    int duration = 120,
    bool showResult = true,
    bool showErrorMessage = true,
  }) async {
    try {
      log.i(
        '|📍📍📍|-----------------[[ POST ]] method details start -----------------|📍📍📍|',
      );

      log.i(url);

      log.i(body);

      log.i(
        '|📍📍📍|-----------------[[ POST ]] method details end ------------|📍📍📍|',
      );

      final response = await http
          .post(
            Uri.parse(url),
            body: jsonEncode(body),
            headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(Duration(seconds: duration));

      log.i(
        '|📒📒📒|-----------------[[ POST ]] method response start ------------------|📒📒📒|',
      );

      if (showResult) {
        log.i(response.body.toString());
      }

      log.i(response.statusCode);

      log.i(
        '|📒📒📒|-----------------[[ POST ]] method response end --------------------|📒📒📒|',
      );
      bool isMaintenance = response.statusCode == 503;

      _maintenanceCheck(isMaintenance, response.body);

      // Check Unauthorized
      if (response.statusCode == 401) {
        log.e(
          '❌ Unauthorized (401)\n'
          'URL: $url\n'
          'Clearing local storage',
        );
        LocalStorage.clear();
      }
      // Check Server Error
      if (response.statusCode == 500) {
        log.e(
          '❌ Server Error (500)\n'
          'URL: $url\n'
          'Response: ${response.body}',
        );
        CustomSnackBar.error(Strings.serverError);
        Get.offAllNamed(Routes.otpLoginScreen);
      }
      if (response.statusCode == 401) {
        log.e(
          '❌ Unauthorized (401) - Redirecting to login\n'
          'URL: $url',
        );
        Get.offAllNamed(Routes.otpLoginScreen);
        LocalStorage.clear();
      }

      if (response.statusCode == code) {
        try {
          // Parse JSON with UTF-8 decoding to handle Arabic text
          return _parseJsonResponse(response);
        } on FormatException catch (fe) {
          log.e(
            '❌ JSON Parse Error (POST)\n'
            'URL: $url\n'
            'Error: ${fe.message}\n'
            'Response Length: ${response.bodyBytes.length} bytes',
          );
          if (showErrorMessage) {
            CustomSnackBar.error('Invalid response format from server');
          }
          return null;
        } catch (e) {
          log.e(
            '❌ Unexpected JSON Decode Error (POST)\n'
            'URL: $url\n'
            'Error: $e\n'
            'Response Length: ${response.body.length} bytes',
          );
          if (showErrorMessage) {
            CustomSnackBar.error('Failed to process server response');
          }
          return null;
        }
      } else {
        log.e(
          '❌ POST Request Failed - Status Code Mismatch\n'
          'URL: $url\n'
          'Expected: $code\n'
          'Received: ${response.statusCode}\n'
          'Request Body: $body',
        );
        try {
          final decoded = _parseJsonResponse(response);
          log.e('Error Response Decoded: $decoded');
          ErrorResponse res = ErrorResponse.fromJson(decoded);
          if (isMaintenance) {
          } else {
            if (showErrorMessage) {
              CustomSnackBar.error(res.message.error.join(''));
            }
          }
        } catch (e) {
          log.e(
            '❌ Error Response Parse Error\n'
            'URL: $url\n'
            'Parse Error: $e',
          );
          if (showErrorMessage) CustomSnackBar.error(Strings.serverError);
        }

        return null;
      }
    } on SocketException catch (e, stackTrace) {
      log.e(
        '❌ Socket Exception (Network Error)\n'
        'URL: $url\n'
        'Error: $e\n'
        'Stack Trace: $stackTrace',
      );
      if (showErrorMessage) {
        CustomSnackBar.error('Check your Internet Connection and try again!');
      }
      return null;
    } on TimeoutException catch (e, stackTrace) {
      log.e(
        '❌ Timeout Exception\n'
        'URL: $url\n'
        'Duration: ${duration}s\n'
        'Error: $e\n'
        'Stack Trace: $stackTrace',
      );
      if (showErrorMessage) {
        CustomSnackBar.error('Request timeout. Try again!');
      }
      return null;
    } on http.ClientException catch (err, stackTrace) {
      log.e(
        '❌ HTTP Client Exception\n'
        'URL: $url\n'
        'Error: $err\n'
        'Stack Trace: $stackTrace',
      );
      return null;
    } catch (e, stackTrace) {
      log.e(
        '❌ Unexpected POST Error\n'
        'URL: $url\n'
        'Error: $e\n'
        'Type: ${e.runtimeType}\n'
        'Stack Trace: $stackTrace',
      );
      return null;
    }
  }

  // Post Method
  Future<Map<String, dynamic>?> multipart(
    String url,
    Map<String, String> body,
    String filepath,
    String filedName, {
    int code = 200,
    bool showResult = false,
  }) async {
    try {
      log.i(
        '|📍📍📍|-----------------[[ Multipart ]] method details start -----------------|📍📍📍|',
      );

      log.i(url);

      log.i(body);
      log.i(filepath);

      log.i(
        '|📍📍📍|-----------------[[ Multipart ]] method details end ------------|📍📍📍|',
      );

      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields.addAll(body)
        ..headers.addAll(isBasic ? basicHeaderInfo() : await bearerHeaderInfo())
        ..files.add(await http.MultipartFile.fromPath(filedName, filepath));
      var response = await request.send();
      var jsonData = await http.Response.fromStream(response);

      log.i(
        '|📒📒📒|-----------------[[ POST ]] method response start ------------------|📒📒📒|',
      );

      log.i(jsonData.body.toString());

      log.i(response.statusCode);

      log.i(
        '|📒📒📒|-----------------[[ POST ]] method response end --------------------|📒📒📒|',
      );
      bool isMaintenance = response.statusCode == 503;

      _maintenanceCheck(isMaintenance, jsonData);

      if (response.statusCode == code) {
        try {
          return _parseJsonResponse(jsonData) as Map<String, dynamic>;
        } on FormatException catch (fe) {
          log.e(
            '❌ JSON Parse Error (Multipart Single)\n'
            'URL: $url\n'
            'File: $filepath\n'
            'Field: $filedName\n'
            'Error: ${fe.message}\n'
            'Raw Response: ${jsonData.body}',
          );
          return null;
        }
      } else {
        log.e(
          '❌ Multipart Request Failed\n'
          'URL: $url\n'
          'Expected: $code\n'
          'Received: ${response.statusCode}\n'
          'File: $filepath\n'
          'Field: $filedName\n'
          'Response: ${jsonData.body}',
        );
        try {
          final decoded = _parseJsonResponse(jsonData);
          log.e('Error Response: $decoded');
          ErrorResponse res = ErrorResponse.fromJson(decoded);
          if (!isMaintenance)
            CustomSnackBar.error(res.message.error.toString());
        } catch (e) {
          log.e(
            '❌ Error Response Parse Error (Multipart)\n'
            'URL: $url\n'
            'Parse Error: $e\n'
            'Raw Response: ${jsonData.body}',
          );
          if (!isMaintenance) CustomSnackBar.error(Strings.serverError);
        }

        return null;
      }
    } on SocketException catch (e, stackTrace) {
      log.e(
        '❌ Socket Exception (Multipart)\n'
        'URL: $url\n'
        'File: $filepath\n'
        'Error: $e\n'
        'Stack Trace: $stackTrace',
      );
      CustomSnackBar.error('Check your Internet Connection and try again!');
      return null;
    } on TimeoutException catch (e, stackTrace) {
      log.e(
        '❌ Timeout Exception (Multipart)\n'
        'URL: $url\n'
        'Error: $e\n'
        'Stack Trace: $stackTrace',
      );
      CustomSnackBar.error('Upload timeout. Try again!');
      return null;
    } on http.ClientException catch (err, stackTrace) {
      log.e(
        '❌ HTTP Client Exception (Multipart)\n'
        'URL: $url\n'
        'Error: $err\n'
        'Stack Trace: $stackTrace',
      );
      return null;
    } catch (e, stackTrace) {
      log.e(
        '❌ Unexpected Multipart Error\n'
        'URL: $url\n'
        'Error: $e\n'
        'Type: ${e.runtimeType}\n'
        'Stack Trace: $stackTrace',
      );
      return null;
    }
  }

  // multipart multi file Method
  Future<Map<String, dynamic>?> multipartMultiFile(
    String url,
    Map<String, String> body, {
    int code = 200,
    bool showResult = false,
    required List<String> pathList,
    required List<String> fieldList,
  }) async {
    try {
      log.i(
        '|📍📍📍|-----------------[[ Multipart ]] method details start -----------------|📍📍📍|',
      );

      log.i(url);

      if (showResult) {
        log.i(body);
        log.i(pathList);
        log.i(fieldList);
      }

      log.i(
        '|📍📍📍|-----------------[[ Multipart ]] method details end ------------|📍📍📍|',
      );
      // Build headers WITHOUT Content-Type — http package sets multipart boundary automatically
      final Map<String, String> multipartHeaders = {
        HttpHeaders.acceptHeader: 'application/json',
      };
      if (!isBasic) {
        multipartHeaders[HttpHeaders.authorizationHeader] =
            'Bearer ${LocalStorage.token}';
      }

      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields.addAll(body)
        ..headers.addAll(multipartHeaders);

      for (int i = 0; i < fieldList.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath(fieldList[i], pathList[i]),
        );
      }

      var response = await request.send();
      var jsonData = await http.Response.fromStream(response);

      log.e(
        '|📒📒📒|-----------------[[ Multipart ]] response: ${response.statusCode} ---|📒📒📒|\n'
        '${jsonData.body}',
      );

      bool isMaintenance = response.statusCode == 503;

      if (response.statusCode == 500) {
        log.e(
          '❌ Server Error (500)\n'
          'URL: $url\n'
          'Response: ${jsonData.body}',
        );
        CustomSnackBar.error(Strings.serverError);
        Get.offAllNamed(Routes.otpLoginScreen);
      }
      if (response.statusCode == 401) {
        log.e(
          '❌ Unauthorized (401)\n'
          'URL: $url\n'
          'Clearing storage and redirecting',
        );
        Get.offAllNamed(Routes.otpLoginScreen);
        LocalStorage.clear();
      }
      _maintenanceCheck(isMaintenance, jsonData);

      if (response.statusCode == code) {
        try {
          final parsed = _parseJsonResponse(jsonData);
          if (parsed is Map<String, dynamic>) return parsed;
          log.e(
            '❌ Unexpected response type (Multipart Multi)\n'
            'URL: $url\n'
            'Type: ${parsed.runtimeType}\n'
            'Body: ${jsonData.body}',
          );
          CustomSnackBar.error('Unexpected response from server');
          return null;
        } on FormatException catch (fe) {
          log.e(
            '❌ JSON Parse Error (Multipart Multi)\n'
            'URL: $url\n'
            'Fields: $fieldList\n'
            'Files: $pathList\n'
            'Error: ${fe.message}\n'
            'Raw Response: ${jsonData.body}',
          );
          return null;
        } catch (e) {
          log.e(
            '❌ Parse Error (Multipart Multi)\n'
            'URL: $url\n'
            'Error: $e\n'
            'Body: ${jsonData.body}',
          );
          return null;
        }
      } else {
        log.e(
          '❌ Multipart Multi Request Failed\n'
          'URL: $url\n'
          'Expected: $code\n'
          'Received: ${response.statusCode}\n'
          'Fields: $fieldList\n'
          'Files: $pathList\n'
          'Response: ${jsonData.body}',
        );
        try {
          final decoded = _parseJsonResponse(jsonData);
          log.e('Error Response: $decoded');
          ErrorResponse res = ErrorResponse.fromJson(decoded);
          if (!isMaintenance)
            CustomSnackBar.error(res.message.error.toString());
        } catch (e) {
          log.e(
            '❌ Error Response Parse Error (Multipart Multi)\n'
            'URL: $url\n'
            'Parse Error: $e\n'
            'Raw Response: ${jsonData.body}',
          );
          if (!isMaintenance) CustomSnackBar.error(Strings.serverError);
        }

        return null;
      }
    } on SocketException catch (e, stackTrace) {
      log.e(
        '❌ Socket Exception (Multipart Multi)\n'
        'URL: $url\n'
        'Error: $e\n'
        'Stack Trace: $stackTrace',
      );
      CustomSnackBar.error('Check your Internet Connection and try again!');
      return null;
    } on TimeoutException catch (e, stackTrace) {
      log.e(
        '❌ Timeout Exception (Multipart Multi)\n'
        'URL: $url\n'
        'Duration: 120s\n'
        'Error: $e\n'
        'Stack Trace: $stackTrace',
      );
      CustomSnackBar.error('Upload timeout. Try again!');
      return null;
    } on http.ClientException catch (err, stackTrace) {
      log.e(
        '❌ HTTP Client Exception (Multipart Multi)\n'
        'URL: $url\n'
        'Error: $err\n'
        'Stack Trace: $stackTrace',
      );
      return null;
    } catch (e, stackTrace) {
      log.e(
        '❌ Unexpected Multipart Multi Error\n'
        'URL: $url\n'
        'Error: $e\n'
        'Type: ${e.runtimeType}\n'
        'Stack Trace: $stackTrace',
      );
      return null;
    }
  }

  void _maintenanceCheck(bool isMaintenance, var jsonData) {
    final controller = Get.put(SystemMaintenanceController());
    if (isMaintenance) {
      controller.maintenanceStatus.value = true;
      // Handle both String and http.Response types
      final decoded = jsonData is http.Response
          ? _parseJsonResponse(jsonData)
          : jsonDecode(jsonData);
      MaintenanceModel maintenanceModel = MaintenanceModel.fromJson(decoded);
      MaintenanceDialog().show(maintenanceModel: maintenanceModel);
    } else {
      controller.maintenanceStatus.value = false;
    }
  }
}
