import 'package:http/http.dart' as http;
import '../../utils/basic_import.dart';
import '../method/api_method.dart';
import '../model/common_success_model.dart';

class ApiServices {
  static var client = http.Client();

  // Generic API service method
  static Future<T?> apiService<T>(
    T Function(Map<String, dynamic>) fromJson,
    String apiEndpoint, {
    Map<String, dynamic>? body,
    String method = 'GET',
    int statusCode = 200,
    bool showResult = false,
    bool isBasic = false,
    bool showSuccessMessage = false,
    bool showErrorMessage = true,
    String tostTitle = 'Success',
  }) async {
    try {
      Map<String, dynamic>? mapResponse;

      if (method == 'POST') {
        mapResponse = await ApiMethod(isBasic: isBasic).post(
          apiEndpoint,
          body ?? {},
          code: statusCode,
          showErrorMessage: showErrorMessage,
        );
      } else if (method == 'GET') {
        mapResponse = await ApiMethod(isBasic: isBasic).get(
          apiEndpoint,
          showResult: showResult,
          showErrorMessage: showErrorMessage,
        );
      }

      if (mapResponse != null) {
        return _handleResponse<T>(
          mapResponse,
          fromJson,
          showSuccessMessage,
          tostTitle,
        );
      } else {
        log.e(
          '❌ API Service Error: Null response from endpoint\n'
          'Endpoint: $apiEndpoint\n'
          'Method: $method\n'
          'Status Code: $statusCode',
        );
      }
    } catch (e, stackTrace) {
      log.e(
        '❌ API Service Exception\n'
        'Endpoint: $apiEndpoint\n'
        'Method: $method\n'
        'Error: $e\n'
        'Type: ${e.runtimeType}\n'
        'Stack Trace: $stackTrace',
      );
      if (showErrorMessage) {
        CustomSnackBar.error('Error: ${e.toString()}');
      }
    }
    return null;
  }

  // Method for multipart file uploads
  static Future<T?> multipartApiService<T>(
    T Function(Map<String, dynamic>) fromJson,
    String apiEndpoint,
    Map<String, String> body,
    List<String> fieldList,
    List<String> pathList, {
    int statusCode = 200,
    bool isBasic = false,
    bool showSuccessMessage = false,
    String tostTitle = Strings.success,
  }) async {
    try {
      Map<String, dynamic>? mapResponse = await ApiMethod(isBasic: isBasic)
          .multipartMultiFile(
            apiEndpoint,
            body,
            fieldList: fieldList,
            pathList: pathList,
          );

      if (mapResponse != null) {
        return _handleResponse<T>(
          mapResponse,
          fromJson,
          showSuccessMessage,
          tostTitle,
        );
      } else {
        log.e(
          '❌ Multipart Service Error: Null response from endpoint\n'
          'Endpoint: $apiEndpoint\n'
          'Fields: $fieldList\n'
          'Files: $pathList',
        );
      }
    } catch (e, stackTrace) {
      log.e(
        '❌ Multipart Service Exception\n'
        'Endpoint: $apiEndpoint\n'
        'Error: $e\n'
        'Type: ${e.runtimeType}\n'
        'Fields: $fieldList\n'
        'Files: $pathList\n'
        'Stack Trace: $stackTrace',
      );
      CustomSnackBar.error('Upload failed: ${e.toString()}');
    }
    return null;
  }

  // Helper method to handle responses
  static T? _handleResponse<T>(
    Map<String, dynamic> mapResponse,
    T Function(Map<String, dynamic>) fromJson,
    bool showSuccessMessage,
    String tostTitle,
  ) {
    try {
      T result = fromJson(mapResponse);

      if (showSuccessMessage) {
        var messages = CommonSuccessModel.fromJson(mapResponse);
        CustomSnackBar.success(
          title: tostTitle,
          message: messages.message.success.first.toString(),
        );
      }

      return result;
    } catch (e, stackTrace) {
      log.e(
        '❌ Response Parsing Error\n'
        'Error: $e\n'
        'Type: ${e.runtimeType}\n'
        'Response: $mapResponse\n'
        'Stack Trace: $stackTrace',
      );
      return null;
    }
  }
}
